//
//  WizFileManger.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define EditTempDirectory   @"EditTempDirectory"

#define  DocumentFileIndexName  @"index.html"
#define  DocumentFileMobileName  @"wiz_mobile.html"
#define  DocumentFileAbstractName  @"wiz_abstract.html"
#define  DocumentFileFullName  @"wiz_full.html"


@interface WizFileManager : NSFileManager
+(NSString*) documentsPath;
+ (NSString*) logFilePath;
+ (id) shareManager;
- (NSString*) accountPathFor:(NSString*)accountUserId;
- (NSString*) wizObjectFilePath:(NSString*)objectGuid           accountUserId:(NSString*)accountUserId;
- (NSString*) getDocumentFilePath:(NSString*)documentFileName   documentGUID:(NSString*)documentGuid    accountUserId:(NSString*)accountUserId;
//
- (NSString*) documentIndexFilesPath:(NSString*)documentGUID    accountUserId:(NSString*)accountUserId;
- (long long) folderTotalSizeAtPath:(NSString*) folderPath;
//
- (NSString*) downloadObjectTempFilePath:(NSString*)objGuid accountUserId:(NSString*)userId;
- (BOOL)      unzipWizObjectData:(NSString*)ziwFilePath toPath:(NSString*)aimPath;
//
- (NSString*) uploadTempFile:(NSString*)objGuid accountUserId:(NSString*)userId;
-(NSString*)  createZipByPath:(NSString*)filesPath;
//
- (NSInteger) accountCacheSize:(NSString*)accountUserId;
//
-(BOOL) ensurePathExists:(NSString*)path;
-(BOOL) ensureFileExists:(NSString*)path;
-(BOOL) deleteFile:(NSString*)fileName;
//
- (NSString*) tempDataBatabasePath:(NSString*)accountUserId;
- (NSString*) metaDataBasePathForAccount:(NSString*)accountUserId   kbGuid:(NSString*)kbGuid;
- (NSString*) settingDataBasePath;
//
-  (NSString*) attachmentFilePath:(NSString*)attachmentGuid accountUserId:(NSString*)accountUserId;
- (NSString*) cacheDbPath;
@end
