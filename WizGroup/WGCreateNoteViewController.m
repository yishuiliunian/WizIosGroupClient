//
//  WGCreateNoteViewController.m
//  WizGroup
//
//  Created by wiz on 12-11-28.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGCreateNoteViewController.h"
#import "WGNavigationBarNew.h"
#import "WGBarButtonItem.h"
#import "WGChooseFolderViewController.h"
#import "WizFileManager.h"
#import "WizSyncCenter.h"
#import "WizDbManager.h"
@interface WGCreateNoteViewController ()

@end

@implementation WGCreateNoteViewController
@synthesize kbGuid;
@synthesize accountUserId;
@synthesize docGuid;
@synthesize backgroundView;
@synthesize titleView;
@synthesize contentView;
@synthesize lineView;
@synthesize keyboardBack_btn;

- (NSString*) titleHtmlString:(NSString*)_titleText
{
    return [NSString stringWithFormat:@"<title>%@</title>",_titleText];
}

- (NSString*) htmlString:(NSString*)bodyText title:(NSString*)titleText
{
   return  [NSString stringWithFormat:@"<html>%@<body>%@</body></html>",[self titleHtmlString:titleText],[bodyText toHtml]];
}
- (void) saveTheDocument
{
    NSString* title = self.titleView.text;
    NSString* bodyText = self.contentView.text;
    if (title == nil || [title isEqualToString:@""]) {
        title = [NSString stringWithString:NSLocalizedString(@"No Title", nil)];
    }
    if (title && bodyText && ![bodyText isEqualToString:NSLocalizedString(@"tap to edit body text",nil)]) {
        WizDocument* doc = [[[WizDocument alloc] init] autorelease];
        doc.strGuid = [WizGlobals genGUID];
        doc.strTitle  = title;
        doc.nLocalChanged = WizEditDocumentTypeAllChanged;
        doc.bServerChanged = NO;
        
        doc.strTagGuids = self.docGuid;
        NSLog(@"strTagGuids: %@ ",doc.strTagGuids);
//        [self updatePrivate];
        
        NSDictionary* docDic = [doc getModelDictionary];
        bodyText = [self htmlString:bodyText title:title];
        NSString* indexFilePath = [[WizFileManager shareManager]getDocumentFilePath:DocumentFileIndexName documentGUID:doc.strGuid accountUserId:self.accountUserId];
        NSString* moblieFilePath = [[WizFileManager shareManager] getDocumentFilePath:DocumentFileMobileName documentGUID:doc.strGuid accountUserId:self.accountUserId];
        [bodyText writeToFile:indexFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [bodyText writeToFile:moblieFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
        [db updateDocument:docDic];
        [[WizSyncCenter defaultCenter] uploadDocument:doc kbguid:self.kbGuid accountUserId:self.accountUserId];
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) updatePrivate
{
    id <WizSettingsDbDelegate> setting = [[WizDbManager shareInstance] getGlobalSettingDb];
    [setting updatePrivateGroup:self.kbGuid accountUserId:self.accountUserId];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
- (void) dealloc
{
//    [self saveTheDocument];
    [docGuid release];
    [backgroundView release];
    [titleView release];
    [contentView release];
    [lineView release];
    [super dealloc];
}

- (void)loadView
{
    self.view = [[[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen]bounds]] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.docGuid = [[NSString alloc]init];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    CGSize size = self.view.frame.size;
    float endX = size.width;
    float endY = size.height;
    
    WGNavigationBarNew* navBar = [[WGNavigationBarNew alloc]initWithFrame:CGRectMake(0, 0, endX, 44)];
    UIBarButtonItem* backTo = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"feedback_back"] hightedImage:nil target:self selector:@selector(backTo)];
    UIBarButtonItem* noteInfo = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"group_createNote_showInfo"] hightedImage:nil target:self selector:@selector(showInfo)];
    navBar.barItem.leftBarButtonItem = backTo;
    navBar.barItem.rightBarButtonItem = noteInfo;
    
    backgroundView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 44, endX, endY-44)];
    backgroundView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    backgroundView.scrollEnabled = YES;
    backgroundView.delegate = self;
    backgroundView.showsHorizontalScrollIndicator = YES;
	backgroundView.showsVerticalScrollIndicator = YES;
    backgroundView.contentSize = [[UIScreen mainScreen]bounds].size;
    backgroundView.alpha = 1.0;
    backgroundView.backgroundColor = [UIColor clearColor];

    
    titleView = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, endX - 20, 40)];
    titleView.font = [UIFont boldSystemFontOfSize:20];
    titleView.delegate = self;
    titleView.borderStyle = UITextBorderStyleNone;
    titleView.textAlignment = UITextAlignmentLeft;
    titleView.placeholder =  NSLocalizedString(@"NoteTitle",nil);
    titleView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [backgroundView addSubview:titleView];
    
    lineView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 40, endX - 20, 2)];
    lineView.image = [UIImage imageNamed:@"separatline"];
    [backgroundView addSubview:lineView];
    
    contentView = [[UITextView alloc]initWithFrame:CGRectMake(3, 42, endX, endY - 45)];
    contentView.font = [UIFont systemFontOfSize:15];
    contentView.textColor = [UIColor lightGrayColor];
    contentView.scrollEnabled = YES;
    contentView.delegate = self;
    contentView.textAlignment = UITextAlignmentLeft;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.text = NSLocalizedString(@"tap to edit body text",nil);
    [backgroundView addSubview:contentView];
    [self.view addSubview:backgroundView];
    [self.view addSubview:navBar];
    [navBar release];
    
    
    keyboardBack_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [keyboardBack_btn setBackgroundImage:[UIImage imageNamed:@"keyboardHidde"] forState:UIControlStateNormal];
    [keyboardBack_btn addTarget:self action:@selector(keyboardHidden) forControlEvents:UIControlEventTouchUpInside];
    keyboardBack_btn.hidden = YES;
    [self.view addSubview:keyboardBack_btn];


}


- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize size = self.view.frame.size;
    float endX = size.width;
    float endY = size.height;
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardBack_btn.hidden = NO;
    keyboardBack_btn.frame = CGRectMake(endX - 45, endY - keyboardRect.size.height - 37, 37, 37);
    contentView.frame = CGRectMake(10, 45, contentView.contentSize.width, endY - keyboardRect.size.height-45);
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    if ([contentView.text length] == 0) {
        contentView.textColor = [UIColor lightGrayColor];
        contentView.text = NSLocalizedString(@"tap to edit body text",nil);
    }
    contentView.frame = CGRectMake(10, 45, contentView.contentSize.width, self.view.frame.size.height - 45);
    [backgroundView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
    keyboardBack_btn.hidden = YES;
}

- (void) keyboardHidden
{
    [titleView resignFirstResponder];
    [contentView resignFirstResponder];
}

- (void) showInfo
{
    WGChooseFolderViewController* chooseVC = [[WGChooseFolderViewController alloc]init];
    chooseVC.delegate = self;
    chooseVC.kbGuid = self.kbGuid;
    chooseVC.docGuid = self.docGuid;
    chooseVC.accountUserId = self.accountUserId;
    [self presentModalViewController:chooseVC animated:YES];
    [chooseVC release];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void) backTo
{
    [self keyboardHidden];
    [self saveTheDocument];
    [self dismissModalViewControllerAnimated:YES];
}

- (void) didFinishChoose:(WGChooseFolderViewController *)controller
{
    self.docGuid = controller.docGuid;
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma textViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView != contentView) {
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == contentView) {
        if ([textView.text isEqualToString: NSLocalizedString(@"tap to edit body text",nil)])
            contentView.text = @"";
        contentView.textColor = [UIColor blackColor];
        [backgroundView scrollRectToVisible:CGRectMake(0, 44, 320, self.view.frame.size.height + 300) animated:YES];
    }
}

@end
