//
//  WizMetaDataBase.m
//  Wiz
//
//  Created by wiz on 12-6-14.
//
//

#import "WizMetaDataBase.h"
#import "WizDocument.h"
#import "WizAttachment.h"
#import "CommonString.h"
#import "WizTag.h"
#import "WizFileManager.h"
#import "WizDbManager.h"
//#import "WGGlobalCache.h"

#import "WizGlobals.h"
#import <QuartzCore/QuartzCore.h>
#define KeyOfSyncVersion                        @"SYNC_VERSION"
#define KeyOfSyncVersionDocument                @"DOCUMENT"
#define KeyOfSyncVersionDeletedGuid             @"DELETED_GUID"
#define KeyOfSyncVersionAttachment              @"ATTACHMENT"
#define KeyOfSyncVersionTag                     @"TAG"

static NSString* const KeyOfDocumentUnReadCount = @"KeyOfDocumentUnReadCount";

//document
@interface NSString(db)
- (NSString*) sqlLikeString;
@end

@implementation NSString(db)
- (NSString*) sqlLikeString
{
    return [NSString stringWithFormat:@"%@%@",self,@"%"];
}

@end

@interface WizMetaDataBase ()
- (BOOL) addDeletedGUIDRecord: (NSString*)guid type:(NSString*)type;
@end

@implementation WizMetaDataBase
@synthesize kbguid;
@synthesize accountUserId;
- (void) dealloc
{
    [kbguid release];
    [accountUserId release];
    [super dealloc];
}

- (BOOL) isMetaExist:(NSString*)lpszName  withKey:(NSString*) lpszKey
{
    if ([self getMeta:lpszName withKey:lpszKey])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSString*) getMeta:(NSString*)lpszName  withKey:(NSString*) lpszKey
{
    NSString* sql = [NSString stringWithFormat:@"select META_VALUE from WIZ_META where META_NAME='%@' and META_KEY='%@'",lpszName,lpszKey];
    __block NSString* value = [NSString string];
    @synchronized(value)
    {
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* s = [db executeQuery:sql];
        if ([s next]) {
            value = [s stringForColumnIndex:0];
        }
        else
        {
            value = nil;
        }
        [s close];
    }];
    }
    return value;
}

- (BOOL) setMeta:(NSString*)lpszName  key:(NSString*)lpszKey value:(NSString*)value
{
    __block BOOL ret;
    if (![self isMetaExist:lpszName withKey:lpszKey])
    {
        [self.queue inDatabase:^(FMDatabase *db) {
            ret = [db executeUpdate:@"insert into WIZ_META (META_NAME, META_KEY, META_VALUE) values(?,?,?)",lpszName, lpszKey, value];
        }];
    }
    else
    {
        [self.queue inDatabase:^(FMDatabase *db) {
           ret= [db executeUpdate:@"update WIZ_META set META_VALUE= ? where META_NAME=? and META_KEY=?",value, lpszName, lpszKey];
        }];
    }
    return ret;
}

- (int64_t) calculateUnreadDocument
{
    __block int64_t count = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:@"select count(*) from WIZ_DOCUMENT where READCOUNT < 1"];
        if ([result next]) {
            count = [result intForColumnIndex:0];
        }
        NSLog(@"%lld",  count);
        [result close];
    }];
    return count;
}

- (int64_t) documentUnReadCount
{
//#warning need improvement
    return [self calculateUnreadDocument];
}
- (BOOL) setDocumentUnReadCount:(int64_t)count
{
    NSString* countStr = [NSString stringWithFormat:@"%lld",count];
    return [self setMeta:KeyOfDocumentUnReadCount key:KeyOfDocumentUnReadCount value:countStr];
}

