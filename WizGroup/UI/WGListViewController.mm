
//  WGListViewController.m
//  WizGroup
//
//  Created by wiz on 12-9-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGListViewController.h"
#import "PPRevealSideViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WGReadViewController.h"
#import "WGNavigationBar.h"
#import "WizGroup.h"
#import "CommonString.h"
#import "WGDetailListCell.h"
#import "WGBarButtonItem.h"
#import "WGToolBar.h"
#import "WGNavigationViewController.h"
#import "WizFileManager.h"

#import "EGORefreshTableHeaderView.h"
#import "WizSyncCenter.h"

#import "WizNotificationCenter.h"
#import "WGFeedBackViewController.h"
#import "WGCreateNoteViewController.h"
#import "WizModuleTransfer.h"
#import "WizMetaDb.h"
#import "WizSettings.h"
using namespace WizModule;
//
#import "MBProgressHUD.h"
#import "WizAccountManager.h"

class CWizTestTime {
    
    NSDate* date;
public:
    CWizTestTime(){ date = [[NSDate date] retain];};
    ~CWizTestTime()
    {
        NSDate* date2 = [NSDate date];
        NSLog(@"spend time is %f", [date timeIntervalSinceDate:date2]);
        [date release];
    };
};

@interface WGListViewController () <WGReadListDelegate,
                                    EGORefreshTableHeaderDelegate,
                                    UISearchBarDelegate,
                                    UISearchDisplayDelegate,
                                    WizXmlSyncKbDelegate
                                    ,WizXmlSearchDelegate
                                    , WizUIEditDocumentDelegate>
{
    CWizDocumentsGroups documentsArray;
    BOOL    isRefreshing;
    CWizDocumentDataArray searchDocArray;
    
}
@property (nonatomic, retain) NSIndexPath* lastIndexPath;
@property (nonatomic, retain) EGORefreshTableHeaderView* pullToRefreshView;
@property (nonatomic, retain) UISearchBar* searchBar;
@property (nonatomic ,retain) UISearchDisplayController* searchDisplayCon;
@property (nonatomic, retain) NSMutableArray* searchHistoryArray;
@property (atomic, retain) NSString* searchKeyWords;
@end

@implementation WGListViewController
@synthesize searchKeyWords;
@synthesize accountUserId;
@synthesize listType;
@synthesize listKey;
@synthesize lastIndexPath;
@synthesize pullToRefreshView;
@synthesize searchBar;
@synthesize searchDisplayCon;
@synthesize searchHistoryArray;
@synthesize groupData;
- (void) dealloc
{
    [[WizUINotifactionCenter shareInstance] removeObserver:self];
    [searchKeyWords release];
    [searchHistoryArray release];
    [searchDisplayCon release];
    [searchBar release];
    [self removeObserver:self forKeyPath:@"listKey"];
    [[WizNotificationCenter defaultCenter] removeObserver:self];
    [pullToRefreshView release];
    [listKey release];
    [lastIndexPath release];
    [super dealloc];
}
//
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"listKey"]) {
        [self reloadAllData];
    }
}
//
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self addObserver:self forKeyPath:@"listKey" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew  context:nil];
        isRefreshing = NO;
        //
        searchHistoryArray = [[NSMutableArray alloc] init];
        [[WizUINotifactionCenter shareInstance] addEditDocumentObserver:self];
    }
    return self;
}
- (void) OnSyncKbBegin:(std::string)kbguid
{
   if (self.groupData.kbGuid== kbguid)
   {
       if(isRefreshing)
       {
           return;
       }
       isRefreshing = YES;
   }
}

