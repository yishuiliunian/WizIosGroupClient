//
//  WizFileManger.m
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizFileManager.h"
#import "ZipArchive.h"
#import "WizAccountManager.h"

#define ATTACHMENTTEMPFLITER @"attchmentTempFliter"
#define EditTempDirectory   @"EditTempDirectory"

@implementation WizFileManager
//singleton

+ (id) shareManager;
{
    static WizFileManager* shareManager = nil;
    @synchronized(self)
    {
        if (shareManager == nil) {
            shareManager = [[super allocWithZone:NULL] init];
        }
        return shareManager;
    }
}
+ (id) allocWithZone:(NSZone *)zone
{
    return [[self shareManager] retain];
}
- (id) retain
{
    return self;
}
- (NSUInteger) retainCount
{
    return NSUIntegerMax;
}
- (id) copyWithZone:(NSZone*)zone
{
    return self;
}
- (id) autorelease
{
    return self;
}
- (oneway void) release
{
    return;
}

//
+(NSString*) documentsPath
{
    static NSString* documentDirectory= nil;
    if (nil == documentDirectory) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentDirectory = [[paths objectAtIndex:0] retain];
    }
	return documentDirectory;
}

+ (NSString*) logFilePath
{
    static NSString* logFilePath = nil;
    if (logFilePath == nil) {
        logFilePath = [[[WizFileManager documentsPath] stringByAppendingPathComponent:@"log.txt"] retain];
    }
    return logFilePath;
}
-(BOOL) ensurePathExists:(NSString*)path
{
	BOOL b = YES;
    if (![self fileExistsAtPath:path])
	{
		NSError* err = nil;
		b = [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
		if (!b)
		{
			[WizGlobals reportError:err];
		}
	}
	return b;
}
- (BOOL) ensureFileExists:(NSString*)path
{
    if (![self fileExistsAtPath:path]) {
        return [self createFileAtPath:path contents:nil attributes:nil];
    }
    return YES;
}
- (NSString*) accountPathFor:(NSString*)accountUserId
{
    NSString* documentPath = [WizFileManager documentsPath];
    NSString* accountPath = [documentPath stringByAppendingPathComponent:accountUserId];
    [self ensurePathExists:accountPath];
    return accountPath;
}




- (NSString*) abstractDataBatabasePath:(NSString*)accountUserId
{
    NSString* accountPath = [self accountPathFor:accountUserId];
    return [accountPath stringByAppendingPathComponent:@"tempAbs.db"];
}

- (NSString*) wizObjectFilePath:(NSString *)objectGuid accountUserId:(NSString *)accountUserId
{
    NSString* accountPath = [self accountPathFor:accountUserId];
	NSString* subName = [NSString stringWithFormat:@"%@", objectGuid];
	NSString* path = [accountPath stringByAppendingPathComponent:subName];
    [self ensurePathExists:path];
	return path;
}

- (NSString*) downloadObjectTempFilePath:(NSString*)objGuid accountUserId:(NSString *)userId
{
    NSString* objectPath = [self wizObjectFilePath:objGuid accountUserId:userId];
    return [objectPath stringByAppendingPathComponent:@"temp.zip"];
}
//

-(BOOL) deleteFile:(NSString*)fileName
{
	NSError* err = nil;
	BOOL b = [self removeItemAtPath:fileName error:&err];
	if (!b && err)
	{
		[WizGlobals reportError:err];
	}
	//
	return b;
}

- (BOOL) unzipWizObjectData:(NSString *)ziwFilePath toPath:(NSString *)aimPath
{
    NSError* error = nil;
    NSArray* contents = [self contentsOfDirectoryAtPath:aimPath error:&error];
    for (NSString* each in contents) {
        NSString* contentPath = [aimPath stringByAppendingPathComponent:each];
        if ([contentPath isEqualToString:ziwFilePath]) {
            continue;
        }
        if ([[[each fileType] lowercaseString] isEqualToString:@"zip"]) {
            continue;
        }
        [self removeItemAtPath:contentPath error:&error];
    }
    
    ZipArchive* zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:ziwFilePath];
    BOOL zipResult = [zip UnzipFileTo:aimPath overWrite:YES];
    [zip UnzipCloseFile];
    [zip release];
    if (!zipResult) {
        if ([WizGlobals checkFileIsEncry:ziwFilePath]) {
            return YES;
        }
        else {
            [self deleteFile:ziwFilePath];
            return NO;
        }
    }
    else {
        [self deleteFile:ziwFilePath];
        return YES;
    }
    return YES;

}