- (void) resetDocumentReadCount
{
//     [WGGlobalCache clearUnreadCountByKbguid:self.kbguid accountUserId:self.accountUserId];
}
//
- (BOOL) setSyncVersion:(NSString*)type  version:(int64_t)ver
{
    NSString* verString = [NSString stringWithFormat:@"%lld", ver];
	return [self setMeta:KeyOfSyncVersion key:type value:verString];
}
- (int64_t) syncVersion:(NSString*)type
{
    NSString* verString = [self getMeta:KeyOfSyncVersion withKey:type];
    if (verString) {
        return [verString longLongValue];
    }
    return 0;
}
- (BOOL) setDocumentVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionDocument version:ver];
}
- (int64_t) documentVersion
{
    return [self syncVersion:KeyOfSyncVersionDocument];
}
- (BOOL) setAttachmentVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionAttachment version:ver];
}
- (int64_t) attachmentVersion
{
    return [self syncVersion:KeyOfSyncVersionAttachment];
}
- (BOOL) setTagVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionTag version:ver];
}
- (int64_t) tagVersion
{
    return [self syncVersion:KeyOfSyncVersionTag];
}
- (BOOL) setDeletedGUIDVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionDeletedGuid version:ver];
}
- (int64_t) deletedGUIDVersion
{
    return [self syncVersion:KeyOfSyncVersionDeletedGuid];
}
//document
- (NSArray*) documentsArrayWithWhereFiled:(NSString*)where arguments:(NSArray*)args
{
    if (nil == where) {
        where = @"";
    }
    NSString* sql = [NSString stringWithFormat:@"select DOCUMENT_GUID, DOCUMENT_TITLE, DOCUMENT_LOCATION, DOCUMENT_URL, DOCUMENT_TAG_GUIDS, DOCUMENT_TYPE, DOCUMENT_FILE_TYPE, DT_CREATED, DT_MODIFIED, DOCUMENT_DATA_MD5, ATTACHMENT_COUNT, SERVER_CHANGED, LOCAL_CHANGED,GPS_LATITUDE ,GPS_LONGTITUDE ,GPS_ALTITUDE ,GPS_DOP ,GPS_ADDRESS ,GPS_COUNTRY ,GPS_LEVEL1 ,GPS_LEVEL2 ,GPS_LEVEL3 ,GPS_DESCRIPTION ,READCOUNT ,PROTECT, OWNER from WIZ_DOCUMENT %@",where];
    __block NSMutableArray* array = [NSMutableArray array];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:sql withArgumentsInArray:args];
        while ([result next]) {
            WizDocument* doc = [[WizDocument alloc] init];
            doc.strGuid = [result stringForColumnIndex:0];
            doc.strTitle = [result stringForColumnIndex:1];
            doc.strLocation = [result stringForColumnIndex:2];
            doc.strUrl = [result stringForColumnIndex:3];
            doc.strTagGuids = [result stringForColumnIndex:4];
            doc.strType = [result stringForColumnIndex:5];
            doc.strFileType = [result stringForColumnIndex:6];
            doc.dateCreated = [[result stringForColumnIndex:7] dateFromSqlTimeString] ;
            doc.dateModified = [[result stringForColumnIndex:8] dateFromSqlTimeString];
            doc.strDataMd5 = [result stringForColumnIndex:9];
            doc.nAttachmentCount = [result intForColumnIndex:10];
            doc.bServerChanged = [result intForColumnIndex:11];
            doc.nLocalChanged = [result intForColumnIndex:12];
            doc.gpsLatitude = [result doubleForColumnIndex:13];
            doc.gpsLongtitude = [result doubleForColumnIndex:14];
            doc.gpsAltitude = [result doubleForColumnIndex:15];
            doc.gpsDop = [result doubleForColumnIndex:16];
            doc.gpsAddress = [result stringForColumnIndex:17];
            doc.gpsCountry = [result stringForColumnIndex:18];
            doc.gpsLevel1 = [result stringForColumnIndex:19];
            doc.gpsLevel2 = [result stringForColumnIndex:20];
            doc.gpsLevel3 = [result stringForColumnIndex:21];
            doc.gpsDescription = [result stringForColumnIndex:22];
            doc.nReadCount = [result intForColumnIndex:23];
            doc.nProtected = [result intForColumnIndex:24];
            doc.strOwner = [result stringForColumnIndex:25];
            [array addObject:doc];
            [doc release];
        }
        [result close];
    }];
    return array;
}
- (NSArray*) unreadDocuments
{
    return [self documentsArrayWithWhereFiled:@"where READCOUNT < 1 order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 30" arguments:nil];
}

- (NSInteger) readCountOfDocument:(NSString*)documentGuid
{
    __block NSInteger readCount = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:@"select READCOUNT from WIZ_DOCUMENT where DOCUMENT_GUID = ?",documentGuid];
        if ([result next]) {
            readCount = [result intForColumnIndex:0];
        }
        [result close];
    }];
    return readCount;
}

- (BOOL) updateDocumentReadCount:(NSString *)documentGuid
{
    int readCount = [self readCountOfDocument:documentGuid];
    __block BOOL ret = NO;
    [self.queue inDatabase:^(FMDatabase *db) {
        ret = [db executeUpdate:@"update WIZ_DOCUMENT set READCOUNT = ? where DOCUMENT_GUID = ?",[NSNumber numberWithInt:readCount+1],documentGuid];
    }];
    [self resetDocumentReadCount];
    return ret;
}
- (WizDocument*) documentFromGUID:(NSString *)documentGUID
{
    if (nil == documentGUID) {
        return nil;
    }
    NSArray* array = [self documentsArrayWithWhereFiled:@"where DOCUMENT_GUID = ?" arguments:[NSArray arrayWithObject:documentGUID]];
    return [array lastObject];
}

- (NSArray*) recentDocuments
{
    return [self documentsArrayWithWhereFiled:@"order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 200" arguments:nil];
}

- (NSArray*) documentForUpload
{
    return [self documentsArrayWithWhereFiled:@"where LOCAL_CHANGED !=0 " arguments:nil];
}

- (WizDocument*) documentForDownloadNext
{
    NSArray* array = [self documentsArrayWithWhereFiled:@"where SERVER_CHANGED != 0 order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 1" arguments:nil];
    if (array) {
        return [array lastObject];
    }
    return 0;
}

- (NSArray*) documentsByKey:(NSString *)keywords
{
    NSString* sqlWhere = [NSString stringWithFormat:@"%@%@%@",@"%",keywords,@"%"];
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_TITLE like ? order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100" arguments:[NSArray arrayWithObject:sqlWhere]];
}

- (NSArray*) documentsByLocation:(NSString *)parentLocation
{
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_LOCATION=? order by max(DT_CREATED, DT_MODIFIED) desc" arguments:[NSArray arrayWithObject:parentLocation]];
}