- (void) OnSyncKbEnd:(std::string)kbguid
{
    if (self.groupData.kbGuid == kbguid) {
        isRefreshing = NO;
        [self.pullToRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        [self reloadAllData];
    }
}

- (void) OnSyncKbFaild:(std::string)kbguid
{
   [self OnSyncKbEnd:kbguid]; 
}
- (std::string) getMetaDbPath
{
    return CWizFileManager::shareInstance()->metaDatabasePath(self.groupData.kbGuid.c_str(), self.groupData.accountUserId.c_str());
}
- (void) loadRecentsDocument:(CWizDocumentDataArray&)array
{
    WizMetaDb metaDb([self getMetaDbPath].c_str());
    if (!metaDb.recentDocuments(array)) {
        return;
    }
//    self.title = [NSString stringWithFormat:@"%@(%@)",self.kbGroup.kbName, NSLocalizedString(@"Recent", nil)];
}



- (void) reloadAllDataByDocuments:(CWizDocumentDataArray& )array
{
    documentsArray.setDocuments(array, CWizDocumentsSortedTypeByModifiedDateAsc);
    [self.tableView reloadData];
}

- (void) reloadAllData
{
    CWizTestTime testTime;
        WizMetaDb metaDb([self getMetaDbPath].c_str());
        CWizDocumentDataArray array;
        switch (listType) {
            case WGListTypeRecent:
                metaDb.recentDocuments(array);
                break;
            case WGListTypeTag:
                metaDb.documentsByTag(WizNSStringToCString(self.listKey), array);
                break;
            case WGListTypeUnread:
                metaDb.unreadDocuments(array);
                break;
            case WGListTypeNoTags:
                metaDb.documentsByNotag(array);
                break;
            case WGListTypeSearch:
                array = searchDocArray;
                break;
            default:
                break;
        }
        documentsArray.setDocuments(array, CWizDocumentsSortedTypeByModifiedDateDesc);
        [self.tableView reloadData]; 
}


- (void) backToHome
{
    CATransition *tran = [CATransition animation];
    tran.duration = .4f;
    tran.type = kCATransitionPush;
    tran.subtype = kCATransitionFromBottom; //Bottom for the opposite direction
    tran.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    tran.removedOnCompletion  = YES;
    [self.navigationController.view.layer addAnimation:tran forKey:@"TransitionDownUp"];
    [self.revealSideViewController dismissModalViewControllerAnimated:YES];
}
- (void) editComment
{
    WGCreateNoteViewController* editCommentVC = [[WGCreateNoteViewController alloc]init];
    editCommentVC.kbGuid = self.groupData.kbGuid;
    editCommentVC.accountUserId = self.groupData.accountUserId;
    [self.navigationController presentModalViewController:editCommentVC animated:YES];
    [editCommentVC release];
}
- (void) feedbackCenter
{
//    WGFeedBackViewController* feedbackVC = [[WGFeedBackViewController alloc]init];
//    feedbackVC.kbGuid = self.kbGuid;
//    feedbackVC.accountUserId = self.accountUserId;
//    feedbackVC.delegate = self;
//    feedbackVC.modalPresentationStyle = UIModalPresentationFullScreen;
//	feedbackVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    [self.navigationController presentModalViewController:feedbackVC animated:YES];
//    [feedbackVC release];
}

- (void)didfinishFeedBack:(WGFeedBackViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void) beginSearch
{
    [self.searchBar becomeFirstResponder];
}


- (void) reloadToolBarItems
{
    WGNavigationViewController* nav = (WGNavigationViewController*)self.navigationController;
    
    
    UIBarButtonItem* flexItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    
    UIBarButtonItem* searchItem= [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"doc_list_finder"] hightedImage:nil target:self selector:@selector(beginSearch)];
   
    
    [nav setWgToolItems:@[searchItem,flexItem]];
    

    UIBarButtonItem* editCommentItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"doc_list_new"] hightedImage:nil target:self selector:@selector(editComment)];
    
