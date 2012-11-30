//
//  WizDbManager.m
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDbManager.h"
#import "WizMetaDataBase.h"
#import "WizSettingsDataBase.h"
#import "WizTempDataBase.h"
//
#import "WizGlobalData.h"

#import "WizFileManager.h"

#define WIZ_ACCOUNTS_SETTINGSFILE   @"WIZ_ACCOUNTS_SETTINGSFILE"
#define PRIMARAY_KEY                @"PRIMARAY_KEY"

@interface WizDbManager()
{
    NSMutableDictionary* dbDataDictionary;
}
@property (atomic, retain) NSMutableDictionary* dbDataDictionary;
@end

@implementation WizDbManager
@synthesize dbDataDictionary;
- (void) dealloc
{
    [dbDataDictionary release];
    [super dealloc];
}
- (void) clearDataBase
{
    
}


- (WizDbManager*) init
{
    self = [super init];
    if (self) {
        dbDataDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}
//Singleton
+ (id) shareInstance
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizDbManager class]];
    }
}




- (NSString*) metaDataBaseKeyForAccount:(NSString *)accountUserId  kbGuid:(NSString*)kbGuid
{
    return [NSString stringWithFormat:@"%@%@-infoDataBase",accountUserId,kbGuid];
}

- (NSString*) abstractBaseKeyString:(NSString*)accountUserId
{
    return [NSString stringWithFormat:@"%@-abstractDataBase",accountUserId];
}

- (id<WizMetaDataBaseDelegate>) getNewMetaDataBase:(NSString*)accountUserId     kbGuid:(NSString *)kbguid
{
    
    NSString* kbDbPath = [[WizFileManager  shareManager] metaDataBasePathForAccount:accountUserId kbGuid:kbguid];
    WizMetaDataBase* dataBase = [[WizMetaDataBase alloc] initWithPath:kbDbPath modelName:@"WizDataBaseModel"];
    dataBase.accountUserId = accountUserId;
    dataBase.kbguid = kbguid;
    NSString* dbKey = [self metaDataBaseKeyForAccount:accountUserId kbGuid:kbguid];
    [self.dbDataDictionary setObject:dataBase forKey:dbKey];
    return [dataBase autorelease];
}

- (id<WizMetaDataBaseDelegate>) getMetaDataBaseForAccount:(NSString *)accountUserId kbGuid:(NSString *)kbGuid
{
    NSString* dbKey = [self metaDataBaseKeyForAccount:accountUserId kbGuid:kbGuid];
    id<WizMetaDataBaseDelegate> dataBase = [self.dbDataDictionary objectForKey:dbKey];
    if (nil == dataBase) {
        dataBase = [self getNewMetaDataBase:accountUserId kbGuid:kbGuid];
    }
    return dataBase;
}


- (void) removeDataBaseForKey:(NSString*)key
{
    id<WizMetaDataBaseDelegate> dataBase = [self.dbDataDictionary objectForKey:key];
    if (nil != dataBase) {
        WizDataBase* metaDb = (WizDataBase*)dataBase;
        [metaDb close];
        [self.dbDataDictionary removeObjectForKey:key];
    }
}

- (void) removeMetaDbForAccount:(NSString *)accountUserId kbGuid:(NSString *)kbGuid
{
    NSString* dbKey = [self metaDataBaseKeyForAccount:accountUserId kbGuid:kbGuid];
    [self removeDataBaseForKey:dbKey];
}

- (id<WizSettingsDbDelegate>) getGlobalSettingDb
{
    NSString* settingDbKey = @"settingDbKey";
    id<WizSettingsDbDelegate> db = [self.dbDataDictionary objectForKey:settingDbKey];
    if (nil == db) {
        NSString* dbPath = [[WizFileManager shareManager] settingDataBasePath];
        WizSettingsDataBase* setDb = [[WizSettingsDataBase alloc] initWithPath:dbPath modelName:@"WizSettingsDataBaseModel"];
        [self.dbDataDictionary setObject:setDb forKey:settingDbKey];
        [setDb release];
        return setDb;
    }
    return db;
}

- (id<WizTemporaryDataBaseDelegate>) getGlobalCacheDb
{
    NSString* cacheDbKey = @"settingDbCache";
    id<WizTemporaryDataBaseDelegate> db = [self.dbDataDictionary objectForKey:cacheDbKey];
    if (nil == db) {
        NSString* dbPath = [[WizFileManager shareManager] cacheDbPath];
        WizTempDataBase* tempDb = [[WizTempDataBase alloc] initWithPath:dbPath modelName:@"WizAbstractDataBaseModel"];
        [self.dbDataDictionary setObject:tempDb forKey:cacheDbKey];
        [tempDb release];
        return tempDb;
    }
    return db;
}

@end
