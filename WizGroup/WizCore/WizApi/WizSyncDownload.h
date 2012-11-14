//
//  WizSyncDownload.h
//  WizCoreFunc
//
//  Created by wiz on 12-9-28.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizSyncDownload : NSObject
@property (nonatomic, retain) NSString* kbguid;
@property (nonatomic, retain) NSString* accountUserId;

- (void) shouldDownload:(WizObject*)obj;
- (void) stopDownload;
@end