- (NSArray*) documentsByTag:(NSString *)tagGUID
{
    NSString* sqlWhere = [NSString stringWithFormat:@"%@%@%@",@"%",tagGUID,@"%"];
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_TAG_GUIDS like ? order by DOCUMENT_TITLE" arguments:[NSArray arrayWithObject:sqlWhere]];
}
- (NSArray*) documentsByNotag
{
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_TAG_GUIDS=\"\" or DOCUMENT_TAG_GUIDS is null " arguments:nil];
}
- (NSArray*) documentsForCache:(NSInteger)duration
{
    NSDate* date = [NSDate dateWithDaysBeforeNow:duration];
    return [self documentsArrayWithWhereFiled:@"where DT_MODIFIED >= ? and SERVER_CHANGED=1 order by DT_MODIFIED" arguments:[NSArray arrayWithObjects:[date stringSql], nil]];
}

- (WizDocument*) documentForClearCacheNext
{
    return [[self documentsArrayWithWhereFiled:@"where  SERVER_CHANGED=0 and LOCAL_CHANGED=0 order by DT_MODIFIED desc limit 0,1" arguments:nil] lastObject];
}

- (BOOL) setDocumentLocalChanged:(NSString *)guid changed:(enum WizEditDocumentType)changed
{
    __block  BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
        ret = [db executeUpdate:@"update WIZ_DOCUMENT set LOCAL_CHANGED=? where DOCUMENT_GUID= ?",[NSNumber numberWithInt:changed],guid];;
    }];
    if (ret && changed) {
//        [WizNotificationCenter postUpdateDocument:guid];
    }
    return ret;
}
- (BOOL) setDocumentServerChanged:(NSString *)guid changed:(BOOL)changed
{
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
        ret=  [db executeUpdate:@"update WIZ_DOCUMENT set SERVER_CHANGED=? where DOCUMENT_GUID= ?",[NSNumber numberWithInt:changed],guid];
    }];
    if (ret && !changed) {
//        [WizNotificationCenter postUpdateDocument:guid];
    }
    return ret;
}


