//
//  WGDetailViewController.h
//  WizGroup
//
//  Created by wiz on 12-9-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <string>
#import "WizModuleTransfer.h"
@interface WGDetailViewController : UITableViewController
@property (nonatomic, assign) WizModule::WIZGROUPDATA groupData;
@end
