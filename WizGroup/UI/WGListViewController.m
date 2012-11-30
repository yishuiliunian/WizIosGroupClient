//
//  WGListViewController.m
//  WizGroup
//
//  Created by wiz on 12-9-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGListViewController.h"
#import "PPRevealSideViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WizDbManager.h"
#import "WGReadViewController.h"
#import "WGNavigationBar.h"
#import "WizGroup.h"
#import "CommonString.h"
#import "WGDetailListCell.h"
#import "WGBarButtonItem.h"
#import "WGToolBar.h"
#import "WGNavigationViewController.h"

#import "EGORefreshTableHeaderView.h"
#import "WizSyncCenter.h"

#import "WizNotificationCenter.h"
#import "WGFeedBackViewController.h"
#import "WGCreateNoteViewController.h"


//
#import "WizApiSearch.h"
#import "MBProgressHUD.h"

@interface WGListViewController () <WGReadListDelegate,
                                    EGORefreshTableHeaderDelegate,
                                    UISearchBarDelegate,UISearchDisplayDelegate,WizSearchDelegate>
{
    NSMutableArray* documentsArray;
    BOOL    isRefreshing;
}
@property (nonatomic, retain) NSIndexPath* lastIndexPath;
@property (nonatomic, retain) EGORefreshTableHeaderView* pullToRefreshView;
@property (nonatomic, retain) UISearchBar* searchBar;
@property (nonatomic ,retain) UISearchDisplayController* searchDisplayCon;
@property (nonatomic, retain) NSMutableArray* searchHistoryArray;
@property (nonatomic, retain) NSMutableArray* searchedDocumentsArray;
@property (atomic, retain) NSString* searchKeyWords;
@end

@implementation WGListViewController
@synthesize kbGuid;
@synthesize searchKeyWords;
@synthesize searchedDocumentsArray;
@synthesize accountUserId;
@synthesize listType;
@synthesize listKey;
@synthesize lastIndexPath;
@synthesize kbGroup;
@synthesize pullToRefreshView;
@synthesize searchBar;
@synthesize searchDisplayCon;
@synthesize searchHistoryArray;
- (void) dealloc
{
    [searchKeyWords release];
    [searchedDocumentsArray release];
    [searchHistoryArray release];
    [searchDisplayCon release];
    [searchBar release];
    [self removeObserver:self forKeyPath:@"listKey"];
    [[WizNotificationCenter defaultCenter] removeObserver:self];
    [pullToRefreshView release];
    [kbGroup release];
    [listKey release];
    [lastIndexPath release];
    [documentsArray release];
    [kbGuid release];
    [accountUserId release];
    [super dealloc];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"listKey"]) {
        [self reloadAllData];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self addObserver:self forKeyPath:@"listKey" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew  context:nil];
        documentsArray = [[NSMutableArray alloc] init];
        isRefreshing = NO;
        //
        searchHistoryArray = [[NSMutableArray alloc] init];
        [[WizNotificationCenter defaultCenter] addObserver:self selector:@selector(startRefreshingGroup:) name:WizNMSyncGroupStart object:nil
         ];
        [[WizNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefreshGroup:) name:WizNMSyncGroupEnd object:nil];
        [[WizNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefreshGroup:) name:WizNMSyncGroupError object:nil];
    }
    return self;
}
- (void) startRefreshingGroup:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter getGuidFromNc:nc];
    if ([self.kbGuid isEqualToString:guid]) {
        isRefreshing = YES;
        [self.pullToRefreshView startLoadingAnimation:self.tableView];
    }
    
}

- (void) endRefreshGroup:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter getGuidFromNc:nc];
    if ([self.kbGuid isEqualToString:guid]) {
        isRefreshing = NO;
        [self.pullToRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        [self reloadAllData];
    }
}

- (void) loadRecentsDocument
{
    id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
    [documentsArray addObjectsFromArray:[db recentDocuments]];
    
    self.title = [NSString stringWithFormat:@"%@(%@)",self.kbGroup.kbName, NSLocalizedString(@"Recent", nil)];
}

