//
//  WGFeedBackHistoryViewController.m
//  WizGroup
//
//  Created by wiz on 12-11-14.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGFeedBackHistoryViewController.h"
#import "WGBarButtonItem.h"
#import "WGFeedBackCell.h"
#import "WGToolBar.h"
#import "WGNavigationBarNew.h"
#import <QuartzCore/QuartzCore.h>
#import "SBJson.h"

@interface WGFeedBackHistoryViewController ()

@end

@implementation WGFeedBackHistoryViewController
@synthesize feedBackDic;
@synthesize filePath;
@synthesize array;

- (void)dealloc
{
    [array release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initUI];

    self.array = [[NSMutableArray alloc]initWithArray:[feedBackDic objectForKey:@"History"]];
    NSLog(@"%@",array);


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUI
{
    //    float startX = 10;
    //    float startY = 10;
    CGSize size = self.view.frame.size;
    float endX = size.width;
    float endY = size.height;
    
    WGNavigationBarNew* navBar = [[WGNavigationBarNew alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem* backTo = [WGBarButtonItem barButtonItemWithImage:[UIImage imageNamed:@"feedback_back"] hightedImage:nil target:self selector:@selector(backToFeedBack)];
    navBar.titleLabel.text = NSLocalizedString(@"History", nil);  //设置标题
    navBar.barItem.leftBarButtonItem = backTo;
    [self.view addSubview:navBar];
    [navBar release];
    
    UITableView *mytable = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, endX, endY-50) style:UITableViewStylePlain];
    mytable.delegate = self;
    mytable.dataSource = self;
    [self.view addSubview:mytable];
    [mytable release];
    
}

- (void)backToFeedBack
{
 //   [self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    WGFeedBackCell *cell = (WGFeedBackCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[[WGFeedBackCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSDictionary* temp = [array objectAtIndex:indexPath.row];
    cell.titleStr = NSLocalizedString(@"Your FeedBack",nil);
    cell.timeStr = [temp objectForKey:@"feedback_time"];
    cell.detailStr = [temp objectForKey:@"account_feedback"];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

//- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}
/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
