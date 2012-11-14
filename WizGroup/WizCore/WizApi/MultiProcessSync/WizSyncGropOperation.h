//
//  WizSyncGropOperation.h
//  WizGroup
//
//  Created by wiz on 12-10-18.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizSyncGropOperation : NSOperation
@property (nonatomic, retain)   NSString* kbguid;
@property (nonatomic, retain)   NSString* accountUserId;
- (id) initWithBbguid:(NSString*)kb accountUserId:(NSString*)userId;
@end