//    UIBarButtonItem* feedBackItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"listFeedbackIcon"] hightedImage:nil target:self selector:@selector(feedbackCenter)];
    [nav setWgToolItems:@[searchItem,flexItem,editCommentItem]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    [self reloadToolBarItems];
    self.revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionContentView | PPRevealSideInteractionNavigationBar;
    [self reloadAllData];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[WizUINotifactionCenter shareInstance] addObserver:self kbguid:(self.groupData.kbGuid)];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) showLeftController
{
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
}
- (void) customizeNavBar {
   
    WGNavigationBar* navBar = [[[WGNavigationBar alloc] init] autorelease];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor blackColor],
                                UITextAttributeTextColor,
                                [UIColor clearColor],
                                UITextAttributeTextShadowColor, nil];
    [navBar setTitleTextAttributes:attributes];
    [self.navigationController setValue:navBar forKeyPath:@"navigationBar"];
    
    UIBarButtonItem* showLeftItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"doc_list_tocategory"] hightedImage:nil target:self selector:@selector(showLeftController)];
    
    self.navigationItem.leftBarButtonItem = showLeftItem;

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeNavBar];
    
    
    self.searchBar = [[[UISearchBar alloc] init] autorelease];
    self.searchBar.frame = CGRectMake(0.0, 00, self.view.frame.size.width, 44);
    self.searchBar.tintColor = [UIColor lightGrayColor];
    self.searchBar.delegate = self;
    self.searchBar.scopeButtonTitles = @[NSLocalizedString(@"Title", nil),NSLocalizedString(@"All", nil)];
   

    self.searchDisplayCon = [[[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self] autorelease];

    self.searchDisplayCon.searchResultsDataSource = self;
    self.searchDisplayCon.searchResultsDelegate = self;

    
    self.tableView.tableHeaderView = self.searchBar;
    
    self.pullToRefreshView = [[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)] autorelease];
    self.pullToRefreshView.delegate = self;
    [self.tableView addSubview:self.pullToRefreshView];
    
    //
    
    isRefreshing = [WizUINotifactionCenter isSyncingGuid:self.groupData.kbGuid];
    if (isRefreshing) {
        [self.pullToRefreshView startLoadingAnimation:self.tableView];
    }
    else
    {
        [self.pullToRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
    
    UIBarButtonItem* backToHomeItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"doc_list_home"] hightedImage:nil target:self selector:@selector(backToHome)];
    self.navigationItem.rightBarButtonItem = backToHomeItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.pullToRefreshView removeFromSuperview];
    self.pullToRefreshView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
       return WizStdStringToNSString(documentsArray.getGroupName(section)); 
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.tableView]) {
        return documentsArray.getGroupCount();
    }
    else if ([tableView isEqual:self.searchDisplayCon.searchResultsTableView])
    {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.tableView]) {
        NSInteger count = documentsArray.getDocumentCount(section);
        if (count) {
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        }
        else
        {
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        return count;
    }
    else if ([tableView isEqual:self.searchDisplayCon.searchResultsTableView])
    {
        return [self.searchHistoryArray count];
    }
    return 0;

}

- (UITableViewCell*) searchTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]autorelease];
    }
//    WizSearch* search = [self.searchHistoryArray objectAtIndex:indexPath.row];
//    cell.textLabel.text = search.strKeyWords;
//    cell.detailTextLabel.text = [search.dateLastSearched stringLocal];
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.searchDisplayCon.searchResultsTableView]) {
        return [self searchTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    static NSString *CellIdentifier = @"ListCell";
    WGDetailListCell *cell = (WGDetailListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[[WGDetailListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    WIZDOCUMENTDATA doc = documentsArray.getDocument(indexPath.section, indexPath.row);
    cell.doc = doc;
    cell.kbguid= self.groupData.kbGuid;
    cell.accountUserId = self.groupData.accountUserId;
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        return 110;
    }
    else if ([tableView isEqual:self.searchDisplayCon.searchResultsTableView])
    {
        return 44;
    }
    return 44;
}
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.searchDisplayCon.searchResultsTableView]) {
        
//        WizSearch* search = [self.searchHistoryArray objectAtIndex:indexPath.row];
//        [self searchOnServer:search.strKeyWords];
        return;
    }
    //
    self.lastIndexPath = indexPath;
    WGReadViewController* readController = [[WGReadViewController alloc] init];
    readController.kbguid = self.groupData.kbGuid;
    readController.accountUserId = self.groupData.accountUserId;
    readController.listDelegate = self;
    
    
    [self.navigationController pushViewController:readController animated:YES];
    self.revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionNone;
    [readController release];
}
// read deleagte
- (std::string) currentDocumentGuid
{
    if (self.lastIndexPath!= nil ) {
        return documentsArray.getDocument(self.lastIndexPath.section, self.lastIndexPath.row).strGUID;
    }
    return "";
}
- (BOOL) shouldCheckNextDocument
{
    if (self.lastIndexPath != nil) {
        int groupCount = documentsArray.getDocumentCount(self.lastIndexPath.section);
        int nextRow = self.lastIndexPath.row+1;
        if (nextRow < groupCount) {
            return YES;
        }
        else
        {
            if (self.lastIndexPath.section < documentsArray.getGroupCount()) {
                return YES;
            }
        }
    }
    return NO;
}

- (void) moveToNextDocument
{
    if ([self shouldCheckNextDocument]) {
        int groupCount = documentsArray.getDocumentCount(self.lastIndexPath.section);
        int nextRow = self.lastIndexPath.row+1;
        if (nextRow < groupCount) {
            self.lastIndexPath = [NSIndexPath indexPathForRow:nextRow inSection:self.lastIndexPath.section];
        }
        else
        {
            if (self.lastIndexPath.section < documentsArray.getGroupCount() -1) {
                self.lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:self.lastIndexPath.section +1];
            }
        }
 
    }
}

