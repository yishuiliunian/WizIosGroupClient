//
//  WizCheckAttachments.m
//  Wiz
//
//  Created by wiz on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizCheckAttachments.h"
#import "WizGlobals.h"
#import "WizCheckAttachment.h"
#import "WizGlobals.h"
#import "WizNotificationCenter.h"
#import "WizFileManager.h"
#import "WizSyncCenter.h"
#import "MBProgressHUD.h"
#import "WizMetaDb.h"

@interface WizCheckAttachments () 
{
    UIAlertView* waitAlert;
    NSIndexPath* lastIndexPath;
    UIDocumentInteractionController* currentPreview;
    BOOL willCheckInWiz;
}
@property (nonatomic, assign) CWizDocumentAttachmentArray attachmentsArray;
@property (nonatomic, retain) UIAlertView* waitAlert;
@property (nonatomic, retain) NSIndexPath* lastIndexPath;
@property (nonatomic, retain) UIDocumentInteractionController* currentPreview;
- (void) downloadDone:(NSNotification*)nc;
@end

@implementation WizCheckAttachments

@synthesize attachmentsArray;
@synthesize waitAlert;
@synthesize lastIndexPath;
@synthesize currentPreview;
@synthesize checkAttachmentDelegate;
@synthesize docGuid;
@synthesize accountUserId;
@synthesize kbguid;
- (void) dealloc
{
    [[WizNotificationCenter defaultCenter] removeObserver:self];
    [currentPreview release];
    [lastIndexPath release];
    [waitAlert release];
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        currentPreview = [[UIDocumentInteractionController alloc] init];
        currentPreview.delegate = self;
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void) backToReadView
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lastIndexPath = nil;
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(backToReadView)];
    self.navigationItem.leftBarButtonItem = backItem;
    [backItem release];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     std::string dbPath = CWizFileManager::shareInstance()->metaDatabasePath(self.kbguid.c_str(), self.accountUserId.c_str());
    WizMetaDb metadb(dbPath.c_str());
    metadb.attachmentsForDocument(self.docGuid.c_str(), attachmentsArray);
    self.title = NSLocalizedString(@"Attachments", nil);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[WizNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.attachmentsArray.size();
}
- (NSURL*) getAttachmentFileURL:(const WIZDOCUMENTATTACH&)attachment
{
    if ([[WizFileManager shareManager] prepareReadingEnviroment:WizStdStringToNSString(attachment.strGuid) accountUserId:WizStdStringToNSString(self.accountUserId)]) {
        NSString* attachmentFilePath = [[WizFileManager shareManager] wizObjectFilePath:WizStdStringToNSString(attachment.strName) accountUserId:WizStdStringToNSString(self.accountUserId)];
        return [[[NSURL alloc] initFileURLWithPath:attachmentFilePath] autorelease];
    }
    return nil;
}
- (BOOL) checkCanOpenInOtherApp:(const WIZDOCUMENTATTACH&)attach
{
    NSURL* url = [self getAttachmentFileURL:attach];
    [currentPreview setURL:url];
    if ([[currentPreview icons] count]) {
        return YES;
    }
    return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    WIZDOCUMENTATTACH attachment = self.attachmentsArray.at(indexPath.row);
//    NSString* attachType = WizStdStringToNSString(attachment.str)
//    WizAttachment* attach = [self.attachmentsArray objectAtIndex:indexPath.row];
//    if (attach.strType == nil || [attach.strType isEqualToString:@""]) {
//        attach.strType = @"noneType";
//    }
//    if (attach.bServerChanged) {
//        cell.detailTextLabel.text = NSLocalizedString(@"Tap to download", nil);
//    }
//    else 
//    {
//        cell.detailTextLabel.text = NSLocalizedString(@"Tap to view", nil);
//    }
//    if ([WizGlobals checkAttachmentTypeIsAudio:attach.strType]) {
//        cell.imageView.image = [UIImage imageNamed:@"icon_video_img"];
//    }
//    else  if ([WizGlobals checkAttachmentTypeIsPPT:attach.strType])
//    {
//        cell.imageView.image = [UIImage imageNamed:@"icon_ppt_img"];
//    }
//    else  if ([WizGlobals checkAttachmentTypeIsWord:attach.strType])
//    {
//        cell.imageView.image = [UIImage imageNamed:@"icon_word_img"];
//    }
//    else  if ([WizGlobals checkAttachmentTypeIsExcel:attach.strType])
//    {
//        cell.imageView.image = [UIImage imageNamed:@"icon_excel_img"];
//    }
//    else if ([WizGlobals checkAttachmentTypeIsImage:attach.strType])
//    {
//        cell.imageView.image = [UIImage imageNamed:@"icon_image_img"];
//    }
//    else 
//    {
//        cell.imageView.image = [UIImage imageNamed:@"icon_file_img"];
//    }
    cell.textLabel.text = WizStdStringToNSString(attachment.strName);
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}
- (void) checkInWiz:(const WIZDOCUMENTATTACH&)attachment
{

    WizCheckAttachment* check = [[WizCheckAttachment alloc] initWithNibName:nil bundle:nil];;
    NSURL* url = [self getAttachmentFileURL:attachment];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    check.req = req;
    [req release];
    if ([WizGlobals WizDeviceIsPad]) {
        [self.checkAttachmentDelegate didPushCheckAttachmentViewController:check];
    }
    else {
        [self.navigationController pushViewController:check animated:YES];
    }
    [check release];
}
- (void) checkInOtherApp:(const WIZDOCUMENTATTACH&)attachment
{
    NSURL* url = [self getAttachmentFileURL:attachment];
    [currentPreview setURL:url];
    CGRect nav = CGRectMake(0.0, 40*(lastIndexPath.row+1), 320, 40);
    if (![currentPreview presentOptionsMenuFromRect:nav inView:self.view  animated:YES]) {
        [WizGlobals reportWarningWithString:NSLocalizedString(@"There is no application can open this file.", nil)];
    }
}
-(void) checkAttachment:(const WIZDOCUMENTATTACH&) attachment inWiz:(BOOL)inWiz
{
    if (!attachment.nServerChanged) {
        if (inWiz) {
            [self checkInWiz:attachment];
        }
        else {
            [self checkInOtherApp:attachment];
        }
        
    }
    else
    {
        willCheckInWiz = inWiz;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WIZDOCUMENTATTACH attachment = self.attachmentsArray.at(indexPath.row);
    self.lastIndexPath = indexPath;
    [self checkAttachment:attachment inWiz:YES];
}
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    WIZDOCUMENTATTACH attachment = self.attachmentsArray.at(indexPath.row);
    self.lastIndexPath = indexPath;
    [self checkAttachment:attachment inWiz:NO];
}
@end