-(BOOL) addToZipFile:(NSString*) directory directoryName:(NSString*)name zipFile:(ZipArchive*) zip
{
    NSArray* selectedFile = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    
    for(NSString* each in selectedFile) {
        BOOL isDir;
        NSString* path = [directory stringByAppendingPathComponent:each];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)
        {
            [self addToZipFile:path directoryName:[NSString stringWithFormat:@"%@/%@",name,each] zipFile:zip];
        }
        else
        {
            if(![zip addFileToZip:path newname:[NSString stringWithFormat:@"%@/%@",name,each]]) 
            {
                return NO;
            }
        }
    }
    return YES;
}
-(NSString*) createZipByPath:(NSString *)objectPath
{
    NSArray* selectedFile = [self contentsOfDirectoryAtPath:objectPath error:nil];
    NSString* zipPath = [objectPath stringByAppendingPathComponent:@"temppp.ziw"];
    ZipArchive* zip = [[ZipArchive alloc] init];
    BOOL ret;
    ret = [zip CreateZipFile2:zipPath];
    for(NSString* each in selectedFile) {
        BOOL isDir;
        NSString* path = [objectPath stringByAppendingPathComponent:each];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)
        {
            [self addToZipFile:path directoryName:each zipFile:zip];
        }
        else
        {
            ret = [zip addFileToZip:path newname:each];
        }
    }
    
    [zip CloseZipFile2];
    if(!ret) zipPath =nil;
    [zip release];
    return zipPath;
}
- (NSString*) uploadTempFile:(NSString*)objGuid accountUserId:(NSString*)userId
{
    NSString* objectPath = [self wizObjectFilePath:objGuid accountUserId:userId];
    return [objectPath stringByAppendingPathComponent:@"temppp.ziw"];
}

- (long long) fileSizeAtPath:(NSString*) filePath{
    if ([self fileExistsAtPath:filePath]){
        return [[self attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
- (long long) folderTotalSizeAtPath:(NSString*) folderPath{
    if (![self fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[self subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        if ([fileName isEqualToString:@"index.db"]) {
            continue;
        }
        if ([fileName isEqualToString:@"tempAbs.db"]) {
            continue;
        }
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
        }
    return folderSize;
}
- (NSString*) getDocumentFilePath:(NSString *)documentFileName documentGUID:(NSString *)documentGuid accountUserId:(NSString *)accountUserId
{
    NSString* objectPath = [self wizObjectFilePath:documentGuid accountUserId:accountUserId];
    return [objectPath stringByAppendingPathComponent:documentFileName];
}

- (NSString*) documentIndexFilesPath:(NSString *)documentGUID accountUserId:(NSString *)accountUserId
{
    NSString* objectPath = [self wizObjectFilePath:documentGUID accountUserId:accountUserId];
    return [objectPath stringByAppendingPathComponent:@"index_files"];
}

- (NSInteger) accountCacheSize:(NSString *)accountUserId
{
    NSString* accountPath = [self accountPathFor:accountUserId];
    return [self folderTotalSizeAtPath:accountPath];
}
//
- (NSString*) settingDataBasePath
{
    NSString* path = [WizFileManager documentsPath];
    return [path stringByAppendingPathComponent:@"settings.db"];
}

- (NSString*) cacheDbPath
{
    NSString* path = [WizFileManager documentsPath];
    return [path stringByAppendingPathComponent:@"cache.db"];
}
- (NSString*) metaDataBasePathForAccount:(NSString *)accountUserId kbGuid:(NSString *)kbGuid
{
    NSString* accountPath = [self accountPathFor:accountUserId];
    return [accountPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",kbGuid]];
}

- (NSString*) tempDataBatabasePath:(NSString *)accountUserId
{
    NSString* accountPath = [self accountPathFor:accountUserId];
    return [accountPath stringByAppendingPathComponent:@"abstract.db"];
}

- (NSString*) attachmentFilePath:(NSString *)attachmentGuid accountUserId:(NSString *)accountUserId
{
    NSString* objectPath = [self wizObjectFilePath:attachmentGuid accountUserId:accountUserId];
    NSArray* content  = [self contentsOfDirectoryAtPath:objectPath error:nil];
    if (content) {
        NSString* fileName = [content lastObject];
        return [objectPath stringByAppendingPathComponent:fileName];
    }
    return nil;
}
@end
