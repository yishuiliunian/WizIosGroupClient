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
@synthesize backgroundView;
@synthesize titilView;
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
    NSString* title = self.titilView.text;
    NSString* bodyText = self.contentView.text;
    WizDocument* doc = [[[WizDocument alloc] init] autorelease];
    doc.strGuid = [WizGlobals genGUID];
    doc.strTitle  = title;
    doc.nLocalChanged = WizEditDocumentTypeAllChanged;
    doc.bServerChanged = NO;
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
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    [self saveTheDocument];
    [backgroundView release];
    [titilView release];
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardDidHideNotification object:nil];
    
    CGSize size = self.view.frame.size;
    float endX = size.width;
    float endY = size.height;
    
//    WGNavigationBar* navBar = [[WGNavigationBar alloc]initWithFrame:CGRectMake(0, 0, endX, 44)];
//    UINavigationItem* barItem = [[UINavigationItem alloc]initWithTitle:@""];
//    UIBarButtonItem* backTo = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"feedback_back"] hightedImage:nil target:self selector:@selector(backTo)];
//    UIBarButtonItem* noteInfo = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"group_createNote_showInfo"] hightedImage:nil target:self selector:@selector(showInfo)];
//    barItem.leftBarButtonItem = backTo;
//    barItem.rightBarButtonItem = noteInfo;
//    [navBar pushNavigationItem:barItem animated:YES];
    
    WGNavigationBarNew* navBar = [[WGNavigationBarNew alloc]initWithFrame:CGRectMake(0, 0, endX, 44)];
    UIBarButtonItem* backTo = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"feedback_back"] hightedImage:nil target:self selector:@selector(backTo)];
    UIBarButtonItem* noteInfo = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"group_createNote_showInfo"] hightedImage:nil target:self selector:@selector(showInfo)];
    navBar.barItem.leftBarButtonItem = backTo;
    navBar.barItem.rightBarButtonItem = noteInfo;
    
    backgroundView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, endX, endY-44)];
    backgroundView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    backgroundView.scrollEnabled = YES;
    backgroundView.delegate = self;
    backgroundView.showsHorizontalScrollIndicator = YES;
	backgroundView.showsVerticalScrollIndicator = YES;
    backgroundView.contentSize = [[UIScreen mainScreen]bounds].size;
    backgroundView.alpha = 1.0;
    backgroundView.backgroundColor = [UIColor clearColor];

    
    titilView = [[UITextField alloc]initWithFrame:CGRectMake(10, 44, endX - 20, 40)];
    titilView.font = [UIFont boldSystemFontOfSize:20];
    titilView.delegate = self;
    titilView.borderStyle = UITextBorderStyleNone;
    titilView.textAlignment = UITextAlignmentLeft;
    titilView.placeholder =  NSLocalizedString(@"NoteTitle",nil);
    titilView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [backgroundView addSubview:titilView];
    
    lineView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 84, endX - 20, 2)];
    lineView.image = [UIImage imageNamed:@"separatline"];
    [backgroundView addSubview:lineView];
    
    contentView = [[UITextView alloc]initWithFrame:CGRectMake(3, 86, endX, endY - 86)];
    contentView.font = [UIFont systemFontOfSize:15];
    contentView.textColor = [UIColor lightGrayColor];
    contentView.delegate = self;
    contentView.textAlignment = UITextAlignmentLeft;
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.text =  NSLocalizedString(@"tap to edit body text",nil);
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

- (void) viewWillAppear:(BOOL)animated
{
    
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
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    if ([contentView.text length] == 0) {
        contentView.textColor = [UIColor lightGrayColor];
        contentView.text = NSLocalizedString(@"tap to edit body text",nil);
    }
}

- (void) keyboardHidden
{
    [titilView resignFirstResponder];
    [contentView resignFirstResponder];
    [backgroundView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) animated:YES];
    keyboardBack_btn.hidden = YES;
}
- (void) showInfo
{
    WGChooseFolderViewController* chooseVC = [[WGChooseFolderViewController alloc]init];
    chooseVC.kbGuid = self.kbGuid;
    chooseVC.accountUserId = self.accountUserId;
    [self presentModalViewController:chooseVC animated:YES];
    [chooseVC release];
}

- (void) backTo
{
    [titilView resignFirstResponder];
    [contentView resignFirstResponder];
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
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    
    if (textView == contentView && textView.contentSize.height > 150) {
        CGRect frame = CGRectMake(0, - textView.contentSize.height + 100, self.view.frame.size.width, self.view.frame.size.height);
        [backgroundView scrollRectToVisible:frame animated:YES];
        return YES;
    }
    return YES;
}
@end
