//
//  WizApiSyncGroupMeta.m
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-13.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizApiSyncGroupMeta.h"
#import "WizNotificationCenter.h"
//
NSString* const SyncVersionDocument = @"document_version";
NSString* const SyncVersionAttachment = @"attachment_version";
NSString* const SyncVersionDeleted  = @"deleted_version";
NSString* const SyncVersionTag      = @"tag_version";
@interface WizApiSyncGroupMeta ()
@property (nonatomic, retain) NSMutableDictionary* syncDataDictionary;
@end

@implementation WizApiSyncGroupMeta
@synthesize syncDataDictionary;
- (void) dealloc
{
    [syncDataDictionary release];
    [super dealloc];
}

- (id) init
{
    self = [self initWithKbguid:nil accountUserId:nil apiDelegate:nil];
    if (self) {
        
    }
    return self;
}

- (id) initWithKbguid:(NSString *)kbguid accountUserId:(NSString *)accountUserId apiDelegate:(id<WizApiDelegate>)delegate
{
    self = [super initWithKbguid:kbguid accountUserId:accountUserId apiDelegate:delegate];
    if (self) {
        syncDataDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (int64_t) getNewVersion:(NSArray*)array
{
    int64_t newVer = 0;
    for (NSDictionary* dict in array)
    {
        NSString* verString = [dict valueForKey:@"version"];
        
        int64_t ver = [verString longLongValue];
        if (ver > newVer)
        {
            newVer = ver;
        }
    }
    return newVer;
}
- (NSInteger) getLocalVersion:(NSString*)syncMethod
{
    id<WizMetaDataBaseDelegate> db = [self groupDataBase];
    if ([SyncMethod_DownloadDocumentList isEqualToString:syncMethod]) {
        return [db documentVersion];
    }
    else if ([syncMethod isEqualToString:SyncMethod_DownloadDeletedList])
    {
        return [db deletedGUIDVersion];
    }
    else if ([syncMethod isEqualToString:SyncMethod_GetAttachmentList])
    {
        return [db attachmentVersion];
    }
    else if ([syncMethod isEqualToString:SyncMethod_GetAllTags])
    {
        return [db tagVersion];
    }
    else
    {
        return 0;
    }

}

- (NSInteger) getServerVersion:(NSString*)syncMethod
{
    if ([SyncMethod_DownloadDocumentList isEqualToString:syncMethod]) {
        return [[self.syncDataDictionary objectForKey:SyncVersionDocument] integerValue];
    }
    else if ([syncMethod isEqualToString:SyncMethod_DownloadDeletedList])
    {
        return [[self.syncDataDictionary objectForKey:SyncVersionDeleted] integerValue];
    }
    else if ([syncMethod isEqualToString:SyncMethod_GetAttachmentList])
    {
        return [[self.syncDataDictionary objectForKey:SyncVersionAttachment] integerValue];
    }
    else if ([syncMethod isEqualToString:SyncMethod_GetAllTags])
    {
        return [[self.syncDataDictionary objectForKey:SyncVersionTag] integerValue];
    }
    else
    {
        return 0;
    }
}
- (void) uploadLocalList:(NSArray*)list method:(NSString*)syncMethod
{
    id<WizMetaDataBaseDelegate> db = [self groupDataBase];
    int64_t version = [self getNewVersion:list];
    if (version == 0) {
        version = [self getServerVersion:syncMethod];
    }
    version++;
    if ([SyncMethod_DownloadDocumentList isEqualToString:syncMethod]) {
        [db updateDocuments:list];
        [db setDocumentVersion:version];
    }
    else if ([syncMethod isEqualToString:SyncMethod_DownloadDeletedList])
    {
        [db setDeletedGUIDVersion:version];
    }
    else if ([syncMethod isEqualToString:SyncMethod_GetAttachmentList])
    {
        [db updateAttachments:list];
        [db setAttachmentVersion:version];
    }
    else if ([syncMethod isEqualToString:SyncMethod_GetAllTags])
    {
        [db updateTags:list];
        [db setTagVersion:version];
    }
}

- (BOOL) callDownloadList:(NSString*)syncMethod  nextSel:(SEL)selector
{
    NSInteger localVersion = [self getLocalVersion:syncMethod];
    NSInteger serverVersion = [self getServerVersion:syncMethod];
    if (serverVersion !=0 && localVersion >= serverVersion) {
        [self performSelector:selector];
        return YES;
    }
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [postParams setObject:[NSNumber numberWithInt:[self listCount]] forKey:@"count"];
    [postParams setObject:[NSNumber numberWithInt:localVersion] forKey:@"version"];
    return [self executeXmlRpcWithArgs:postParams methodKey:syncMethod needToken:YES];
}


- (void) onDownloadList:(NSArray*)list  syncMethod:(NSString*)methodName nextSEL:(SEL)selector
{
    [self uploadLocalList:list method:methodName];
    [self callDownloadList:methodName nextSel:selector];
}


- (BOOL) canUploadDeletedList
{
    return NO;
}

- (BOOL) canUploadTags
{
    return NO;
}




- (BOOL) callGetAllVersion
{
    return [self executeXmlRpcWithArgs:[NSMutableDictionary dictionary] methodKey:SyncMethod_GetAllObjectVersion needToken:YES];
}

- (void) onGetAllVersion:(NSDictionary*)ret
{
    NSNumber* attachmentVer = [ret objectForKey:@"attachment_version"];
    NSNumber* documentVer = [ret objectForKey:@"document_version"];
    NSNumber* tagVer = [ret objectForKey:@"tag_version"];
    NSNumber* deletedVer = [ret objectForKey:@"deleted_version"];
    [self.syncDataDictionary setObject:attachmentVer forKey:SyncVersionAttachment];
    [self.syncDataDictionary setObject:documentVer forKey:SyncVersionDocument];
    [self.syncDataDictionary setObject:deletedVer forKey:SyncVersionDeleted];
    [self.syncDataDictionary setObject:tagVer forKey:SyncVersionTag];
    [self callUploadDeletedList];
}

- (BOOL) callUploadDeletedList
{
    id<WizMetaDataBaseDelegate> db = [self groupDataBase];
    NSArray* deleteGuids = [db deletedGUIDsForUpload];
    
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    NSMutableArray* deletedArray = [NSMutableArray array];
    if ([deleteGuids count] == 0 || ![self canUploadDeletedList]) {
        return [self callDownloadDeletedList];
    }
    else
    {
        for (id deletedGuid in deleteGuids) {
            if ([deletedGuid isKindOfClass:[WizDeletedGUID class]]) {
                WizDeletedGUID* deletedObject = (WizDeletedGUID*)deletedGuid;
                
                NSMutableDictionary* deletedObjectDic = [NSMutableDictionary dictionaryWithCapacity:3];
                [deletedObjectDic setObject:deletedObject.strGuid forKey:@"deleted_guid"];
                [deletedObjectDic setObject:deletedObject.strType forKey:@"guid_type"];
                [deletedObjectDic setObject:[deletedObject.dateDeleted dateFromSqlTimeString]  forKey:@"dt_deleted"];
                [deletedArray addObject:deletedObjectDic];
            }
        }
        [postParams setObject:deletedArray forKey:@"deleteds"];
        return [self executeXmlRpcWithArgs:postParams methodKey:SyncMethod_UploadDeletedList needToken:YES];
    }
}
- (void) onUploadDeletedList:(NSDictionary*)ret
{
    [self callDownloadDeletedList];
}
- (BOOL) callDownloadDeletedList
{
    return [self callDownloadList:SyncMethod_DownloadDeletedList nextSel:@selector(callUploadTags)];
}
- (void) onDownloadDeletedList:(NSArray*)ret
{
    [self onDownloadList:ret syncMethod:SyncMethod_DownloadDeletedList nextSEL:@selector(callUploadTags)];
}

- (BOOL) callUploadTags
{
    id<WizMetaDataBaseDelegate> db = [self groupDataBase];
    
    NSArray* tagList = [db tagsForUpload];
    if (0 == [tagList count] || ![self canUploadTags]) {
        return [self callDownloadTagList];
    }
    else
    {
        NSMutableArray* tagTemp = [[NSMutableArray alloc] initWithCapacity:[tagList count]];
        for(WizTag* each in tagList)
        {
            NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
            [dic setObject:each.strGuid forKey:@"tag_guid"];
            if(nil !=each.strParentGUID)
                [dic setObject:each.strParentGUID forKey:@"tag_group_guid"];
            [dic setObject:each.strTitle forKey:@"tag_name"];
            [dic setObject:each.description forKey:@"tag_description"];
            [dic setObject:each.dateInfoModified forKey:@"dt_info_modified"];
            [tagTemp addObject:dic];
            [dic release];
            
        }
        NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
        [postParams setObject:tagTemp forKey:@"tags"];
        [tagTemp release];
        return [self executeXmlRpcWithArgs:postParams methodKey:SyncMethod_PostTagList needToken:YES];
    }
}

- (void) onUploadTags:(NSDictionary*)ret
{
    [self callDownloadTagList];
}
- (BOOL) callDownloadTagList
{
    return [self callDownloadList:SyncMethod_GetAllTags nextSel:@selector(callDownloadDocumentList)];
}

- (void) onDownloadTaglist:(NSArray*)ret
{
    [self onDownloadList:ret syncMethod:SyncMethod_GetAllTags nextSEL:@selector(callDownloadDocumentList)];
}

- (BOOL) callDownloadDocumentList
{
    return [self callDownloadList:SyncMethod_DownloadDocumentList nextSel:@selector(callDownloadAttachmentList)];
}


- (void) onDownloadDocumentList:(NSArray*)ret
{
    return [self onDownloadList:ret syncMethod:SyncMethod_DownloadDocumentList nextSEL:@selector(callDownloadAttachmentList)];
}

- (BOOL) callDownloadAttachmentList
{
    return [self callDownloadList:SyncMethod_GetAttachmentList nextSel:@selector(syncEnd)];
}

- (void) onDownloadAttachmentList:(NSArray*)ret
{
    [self onDownloadList:ret syncMethod:SyncMethod_GetAttachmentList nextSEL:@selector(syncEnd)];
}

- (void) syncEnd
{
    [self end];
    [[WizNotificationCenter defaultCenter] postNotificationName:WizNMSyncGroupEnd object:nil];
}

- (BOOL) start
{
    if (![super start]) {
        return NO;
    }
    [[WizNotificationCenter defaultCenter] postNotificationName:WizNMSyncGroupStart object:nil];
    return  [self callGetAllVersion];
}

- (void) xmlrpcDoneSucced:(id)retObject forMethod:(NSString *)method
{
    if ([method isEqualToString:SyncMethod_GetAllObjectVersion]) {
        [self onGetAllVersion:retObject];
    }
    else if ([method isEqualToString:SyncMethod_GetAllTags])
    {
        [self onDownloadTaglist:retObject];
    }
    else if ([method isEqualToString:SyncMethod_GetAttachmentList])
    {
        [self onDownloadAttachmentList:retObject];
    }
    else if ([method isEqualToString:SyncMethod_DownloadDeletedList])
    {
        [self onDownloadDeletedList:retObject];
    }
    else if ([method isEqualToString:SyncMethod_DownloadDocumentList])
    {
        [self onDownloadDocumentList:retObject];
    }
    else if ([method isEqualToString:SyncMethod_UploadDeletedList])
    {
        [self onUploadDeletedList:retObject];
    }
    else if ([method isEqualToString:SyncMethod_PostTagList])
    {
        [self onUploadTags:retObject];
    }
    else
    {
        [self end];
    }
}

@end
