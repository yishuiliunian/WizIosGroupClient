//
//  WizSyncGropOperation.m
//  WizGroup
//
//  Created by wiz on 12-10-18.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizSyncGropOperation.h"
#import "WizApiDownloadDeletedGuids.h"
#import "WizApiDownloadTagList.h"
#import "WizApiDownloadDocumentList.h"
#import "WizApiDownloadAttachmentList.h"
#import "WizApiUploadDeletedGuids.h"
#import "WizApiUploadTags.h"
#import "WizUploadObject.h"
#import "WizDownloadObject.h"
#import "WizApiGetAllVersions.h"
//
#import "WizSyncMeta.h"
@interface WizSyncGropOperation () <WizApiDelegate, WizApiGetAllVersionsDelegate>
{
    BOOL isWorking;
    NSMutableArray* apiQueque;
    NSInteger   syncType;
    NSInteger   apiIndex;
}

@end
@implementation WizSyncGropOperation
@synthesize kbguid;
@synthesize accountUserId;

- (void) dealloc
{
    [apiQueque release];
    [kbguid release];
    [accountUserId release];
    [super dealloc];
}
- (void) setupSyncTools
{
    WizApiDownloadDeletedGuids* deleted = [[WizApiDownloadDeletedGuids alloc] initWithKbguid:self.kbguid accountUserId:self.accountUserId apiDelegate:self];
    
    
    WizApiDownloadTagList* tagList = [[WizApiDownloadTagList alloc] initWithKbguid:self.kbguid accountUserId:self.accountUserId apiDelegate:self];
    
    //
    
    WizApiDownloadDocumentList* documentList = [[WizApiDownloadDocumentList alloc] initWithKbguid:self.kbguid accountUserId:self.accountUserId apiDelegate:self];
    
    //
    WizApiDownloadAttachmentList* attachmentList = [[WizApiDownloadAttachmentList alloc] initWithKbguid:self.kbguid accountUserId:self.accountUserId apiDelegate:self];
    //
    
    if (WizSyncMetaAll == syncType) {
        WizApiUploadTags* upTags = [[WizApiUploadTags alloc] initWithKbguid:self.kbguid accountUserId:self.accountUserId apiDelegate:self];
        //
        //
        WizApiUploadDeletedGuids* upDeleted = [[WizApiUploadDeletedGuids alloc] initWithKbguid:self.kbguid accountUserId:self.accountUserId apiDelegate:self];
        //
        [apiQueque addObject:deleted];
        [apiQueque addObject:upDeleted];
        [apiQueque addObject:tagList];
        [apiQueque addObject:upTags];
        [apiQueque addObject:documentList];
        [apiQueque addObject:attachmentList];
        [upDeleted release];
        [upTags release];
    }
    else
    {
        [apiQueque addObject:deleted];
        [apiQueque addObject:tagList];
        [apiQueque addObject:documentList];
        [apiQueque addObject:attachmentList];
    }
    //
    [deleted release];
    [tagList release];
    [documentList release];
    [attachmentList release];
}
- (id) initWithBbguid:(NSString*)kb accountUserId:(NSString*)userId
{
    self = [super init];
    if (self) {
        apiQueque = [[NSMutableArray alloc] init];
        kbguid = [kb retain];
        accountUserId = [userId retain];
        WizApiGetAllVersions* getAllVersion = [[WizApiGetAllVersions alloc] initWithKbguid:kb accountUserId:userId apiDelegate:self];
        getAllVersion.delegate = self;
        syncType = WizSyncMetaOnlyDownload;
        [apiQueque addObject:getAllVersion];
        [getAllVersion release];
        [self setupSyncTools];
    }
    return self;
}
- (WizApi*) getSyncTool:(Class)classKind
{
    for (WizApi* each in apiQueque) {
        if ([each isKindOfClass:classKind]) {
            return each;
        }
    }
    return nil;
}

- (void) didGetAllObjectVersions:(NSDictionary *)dic
{
    NSNumber* attachmentVer = [dic objectForKey:@"attachment_version"];
    NSNumber* documentVer = [dic objectForKey:@"document_version"];
    NSNumber* tagVer = [dic objectForKey:@"tag_version"];
    NSNumber* deletedVer = [dic objectForKey:@"deleted_version"];
    
    WizApiDownloadAttachmentList* attachmentList = (WizApiDownloadAttachmentList*)[self getSyncTool:[WizApiDownloadAttachmentList class]];
    WizApiDownloadDeletedGuids* deletedList = (WizApiDownloadDeletedGuids*)[self getSyncTool:[WizApiDownloadDeletedGuids class]];
    WizApiDownloadDocumentList* documentList = (WizApiDownloadDocumentList*)[self getSyncTool:[WizApiDownloadDocumentList class]];
    WizApiDownloadTagList* tagList = (WizApiDownloadTagList*)[self getSyncTool:[WizApiDownloadTagList class]];
    
    attachmentList.serverVersion = [attachmentVer integerValue];
    documentList.serverVersion = [documentVer integerValue];
    deletedList.serverVersion = [deletedVer integerValue];
    tagList.serverVersion = [tagVer integerValue];
    
}
- (void) wizApiEnd:(WizApi *)api withSatue:(enum WizApiStatue)statue
{
    if (statue == WizApistatueError || !isWorking) {
        
    }
    else
    {
        apiIndex ++;
        if (apiIndex >= [apiQueque count]) {
            isWorking = NO;
        }
        else
        {
            WizApi* nextApi = [apiQueque objectAtIndex:apiIndex];
            [nextApi start];
        }
    }
}
- (void) main
{
    apiIndex = 0;
    if ([apiQueque count]) {
        WizApi* api = [apiQueque objectAtIndex:0];
        [api start];
    }
    isWorking = YES;
    while (isWorking) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    NSLog(@"work!");
}
@end
