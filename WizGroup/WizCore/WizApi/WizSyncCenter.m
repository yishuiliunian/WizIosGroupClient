//
//  WizSyncCenter.m
//  WizCore
//
//  Created by wiz on 12-8-2.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizSyncCenter.h"
#import "WizApiClientLogin.h"
#import "WizApiRefreshGroups.h"
#import "WizAccountManager.h"
#import "WizNotificationCenter.h"
#import "WizGlobalData.h"
#import "WizApiSyncGroupMeta.h"
#import "WizDownloadObject.h"

NSString* const WizNSOpertaionQueueDownload = @"WizNSOpertaionQueueDownload";
NSString* const WizNSOpertaionQueueSyncGroup = @"WizNSOpertaionQueueSyncGroup";
NSString* const WizNSOpertaionQueueUpload = @"WizNSOpertaionQueueUpload";
@implementation NSOperationQueue (WizSync)

+ (NSOperationQueue*)wizDownloadQueue
{
    NSOperationQueue* queue = [WizGlobalData shareInstanceFor:[NSOperationQueue class] category:WizNSOpertaionQueueDownload];
    return queue;
}
+ (NSOperationQueue*) wizUploadQueue
{
    NSOperationQueue* queue = [WizGlobalData shareInstanceFor:[NSOperationQueue class] category:WizNSOpertaionQueueUpload];
    return queue;
}
+ (NSOperationQueue*) wizSyncGroupQueue
{
    NSOperationQueue* queue = [WizGlobalData shareInstanceFor:[NSOperationQueue class] category:WizNSOpertaionQueueSyncGroup];
    
    [queue setMaxConcurrentOperationCount:3];
    return queue;
}

@end

@interface WizApiOpertaion : NSOperation
@property (nonatomic, retain) WizApi* api;
+ (WizApiOpertaion*) wizApiOperation:(WizApi*)api_;
@end

@implementation WizApiOpertaion
@synthesize api;
- (void) dealloc
{
    [api release];
    api = nil;
    [super dealloc];
}
- (void) main
{
    if (self.api) {
        [self.api start];
        while (self.api.statue != WizApiStatueNormal) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

+ (WizApiOpertaion*) wizApiOperation:(WizApi*)api_
{
    WizApiOpertaion* operation = [[WizApiOpertaion alloc] init];
    operation.api = api_;
    return [operation autorelease];
}
@end


typedef enum WizGroupSyncStatue_
{
    WizGroupSyncStatueNormal = 0,
    WizGroupSyncStatueSycning = 1
}WizGroupSyncStatue;

@interface WizSyncCenter () <WizApiLoginDelegate, WizApiRefreshGroupsDelegate,WizApiDelegate,WizApiDownloadObjectDelegate>
{
    NSMutableDictionary* syncToolDictionay;
    //
    NSOperationQueue*  apiWorkingQueue;
    NSOperationQueue* downloadApiWorkingQueue;
}
@property (nonatomic, retain) WizApiRefreshGroups* refreshGroupsTool;
@property (nonatomic, retain) WizApiClientLogin* loginTool;
@property (atomic, retain)     NSMutableDictionary* syncStatueDic;
@property (atomic, retain)      NSMutableDictionary* downloadObjectCacheDic;
@end

@implementation WizSyncCenter
@synthesize refreshGroupsTool;
@synthesize loginTool;
@synthesize syncStatueDic;
@synthesize downloadObjectCacheDic;
- (void) dealloc
{
    [downloadObjectCacheDic release];
    [downloadApiWorkingQueue release];
    [syncStatueDic release];
    [syncToolDictionay release];
    [loginTool release];
    [refreshGroupsTool release];
    [apiWorkingQueue release];
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        syncToolDictionay = [[NSMutableDictionary alloc] init];
        syncStatueDic = [[NSMutableDictionary alloc] init];
        //
        apiWorkingQueue = [[NSOperationQueue alloc] init];
        //
        downloadObjectCacheDic = [[NSMutableDictionary alloc] init];
        downloadApiWorkingQueue = [[NSOperationQueue alloc] init];
        [downloadApiWorkingQueue setMaxConcurrentOperationCount:6];
    }
    return self;
}
+ (WizSyncCenter*) defaultCenter
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizSyncCenter class]];
    }
}

NSString* (^WizSyncStatueGroupKey)(NSString*,NSString*) = ^(NSString* kbguid, NSString* accountUserId)
{
    return [NSString stringWithFormat:@"%@%@syncGroup",accountUserId,kbguid];
};

NSString* (^WizSyncStatueObjecgKey)(NSString*,NSString*,NSString*) = ^(NSString* objguid,NSString* kbguid, NSString* accountUserId )
{
    return [NSString stringWithFormat:@"%@%@%@",accountUserId,kbguid,objguid];
};

- (void) setSync:(NSString*)key statue:(NSInteger)statue
{
    [self.syncStatueDic setObject:[NSNumber numberWithInteger:statue] forKey:key];
}
- (void) didDownloadObjectSucceed:(WizObject *)obj
{
    NSLog(@"obj name is %@",obj.strTitle);
}

- (void) wizApiDidChangedStatue:(WizApiStatue)statue forKey:(NSString *)key
{
    [self setSyncStatue:statue forKey:key];
    NSLog(@"key%@ statue%d ",@"",statue);
}