//
- (BOOL) updateDocument:(NSDictionary *)doc
{
    NSString*  guid = [doc valueForKey:DataTypeUpdateDocumentGUID];
    if (!guid) {
        return NO;
    }
	NSString*  title =[doc valueForKey:DataTypeUpdateDocumentTitle];
	NSString*  location = [doc valueForKey:DataTypeUpdateDocumentLocation];
	NSString*  dataMd5 = [doc valueForKey:DataTypeUpdateDocumentDataMd5];
	NSString*  url = [doc valueForKey:DataTypeUpdateDocumentUrl];
	NSString*  tagGUIDs = [doc valueForKey:DataTypeUpdateDocumentTagGuids];
	NSDate*    dateCreated = [doc valueForKey:DataTypeUpdateDocumentDateCreated];
	NSDate*   dateModified = [doc valueForKey:DataTypeUpdateDocumentDateModified];
	NSString* type = [doc valueForKey:DataTypeUpdateDocumentType];
	NSString* fileType = [doc valueForKey:DataTypeUpdateDocumentFileType];
    NSNumber* nAttachmentCount = [doc valueForKey:DataTypeUpdateDocumentAttachmentCount];
    NSNumber* localChanged = [doc valueForKey:DataTypeUpdateDocumentLocalchanged];
    NSNumber* nProtected = [doc valueForKey:DataTypeUpdateDocumentProtected];
    NSNumber* serverChanged = [doc valueForKey:DataTypeUpdateDocumentServerChanged];
    NSNumber* nReadCount = [doc valueForKey:DataTypeUpdateDocumentREADCOUNT];
    NSNumber* gpsLatitue = [doc valueForKey:DataTypeUpdateDocumentGPS_LATITUDE];
    NSNumber* gpsLongtitue = [doc valueForKey:DataTypeUpdateDocumentGPS_LONGTITUDE];
    NSNumber* gpsAltitue    = [doc valueForKey:DataTypeUpdateDocumentGPS_ALTITUDE];
    NSNumber* gpsDop        = [doc valueForKey:DataTypeUpdateDocumentGPS_DOP];
    NSString* gpsAddress  = [doc valueForKey:DataTypeUpdateDocumentGPS_ADDRESS];
    NSString* gpsCountry = [doc valueForKey:DataTypeUpdateDocumentGPS_COUNTRY];
    NSString* gpsLevel1 = [doc valueForKey:DataTypeUpdateDocumentGPS_LEVEL1];
    NSString* gpsLevel2 = [doc valueForKey:DataTypeUpdateDocumentGPS_LEVEL2];
    NSString* gpsLevel3 = [doc valueForKey:DataTypeUpdateDocumentGPS_LEVEL3];
    NSString* gpsDescription  = [doc valueForKey:DataTypeUpdateDocumentGPS_DESCRIPTION];
    NSString* strOwner = [doc valueForKey:DataTypeUpdateDocumentOwner];
    
    BOOL serverDocument;
    if (!dateCreated) {
        dateCreated = [NSDate date];
    }
    nReadCount = [NSNumber numberWithInt:0];
    if (!dateModified) {
        dateModified = [NSDate date];
    }
    if (!localChanged) {
        serverDocument = YES;
    }
    else
    {
        serverDocument = NO;
    }
    WizDocument* docExist = [self documentFromGUID:guid];
    __block BOOL ret;
    if (docExist)
    {
        if (serverDocument) {
            switch (docExist.nLocalChanged) {
                case WizEditDocumentTypeNoChanged:
                    if ([docExist.strDataMd5 isEqualToString:dataMd5]) {
                        serverChanged = [NSNumber numberWithInt:0];
                        localChanged = [NSNumber numberWithInt:0];
                    }
                    else
                    {
                        serverChanged = [NSNumber numberWithInt:1];
                        localChanged = [NSNumber numberWithInt:0];
                    }
                    break;
                case WizEditDocumentTypeInfoChanged:
                {
                    if ([dateModified isEarlierThanDate:docExist.dateModified]) {
                        title = docExist.strTitle;
                        location = docExist.strLocation;
                        dataMd5 = docExist.strDataMd5;
                        url = docExist.strUrl;
                        tagGUIDs = docExist.strTagGuids;
                        dateCreated = docExist.dateCreated;
                        dateModified = docExist.dateModified;
                        type = docExist.strType;
                        fileType = docExist.strFileType;
                        nAttachmentCount =  [NSNumber numberWithInt:docExist.nAttachmentCount];
                        localChanged = [NSNumber numberWithInt:docExist.nLocalChanged];
                        nProtected = [NSNumber numberWithBool:docExist.nProtected];
                        serverChanged = [NSNumber numberWithInt:0];
                        nReadCount = [NSNumber numberWithInt:docExist.nReadCount];
                        gpsLatitue = [NSNumber numberWithFloat:docExist.gpsLatitude];
                         gpsLongtitue = [NSNumber numberWithFloat:docExist.gpsLongtitude];
                         gpsAltitue    = [NSNumber numberWithFloat:docExist.gpsAltitude];
                         gpsDop        = [NSNumber numberWithFloat:docExist.gpsDop];
                         gpsAddress  = docExist.gpsAddress;
                         gpsCountry = docExist.gpsCountry;
                         gpsLevel1 = docExist.gpsLevel1;
                         gpsLevel2 = docExist.gpsLevel2;
                         gpsLevel3 = docExist.gpsLevel3;
                         gpsDescription  = docExist.gpsDescription;
                    }
                    else
                    {
                        localChanged = [NSNumber numberWithInt:0];
                        serverChanged = [NSNumber numberWithInt:1];
                    }
                    break;
                }
                case WizEditDocumentTypeAllChanged:
                {
                    if ([dataMd5 isEqualToString:docExist.strDataMd5]) {
                        break;
                    }
                    {
                        serverChanged = [NSNumber numberWithInt:1];
                        localChanged = [NSNumber numberWithInt:0];
                    }
//                    NSString* backupGuid = [WizGlobals genGUID];
//                    NSString* backupTitle = [docExist.strTitle stringByAppendingString:NSLocalizedString(@"(Conflicted copy)", nil)];
//                    WizFileManager* fileManager = [WizFileManager shareManager];
//                    NSString* backupPath = [fileManager objectFilePath:backupGuid];
//                    NSError* error = nil;
//                    NSString* sourcePath = [fileManager objectFilePath:docExist.strGuid];
//                    NSArray* contentItems = [fileManager contentsOfDirectoryAtPath:sourcePath error:&error];
//                    if (nil == contentItems || [contentItems count] ==0) {
//                        NSLog(@"backup error %@",error);
//                        break;
//                    }
//                    for (NSString* eachItem in contentItems) {
//                        NSString* sourceItemPath = [sourcePath stringByAppendingPathComponent:eachItem];
//                        NSString* aimItemPath = [backupPath stringByAppendingPathComponent:eachItem];
//                        if (![fileManager copyItemAtPath:sourceItemPath toPath:aimItemPath error:&error]) {
//                            NSLog(@"copy backup error %@",error);
//                        }
//                    }
//
//                    [self.queue inDatabase:^(FMDatabase *db) {
//                        ret= [db executeUpdate:@"insert into WIZ_DOCUMENT (DOCUMENT_GUID, DOCUMENT_TITLE, DOCUMENT_LOCATION, DOCUMENT_URL, DOCUMENT_TAG_GUIDS, DOCUMENT_TYPE, DOCUMENT_FILE_TYPE, DT_CREATED, DT_MODIFIED, DOCUMENT_DATA_MD5, ATTACHMENT_COUNT, SERVER_CHANGED, LOCAL_CHANGED,GPS_LATITUDE ,GPS_LONGTITUDE ,GPS_ALTITUDE ,GPS_DOP ,GPS_ADDRESS ,GPS_COUNTRY ,GPS_LEVEL1 ,GPS_LEVEL2 ,GPS_LEVEL3 ,GPS_DESCRIPTION ,READCOUNT ,PROTECT) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
//                              backupGuid,
//                              backupTitle,
//                              docExist.strLocation,
//                              docExist.strUrl,
//                              docExist.strTagGuids,
//                              docExist.strType,
//                              docExist.strFileType,
//                              [docExist.dateCreated stringSql],
//                              [docExist.dateModified stringSql],
//                              docExist.strDataMd5,
//                              [NSNumber numberWithInt:docExist.nAttachmentCount],
//                              [NSNumber numberWithInt:0],
//                              [NSNumber numberWithInt:WizEditDocumentTypeAllChanged],
//                              [NSNumber numberWithDouble:docExist.gpsLatitude],
//                              [NSNumber numberWithDouble:docExist.gpsLongtitude],
//                              [NSNumber numberWithDouble:docExist.gpsAltitude],
//                              [NSNumber numberWithDouble:docExist.gpsDop],
//                              gpsAddress,
//                              gpsCountry,
//                              gpsLevel1,
//                              gpsLevel2 ,
//                              gpsLevel3,
//                              gpsDescription,
//                              [NSNumber numberWithInt:docExist.nReadCount],
//                              [NSNumber numberWithBool:docExist.nProtected]];
//                    }];
                    break;
                }
                default:
                    break;
            }
        }
        
        [self.queue inDatabase:^(FMDatabase *db) {
            ret =[db executeUpdate:@"update WIZ_DOCUMENT set DOCUMENT_TITLE=?, DOCUMENT_LOCATION=?, DOCUMENT_URL=?, DOCUMENT_TAG_GUIDS=?, DOCUMENT_TYPE=?, DOCUMENT_FILE_TYPE=?, DT_CREATED=?, DT_MODIFIED=?, DOCUMENT_DATA_MD5=?, ATTACHMENT_COUNT=?, SERVER_CHANGED=?, LOCAL_CHANGED=?, GPS_LATITUDE=?, GPS_LONGTITUDE=?, GPS_ALTITUDE=?, GPS_DOP=?, GPS_ADDRESS=?, GPS_COUNTRY=?, GPS_LEVEL1=?, GPS_LEVEL2=?, GPS_LEVEL3=?, GPS_DESCRIPTION=?, READCOUNT=?, PROTECT=?, OWNER = ? where DOCUMENT_GUID= ?",title, location, url, tagGUIDs, type, fileType, [dateCreated stringSql], [dateModified stringSql],dataMd5, nAttachmentCount, serverChanged, localChanged, gpsLatitue, gpsLongtitue, gpsAltitue, gpsDop, gpsAddress, gpsCountry, gpsLevel1, gpsLevel2 , gpsLevel3, gpsDescription, nReadCount, nProtected,strOwner ,guid];
        }];
    }
    else
    {
        if (nil == serverChanged) {
            serverChanged = [NSNumber numberWithInt:1];
        }
        if (nil == localChanged) {
            localChanged = [NSNumber numberWithInt:0];
        }
        [self.queue inDatabase:^(FMDatabase *db) {
           ret= [db executeUpdate:@"insert into WIZ_DOCUMENT (DOCUMENT_GUID, DOCUMENT_TITLE, DOCUMENT_LOCATION, DOCUMENT_URL, DOCUMENT_TAG_GUIDS, DOCUMENT_TYPE, DOCUMENT_FILE_TYPE, DT_CREATED, DT_MODIFIED, DOCUMENT_DATA_MD5, ATTACHMENT_COUNT, SERVER_CHANGED, LOCAL_CHANGED,GPS_LATITUDE ,GPS_LONGTITUDE ,GPS_ALTITUDE ,GPS_DOP ,GPS_ADDRESS ,GPS_COUNTRY ,GPS_LEVEL1 ,GPS_LEVEL2 ,GPS_LEVEL3 ,GPS_DESCRIPTION ,READCOUNT ,PROTECT, OWNER) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",guid, title, location, url, tagGUIDs, type, fileType, [dateCreated stringSql], [dateModified stringSql],dataMd5, nAttachmentCount, serverChanged, localChanged, gpsLatitue, gpsLongtitue, gpsAltitue, gpsDop, gpsAddress, gpsCountry, gpsLevel1, gpsLevel2 , gpsLevel3, gpsDescription, nReadCount, nProtected, strOwner];
        }];
    }
    [self resetDocumentReadCount];
//    [WGGlobalCache clearAbstractForDocument:guid];
    return ret;
}

