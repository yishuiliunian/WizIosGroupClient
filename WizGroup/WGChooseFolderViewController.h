//
//  WGChooseFolderViewController.h
//  WizGroup
//
//  Created by wiz on 12-11-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGChooseFolderViewController : UITableViewController
@property (nonatomic, retain) NSString* kbGuid;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* listKeyStr;
@property (nonatomic, assign) NSInteger listType;

@end
