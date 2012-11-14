//
//  WizApiClientLogin.m
//  WizCore
//
//  Created by wiz on 12-9-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizApiClientLogin.h"
#import "WizSyncDataCenter.h"
#import "WizSyncErrorCenter.h"

@implementation WizApiClientLogin
@synthesize password;
@synthesize delegate;

- (void) dealloc
{
    delegate = nil;
    [password release];
    [super dealloc];
}

- (BOOL) start
{
    if ([super start]) {
        NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
        [postParams setObject:self.accountUserId forKey:@"user_id"];
        [postParams setObject:self.password forKey:@"password"];
        [self executeXmlRpcWithArgs:postParams methodKey:SyncMethod_ClientLogin needToken:NO];
        return YES;
    }
    else
    {
        [self end];
        return NO;
    }
}
- (void) onError:(NSError *)error
{
    [self.delegate didClientLoginFaild:error];
    if ([error.domain isEqualToString:WizErrorDomain] && WizSyncErrorTokenUnactive == error.code) {
        
    }
    else
    {
        [super onError:error];
    }
}

- (void) loginSucceed:(id)ret
{
    NSString* token = [ret objectForKey:@"token"];
    NSString* apiUrl = [ret objectForKey:@"kapi_url"];
    NSString* kbGuid = [ret objectForKey:@"kb_guid"];
    
    WizSyncDataCenter* dataCenter = [WizSyncDataCenter shareInstance];
    [dataCenter refreshApiurl:[NSURL URLWithString:apiUrl] kbguid:kbGuid];
    [dataCenter refreshToken:token accountUserId:self.accountUserId];
    
    id<WizSettingsDbDelegate> setDb = [[WizDbManager shareInstance] getGlobalSettingDb];
    NSString* myWizEmail = [ret objectForKey:@"mywiz_email"];
    NSNumber* uploadSize = [ret objectForKey:@"upload_size_limit"];
    NSString* userLevelName = [ret objectForKey:@"user_level_name"];
    NSNumber* userLevel = [ret objectForKey:@"user_level"];
    NSString* userType = [ret objectForKey:@"user_type"];
    NSNumber* userPoints = [ret objectForKey:@"user_points"];
    
    [setDb setInt64_tSettingVelue:[uploadSize longLongValue] forKey:WizSettingAccountUploadSize accountUserId:self.accountUserId kbguid:nil];
    [setDb setInt64_tSettingVelue:[userLevel longLongValue] forKey:WizSettingAccountUserLevel accountUserId:self.accountUserId kbguid:nil];
    [setDb setInt64_tSettingVelue:[userPoints longLongValue] forKey:WizSettingAccountUserPoints accountUserId:self.accountUserId kbguid:nil];
    [setDb setStrSettingSettingVelue:myWizEmail forKey:WizSettingAccountMyWizEmail accountUserId:self.accountUserId kbguid:nil];
    [setDb setStrSettingSettingVelue:userType forKey:WizSettingAccountUserType accountUserId:self.accountUserId kbguid:nil];
    [setDb setStrSettingSettingVelue:userLevelName forKey:WizSettingAccountUserLevelName accountUserId:self.accountUserId kbguid:nil];
    
    [self.delegate didClientLoginSucceed:self.accountUserId retObject:ret];
    [super end];
}

- (void) xmlrpcDoneSucced:(id)retObject forMethod:(NSString *)method
{
    if ([method isEqualToString:SyncMethod_ClientLogin]) {
        [self loginSucceed:retObject];
    }
    else
    {
        [self end];
    }
}
@end
