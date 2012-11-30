//
//  WizApiRefreshGroups.h
//  WizCore
//
//  Created by wiz on 12-9-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizApi.h"
@protocol WizApiRefreshGroupsDelegate <NSObject>
- (void) didRefreshGroupsSucceed;
@end
@interface WizApiRefreshGroups : WizApi
@property (nonatomic, assign) id<WizApiRefreshGroupsDelegate> delegate;
@end
