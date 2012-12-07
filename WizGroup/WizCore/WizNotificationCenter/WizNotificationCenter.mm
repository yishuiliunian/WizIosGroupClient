//
//  WizNotificationCenter.m
//  WizGroup
//
//  Created by wiz on 12-9-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizNotificationCenter.h"

@implementation WizNotificationCenter
+ (NSString*) getDocumentGuidFromNc:(NSNotification *)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSString* documentGuid = [userInfo objectForKey:WizNMDocumentKeyString];
    return documentGuid;
}

+ (void) addDocumentGuid:(NSString *)guid toUserInfo:(NSMutableDictionary*)userInfo
{
    [userInfo setObject:guid forKey:WizNMDocumentKeyString];
}

+ (NSString*) getGuidFromNc:(NSNotification *)nc
{
    return [[nc userInfo] objectForKey:WizNMGuidKeyString];
}

+ (void) addGuid:(NSString *)guid toUserInfo:(NSMutableDictionary *)userInfo
{
    [userInfo setObject:guid forKey:WizNMGuidKeyString];
}
@end
