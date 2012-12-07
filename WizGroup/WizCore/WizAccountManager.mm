//
//  WizAccountManager.m
//  Wiz
//
//  Created by 朝 董 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAccountManager.h"
#import "WizAccount.h"

#import "WizFileManager.h"
#import "WizGlobalData.h"
#import "WizModuleTransfer.h"
#import "WizSyncCenter.h"

#define KeyOfAccounts               @"accounts"
#define KeyOfUserId                 @"userId"
#define KeyOfPassword               @"password"
#define KeyOfDefaultUserId          @"defaultUserId"
#define KeyOfProtectPassword        @"protectPassword"
#define KeyOfKbguids                @"KeyOfKbguids"
#import "WizNotificationCenter.h"

//
#define WGDefaultChineseUserName    @"groupdemo@wiz.cn"
#define WGDefaultChinesePassword    @"kk0x5yaxt1ey6v4n"

//
#define WGDefaultEnglishUserName    @"groupdemo@wiz.cn"
#define WGDefaultEnglishPassword    @"kk0x5yaxt1ey6v4n"
NSString* getDefaultAccountUserId()
{
    if ([WizGlobals isChineseEnviroment]) {
        return WGDefaultChineseUserName;
    }
    else
    {
        return WGDefaultEnglishUserName;
    }
}

NSString* getDefaultAccountPassword()
{
    if ([WizGlobals isChineseEnviroment]) {
        return WGDefaultChinesePassword;
    }
    else
    {
        return WGDefaultEnglishPassword;
    }
}


//
@interface WizAccountManager()



@end

static NSString* const WizSettingsAccounts = @"WizSettingsAccounts";
//
static NSString* const WizSettingsAccountUserId = @"WizSettingsAccountUserId";
static NSString* const WizSettingsAccountPassword = @"WizSettingsAccountPassword";
//
static NSString* const WizSettingsAccountGroups = @"WizSettingsAccountGroups";
static NSString* const WizSettingsActiveAccountUserId = @"WizSettingsActiveAccountUserId";
//
@implementation WizAccountManager

- (NSInteger) indexOfAccount:(NSString*)userId inArray:(NSArray*)array
{
    int index = NSNotFound;
    for (int i = 0; i  < [array  count]; i++) {
        NSDictionary* account = [array objectAtIndex:i];
        NSString* userIdExist = [account objectForKey:WizSettingsAccountUserId];
        if ([userIdExist isEqualToString:userId]) {
            index = i;
            break;
        }
    }
    return index;
}
- (void) updateAccounts:(NSArray*)accounts
{
    [[NSUserDefaults standardUserDefaults] setObject:accounts forKey:WizSettingsAccounts];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (NSArray*) accountsArray
{
    @synchronized(self)
    {
        NSArray* array = [[NSUserDefaults standardUserDefaults] arrayForKey:WizSettingsAccounts];
        if (array == nil) {
            array = [NSArray array];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:WizSettingsAccounts];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        return array;
    }
}

- (NSString*) accountPasswordByUserId:(NSString *)userID
{
    userID = [userID lowercaseString];
    NSArray* array = [self accountsArray];
    NSInteger index = [self indexOfAccount:userID inArray:array];
    if (index != NSNotFound) {
        NSDictionary* dic = [array objectAtIndex:index];
        return [dic objectForKey:WizSettingsAccountPassword];
    }
    return nil;
}

- (std::string) CAccountPasswordByUserId:(const std::string&)userID
{
    return WizNSStringToStdString([self accountPasswordByUserId:WizStdStringToNSString(userID)]);
}
- (void) updateAccount:(NSString *)userId password:(NSString *)passwrod
{
    userId = [userId lowercaseString];
    passwrod = [WizGlobals ensurePasswordIsEncrypt:passwrod];
    NSMutableArray* accountArray = [NSMutableArray arrayWithArray:[self accountsArray]];
    NSInteger index = [self indexOfAccount:userId inArray:accountArray];
    //
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:userId forKey:WizSettingsAccountUserId];
    [dic setObject:passwrod forKey:WizSettingsAccountPassword];
    if (index == NSNotFound) {
        [accountArray addObject:dic];
    }
    else
    {
        [accountArray replaceObjectAtIndex:index withObject:dic];
    }
    [self updateAccounts:accountArray];
}
//
- (WizModule::CWizGroupArray) groupsForAccount:(NSString*)accountUserId
{
    accountUserId = [accountUserId lowercaseString];
    NSArray* array = [[NSUserDefaults standardUserDefaults] arrayForKey:accountUserId];
    if (array == nil) {
        array = [NSArray array];
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:accountUserId];
    }
    WizModule::CWizGroupArray groupsArray;
    for (NSDictionary* each  in array) {
        WizModule::WIZGROUPDATA data;
        data.fromWizServerObject(each);
        groupsArray.push_back(data);
    }
    return groupsArray;
}
- (void) updateGroupsArray:(NSArray*)array  forAccount:(NSString*)userId
{
    userId = [userId lowercaseString];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:userId];
}
- (void) updateGroup:(WizModule::CWizGroupArray&)groups forAccount:(NSString*)userId
{
    NSMutableArray* groupsArray = [NSMutableArray array];
    for (WizModule::CWizGroupArray::iterator itor = groups.begin(); itor != groups.end(); itor++) {
        NSDictionary* dic = itor->toWizObjcModule();
        [groupsArray addObject:dic];
    }
    [self updateGroupsArray:groupsArray forAccount:userId];
}
- (id) init
{
    self = [super init];
    if (self) {
        [self updateAccount:WGDefaultChineseUserName password:WGDefaultChinesePassword];
        [self updateAccount:WGDefaultEnglishUserName password:WGDefaultEnglishPassword];
    }
    return self;
}
+ (id) defaultManager;
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizAccountManager class]];
    }
}
- (void) updateActiveAccontUserId:(NSString*)userId
{
    userId = [userId lowercaseString];
    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:WizSettingsActiveAccountUserId];
}

- (NSString*) activeAccountUserId
{
    NSString* activeUserId = [[NSUserDefaults standardUserDefaults] stringForKey:WizSettingsActiveAccountUserId];
    if (activeUserId == nil) {
        return WGDefaultAccountUserId;
    }
    return activeUserId;
}
- (void) registerActiveAccount:(NSString *)userId
{
    [self updateActiveAccontUserId:userId];
    [WizSyncCenter syncAccount:userId password:[self accountPasswordByUserId:userId]];
}
@end