- (BOOL) updateDocuments:(NSArray *)documents
{
    for (NSDictionary* doc in documents) {
        if (![self updateDocument:doc]) {
            return NO;
        }
    }
    return YES;
}

// attachment
- (BOOL) updateAttachment:(NSDictionary *)attachment
{
    NSString* guid = [attachment valueForKey:DataTypeUpdateAttachmentGuid];
    NSString* title = [attachment valueForKey:DataTypeUpdateAttachmentTitle];
    NSString* description = [attachment valueForKey:DataTypeUpdateAttachmentDescription];
    NSString* dataMd5 = [attachment valueForKey:DataTypeUpdateAttachmentDataMd5];
    NSString* documentGuid = [attachment valueForKey:DataTypeUpdateAttachmentDocumentGuid];
    NSNumber* localChanged = [attachment valueForKey:DataTypeUpdateAttachmentLocalChanged];
    NSNumber* serVerChanged = [attachment valueForKey:DataTypeUpdateAttachmentServerChanged];
    NSDate*   dateModified = [attachment valueForKey:DataTypeUpdateAttachmentDateModified];
    if (nil == title  || [title isBlock]) {
        title = WizStrNoTitle;
    }
    if (nil == description || [description isBlock]) {
        description = @"none";
    }
    if (nil == dataMd5 || [dataMd5 isBlock]) {
        dataMd5 = @"";
    }
    if (nil == dateModified) {
        dateModified = [NSDate date];
    }
    if (nil == localChanged) {
        localChanged = [NSNumber numberWithInt:0];
    }
    if (nil == serVerChanged) {
        serVerChanged = [NSNumber numberWithInt:1];
    }
    __block BOOL ret;
    WizAttachment* attachmentExist =[self attachmentFromGUID:guid];
    if (attachmentExist) {
        if ([localChanged intValue] ==0 && (attachmentExist.bServerChanged || ![dataMd5 isEqualToString:attachmentExist.strDataMd5])) {
            serVerChanged = [NSNumber numberWithBool:1];
        }
        else
        {
            serVerChanged = [NSNumber numberWithBool:0];
        }
        [self.queue inDatabase:^(FMDatabase *db) {
           ret = [db executeUpdate:@"update WIZ_DOCUMENT_ATTACHMENT set DOCUMENT_GUID=?, ATTACHMENT_NAME=?, ATTACHMENT_DATA_MD5=?, ATTACHMENT_DESCRIPTION=?, DT_MODIFIED=?, SERVER_CHANGED=?, LOCAL_CHANGED=? where ATTACHMENT_GUID=?"
               withArgumentsInArray:[NSArray arrayWithObjects:documentGuid, title, dataMd5, description, [dateModified stringSql] , serVerChanged, localChanged,guid, nil]];
        }];
    }
    else
    {
        [self.queue inDatabase:^(FMDatabase *db) {
           ret = [db executeUpdate:@"insert into WIZ_DOCUMENT_ATTACHMENT (ATTACHMENT_GUID ,DOCUMENT_GUID, ATTACHMENT_NAME,ATTACHMENT_DATA_MD5,ATTACHMENT_DESCRIPTION,DT_MODIFIED,SERVER_CHANGED,LOCAL_CHANGED) values(?, ?, ?, ?, ?, ?, ?, ?)"
               withArgumentsInArray:[NSArray arrayWithObjects:guid,documentGuid, title, dataMd5, description, [dateModified stringSql], serVerChanged, localChanged, nil]];
        }];
    }
    return ret;
}

