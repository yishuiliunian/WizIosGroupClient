//
//  SearchHistoryView.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SearchHistoryViewController.h"

#import "WizGlobals.h"
#import "CommonString.h"
#import "WizAccountManager.h"
#import "WizFileManager.h"
#import "WizDbManager.h"
@implementation SearchHistoryView
@synthesize history;
@synthesize historyDelegate;
- (void) dealloc
{
    [history release];
    historyDelegate = nil;
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void) reloadData
{
    id<WizTemporaryDataBaseDelegate> searchHistoryDataBase =[[WizDbManager shareInstance] getGlobalCacheDb];
    NSArray* allSearchs = [searchHistoryDataBase allWizSearchs];
    if (allSearchs) {
        self.history = [NSMutableArray arrayWithArray:allSearchs];
    }
    else
    {
        self.history = [NSMutableArray array];
    }
    [self.tableView reloadData];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizSearch* search = [[self.history objectAtIndex:indexPath.row] retain];
    [self.history removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    //
    id<WizTemporaryDataBaseDelegate> searchHistoryDataBase =[[WizDbManager shareInstance] getGlobalCacheDb];
    [searchHistoryDataBase deleteWizSearch:search.strKeyWords];
    [search release];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadData];
    [super viewWillAppear:animated];
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, [WizGlobals heightForWizTableFooter:[self.history count]])];
    UIImageView* searchFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchTableFooter"]];
    [footerView addSubview:searchFooter];
    self.tableView.tableFooterView = footerView;
    footerView.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    [searchFooter release];
    [footerView release];
    
    UITextView* remind = [[UITextView alloc] initWithFrame:CGRectMake(90, 7, 210, 100)];
    remind.text = NSLocalizedString(@"Tap the field above to search your notes. Tap a recent or saved search to view the results of that search.", nil);
    remind.backgroundColor = [UIColor clearColor];
    remind.textColor = [UIColor grayColor];
    [searchFooter addSubview:remind];
    [remind release];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    WizSearch* search = [self.history objectAtIndex:indexPath.row];
    cell.textLabel.text = search.strKeyWords;
    NSString* detailString = [NSString stringWithFormat:NSLocalizedString(@"find %d notes", nil),search.nNotesNumber];
    NSString* displayStr = [NSString stringWithFormat:@"%@  %@",[search.dateLastSearched stringLocal],detailString];
    cell.detailTextLabel.text = displayStr;
    cell.imageView.image = [UIImage imageNamed:@"barItemSearch"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizSearch* search = [self.history objectAtIndex:indexPath.row];
    NSString* keywords = search.strKeyWords;
	if (keywords == nil || [keywords length] == 0)
		return;
    [self.historyDelegate didSelectedSearchHistory:keywords];
}

- (void) addSearchHistory:(NSString *)keyWords notesNumber:(int)count isSearchLoal:(BOOL)isSearchLocal
{
    WizSearch* search = [[WizSearch alloc] init];
    search.strKeyWords = keyWords;
    search.nNotesNumber = count;
    search.bSearchLocal = isSearchLocal;
    search.dateLastSearched = [NSDate date];
    [self.history insertObject:search atIndex:0];
    [search release];
    id<WizTemporaryDataBaseDelegate> searchHistoryDataBase =[[WizDbManager shareInstance] getGlobalCacheDb];
    [searchHistoryDataBase updateWizSearch:keyWords notesNumber:count isSerchLocal:isSearchLocal];
    
}
@end