- (BOOL) shouldCheckPreDocument
{
    if (self.lastIndexPath != nil) {
        if (self.lastIndexPath.row > 0) {
            return YES;
        }
        else
        {
            if (self.lastIndexPath.section > 0) {
                return YES;
            }
        }
    }
    return NO;
}
//
- (void) moveToPreDocument
{
    if (self.lastIndexPath != nil) {
        if (self.lastIndexPath.row > 0) {
            self.lastIndexPath = [NSIndexPath indexPathForRow:self.lastIndexPath.row-1 inSection:self.lastIndexPath.section];
        }
        else
        {
            if (self.lastIndexPath.section > 0) {
                int preSection = self.lastIndexPath.section - 1;
                self.lastIndexPath = [NSIndexPath indexPathForRow:documentsArray.getDocumentCount(preSection)-1 inSection:preSection];
            }
        }
    }
}
- (void) refreshGroupData
{
    [WizSyncCenter defaultCenter] ;
    [WizSyncCenter syncKbGuid:self.groupData.kbGuid account:self.groupData.accountUserId isOnlyUpload:NO userGroup:0];
}
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setNeedsDisplay];
}
#pragma mark -

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.pullToRefreshView egoRefreshScrollViewDidScroll:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.pullToRefreshView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    isRefreshing = YES;
    [self refreshGroupData];
}
- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return isRefreshing;
}

- (NSDate*) egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [[WizSettings shareInstance] lastUpdateDateForKey:WizStdStringToNSString(self.groupData.kbGuid)];
}


//search

- (void) searchBar:(UISearchBar *)searchBar_ textDidChange:(NSString *)searchText
{
//    id<WizTemporaryDataBaseDelegate> db = [[WizDbManager shareInstance] getGlobalCacheDb];
//    NSArray* array = [db allWizSearchsByKbguid:self.kbGuid accountUserId:self.accountUserId];
//    [self.searchHistoryArray removeAllObjects];
//    [self.searchHistoryArray addObjectsFromArray:array];
}

- (void) searchOnServer:(NSString*)keyWords
{
    [MBProgressHUD showHUDAddedTo:self.searchDisplayCon.searchResultsTableView animated:YES];
    self.searchKeyWords = keyWords;
    WizSyncSearchOperation* searchOpration = [[WizSyncSearchOperation alloc] init];
    searchOpration.kbguid = self.groupData.kbGuid;
    searchOpration.accountUserId = self.groupData.accountUserId;
    searchOpration.keyWords = WizNSStringToStdString(keyWords);
    searchOpration.delegate = self;
    searchOpration.password = [[WizAccountManager defaultManager] CAccountPasswordByUserId:self.groupData.accountUserId];
    [[NSOperationQueue backGroupQueue] addOperation:searchOpration];
    [searchOpration release];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar_
{
    
    [self searchOnServer:searchBar_.text];
}
- (void) didSearchedFailed
{
    NSLog(@"search faild");
}

- (void) didSearchedSucceed:(WizModule::CWizDocumentDataArray)array
{
    searchDocArray = array;
    self.listType = WGListTypeSearch;
    self.listKey = @"";
     [MBProgressHUD hideAllHUDsForView:self.searchDisplayCon.searchResultsTableView animated:YES];
    [self.searchDisplayCon setActive:NO animated:YES]; 
}

- (void) didUpdateDocument:(const char *)docGuid
{
    
}

- (void) didDeletedDocument:(const char *)docGuid
{
    WizMetaDb db([self getMetaDbPath].c_str());
    WIZDOCUMENTDATA doc;
    if (db.documentFromGUID(docGuid, doc)) {
        int group;
        int row;
        if (documentsArray.removeDocument(doc, group, row)) {
            NSIndexPath* deletedIndexPath = [NSIndexPath indexPathForRow:row inSection:group];
            [self.tableView deleteRowsAtIndexPaths:@[deletedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}
- (void) didInsertDocumentLocal:(const char *)docGuid
{
    WizMetaDb db([self getMetaDbPath].c_str());
    WIZDOCUMENTDATA doc;
    if (db.documentFromGUID(docGuid, doc)) {
        if (listType != WGListTypeRecent) {
            return;
        }
        int groupIndex;
        int rowIndex;
        bool groupCreated;
        documentsArray.insertDocument(doc, groupCreated, groupIndex, rowIndex);
        if (groupCreated) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:groupIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowIndex inSection:groupIndex]] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void) didInsertDocument:(const char *)docGuid
{
    
}

@end
