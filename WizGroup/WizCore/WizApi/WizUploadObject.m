//
//  WizUploadObject.m
//  WizCoreFunc
//
//  Created by wiz on 12-9-26.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

@interface NSMutableDictionary (WizDocument)
- (BOOL) setObjectNotNull:(id)object   forKey:(id)key;
@end
@implementation NSMutableDictionary (WizDocument)
- (BOOL) setObjectNotNull:(id)object   forKey:(id)key
{
    if (object) {
        [self setObject:object forKey:key];
        return YES;
    }
    else {
        return NO;
    }
}

@end

#import "WizFileManager.h"
#import "WizUploadObject.h"

#define WizUploadObjectSize 262114

@interface WizUploadObject ()
@property (nonatomic, retain) NSString* tempFilePath;
@property (nonatomic, retain) NSString* fileMd5;
@property (nonatomic, assign) NSInteger  fileSize;
@property (nonatomic, assign) NSInteger currentSize;
@property (nonatomic, assign) NSInteger uploadingSize;
@property (nonatomic, assign) NSInteger partCount;
@end

@implementation WizUploadObject
@synthesize uploadObject;
@synthesize tempFilePath;
@synthesize fileMd5;
@synthesize fileSize;
@synthesize currentSize;
@synthesize uploadingSize;
@synthesize partCount;
@synthesize delegate;
- (void) dealloc
{
    delegate = nil;
    [fileMd5 release];
    [tempFilePath release];
    [uploadObject release];
    [super dealloc];
}

- (NSFileHandle*) uploadFileHandle
{
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForReadingAtPath:self.tempFilePath];
    return fileHandle;
}

- (void) prepareUploadEnviroment
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSString* uploadFilePath = [fileManager uploadTempFile:uploadObject.strGuid accountUserId:self.accountUserId];
    if ([fileManager fileExistsAtPath:uploadFilePath]) {
        [fileManager deleteFile:uploadFilePath];
    }
    NSString* objectPath = [fileManager wizObjectFilePath:uploadObject.strGuid accountUserId:self.accountUserId];
    self.tempFilePath = [fileManager createZipByPath:objectPath];
    self.fileMd5 = [WizGlobals fileMD5:self.tempFilePath];
    self.fileSize = [WizGlobals fileLength:self.tempFilePath];
    
    //
    self.partCount = self.fileSize / WizUploadObjectSize;
    if (self.fileSize % WizUploadObjectSize > 0) {
        self.partCount++;
    }
    self.currentSize = 0;
}

- (void) uploadNextPart
{
    NSFileHandle* fileHanle = [self uploadFileHandle];
    [fileHanle seekToFileOffset:self.currentSize];
    NSData* data = [fileHanle readDataOfLength:WizUploadObjectSize];
    [fileHanle closeFile];
    
    NSInteger partIndex = self.currentSize / WizUploadObjectSize;
    self.uploadingSize = data.length;
    //
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [postParams setObject:[NSNumber numberWithInt:self.fileSize] forKey:@"obj_size"];
    [postParams setObject:self.uploadObject.strGuid forKey:@"obj_guid"];
    [postParams setObject:[self.uploadObject wizObjectType] forKey:@"obj_type"];
    [postParams setObject:self.fileMd5 forKey:@"obj_md5"];
    [postParams setObject:[NSNumber numberWithInt:self.partCount] forKey:@"part_count"];
    [postParams setObject:data forKey:@"data"];
    [postParams setObject:[NSNumber numberWithInt:partIndex] forKey:@"part_sn"];
    NSString* localMd5 = [WizGlobals md5:data];
    [postParams setObject:localMd5 forKey:@"part_md5"];
    NSUInteger partSize=[data length];
    [postParams setObject:[NSNumber numberWithInt:partSize]   forKey:@"part_size"];
    [self executeXmlRpcWithArgs:postParams methodKey:SyncMethod_UploadObject needToken:YES];
}
- (void) uploadDocumentMeta:(BOOL) isWithData
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    
    WizDocument* doc = (WizDocument*)self.uploadObject;
    
    [postParams setObjectNotNull:doc.strGuid forKey:@"document_guid"];
    [postParams setObjectNotNull:doc.strTitle forKey:@"document_title"];
    [postParams setObjectNotNull:doc.strType forKey:@"document_type"];
    [postParams setObjectNotNull:doc.strFileType forKey:@"document_filetype"];
    [postParams setObjectNotNull:doc.dateModified forKey:@"dt_modified"];
    [postParams setObjectNotNull:doc.strLocation forKey:@"document_category"];
    [postParams setObjectNotNull:[NSNumber numberWithInt:1] forKey:@"document_info"];
    [postParams setObjectNotNull:self.fileMd5 forKey:@"document_zip_md5"];
    [postParams setObjectNotNull:doc.dateCreated forKey:@"dt_created"];
    [postParams setObjectNotNull:[NSNumber numberWithInt:isWithData] forKey:@"with_document_data"];
    [postParams setObjectNotNull:[NSNumber numberWithInt:doc.nAttachmentCount] forKey:@"document_attachment_count"];
    [postParams setObjectNotNull:[NSNumber numberWithFloat:doc.gpsLatitude] forKey:@"gps_latitude"];
    [postParams setObjectNotNull:[NSNumber numberWithFloat:doc.gpsLongtitude] forKey:@"gps_longitude"];
    
    NSString* tags = [NSString stringWithString:doc.strTagGuids];
    NSString* ss = [tags stringByReplacingOccurrencesOfString:@"*" withString:@";"];
    if(tags != nil)
        [postParams setObjectNotNull:ss forKey:@"document_tag_guids"];
    else
        [postParams setObjectNotNull:tags forKey:@"document_tag_guids"];
	[self executeXmlRpcWithArgs:postParams methodKey:SyncMethod_DocumentPostSimpleData needToken:YES];
}

