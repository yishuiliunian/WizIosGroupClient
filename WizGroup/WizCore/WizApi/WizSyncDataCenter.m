//
//  WizSyncDataCenter.m
//  WizCore
//
//  Created by wiz on 12-9-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#define WizSyncKbguid @"WizSyncKbguid"

#import "WizSyncDataCenter.h"
#import "WizGlobalData.h"
@interface WizSyncDataCenter()
@property (atomic, retain)    NSMutableDictionary* syncDataDictionary;
@end

@implementation WizSyncDataCenter
@synthesize syncDataDictionary;

-(void) dealloc
{
    [syncDataDictionary release];
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        syncDataDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}
+ (id<WizSyncShareParamsDelegate>) shareInstance;
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizSyncDataCenter class]];
    }
}

- (NSURL*) apiUrlForKbguid:(NSString *)kbguid
{
    static NSURL* serverUrl = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serverUrl = [[NSURL alloc] initWithString:@"http://service.wiz.cn/wizkm/xmlrpc"];
//        serverUrl = [[NSURL alloc] initWithString:@"http://221.194.146.64:8080/wizkm/xmlrpc"];
        
    });
    
    if (nil == kbguid) {
        return serverUrl;
    }
    
    NSURL* apiUrl = [self.syncDataDictionary objectForKey:kbguid];
    if (apiUrl) {
        return apiUrl;
    }
    return serverUrl;
}
- (NSString*) tokenForAccount:(NSString *)userId
{
    return [self.syncDataDictionary objectForKey:userId];
}
- (void) refreshApiurl:(NSURL *)apiUrl kbguid:(NSString *)kbguid
{
    [self.syncDataDictionary setObject:apiUrl forKey:kbguid];
}
- (void) refreshToken:(NSString *)token accountUserId:(NSString *)userId
{
    [self.syncDataDictionary setObject:token forKey:userId];
}

@end
