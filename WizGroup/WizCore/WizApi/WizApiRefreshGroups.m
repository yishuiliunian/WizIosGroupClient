//
//  WizApiRefreshGroups.m
//  WizCore
//
//  Created by wiz on 12-9-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizApiRefreshGroups.h"
#import "WizDbManager.h"
#import "WizAccountManager.h"
#import "WizSyncDataCenter.h"

@implementation WizApiRefreshGroups
@synthesize delegate;

- (void) dealloc
{
    delegate = nil;
    [super dealloc];
}

- (BOOL) start
{
    if ([super start]) {
        [self executeXmlRpcWithArgs:[NSMutableDictionary dictionary] methodKey:SyncMethod_GetGropKbGuids needToken:YES];
        return YES;
    }
    return NO;
}

- (void) onGetGroupList:(id)retObject
{
    id<WizSettingsDbDelegate> settingDb =  [[WizDbManager shareInstance] getGlobalSettingDb];
    //
    if ([retObject isKindOfClass:[NSArray class]]) {
        for (NSDictionary* group in retObject) {
            NSString* kguid = [group objectForKey:@"kb_guid"];
            NSString* kapi_url = [group objectForKey:@"kapi_url"];
            if (kapi_url) {
                [[WizSyncDataCenter shareInstance] refreshApiurl:[NSURL URLWithString:kapi_url] kbguid:kguid];
            }
        }
    }
    [settingDb updateGroups:retObject accountUserId:self.accountUserId];
    
    [self.delegate didRefreshGroupsSucceed];
    [super end];
}

- (void) xmlrpcDoneSucced:(id)retObject forMethod:(NSString *)method
{
    if([method isEqualToString:SyncMethod_GetGropKbGuids])
    {
        [self onGetGroupList:retObject];
    }
}

- (NSString*) apiStatueKey
{
    return [NSString stringWithFormat:@"%@%@",self.kbGuid,self.accountUserId];
}
@end
