//
//  WizGlobalCache.m
//  WizCoreFunc
//
//  Created by dzpqzb on 12-12-4.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizGlobalCache.h"
#import "WizAbstract.h"
#import "WizGlobalData.h"

#import "WizSyncQueque.h"
#import "WizFileManager.h"
#import "WizCacheDb.h"


using namespace WizModule;
@interface WizGlobalCacheGenDocumentAbstractThread : NSThread

@end

@implementation WizGlobalCacheGenDocumentAbstractThread
- (BOOL) generateAbstractForDocument:(NSString*)documengGuid    accountUserId:(NSString*)accountUserId
{
    std::string dbPath = CWizFileManager::shareInstance()->cacheDatabasePath();
    
    WizCacheDb cacheDb(dbPath.c_str());
    WIZABSTRACT cAbstract;
    if (cacheDb.abstractFromGuid(WizNSStringToCString(documengGuid), cAbstract)) {
        [[WizGlobalCache shareInstance] setAbstract:cAbstract forKey:documengGuid];
        return YES;
    }
    if (![[WizFileManager shareManager] prepareReadingEnviroment:documengGuid accountUserId:accountUserId]) {
        return NO;
    }
    NSString* sourceFilePath = [[WizFileManager shareManager] getDocumentFilePath:DocumentFileIndexName documentGUID:documengGuid];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath]) {
        return NO;
    }
    NSString* abstractText = nil;
    if ([WizGlobals fileLength:sourceFilePath] < 1024*1024) {
        
        NSString* sourceStr = [NSString stringWithContentsOfFile:sourceFilePath
                                                    usedEncoding:nil
                                                           error:nil];
        if (sourceStr.length > 1024*50) {
            sourceStr = [sourceStr substringToIndex:1024*50];
        }
        NSString* destStr = [sourceStr htmlToText:200];
        destStr = [destStr stringReplaceUseRegular:@"&(.*?);|\\s|/\n" withString:@""];
        if (destStr == nil || [destStr isEqualToString:@""]) {
            destStr = @"";
        }
        if (WizDeviceIsPad) {
            NSRange range = NSMakeRange(0, 100);
            if (destStr.length <= 100) {
                range = NSMakeRange(0, destStr.length);
            }
            abstractText = [destStr substringWithRange:range];
        }
        else
        {
            NSRange range = NSMakeRange(0, 70);
            if (destStr.length <= 70) {
                range = NSMakeRange(0, destStr.length);
            }
            abstractText = [destStr substringWithRange:range];
        }
    }
    else
    {
        NSLog(@"the file name is %@",sourceFilePath);
    }
    
    
    NSString* sourceImagePath = [[WizFileManager shareManager] documentIndexFilesPath:documengGuid];
    NSArray* imageFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourceImagePath  error:nil];
    
    NSString* maxImageFilePath = nil;
    int maxImageSize = 0;
    for (NSString* each in imageFiles) {
        NSArray* typeArry = [each componentsSeparatedByString:@"."];
        if ([WizGlobals checkAttachmentTypeIsImage:[typeArry lastObject]]) {
            NSString* sourceImageFilePath = [sourceImagePath stringByAppendingPathComponent:each];
            int fileSize = [WizGlobals fileLength:sourceFilePath];
            if (fileSize > maxImageSize && fileSize < 1024*1024) {
                maxImageFilePath = sourceImageFilePath;
            }
        }
    }
    UIImage* compassImage = nil;
    
    //
    if (nil != maxImageFilePath) {
        float compassWidth=140;
        float compassHeight = 140;
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:maxImageFilePath];
        
        if (nil != image)
        {
            if (image.size.height >= compassHeight && image.size.width >= compassWidth) {
                compassImage = [image wizCompressedImageWidth:compassWidth height:compassHeight];
            }
            [image release];
        }
    }
    
    NSData* imageData = nil;
    if (nil != compassImage) {
        imageData = [compassImage compressedData];
    }

    CWizData cimageData;
    cimageData.fromNSData(imageData);

    if (abstractText == nil) {
        abstractText = @"";
    }
    WizModule::WIZABSTRACT abstract;
    abstract.text = WizNSStringToStdString(abstractText);
    abstract.imageData = cimageData;
    abstract.guid = WizNSStringToStdString(documengGuid);
    cacheDb.updateAbstract(abstract);
    [[WizGlobalCache  shareInstance] setAbstract:abstract forKey:documengGuid];
    return true;
}

- (void) main
{
    while (true) {
        WIZDOCUMENTGENERATEABSTRACTDATA data;
        if (g_GetDocumentGenerateAbstractData(data)) {
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

            if ([self generateAbstractForDocument:WizStdStringToNSString(data.guid) accountUserId:WizStdStringToNSString(data.accountUserID)]) {
            }
            g_RemoveDocumentGenerateAbstractData(data);
            [pool drain];

        }
        else
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
    }
}

@end

@implementation WizGlobalCache

- (id) init
{
    self = [super init];
    if (self) {
        WizGlobalCacheGenDocumentAbstractThread* thread = [[[WizGlobalCacheGenDocumentAbstractThread alloc] init] autorelease];
        [thread start];
    }
    return self;
}

+ (id) shareInstance
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizGlobalCache class]];
    }
}
- (void) setAbstract:(WIZABSTRACT&)abstract forKey:(NSString*)key
{
    @synchronized(self)
    {
        WizAbstract* ab = [[WizAbstract alloc] init];
        ab.strText = WizStdStringToNSString(abstract.text);
        ab.uiImage = [UIImage imageWithData:abstract.imageData.toNSData()];
        [self setObject:ab forKey:key];
    }
}
- (WizAbstract*) abstractForDocument:(NSString*)documentguid kbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    WizAbstract* abstract = [self objectForKey:documentguid];
    if (abstract == nil) {
        WIZDOCUMENTGENERATEABSTRACTDATA data;
        data.guid = WizNSStringToStdString(documentguid);
        data.accountUserID = WizNSStringToStdString(accountUserId);
        g_AddDocumentGenerateAbstractData(data);
    }
    return abstract;
}
- (void) removeDocumentAbstractForKey:(NSString*)documentGuid
{
    @synchronized(self)
    {
        std::string dbPath = CWizFileManager::shareInstance()->cacheDatabasePath();
        WizCacheDb cacheDb(dbPath.c_str());
        cacheDb.deleteAbstractByGUID(WizNSStringToCString(documentGuid));
        [self removeObjectForKey:documentGuid];
    }
}
@end
