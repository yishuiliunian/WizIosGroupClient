//
//  WizFileManger.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <string>
#import "WizStrings.h"
#import "WizLock.h"
#import "WizMisc.h"
#define EditTempDirectory   @"EditTempDirectory"

#define  DocumentFileIndexName  @"index.html"
#define  DocumentFileMobileName  @"wiz_mobile.html"
#define  DocumentFileAbstractName  @"wiz_abstract.html"
#define  DocumentFileFullName  @"wiz_full.html"

using namespace std;


@interface WizFileManager : NSFileManager
+(NSString*) documentsPath;
+ (NSString*) logFilePath;
+ (id) shareManager;
- (NSString*) accountPathFor:(NSString*)accountUserId;
- (NSString*) wizObjectFilePath:(NSString*)objectGuid           accountUserId:(NSString*)accountUserId;
- (NSString*) getDocumentFilePath:(NSString*)documentFileName   documentGUID:(NSString*)documentGuid;
//
- (NSString*) documentIndexFilesPath:(NSString*)documentGUID;
- (long long) folderTotalSizeAtPath:(NSString*) folderPath;
//
- (NSString*) downloadObjectTempFilePath:(NSString*)objGuid accountUserId:(NSString*)userId;
- (BOOL)      unzipWizObjectData:(NSString*)ziwFilePath toPath:(NSString*)aimPath;
- (NSString*) wizLocalObjectFilePath:(NSString*)objguid accountUserId:(NSString*)userId;
//
- (NSString*) uploadTempFile:(NSString*)objGuid accountUserId:(NSString*)userId;
-(NSString*)  createZipByPath:(NSString*)filesPath;
//
- (NSInteger) accountCacheSize:(NSString*)accountUserId;
//
-(BOOL) ensurePathExists:(NSString*)path;
-(BOOL) deleteFile:(NSString*)fileName;
//
- (NSString*) tempDataBatabasePath:(NSString*)accountUserId;
- (NSString*) metaDataBasePathForAccount:(NSString*)accountUserId   kbGuid:(NSString*)kbGuid;
- (NSString*) settingDataBasePath;
//
-  (NSString*) attachmentFilePath:(NSString*)attachmentGuid accountUserId:(NSString*)accountUserId;
- (NSString*) cacheDbPath;

//
- (NSString*) wizTempObjectDirectory:(NSString*)objecguid;
- (BOOL) prepareReadingEnviroment:(NSString*)documentGuid accountUserId:(NSString*)accountUserId;
@end


class CWizFileManager {
    std::string documentsPath;
    std::string cachePath;
private:
    CWizFileManager()
    {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentDirectory = [paths objectAtIndex:0];
        documentsPath = WizNSStringToStdString(documentDirectory);
        NSArray* cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString* cacheDirectory = [cachePaths objectAtIndex:0];
        cachePath = WizNSStringToStdString(cacheDirectory);
    };
    std::string stringByAppendingPathComponent(const std::string parentPath,const std::string pathComponent)
    {
        if (parentPath.size() > 0) {
            
            if (strcmp(&(parentPath[parentPath.length()-1]),"/") == 0) {
                return parentPath+pathComponent;
            }
            else
            {
                return parentPath+"/"+pathComponent ;
            }
        }
        else
        {
            return "";
        }
    }
    bool ensurePathExist(const string& path)
    {
        return [[WizFileManager shareManager] ensurePathExists:WizStdStringToNSString(path)];
    }
public:
    static CWizFileManager* shareInstance()
    {
        static CMutex singlon_mutex;
        static CWizFileManager* shareInstance;
        if (shareInstance == NULL) {
            CWizLock lock(singlon_mutex);
            shareInstance = new CWizFileManager();
        }
        return shareInstance;
    }
    std::string objectPath(const string& guid, const string& accountUserId)
    {
        string path = stringByAppendingPathComponent(accountPath(accountUserId), guid);
        ensurePathExist(path);
        return path;
    };
    std::string accountPath(const string& accountUserId)
    {
        string path = stringByAppendingPathComponent(documentsPath, accountUserId);
        ensurePathExist(path);
        return path;
    };
    std::string metaDatabasePath(const string& kbguid, const string& accountUserId)
    {
        if (IsEmptyString(kbguid.c_str()) || kbguid == WizGlobalPersonalKbguid) {
            return getPersonalDatabasePath(accountUserId);
        }
        return stringByAppendingPathComponent(accountPath(accountUserId), kbguid + ".db");
    }
    std::string getPersonalDatabasePath(const string& accountUserId)
    {
        return stringByAppendingPathComponent(accountPath(accountUserId), "index.db");
    }
    std::string objectFilePath(const string& guid, const string& acountUserId)
    {
        return stringByAppendingPathComponent(objectPath(guid, acountUserId), "temp.ziw");
    }
    std::string cacheDatabasePath()
    {
        return stringByAppendingPathComponent(documentsPath.c_str(), "cache.db");
    }
};