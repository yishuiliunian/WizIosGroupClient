//
//  WGChooseFolderViewController.h
//  WizGroup
//
//  Created by wiz on 12-11-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WGChooseFolderViewControllerDelegate;
@interface WGChooseFolderViewController : UITableViewController{
    id <WGChooseFolderViewControllerDelegate> delegate;
}
@property (nonatomic, assign) id <WGChooseFolderViewControllerDelegate> delegate;
@property (nonatomic, retain) NSString* kbGuid;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* docGuid;
@property (nonatomic, retain) NSString* listKeyStr;
@property (nonatomic, assign) NSInteger listType;

@end

@protocol WGChooseFolderViewControllerDelegate

- (void) didFinishChoose:(WGChooseFolderViewController*)controller;

@end