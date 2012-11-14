//
//  WizDownloadObject.m
//  WizCoreFunc
//
//  Created by wiz on 12-9-26.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizDownloadObject.h"
#import "WizFileManager.h"

#define WizDownloadPartSize     262114

@implementation WizDownloadObject
@synthesize downloadObject;
@synthesize delegate;
- (void) dealloc
{
    delegate = nil;
    [downloadObject release];
    [super dealloc];
}

- (void) prepareDownloadEnviroment
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    
    NSString* downloadTempFile = [fileManager downloadObjectTempFilePath:downloadObject.strGuid accountUserId:self.accountUserId];
    if ([fileManager fileExistsAtPath:downloadTempFile]) {
        [fileManager deleteFile:downloadTempFile];
    }
    if (![fileManager createFileAtPath:downloadTempFile contents:nil attributes:nil]) {
        
    }
}

- (NSFileHandle*) downloadTempFileHandle
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSString* downloadTempFile = [fileManager downloadObjectTempFilePath:downloadObject.strGuid accountUserId:self.accountUserId];
    return [NSFileHandle fileHandleForWritingAtPath:downloadTempFile];
}

- (void) downloadNextPart
{
    NSFileHandle* downloadFileHandle = [self downloadTempFileHandle];
    
    int64_t currentPos = [downloadFileHandle seekToEndOfFile];
    
    [downloadFileHandle closeFile];
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];

    [postParams setObject:downloadObject.strGuid forKey:@"obj_guid"];
    [postParams setObject:[downloadObject wizObjectType] forKey:@"obj_type"];
    [postParams setObject:[NSNumber numberWithInt:currentPos] forKey:@"start_pos"];
    [postParams setObject:[NSNumber numberWithInt:WizDownloadPartSize] forKey:@"part_size"];
    [self executeXmlRpcWithArgs:postParams methodKey:SyncMethod_DownloadObject needToken:YES];
}

- (BOOL) start
{
    if (![super start]) {
        return NO;
    }
    //
    [self prepareDownloadEnviroment];
    [self downloadNextPart];
    return YES;
}

- (void) onDownloadFaild
{
    [self.delegate didDownloadObjectFaild:downloadObject];
    [self changeStatue:WizApistatueError];
    [super end];
}

- (void) onDownloadSucceed
{
    id<WizMetaDataBaseDelegate> db = [self groupDataBase];
    if ([[downloadObject wizObjectType] isEqualToString:WizDocumentKeyString]) {
        [db setDocumentServerChanged:downloadObject.strGuid changed:NO];
        WizDocument* document = (WizDocument*)downloadObject;
        document.bServerChanged = NO;
    }
    else if ([[downloadObject wizObjectType] isEqualToString:WizAttachmentKeyString])
    {
        [db setAttachmentServerChanged:downloadObject.strGuid changed:NO];
        WizAttachment* attachment = (WizAttachment*) downloadObject;
        attachment.bServerChanged = NO;
    }
    
    [self.delegate didDownloadObjectSucceed:downloadObject];
    self.downloadObject = nil;
    [super end];
}

- (void) onDownloadObject:(id)ret
{
    NSDictionary* obj = ret;
    NSData* data = [obj valueForKey:@"data"];
    NSNumber* eofPre = [obj valueForKey:@"eof"];
    BOOL eof = [eofPre intValue]? YES:NO;
    NSString* serverMd5 = [obj valueForKey:@"part_md5"];
    NSString* localMd5 = [WizGlobals md5:data];
    BOOL succeed = [serverMd5 isEqualToString:localMd5]?YES:NO;
    if(!succeed) {
        if (attemptTime < WizApiAttemptTimeMax) {
            [self downloadNextPart];
        }
        else
        {
            [self onDownloadFaild];
        }
    }
    else
    {
        NSFileHandle* downloadFileHandle = [self downloadTempFileHandle];
        [downloadFileHandle seekToEndOfFile];
        [downloadFileHandle writeData:data];
        
        
        [downloadFileHandle closeFile];
        if (!eof) {
            [self downloadNextPart];
        }
        else {
            
            WizFileManager* fileManager = [WizFileManager shareManager];
            
            NSString* downloadTempFile = [fileManager downloadObjectTempFilePath:downloadObject.strGuid accountUserId:self.accountUserId];
            
            NSString* objectFilePath = [fileManager wizObjectFilePath:downloadObject.strGuid accountUserId:self.accountUserId];
            
            if (![fileManager unzipWizObjectData:downloadTempFile toPath:objectFilePath]) {
                [self onDownloadFaild];
            }
            else
            {
                [self onDownloadSucceed];
            }
            
        }
        
        
    }
}

- (void) xmlrpcDoneSucced:(id)retObject forMethod:(NSString *)method
{
    if ([method isEqualToString:SyncMethod_DownloadObject]) {
        [self onDownloadObject:retObject];
    }
    else
    {
        [self end];
    }
}
- (void) onError:(NSError *)error
{
    if (error.code == -101 && [error.domain isEqualToString:@"GDataParaseErrorDomain"]) {
        [self  onDownloadFaild];
    }
    else
    {
        [super onError:error];
    }
}

- (NSString*) apiStatueKey
{
    return [NSString stringWithFormat:@"%@%@%@",self.downloadObject.strGuid,self.kbGuid,self.accountUserId];
}
@end