- (BOOL) updateAttachments:(NSArray *)attachments
{
    for (NSDictionary* attach in attachments)
    {
        if (![self updateAttachment:attach]) {
            return NO;
        }
    }
    return YES;
}

- (NSArray*) attachmentsWithWhereFiled:(NSString*)where args:(NSArray*)args
{
    if (nil == where) {
        where = @"";
    }
    __block NSMutableArray* attachments = [NSMutableArray array];
    NSString* sql = [NSString stringWithFormat:@"select ATTACHMENT_GUID ,DOCUMENT_GUID, ATTACHMENT_NAME,ATTACHMENT_DATA_MD5,ATTACHMENT_DESCRIPTION,DT_MODIFIED,SERVER_CHANGED,LOCAL_CHANGED from WIZ_DOCUMENT_ATTACHMENT %@",where];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:sql withArgumentsInArray:args];
        while ([result next]) {
            WizAttachment* attachment = [[WizAttachment alloc] init];
            attachment.strGuid = [result stringForColumnIndex:0];
            attachment.strDocumentGuid = [result stringForColumnIndex:1];
            attachment.strTitle = [result stringForColumnIndex:2];
            attachment.strDataMd5 = [result stringForColumnIndex:3];
            attachment.strDescription = [result stringForColumnIndex:4];
            attachment.dateModified = [[result stringForColumnIndex:5] dateFromSqlTimeString];
            attachment.bServerChanged = [result intForColumnIndex:6];
            attachment.nLocalChanged = [result intForColumnIndex:7];
            [attachments addObject:attachment];
            [attachment release];
        }
        [result close];
    }];
    return attachments;
}

- (WizAttachment*) attachmentFromGUID:(NSString *)guid
{
    return [[self attachmentsWithWhereFiled:@"where ATTACHMENT_GUID=?" args:[NSArray arrayWithObject:guid]] lastObject];
}

- (NSArray*) attachmentsByDocumentGUID:(NSString *)documentGUID
{
    return [self attachmentsWithWhereFiled:@"where DOCUMENT_GUID=?" args:[NSArray arrayWithObject:documentGUID]];
}

- (BOOL) setAttachmentLocalChanged:(NSString *)attchmentGUID changed:(BOOL)changed
{
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
       ret = [db executeUpdate:@"update WIZ_DOCUMENT_ATTACHMENT set LOCAL_CHANGED=? where ATTACHMENT_GUID=?",[NSNumber numberWithBool:changed], attchmentGUID];
    }];
    return ret;
}

- (BOOL) setAttachmentServerChanged:(NSString *)attchmentGUID changed:(BOOL)changed
{
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
       ret = [db executeUpdate:@"update WIZ_DOCUMENT_ATTACHMENT set SERVER_CHANGED=? where ATTACHMENT_GUID=?",[NSNumber numberWithBool:changed], attchmentGUID];
    }];
    return ret;
}

//tag

- (NSArray*) tagsArrayWithWhereField:(NSString*)where   args:(NSArray*)args
{
    if (nil == where) {
        where = @"";
    }
    NSString* sql = [NSString stringWithFormat:@"select TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION  ,LOCALCHANGED, DT_MODIFIED from WIZ_TAG %@",where];
    __block NSMutableArray* array = [NSMutableArray array];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:sql withArgumentsInArray:args];
        while ([result next]) {
            WizTag* tag = [[WizTag alloc] init];
            tag.strGuid = [result stringForColumnIndex:0];
            tag.strParentGUID = [result stringForColumnIndex:1];
            tag.strTitle = [result stringForColumnIndex:2];
            tag.strDescription = [result stringForColumnIndex:3];
            tag.blocalChanged = [result intForColumnIndex:4];
            tag.dateInfoModified = [[result stringForColumnIndex:5] dateFromSqlTimeString];
            [array addObject:tag];
            [tag release];
        }
        [result close];
    }];
    return array;
}

