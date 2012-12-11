//
//  WGDetailViewController.h
//  WizGroup
//
//  Created by wiz on 12-9-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <string>
@interface WGDetailViewController : UITableViewController
@property (nonatomic, assign) std::string kbGuid;
@property (nonatomic, assign) std::string accountUserId;

@end
