//
//  WGFeedBackViewController.m
//  WizGroup
//
//  Created by wiz on 12-11-13.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGFeedBackViewController.h"
#import "WGFeedBackHistoryViewController.h"
#import "WGBarButtonItem.h"
#import "WizFileManager.h"
#import "SBJson.h"
#import "WizGlobals.h"
#import "WizAccountManager.h"
#import "WGNavigationBarNew.h"
#import "WGUnderlineLabel.h"
#import "WizNotificationCenter.h"
#import "CommonString.h"
#import <QuartzCore/QuartzCore.h>

@interface WGFeedBackViewController ()

@end

@implementation WGFeedBackViewController
@synthesize delegate;
@synthesize kbGuid;
@synthesize accountUserId;
@synthesize mytext;
@synthesize historyFilePath;
@synthesize feedBackArray;
@synthesize feedBackHistoryDic;
@synthesize imgView;
@synthesize conf_btn;

- (void)dealloc
{
    [mytext release];
    [feedBackArray release];
    [feedBackHistoryDic release];
    [imgView release];
    [conf_btn release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    textViewH = 160;
    [self initUI];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];

    WizFileManager *fileManager = [WizFileManager shareManager];
    self.historyFilePath = [[WizFileManager documentsPath]stringByAppendingPathComponent:@"FeedBackData"];
    [fileManager ensureFileExists:historyFilePath];
    NSLog(@"filepath  %@",historyFilePath);    
    [self jsonRead];

    self.view.backgroundColor = [UIColor whiteColor];    
}

- (void)viewWillUnload
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)moveInputBarWithKeyboardHeight:(float)height withDuration:(NSTimeInterval)animation
{
    textViewH = self.view.frame.size.height - height - 44 - 45;
    NSLog(@"%f,%f,%f",self.view.frame.size.height,height,textViewH);
    [self resize];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    CGSize size = self.view.frame.size;
    float endX = size.width;    
    
    
    WGNavigationBarNew* navBar = [[WGNavigationBarNew alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem* backTo = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"feedback_back"] hightedImage:nil target:self selector:@selector(backSetting)];
    UIBarButtonItem* confirm = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"feedback_confirm"] hightedImage:nil target:self selector:@selector(save)];
    navBar.barItem.leftBarButtonItem = backTo;
    navBar.barItem.rightBarButtonItem = confirm;
    navBar.titleLabel.text = NSLocalizedString(@"FeedBack", nil);
    [self.view addSubview:navBar];
    [navBar release];
    
    mytext = [[UITextView alloc] initWithFrame:CGRectMake(0, 44, endX , textViewH)];
    [mytext becomeFirstResponder];
    mytext.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mytext.font =  [UIFont systemFontOfSize:15];
    [self.view addSubview:mytext];
    
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50 + textViewH, endX, 2)];
    imgView.image = [UIImage imageNamed:@"separatline"];
    [self.view addSubview:imgView];
    
    NSString* title = NSLocalizedString(@"History", nil);
    NSLog(@"%@",title);
    self.conf_btn = [[WGUnderlineLabel alloc]initWithTitle:title Frame:CGRectMake(0, 50 + textViewH, 100, 45)];
    [conf_btn addTarget:self action:@selector(History) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:conf_btn];
}

- (void)resize
{
    CGSize size = self.view.frame.size;
    float endX = size.width;
    
    mytext.frame = CGRectMake(0, 44, endX , textViewH);
    imgView.frame = CGRectMake(0, 50 + textViewH, endX, 2);
    conf_btn.frame = CGRectMake(0, 50 + textViewH, 100, 40);
}
//
- (void)backSetting
{
    [self.delegate didfinishFeedBack:self];
}
- (void)save
{
 //   [mytext resignFirstResponder];
    if (nil != mytext.text && ![mytext.text isEqualToString:@""]) {
        [self jsonWrite];
        mytext.text = @"";
    }
    else
        NSLog(@"input nothing");
}

- (void)History
{
    WGFeedBackHistoryViewController* historyVC = [[WGFeedBackHistoryViewController alloc]init];
    historyVC.filePath = self.historyFilePath;
    historyVC.feedBackDic = self.feedBackHistoryDic;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:historyVC animated:YES];
    [historyVC release];
}


- (void)jsonWrite
{    
    NSString* date = [NSString stringWithFormat:@"%@",[NSDate date]];
    NSString* time = [date substringToIndex:19];
    NSMutableDictionary* feedbackDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [feedbackDic setObject:mytext.text forKey:@"account_feedback"];
    [feedbackDic setObject:kbGuid forKey:@"group_id"];
    [feedbackDic setObject:accountUserId forKey:@"account_userid"];
    [feedbackDic setObject:time forKey:@"feedback_time"];
    
    NSDictionary* currentFeedBack = [NSDictionary dictionaryWithObject:feedbackDic forKey:@"FeedBack"];
    NSError* error = nil;
    [self send:[[SBJsonWriter alloc]stringWithObject:currentFeedBack error:&error]];
    
    [feedBackArray addObject:feedbackDic];
    [feedBackHistoryDic setObject:feedBackArray forKey:@"History"];
    
    NSData* feedbackData = [[SBJsonWriter alloc]dataWithObject:feedBackHistoryDic];
    
    WizFileManager *fileManager = [WizFileManager shareManager];
    [fileManager ensureFileExists:historyFilePath];
    [feedbackData writeToFile:historyFilePath atomically:YES];
}

- (void)jsonRead
{
    WizFileManager *fileManager = [WizFileManager shareManager];
    [fileManager ensureFileExists:historyFilePath];
    NSString* string = [NSString stringWithContentsOfFile:historyFilePath encoding:NSUTF8StringEncoding error:nil];
    self.feedBackHistoryDic = [NSMutableDictionary dictionaryWithCapacity:1];
    self.feedBackArray = [NSMutableArray arrayWithCapacity:1];
    if (string && ![string isEqualToString:@""]) {
        feedBackHistoryDic = [string JSONValue];
        feedBackArray = [feedBackHistoryDic objectForKey:@"History"];
    }
//    NSLog(@"%@",feedBackHistoryDic);
//    NSLog(@"%@",feedBackArray);
}

#pragma post
- (void)send:(NSString*)postData;
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:@"http://127.0.0.1:3000/feedback"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    [connection release];
    [request release];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	NSLog(@"SendBodyData");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"ReceiveResponse");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"FinishLoading");
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[error localizedDescription]
												   message:[error localizedFailureReason]
												  delegate:self
										 cancelButtonTitle:@"OK"
										 otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"ReceiveData");
}

@end
