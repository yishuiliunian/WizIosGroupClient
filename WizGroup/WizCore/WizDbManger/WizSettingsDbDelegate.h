//
//  WizSettingsDbDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//glocal setttings
#define WizSettingGlobalActiveAccount       @"WizSettingGlobalActiveAccount"
#define WizSettingGlobalActiveGroup         @"WizSettingGlocalActiveGroup"
//

#define WizSettingAccountMyWizEmail         @"WizSettingAccountMyWizEmail"
#define WizSettingAccountUploadSize         @"WizSettingAccountUploadSize"
#define WizSettingAccountUserLevel          @"WizSettingAccountUserLevel"
#define WizSettingAccountUserLevelName      @"WizSettingAccountUserLevelName"
#define WizSettingAccountUserPoints         @"WizSettingAccountUserPoints"
#define WizSettingAccountUserType           @"WizSettingAccountUserType"

#define WizSettingLastUpdateTime            @"WizSettingLastUpdateTime"

@class WizGroup;
@class WizAccount;
@protocol WizSettingsDbDelegate <NSObject>
- (BOOL) updatePrivateGroup:(NSString*)guid accountUserId:(NSString*)userId;
- (BOOL) updateGroups:(NSArray*)groupsData accountUserId:(NSString*)userId;
- (WizGroup*) groupFromGuid:(NSString*)kbguid  accountUserId:(NSString*)userId;
- (NSArray*) groupsByAccountUserId:(NSString*)userId;
- (BOOL) deleteAccountGroups:(NSString*)userId;
- (WizAccount*) accountFromUserId:(NSString*)userId;
- (BOOL) updateAccount:(NSString*)userId password:(NSString *)password;
- (NSArray*) allAccounts;
- (BOOL) deleteAccountByUserId:(NSString*)userId;

//
- (int64_t) int64_tSettingValueForKey:(NSString*)key accountUserId:(NSString*)accountUserId  kbguid:(NSString*)kbguid;
- (BOOL) boolSettingValueForKey:(NSString*)key accountUserId:(NSString*)accountUserId  kbguid:(NSString*)kbguid;
- (NSString*) strSettingValueForKey:(NSString*)key  accountUserId:(NSString*)accountUserId  kbguid:(NSString*)kbguid;
//
- (void) setInt64_tSettingVelue:(int64_t)value      forKey:(NSString*)key accountUserId:(NSString*)accountUserId  kbguid:(NSString*)kbguid;
- (void) setBoolSettingSettingVelue:(BOOL)value  forKey:(NSString*)key accountUserId:(NSString*)accountUserId  kbguid:(NSString*)kbguid;
- (void) setStrSettingSettingVelue:(NSString*)value   forKey:(NSString*)key accountUserId:(NSString*)accountUserId  kbguid:(NSString*)kbguid;

- (NSDate*) lastUpdateTimeForGroup:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
- (void)    setLastUpdateTimeForGroup:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
@end
