//
//  WizDbManager.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizMetaDataBaseDelegate.h"
#import "WizSettingsDbDelegate.h"
#import "WizTemporaryDataBaseDelegate.h"

@interface WizDbManager : NSObject
+ (id) shareInstance;
- (id<WizMetaDataBaseDelegate>) getMetaDataBaseForAccount:(NSString*)accountUserId  kbGuid:(NSString*)kbGuid;
- (void) removeMetaDbForAccount:(NSString*)accountUserId  kbGuid:(NSString*)kbGuid;
- (id<WizSettingsDbDelegate>) getGlobalSettingDb;
- (id<WizTemporaryDataBaseDelegate>) getGlobalCacheDb;
@end