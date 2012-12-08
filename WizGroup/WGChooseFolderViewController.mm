//
//  WGChooseFolderViewController.m
//  WizGroup
//
//  Created by wiz on 12-11-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGChooseFolderViewController.h"
#import "TreeNode.h"
#import "WizPadTreeTableCell.h"
#import "WGListViewController.h"
#import "PPRevealSideViewController.h"
#import "WizAccountManager.h"
#import "WGNavigationBar.h"
#import "WGBarButtonItem.h"

enum WGFolderListIndex {
    WGFolderListIndexOfCustom = 0,
    WGFolderListIndexOfUserTree = 1
};


@interface WGChooseFolderViewController ()<WizPadTreeTableCellDelegate>
{
    TreeNode* rootTreeNode;
    NSMutableArray* allNodes;
}
@property (nonatomic, retain) NSMutableArray* allNodes;
@end

@implementation WGChooseFolderViewController
@synthesize kbGuid;
@synthesize accountUserId;
@synthesize listType;
@synthesize listKeyStr;
@synthesize allNodes;

//- (void) dealloc
//{
//    [allNodes release];
//    [rootTreeNode release];
//    [kbGuid release];
//    [accountUserId release];
//    [super dealloc];
//}
//
//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        
//        TreeNode* folderRootNode = [[TreeNode alloc] init];
//        folderRootNode.title   = @"key";
//        folderRootNode.keyString = @"key";
//        folderRootNode.isExpanded = YES;
//        rootTreeNode = folderRootNode;
//
//        allNodes = [[NSMutableArray array] retain];
//        //
//        
//        listKeyStr = nil;
//        listType = 0;
//    }
//    return self;
//}
//
//
//- (void) addTagTreeNodeToParent:(WizTag*)tag   rootNode:(TreeNode*)root  allTags:(NSArray*)allTags
//{
//    TreeNode* node = [[TreeNode alloc] init];
//    node.title = tag.strTitle;
//    node.keyString = tag.strGuid;
//    node.isExpanded = NO;
//    node.strType = WizTreeViewTagKeyString;
//    if (tag.strParentGUID == nil || [tag.strParentGUID isEqual:@""]) {
//        [root addChildTreeNode:node];
//    }
//    else
//    {
//        TreeNode* parentNode = [root childNodeFromKeyString:tag.strParentGUID];
//        if(nil != parentNode)
//        {
//            [parentNode addChildTreeNode:node];
//        }
//        else
//        {
//            WizTag* parent = nil;
//            for (WizTag* each in allTags) {
//                if ([each.strGuid isEqualToString:tag.strParentGUID]) {
//                    parent = each;
//                    break;
//                }
//            }
//            [self addTagTreeNodeToParent:parent rootNode:root allTags:allTags];
//            parentNode = [root childNodeFromKeyString:tag.strParentGUID];
//            [parentNode addChildTreeNode:node];
//        }
//    }
//    [node release];
//}
//
//- (void) reloadTagRootNode
//{
//    NSArray* tagArray = [[[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid ] allTagsForTree];
//    TreeNode* tagRootNode = rootTreeNode;
//    [tagRootNode removeAllChildrenNodes];
//    for (WizTag* each in tagArray) {
//        if (each.strTitle != nil && ![each.strTitle isEqualToString:@""]) {
//            [self addTagTreeNodeToParent:each rootNode:tagRootNode allTags:tagArray];
//        }
//    }
//}
////- (void) reloadCustomNodes
////{
////    NSMutableArray* customNodes = [allNodes objectAtIndex:WGFolderListIndexOfCustom];
////    [customNodes removeAllObjects];
////    
////    id<WizSettingsDbDelegate> db = [[WizDbManager shareInstance] getGlobalSettingDb];
////    NSLog(@"%@  %@",self.kbGuid,self.accountUserId);
////    WizGroup* curretnGroup = [ db groupFromGuid:self.kbGuid accountUserId:self.accountUserId];
////    [customNodes addObject:curretnGroup.kbName];
////}
//
//- (void )reloadAllTreeNodes
//{
//    [self reloadTagRootNode];
//}
//
//- (void) reloadAllData
//{
//    [self reloadAllTreeNodes];
//    //
//    [self.allNodes removeAllObjects];
//    [self.allNodes addObjectsFromArray:[rootTreeNode allExpandedChildrenNodes]];
//    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
//}
//
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    
//    id<WizSettingsDbDelegate> db = [[WizDbManager shareInstance] getGlobalSettingDb];
//    NSLog(@"%@  %@",self.kbGuid,self.accountUserId);
//    WizGroup* curretnGroup = [ db groupFromGuid:self.kbGuid accountUserId:self.accountUserId];
//    [allNodes addObject:curretnGroup.kbName];
//    [self reloadAllData];
//    [self loadNavigation];
//    self.tableView.backgroundColor = WGDetailCellBackgroudColor;
//}
//
//- (void) loadNavigation
//{
//    WGNavigationBar* navBar = [[WGNavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
//    UINavigationItem* barItem = [[UINavigationItem alloc]initWithTitle:@""];
//    UIBarButtonItem* saveBack = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"feedback_back"] hightedImage:nil target:self selector:@selector(saveAndBack)];
//    barItem.leftBarButtonItem = saveBack;
//    [navBar pushNavigationItem:barItem animated:YES];
//    self.tableView.tableHeaderView = navBar;
//    [navBar release];
//    [barItem release];
//}
//
//- (void) saveAndBack
//{
//    [self dismissModalViewControllerAnimated:YES];
//}
//
//- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0;
//}
//- (void) viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//}
//- (void)viewDidUnload
//{
//    [super viewDidUnload];
//    
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}
//
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [allNodes count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//        static NSString *CellIdentifier = @"WizPadTreeTableCell";
//        WizPadTreeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        
//        if (nil == cell) {
//            cell = [[[WizPadTreeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
//            cell.delegate = self;
//            cell.contentView.backgroundColor = WGDetailCellBackgroudColor;
//        }        
//        TreeNode* node = [self.allNodes objectAtIndex:indexPath.row];
//        cell.strTreeNodeKey = node.keyString;
//        if ([cell.strTreeNodeKey isEqualToString:listKeyStr]) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }else{
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }        
//    return cell;
//}
//
//- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    WizPadTreeTableCell* treeCell = (WizPadTreeTableCell*)cell;
//    [treeCell showExpandedIndicatory];
//    [treeCell setNeedsDisplay];
//}
//
//
//- (TreeNode*) findTreeNodeByKey:(NSString*)strKey
//{
//    return [rootTreeNode childNodeFromKeyString:strKey];
//}
//
//- (void) onexpandedRootNode
//{
//    if (rootTreeNode.isExpanded) {
//        rootTreeNode.isExpanded = !rootTreeNode.isExpanded;
//        [self.allNodes removeAllObjects];
//        [self.tableView reloadData];
//    }
//    else
//    {
//        rootTreeNode.isExpanded = !rootTreeNode.isExpanded;
//        [self.allNodes removeAllObjects];
//        [self.allNodes addObjectsFromArray:[rootTreeNode allExpandedChildrenNodes]];
//        [self.tableView reloadData];
//    }
//    ;
//}
//
//- (void) onExpandedNode:(TreeNode *)node
//{
//    NSInteger row = NSNotFound;
//    for (int i = 0 ; i < [self.allNodes count]; i++) {
//        
//        TreeNode* eachNode = [self.allNodes objectAtIndex:i];
//        if ([eachNode.keyString isEqualToString:node.keyString]) {
//            row = i;
//            break;
//        }
//    }
//    if(row != NSNotFound)
//    {
//        [self onExpandNode:node refrenceIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
//    }
//}
//
//- (void) onExpandNode:(TreeNode*)node refrenceIndexPath:(NSIndexPath*)indexPath
//{
//    
//    if (!node.isExpanded) {
//        node.isExpanded = YES;
//        NSArray* array = [node allExpandedChildrenNodes];
//        
//        NSInteger startPostion = [self.allNodes count] == 0? 0: indexPath.row+1;
//        
//        NSMutableArray* rows = [NSMutableArray array];
//        for (int i = 0; i < [array count]; i++) {
//            NSInteger  positionRow = startPostion+ i;
//            
//            TreeNode* node = [array objectAtIndex:i];
//            [self.allNodes insertObject:node atIndex:positionRow];
//            
//            [rows addObject:[NSIndexPath indexPathForRow:positionRow inSection:indexPath.section]];
//        }
//        
//        [self.tableView beginUpdates];
//        [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.tableView endUpdates];
//    }
//    else
//    {
//        node.isExpanded = NO;
//        NSMutableArray* deletedIndexPaths = [NSMutableArray array];
//        NSMutableArray* deletedNodes = [NSMutableArray array];
//        for (int i = indexPath.row; i < [self.allNodes count]; i++) {
//            TreeNode* displayedNode = [self.allNodes objectAtIndex:i];
//            if ([node childNodeFromKeyString:displayedNode.keyString]) {
//                [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
//                [deletedNodes addObject:displayedNode];
//            }
//        }
//        
//        for (TreeNode* each in deletedNodes) {
//            [self.allNodes removeObject:each];
//        }
//        
//        [self.tableView beginUpdates];
//        [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.tableView endUpdates];
//    }
//}
//
//- (UIImage*) placeHolderImage
//{
//    return nil;
//}
//- (void) showExpandedIndicatory:(WizPadTreeTableCell*)cell
//{
//    TreeNode* node = [self findTreeNodeByKey:cell.strTreeNodeKey];
//    if ([node.childrenNodes count]) {
//        if (!node.isExpanded) {
//            [cell.expandedButton setImage:[UIImage imageNamed:@"treePhoneItemClosed"] forState:UIControlStateNormal];
//        }
//        else
//        {
//            [cell.expandedButton setImage:[UIImage imageNamed:@"treePhoneItemOpened"] forState:UIControlStateNormal];
//        }
//    }
//    else
//    {
//        [cell.expandedButton setImage:[self placeHolderImage] forState:UIControlStateNormal];
//    }
//}
//- (void) onExpandedNodeByKey:(NSString*)strKey
//{
//    TreeNode* node = [self findTreeNodeByKey:strKey];
//    if (node) {
//        [self onExpandedNode:node];
//    }
//}
//- (NSInteger) treeNodeDeep:(NSString*)strKey
//{
//    TreeNode* node = [self findTreeNodeByKey:strKey];
//    return node.deep;
//}
//
//- (void) decorateTreeCell:(WizPadTreeTableCell *)cell
//{
//    TreeNode* node = [rootTreeNode childNodeFromKeyString:cell.strTreeNodeKey];
//    if (node == nil) {
//        return;
//    }
//    cell.titleLabel.text = getTagDisplayName(node.title);
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    TreeNode* node = [self.allNodes objectAtIndex:indexPath.row];
//    listType = WGListTypeTag;
//    listKeyStr = node.keyString;
//    NSLog(@"%@  %d",listKeyStr,listType);
//    [self.tableView reloadData];
////    UINavigationController* navCon = (UINavigationController*) self.revealSideViewController.rootViewController ;
////    for (UIViewController* each in navCon.viewControllers) {
////        if ([each isKindOfClass:[WGListViewController class]]) {
////            WGListViewController* listController = (WGListViewController*)each;
////            listController.listType = listType;
////            listController.listKey = listKeyStr;
////            break;
////        }
////    }
////    
////    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft animated:YES];
//    
//}
//- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return NSLocalizedString(@"Folder", nil);
//}
//- (void) viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    NSLog(@"detail appeared");
//}
@end