- (WizTag*) tagFromGuid:(NSString *)guid
{
    return [[self tagsArrayWithWhereField:@"where TAG_GUID = ?" args:[NSArray arrayWithObject:guid]] lastObject];
}

- (BOOL) updateTag:(NSDictionary *)tag
{
    NSString* name = [tag valueForKey:DataTypeUpdateTagTitle];
	NSString* guid = [tag valueForKey:DataTypeUpdateTagGuid];
	NSString* parentGuid = [tag valueForKey:DataTypeUpdateTagParentGuid];
	NSString* description = [tag valueForKey:DataTypeUpdateTagDescription];
    NSDate* dtInfoModifed = [tag valueForKey:DataTypeUpdateTagDtInfoModifed];
    NSNumber* localChanged = [tag valueForKey:DataTypeUpdateTagLocalchanged];
    if (nil == localChanged) {
        localChanged = [NSNumber numberWithInt:0];
    }
    if (nil == guid) {
        return NO;
    }
    __block BOOL ret;
    if ([self tagFromGuid:guid]) {
        [self.queue inDatabase:^(FMDatabase *db) {
           ret = [db executeUpdate:@"update WIZ_TAG set TAG_NAME=?, TAG_DESCRIPTION=?, TAG_PARENT_GUID=?, LOCALCHANGED=?, DT_MODIFIED=? where TAG_GUID=?",name, description,parentGuid,localChanged,[dtInfoModifed stringSql], guid];
        }];
    }
    else
    {
        [self.queue inDatabase:^(FMDatabase *db) {
          ret =  [db executeUpdate:@"insert into WIZ_TAG (TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION ,LOCALCHANGED, DT_MODIFIED ) values (?, ?, ?, ?, ?, ?)",guid,parentGuid,name,description,localChanged,[dtInfoModifed stringSql]];
        }];
    }
    return ret;
}

- (BOOL) updateTags:(NSArray *)tags
{
    for (NSDictionary* tag in tags) {
        if (![self updateTag:tag]) {
            return NO;
        }
    }
    return YES;
}
//- (void) genTagNamePath:(WizTag*)parentTag rest:(NSMutableArray*)rest
//{
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"parentGUID == %@",parentTag.strGuid];
//    NSPredicate* rpredicate = [NSPredicate predicateWithFormat:@"parentGUID != %@",parentTag.strGuid];
//    NSArray* section = [rest filteredArrayUsingPredicate:predicate];
//    [rest filterUsingPredicate:rpredicate];
//    for (WizTag* each in section) {
//        each.namePath = [parentTag.namePath stringByAppendingFormat:@"%@/",ea];
//        [self genTagNamePath:each rest:rest];
//    }
//}

//- (void) getTagNamePath:(NSMutableArray*)array
//{
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"parentGUID.length != 0"];
//    NSPredicate* rPredicate = [NSPredicate predicateWithFormat:@"parentGUID.length == 0"];
//    NSArray* root = [array filteredArrayUsingPredicate:rPredicate];
//    NSMutableArray* rest =[NSMutableArray arrayWithArray:[array filteredArrayUsingPredicate:predicate]];
//    
//    for (WizTag* each in root) {
//        each.namePath = [NSString stringWithFormat:@"/%@/",each.guid];
//        [self genTagNamePath:each rest:rest];
//    }
//}
- (NSArray*) allTagsForTree
{
    NSMutableArray* allTags =[NSMutableArray arrayWithArray:[self tagsArrayWithWhereField:@"" args:nil]];
    return allTags;
}

- (NSArray*) tagsForUpload
{
    return [self tagsArrayWithWhereField:@"where LOCALCHANGED != 0" args:nil];
}

- (NSString*) tagAbstractString:(NSString *)guid
{
    NSString* where = [NSString stringWithFormat:@"%@%@%@",@"%",guid,@"%"];
    __block NSMutableString* ret = [NSMutableString string];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:@"select DOCUMENT_TITLE from WIZ_DOCUMENT where DOCUMENT_TAG_GUIDS like ? order by DT_MODIFIED limit 6",where];
        NSInteger i = 0;
        while ([result next]) {
            [ret insertString:[NSString stringWithFormat:@"%d ",i++] atIndex:ret.length];
            [ret appendFormat:@"%@\n",[result stringForColumnIndex:0]];
        }
        [result close];
    }];
    return ret;
}
- (BOOL) setTagLocalChanged:(NSString *)guid changed:(BOOL)changed
{
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
       ret = [db executeUpdate:@"update WIZ_TAG set LOCAL_CHANGED=? where TAG_GUID =?",guid
         , [NSNumber numberWithBool:changed]];
    }];
    return ret;
}
//
- (BOOL) addDeletedGUIDRecord:(NSString *)guid type:(NSString *)type
{
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
        ret = [db executeUpdate:@"insert into WIZ_DELETED_GUID (DELETED_GUID, GUID_TYPE, DT_DELETED) values (?, ?, ?)",guid, type, [[NSDate date] stringSql]];
    }];
    return ret;
}