- (void) wizApiEnd:(WizApi *)api withSatue:(enum WizApiStatue)statue
{
    if ([api isKindOfClass:[WizApiSyncGroupMeta class]]) {
        [self setSyncStatue:WizApiStatueNormal forKey:WizSyncStatueGroupKey(api.kbGuid,api.accountUserId)];
    }
    else if ([api isKindOfClass:[WizDownloadObject class]])
    {
    }
}

- (void) didRefreshGroupsSucceed
{
    [[WizNotificationCenter defaultCenter] postNotificationName:WizNMDidUpdataGroupList object:nil];
    NSString* accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    NSArray* groupsArray = [[WizAccountManager defaultManager] groupsForAccount:accountUserId];
    for (WizGroup* each in groupsArray) {
        [self refreshGroup:each.kbguid accountUserId:each.accountUserId];
    }
}


- (void) didClientLoginFaild:(NSError *)error
{
    [WizGlobals reportError:error];
}

- (void) didClientLoginSucceed:(NSString *)accountUserId retObject:(id)ret
{
    self.refreshGroupsTool = [[[WizApiRefreshGroups alloc] initWithKbguid:nil accountUserId:accountUserId apiDelegate:nil] autorelease];
    self.refreshGroupsTool.delegate = self;
    [self.refreshGroupsTool start];
}

- (BOOL) isRefreshingGrop:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    return NO;
}
- (void) refreshGroup:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    if (![self isRefreshingGrop:kbguid accountUserId:accountUserId]) {
        WizApiSyncGroupMeta* groupSync = [[[WizApiSyncGroupMeta alloc] initWithKbguid:kbguid accountUserId:accountUserId apiDelegate:self] autorelease];
        [WizSyncCenter runWizApi:groupSync inQueue:[NSOperationQueue wizSyncGroupQueue]];
    }
}
- (BOOL) isRefreshingAccount:(NSString *)accountUserId
{
    return NO;
}

- (void) refreshAccount:(NSString *)accountUserId
{
    if (![self isRefreshingAccount:accountUserId]) {
        self.loginTool = [[[WizApiClientLogin alloc] init] autorelease];
        self.loginTool.accountUserId = accountUserId;
        self.loginTool.password = [[WizAccountManager defaultManager] accountPasswordByUserId:accountUserId];
        self.loginTool.delegate = self;
        [self.loginTool start];
    }
}

- (NSString*) downloadQueueKey:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    return [NSString stringWithFormat:@"%@-%@-downloadQueue",accountUserId,kbguid];
}

- (NSArray*) downloadWizObjectQueue:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    NSString* key = [self downloadQueueKey:kbguid accountUserId:accountUserId];
    NSMutableArray* array = [self.syncStatueDic objectForKey:key];
    if (array == nil) {
        array = [NSMutableArray array];
        [self.syncStatueDic setObject:array forKey:key];
    }
    return array;
}

- (void) downloadWizObject:(WizObject *)object
                   kbguid:(NSString *)kbguid
            accountUserId:(NSString *)accountUserId
                 priority:(WizDownloadPriority)priority
{
    WizDownloadObject* downloadTool = [[WizDownloadObject alloc]
                                       initWithKbguid:kbguid
                                       accountUserId:accountUserId
                                       apiDelegate:self];
    downloadTool.downloadObject = object;
    downloadTool.delegate = self;
    WizApiOpertaion* apiOper = [WizApiOpertaion wizApiOperation:downloadTool];
    apiOper.queuePriority = priority;
    apiOper.queuePriority = NSOperationQueuePriorityHigh;
    [WizSyncCenter runWizApi:downloadTool inQueue:[NSOperationQueue wizDownloadQueue]];
    [downloadTool release];
}

- (void) downloadDocument:(WizDocument *)doc
                   kbguid:(NSString *)kbguid
            accountUserId:(NSString *)accountUserId
                 priority:(WizDownloadPriority)priority
{
    [self downloadWizObject:doc kbguid:kbguid accountUserId:accountUserId priority:priority];
}
- (void) downloadAttachment:(WizAttachment*)attach
                     kbguid:(NSString*)kbguid
              accountUserId:(NSString*)accountUserId
                   priority:(WizDownloadPriority)priority
{
    [self downloadWizObject:attach kbguid:kbguid accountUserId:accountUserId priority:priority];
}

- (WizApiStatue) getSyncStatueForKey:(NSString*)key
{
    return [[self.syncStatueDic objectForKey:key] integerValue];
}
- (void) setSyncStatue:(WizApiStatue)statue forKey:(NSString*)key
{
    [self.syncStatueDic setObject:[NSNumber numberWithInteger:statue] forKey:key];
}
+ (NSString*) syncStatueKeyGrop:(NSString *)kbguid accountUserId:(NSString *)accountUserId
{
    return [NSString stringWithFormat:@"syncStatue%@%@",kbguid,accountUserId];
}
+ (void) runWizApi:(WizApi *)api inQueue:(NSOperationQueue *)queue
{
    WizApiOpertaion* op = [WizApiOpertaion wizApiOperation:api];
    [queue addOperation:op];
}
@end
