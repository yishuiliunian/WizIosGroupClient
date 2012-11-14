//
//  WizSyncErrorCenter.m
//  WizCore
//
//  Created by wiz on 12-9-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizSyncErrorCenter.h"
#import "WizApiClientLogin.h"
#import "WizSyncDataCenter.h"
#import "WizAccountManager.h"
#import "WizGlobalData.h"

#define WizErrorQuequeUnactiveToken @"WizErrorQuequeUnactiveToken"
#define WizShowErrorSpaceTime           120

@interface WizSyncErrorCenter () <WizApiLoginDelegate>
@property (atomic, retain) NSMutableDictionary* errorTimeDictionary;
@property (atomic, retain) NSMutableDictionary* syncDataDictionay;
@property (atomic, retain) NSMutableDictionary* errorQuequeDictionary;
@property (nonatomic, retain) WizApiClientLogin* refreshTokenTool;
@end

@implementation WizSyncErrorCenter
@synthesize errorQuequeDictionary;
@synthesize syncDataDictionay;
@synthesize refreshTokenTool;
@synthesize errorTimeDictionary;
- (void) dealloc
{
    [errorTimeDictionary release];
    [refreshTokenTool release];
    [errorQuequeDictionary release];
    [syncDataDictionay release];
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        errorQuequeDictionary = [[NSMutableDictionary alloc] init];
        syncDataDictionay = [[NSMutableDictionary alloc] init];
        errorTimeDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}


+ (id) shareInstance
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizSyncErrorCenter class]];
    }
}



- (NSMutableArray*) errorQuequeFor:(NSString*)errorKey
{
    NSMutableArray* errorQueque = [self.errorQuequeDictionary objectForKey:errorKey];
    if (nil == errorQueque) {
        errorQueque = [NSMutableArray array];
        [self.errorQuequeDictionary setObject:errorQueque forKey:errorKey];
    }
    return errorQueque;
}
- (NSString*) keyForError:(NSError*)error
{
    return [NSString stringWithFormat:@"%@%d",error.domain,error.code];
}

- (NSDate*) lastErrorTimeFor:(NSError*)error
{
    NSString* errorKey = [self keyForError:error];
    NSDate* lastDate = [self.errorTimeDictionary objectForKey:errorKey];
    if (lastDate == nil) {
        return [NSDate date];
    }
    return lastDate;
}

- (void) updateLastErrorTimeFor:(NSError*)error
{
     NSString* errorKey = [self keyForError:error];
    [self.errorTimeDictionary setObject:[NSDate date] forKey:errorKey];
}
- (void) showAlertForError:(NSError*)error
{
    NSDate* now = [NSDate date];
    NSDate* lastDate = [self lastErrorTimeFor:error];
    if ([lastDate timeIntervalSinceDate:now] > WizShowErrorSpaceTime) {
        [WizGlobals reportError:error];
        [self updateLastErrorTimeFor:error];
    }
}

- (void) didClientLoginFaild:(NSError *)error
{
    
}

- (void) didClientLoginSucceed:(NSString *)accountUserId retObject:(id)ret
{
    self.refreshTokenTool = nil;
    //
    NSLog(@"ret %@",ret);
    NSString* apiUrl = [ret objectForKey:@"kapi_url"];
    NSString* token = [ret objectForKey:@"token"];
    
    id<WizSyncShareParamsDelegate> wizSyncCenter = [WizSyncDataCenter shareInstance];
    [wizSyncCenter refreshApiurl:[NSURL URLWithString:apiUrl] kbguid:apiUrl];
    [wizSyncCenter refreshToken:token accountUserId:accountUserId];
    //
    
    NSMutableArray* errorQueque = [self errorQuequeFor:WizErrorQuequeUnactiveToken];
    for (WizApi* api in errorQueque ) {
        if ([api isKindOfClass:[WizApiClientLogin class]]) {
            continue;
        }
        [api start];
    }
    [errorQueque removeAllObjects];
}
- (void) refreshToken
{
    if (self.refreshTokenTool == nil) {
        self.refreshTokenTool = [[[WizApiClientLogin alloc] init] autorelease];
    }
    // is refreshing
    if (self.refreshTokenTool.statue != WizApiStatueNormal) {
        return;
    }
    //
    self.refreshTokenTool.accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    self.refreshTokenTool.password = [[WizAccountManager defaultManager] accountPasswordByUserId:self.refreshTokenTool.accountUserId];
    self.refreshTokenTool.delegate = self;
    [self.refreshTokenTool start];
    
}

- (void) willSolveWizApi:(WizApi *)api onError:(NSError *)error
{
    if (nil == error) {
        [api end];
        return;
    }
    if([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorNotConnectedToInternet)
    {
        [self showAlertForError:error];
        [api end];
    }
    else if ([error.domain isEqualToString:WizErrorDomain] && WizSyncErrorNullException == error.code) {
        NSMutableArray* errorQueque = [self errorQuequeFor:WizErrorQuequeUnactiveToken];
        [errorQueque addObject:api];
        [self refreshToken];
    }
    else if ([error.domain isEqualToString:WizErrorDomain] && WizSyncErrorTokenUnactive == error.code)
    {
        NSMutableArray* errorQueque = [self errorQuequeFor:WizErrorQuequeUnactiveToken];
        [errorQueque addObject:api];
        [self refreshToken];
    }
    else if ([error.domain isEqualToString:NSURLErrorDomain] && NSURLErrorTimedOut == error.code)
    {
        [self showAlertForError:error];
        [api end];
    }
    else
    {
        [self showAlertForError:error];
        [api end];
    }
}
@end