- (void) loadTagDocument
{
    id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
    [documentsArray addObjectsFromArray:[db documentsByTag:self.listKey]];
    
    WizTag* tag = [db tagFromGuid:self.listKey];
    self.title = getTagDisplayName(tag.strTitle);
}

- (void) loadUnreadDocument
{
    id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
    [documentsArray addObjectsFromArray:[db unreadDocuments]];
    
    self.title = WizStrUnreadNotes;
}
- (void) loadNotagDocuments
{
    id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
    [documentsArray addObjectsFromArray:[db documentsByNotag]];
    self.title = self.kbGroup.kbName;
}
- (void) loadSearchDocuments
{
    [documentsArray addObjectsFromArray:self.searchedDocumentsArray];
}
- (void) reloadAllData
{
    [documentsArray removeAllObjects];
    switch (listType) {
        case WGListTypeRecent:
            [self loadRecentsDocument];
            break;
        case WGListTypeTag:
            [self loadTagDocument];
            break;
        case WGListTypeUnread:
            [self loadUnreadDocument];
            break;
        case WGListTypeNoTags:
            [self loadNotagDocuments];
            break;
        case WGListTypeSearch:
            [self loadSearchDocuments];
            break;
        default:
            [self loadRecentsDocument];
            break;
    }
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
    editCommentVC.kbGuid = self.kbGuid;
    editCommentVC.accountUserId = self.accountUserId;
    [self.navigationController presentModalViewController:editCommentVC animated:YES];
    [editCommentVC release];
}
- (void) feedbackCenter
{
    WGFeedBackViewController* feedbackVC = [[WGFeedBackViewController alloc]init];
    feedbackVC.kbGuid = self.kbGuid;
    feedbackVC.accountUserId = self.accountUserId;
    feedbackVC.delegate = self;
    feedbackVC.modalPresentationStyle = UIModalPresentationFullScreen;
	feedbackVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentModalViewController:feedbackVC animated:YES];
    [feedbackVC release];
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
    UIBarButtonItem* backToHomeItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"doc_list_home"] hightedImage:nil target:self selector:@selector(backToHome)];
    

    UIBarButtonItem* editCommentItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"listEditIcon"] hightedImage:nil target:self selector:@selector(editComment)];
    
    UIBarButtonItem* feedBackItem = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"listFeedbackIcon"] hightedImage:nil target:self selector:@selector(feedbackCenter)];
    [nav setWgToolItems:@[backToHomeItem,flexItem,editCommentItem,feedBackItem]];

    [nav setWgToolItems:@[flexItem]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    [self reloadAllData];
    [self reloadToolBarItems];
    self.revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionContentView | PPRevealSideInteractionNavigationBar;
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
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
    isRefreshing = [[WizSyncCenter defaultCenter]  isRefreshingGroup:self.kbGuid accountUserId:self.accountUserId];
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual:self.tableView]) {
        return 1;
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
        NSInteger count = [documentsArray count];
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
    WizSearch* search = [self.searchHistoryArray objectAtIndex:indexPath.row];
    cell.textLabel.text = search.strKeyWords;
    cell.detailTextLabel.text = [search.dateLastSearched stringLocal];
    return cell;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.searchDisplayCon.searchResultsTableView]) {
        return [self searchTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    //
    static NSString *CellIdentifier = @"ListCell";
    WGDetailListCell *cell = (WGDetailListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[[WGDetailListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if ([documentsArray count] == 0) {
        return cell;
    }
    WizDocument* doc = [documentsArray objectAtIndex:indexPath.row];
    cell.documentGuid = doc.strGuid;
    cell.kbGuid = self.kbGuid;
    cell.accountUserId = self.accountUserId;
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
        
        WizSearch* search = [self.searchHistoryArray objectAtIndex:indexPath.row];
        [self searchOnServer:search.strKeyWords];
        return;
    }
    //
    self.lastIndexPath = indexPath;
    WGReadViewController* readController = [[WGReadViewController alloc] init];
    readController.kbguid = self.kbGuid;
    readController.accountUserId = self.accountUserId;
    readController.listDelegate = self;
    
    
    [self.navigationController pushViewController:readController animated:YES];
    self.revealSideViewController.panInteractionsWhenClosed = PPRevealSideInteractionNone;
    [readController release];
}
// read deleagte

- (WizDocument*) currentDocument
{
    if (self.lastIndexPath!= nil  && self.lastIndexPath.row < [documentsArray count]) {
        return [documentsArray objectAtIndex:self.lastIndexPath.row];
    }
    return nil;
}

- (BOOL) shouldCheckNextDocument
{
    if (self.lastIndexPath != nil) {
        if (self.lastIndexPath.row + 1 < [documentsArray count]) {
            return YES;
        }
    }
    return NO;
}

- (void) moveToNextDocument
{
    if ([self shouldCheckNextDocument]) {
        self.lastIndexPath = [NSIndexPath indexPathForRow:self.lastIndexPath.row+1 inSection:0];
    }
}

- (BOOL) shouldCheckPreDocument
{
    if (self.lastIndexPath != nil) {
        if (self.lastIndexPath.row - 1 >= 0) {
            return YES;
        }
    }
    return NO;
}

- (void) moveToPreDocument
{
    if ([self shouldCheckPreDocument]) {
        self.lastIndexPath = [NSIndexPath indexPathForRow:self.lastIndexPath.row -1 inSection:0];
    }
}
- (void) refreshGroupData
{
    [[WizSyncCenter defaultCenter] refreshGroup:self.kbGuid accountUserId:self.accountUserId];
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
    id<WizSettingsDbDelegate> db = [[WizDbManager shareInstance] getGlobalSettingDb];
    return [db lastUpdateTimeForGroup:self.kbGuid accountUserId:self.accountUserId];
}


//search

- (void) searchBar:(UISearchBar *)searchBar_ textDidChange:(NSString *)searchText
{
    id<WizTemporaryDataBaseDelegate> db = [[WizDbManager shareInstance] getGlobalCacheDb];
    NSArray* array = [db allWizSearchsByKbguid:self.kbGuid accountUserId:self.accountUserId];
    [self.searchHistoryArray removeAllObjects];
    [self.searchHistoryArray addObjectsFromArray:array];
}

- (void) searchOnServer:(NSString*)keyWords
{
    [MBProgressHUD showHUDAddedTo:self.searchDisplayCon.searchResultsTableView animated:YES];
    self.searchKeyWords = keyWords;
    WizApiSearch* search = [[[WizApiSearch alloc] initWithKbguid:self.kbGuid accountUserId:self.accountUserId apiDelegate:nil] autorelease];
    search.delegate = self;
    search.keyWords = keyWords;
    [WizSyncCenter runWizApi:search inQueue:[NSOperationQueue wizDownloadQueue]];
 
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar_
{
    
    [self searchOnServer:searchBar_.text];
}
- (void) didSearchSucceed:(NSArray *)array
{
    [MBProgressHUD hideAllHUDsForView:self.searchDisplayCon.searchResultsTableView animated:YES];
    
    NSLog(@"search key words is %@",self.searchKeyWords);
    
    id<WizTemporaryDataBaseDelegate> db = [[WizDbManager shareInstance] getGlobalCacheDb];
    [db updateWizSearch:self.searchKeyWords notesNumber:[array count] isSerchLocal:NO kbguid:self.kbGuid accountUserId:self.accountUserId];
    //

    dispatch_async(dispatch_get_main_queue(), ^{
        self.searchedDocumentsArray = [NSMutableArray arrayWithArray:array];
        self.listKey = @"";
        self.listType = WGListTypeSearch;
        [self reloadAllData];
       [self.searchDisplayCon setActive:NO animated:YES]; 
    });
    

}
- (void) didSearchError:(NSError *)error
{
    NSLog(@"search faild");
}

@end