- (NSArray*) deletedGuidWithWhereField:(NSString*)whereField args:(NSArray*)args
{
    if (whereField == nil) {
        whereField = @"";
    }
    NSString* sql = [NSString stringWithFormat:@"SELECT DELETED_GUID, GUID_TYPE, DT_DELETED from WIZ_DELETED_GUID %@",whereField];
    
    __block NSMutableArray* array = [NSMutableArray array];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:sql withArgumentsInArray:args];
        while ([result next]) {
            WizDeletedGUID* deleteGuid = [[WizDeletedGUID alloc] init];
            deleteGuid.strGuid = [result stringForColumnIndex:0];
            deleteGuid.strType = [result stringForColumnIndex:1];
            deleteGuid.dateDeleted = [result stringForColumnIndex:2];
            [array addObject:deleteGuid];
            [deleteGuid release];
        }
        [result close];
    }];
    
    return array;
}

- (NSArray*) deletedGUIDsForUpload
{
    return [self deletedGuidWithWhereField:nil args:nil];
}

- (BOOL) clearDeletedGUIDs
{
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
       ret= [db executeUpdate:@"delete from WIZ_DELETED_GUID"];
    }];
    return ret;
}

- (BOOL) deleteAttachment:(NSString *)attachGuid
{
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
        ret= [db executeUpdate:@"delete from WIZ_DOCUMENT_ATTACHMENT where ATTACHMENT_GUID=?",attachGuid];
    }];
    if (ret) {
        [self addDeletedGUIDRecord:attachGuid type:WizAttachmentKeyString];
    }
    return ret;
}

- (BOOL) deleteDocument:(NSString *)documentGUID
{
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
        ret= [db executeUpdate:@"delete from WIZ_DOCUMENT where DOCUMENT_GUID=?",documentGUID];
    }];
    if (ret) {
        [self addDeletedGUIDRecord:documentGUID type:WizDocumentKeyString];
    }
    return ret;
}

- (BOOL) deleteTag:(NSString *)tagGuid
{
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
        ret= [db executeUpdate:@"delete from WIZ_TAG where TAG_GUID=?",tagGuid];
    }];
    if (ret) {
        [self addDeletedGUIDRecord:tagGuid type:WizTagKeyString];
    }
    return ret;
}
//folder
- (BOOL) isLocationExists:(NSString*)location
{
    
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:@"select DOCUMENT_LOCATION from WIZ_LOCATION where DOCUMENT_LOCATION=?",location];
        if ([result next]) {
            ret =  YES;
        }
        else
        {
            ret=  NO;
        }
        [result close];
    }];
    return ret;
    
}
- (BOOL) updateLocation:(NSString*)location
{
    if ([self isLocationExists:location]) {
        return YES;
    }
    
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
        ret= [db executeUpdate:@"insert into WIZ_LOCATION (DOCUMENT_LOCATION) values (?)",location];
    }];
    return ret;
}

- (BOOL) updateLocations:(NSArray *)locations
{
    for (NSString* location in locations)
    {
        if (![self updateLocation:location])
        {
            return NO;
        }
    }
    return YES;
}

- (NSArray*) allLocationsForTree
{
    __block NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:@"select distinct DOCUMENT_LOCATION from WIZ_DOCUMENT"];
        
        while ([result next]) {
            NSString* location = [result stringForColumnIndex:0];
            if (!location) {
                continue;
            }
            [dic setObject:location forKey:location];
        }
        [dic setObject:@"/My Mobiles/" forKey:@"/My Mobiles/"];
        [result close];
    }];
    return [dic allValues];
}

//

- (NSInteger) fileCountOfLocation:(NSString *)location
{
    __block NSInteger count = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:@"select count(*) from WIZ_DOCUMENT where DOCUMENT_LOCATION =?",location];
        if ([result next]) {
            count = [result intForColumnIndex:0];
        }
        [result close];
    }];
    return count;
}

- (NSInteger) filecountWithChildOfLocation:(NSString *)location
{
    __block NSInteger count = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:@"select count(*) from WIZ_DOCUMENT where DOCUMENT_LOCATION like ?",[location sqlLikeString] ];
        if ([result next]) {
            count = [result intForColumnIndex:0];
        }
        [result close];
    }];
    return count;
}

- (NSInteger) fileCountOfTag:(NSString *)tagGUID
{
    __block NSInteger count = 0;
    [self.queue inDatabase:^(FMDatabase *db) {
        NSString* tagLikeString = [NSString stringWithFormat:@"%@%@%@",@"%",tagGUID,@"%"];
        FMResultSet* result = [db executeQuery:@"select count(*) from WIZ_DOCUMENT where DOCUMENT_TAG_GUIDS like ?",tagLikeString];
        if ([result next]) {
            count = [result intForColumnIndex:0];
        }
        [result close];
    }];
    return count;
}
- (NSString*) folderAbstractString:(NSString *)folderKey
{
    __block NSMutableString* ret = [NSMutableString string];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:@"select DOCUMENT_TITLE from WIZ_DOCUMENT where DOCUMENT_LOCATION = ? order by DT_MODIFIED limit 6",folderKey];
        
        NSInteger i = 0;
        while ([result next]) {
            [ret insertString:[NSString stringWithFormat:@"%d ",i++] atIndex:ret.length];
            [ret appendFormat:@"%@\n",[result stringForColumnIndex:0]];
        }
        [result close];
    }];
    return ret;
}
@end
