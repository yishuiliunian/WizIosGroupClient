//
//  WizGlobalData.m
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-13.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizGlobalData.h"
#import "WizAccountManager.h"
#import "WizFileManager.h"

NSString* const WizSingletonAccountManager  = @"WizSingletonAccountManager";
NSString* const WizSingletonFileManager     = @"WizSingletonFileManager";
NSString* const WizSingletonSyncCenter      = @"WizSingletonSyncCenter";
NSString* const WizSingletonSyncDataCenter  = @"WizSingletonSyncDataCenter";
NSString* const WizSingletonErrorCenter     = @"WizSingletonErrorCenter";
@interface WizGlobalData ()
{
   NSMutableDictionary* data; 
}
@end

@implementation WizGlobalData
- (void) dealloc
{
    [data release];
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        data = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (id) globalData;
{
    static WizGlobalData* globalData = nil;
    @synchronized(self)
    {
        if (globalData == nil) {
            globalData = [[super allocWithZone:NULL] init];
        }
        return globalData;
    }
}
+ (id) allocWithZone:(NSZone *)zone
{
    return [[self globalData] retain];
}
- (id) retain
{
    return self;
}
- (NSUInteger) retainCount
{
    return NSUIntegerMax;
}
- (id) copyWithZone:(NSZone*)zone
{
    return self;
}
- (id) autorelease
{
    return self;
}
- (oneway void) release
{
    return;
}
//over singlong

- (void) setShareData:(id)shareData  forKey:(NSString*)key
{
    @synchronized(self)
    {
        if (shareData == nil) {
            return;
        }
        [data setObject:shareData forKey:key];
    }
}

- (id) shareDataForKey:(NSString*)key
{
    @synchronized(self)
    {
        return [data objectForKey:key];
    }
}

+ (id) shareInstanceFor:(Class)aclass
{
    NSString* className = [NSString stringWithFormat:@"%@",aclass];
    id shareData = [[WizGlobalData globalData] shareDataForKey:className];
    if (shareData == nil) {
        shareData = [[NSClassFromString(className) alloc] init];
        [[WizGlobalData globalData] setShareData:shareData forKey:className];
    }
    return shareData;
}

+ (id) shareInstanceFor:(Class)aclass category:(NSString *)key
{
    NSString* className = [NSString stringWithFormat:@"%@",aclass];
    NSString* classKey = [NSString stringWithFormat:@"%@-%@",aclass,key];
    id shareData = [[WizGlobalData globalData] shareDataForKey:classKey];
    if (shareData == nil) {
        shareData = [[NSClassFromString(className) alloc] init];
        [[WizGlobalData globalData] setShareData:shareData forKey:classKey];
    }
    return shareData;
}
@end
