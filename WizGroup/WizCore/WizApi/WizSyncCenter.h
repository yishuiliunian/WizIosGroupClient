//
//  WizSyncCenter.h
//  WizCore
//
//  Created by wiz on 12-8-2.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,WizDownloadPriority)
{
    WizDownloadPriorityLow = NSOperationQueuePriorityNormal,
    WizDownloadPriorityHigh = NSOperationQueuePriorityVeryHigh
};

@interface NSOperationQueue(WizSync)
+ (NSOperationQueue*) wizSyncGroupQueue;
+ (NSOperationQueue*) wizDownloadQueue;
+ (NSOperationQueue*) wizUploadQueue;
@end
@class WizApi;
@interface WizSyncCenter : NSObject

+ (WizSyncCenter*) defaultCenter;
- (void) refreshAccount:(NSString*)accountUserId;
- (void) refreshGroup:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
//
- (void) downloadDocument:(WizDocument *)doc
                   kbguid:(NSString *)kbguid
            accountUserId:(NSString *)accountUserId
                 priority:(WizDownloadPriority)priority;
//
- (void) downloadAttachment:(WizAttachment*)attach
                     kbguid:(NSString*)kbguid
              accountUserId:(NSString*)accountUserId
                   priority:(WizDownloadPriority)priority;
//
- (BOOL) isRefreshingAccount:(NSString*)accountUserId;
- (BOOL) isRefreshingGroup:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
//
+ (void) runWizApi:(WizApi*)api  inQueue:(NSOperationQueue*)queue;
//
- (void) uploadDocument:(WizDocument*)doc kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
@end
