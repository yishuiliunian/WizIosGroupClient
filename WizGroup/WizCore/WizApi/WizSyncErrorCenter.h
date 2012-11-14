//
//  WizSyncErrorCenter.h
//  WizCore
//
//  Created by wiz on 12-9-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"

enum WizSyncErrorCode {
    WizSyncErrorNullException = 399,
    WizSyncErrorTokenUnactive = 301,
};

@interface WizSyncErrorCenter : NSObject
+ (id) shareInstance;
- (void) willSolveWizApi:(WizApi*)api  onError:(NSError*)error;
@end
