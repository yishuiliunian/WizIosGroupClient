//
//  WizAccountManager.h
//  Wiz
//
//  Created by 朝 董 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define WGDefaultAccountUserId      getDefaultAccountUserId()
#define WGDefaultAccountPassword    getDefaultAccountPassword()

NSString* getDefaultAccountPassword();
NSString* getDefaultAccountUserId();

@class WizAccount;
@class WizGroup;
@interface WizAccountManager : NSObject
+ (WizAccountManager *) defaultManager;
- (NSArray*)            allAccountUserIds;
- (BOOL)                canFindAccount: (NSString*)userId;
- (NSString*)           accountPasswordByUserId:(NSString *)userID;
//
- (BOOL)                registerActiveAccount:(NSString*)userId;
- (void)                resignAccount;
- (NSString*)           activeAccountUserId;
- (void)                updateAccount:(NSString*)userId password:(NSString*)passwrod;
- (void)                removeAccount: (NSString*)userId;
//
- (BOOL)                registerActiveGroup:(NSString*)groupGuid;
- (void)                resignActiveGroup;
- (NSString*)           activeGroupGuid;
//
- (NSArray*)    groupsForAccount:(NSString*)accountUserId;
- (WizGroup*) groupForKbguid:(NSString*)kbguid accountUserId:(NSString*)userId;
@end
