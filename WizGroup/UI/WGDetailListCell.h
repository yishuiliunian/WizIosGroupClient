//
//  WGDetailListCell.h
//  WizGroup
//
//  Created by wiz on 12-10-22.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizModuleTransfer.h"
using namespace WizModule;
@interface WGDetailListCell : UITableViewCell
@property (nonatomic, assign) WIZDOCUMENTDATA doc;
@property (nonatomic, assign) std::string kbguid;
@property (nonatomic, assign) std::string accountUserId;
@end