- (void) uploadAttachmentMeta
{
    WizAttachment* attach = (WizAttachment*) self.uploadObject;
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	
    [postParams setObject:attach.strGuid             forKey:@"attachment_guid"];
    [postParams setObject:attach.strDocumentGuid           forKey:@"attachment_document_guid"];
    [postParams setObject:[attach.strTitle stringByReplacingOccurrencesOfString:@":" withString:@"-"]            forKey:@"attachment_name"];
    [postParams setObject:attach.dateModified                  forKey:@"dt_modified"];
    [postParams setObject:self.fileMd5                       forKey:@"data_md5"];
    [postParams setObject:self.fileMd5                        forKey:@"attachment_zip_md5"];
    [postParams setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_info"];
    [postParams setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_data"];
    [self executeXmlRpcWithArgs:postParams methodKey:SyncMethod_AttachmentPostSimpleData needToken:YES];
}

- (void) startUpload
{
    if ([self.uploadObject isKindOfClass:[WizDocument class]]) {
        WizDocument* doc = (WizDocument*)self.uploadObject;
        if (WizEditDocumentTypeInfoChanged == doc.nLocalChanged) {
            [self uploadDocumentMeta:NO];
            return;
        }
    }
    [self uploadNextPart];
}

- (BOOL) start
{
    if (![super start]) {
        return NO;
    }
    //
    [self prepareUploadEnviroment];
    [self startUpload];
    return YES;
}


- (void) onUploadObjectDataDone
{
    [[WizFileManager shareManager] deleteFile:self.tempFilePath];
    if ([uploadObject isKindOfClass:[WizDocument class]]) {
        [self uploadDocumentMeta:YES];
    }
    else if ([uploadObject isKindOfClass:[WizAttachment class]])
    {
        [self uploadAttachmentMeta];
    }
}

- (void) onUploadObjectData:(id)retObject
{
    NSMutableDictionary* obj = (NSMutableDictionary*)retObject;
    BOOL succeed = ([[obj valueForKey:@"return_code"] isEqualToString:@"200"])? YES:NO;
    if (!succeed) {
        [self uploadNextPart];
    }
    else {
        self.currentSize += self.uploadingSize;
        if (self.currentSize == self.fileSize)
        {
            [self onUploadObjectDataDone];
        }
        else
        {
            [self uploadNextPart];
        }
    }
}

- (void) end
{
    if (WizApistatueError == self.statue) {
        [self.delegate didUPloadWizObjectFaild:uploadObject];
    }
    else 
    {
        [self.delegate didUploadWizObjectDone:uploadObject];
    }
    [super end];
}

- (void) onPostDocumentMetaDone
{
    id<WizMetaDataBaseDelegate> db = [self groupDataBase];
    [db setDocumentLocalChanged:uploadObject.strGuid changed:WizEditDocumentTypeNoChanged];
    [self end];
}

- (void) onPostAttachmentMetaDone
{
    id<WizMetaDataBaseDelegate> db = [self groupDataBase];
    [db setDocumentLocalChanged:uploadObject.strGuid changed:WizEditDocumentTypeNoChanged];
    [self end];
}
- (void) xmlrpcDoneSucced:(id)retObject forMethod:(NSString *)method
{
    if ([method isEqualToString:SyncMethod_UploadObject]) {
        [self onUploadObjectData:retObject];
    }
    else if ([method isEqualToString:SyncMethod_DocumentPostSimpleData])
    {
        [self onPostDocumentMetaDone];
    }else if ([method isEqualToString:SyncMethod_AttachmentPostSimpleData])
    {
        [self onPostAttachmentMetaDone];
    }
    else
    {
        [self end];
    }
}
- (NSString*) apiStatueKey
{
    return [NSString stringWithFormat:@"%@%@%@",self.uploadObject.strGuid,self.kbGuid,self.accountUserId];
}

@end
