//
//  WizMetaDataBaseDelegate.h
//  WizCore
//
//  Created by wiz on 12-8-23.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizDocument.h"
#import "WizAttachment.h"
#import "WizTag.h"
#import "WizDeletedGUID.h"

@protocol WizMetaDataBaseDelegate <NSObject>
// version
- (int64_t) documentVersion;
- (BOOL)    setDocumentVersion:(int64_t)ver;
- (int64_t) deletedGUIDVersion;
- (BOOL)    setDeletedGUIDVersion:(int64_t)ver;
- (int64_t) tagVersion;
- (BOOL) setTagVersion:(int64_t)ver;
- (int64_t) attachmentVersion;
- (BOOL) setAttachmentVersion:(int64_t)ver;
// read count
- (int64_t) documentUnReadCount;
- (BOOL)    setDocumentUnReadCount:(int64_t)count;
// delete object
- (BOOL) deleteAttachment:(NSString *)attachGuid;
- (BOOL) deleteTag:(NSString*)tagGuid;
- (BOOL) deleteDocument:(NSString*)documentGUID;
- (NSArray*) deletedGUIDsForUpload;
- (BOOL) clearDeletedGUIDs;
//document
- (WizDocument*) documentFromGUID:(NSString*)documentGUID;
- (BOOL)     updateDocument:(NSDictionary*) doc;
- (BOOL)     updateDocuments:(NSArray *)documents;
- (NSArray*) recentDocuments;
- (NSArray*) documentsByTag: (NSString*)tagGUID;
- (NSArray*) documentsByNotag;
- (NSArray*) documentsByKey: (NSString*)keywords;
- (NSArray*) documentsByLocation: (NSString*)parentLocation;
- (NSArray*) documentForUpload;
- (NSArray*) documentsForCache:(NSInteger)duration;
- (WizDocument*) documentForClearCacheNext;
- (WizDocument*) documentForDownloadNext;
- (NSArray*) unreadDocuments;
- (BOOL) setDocumentServerChanged:(NSString*)guid changed:(BOOL)changed;
- (BOOL) setDocumentLocalChanged:(NSString*)guid  changed:(enum WizEditDocumentType)changed;
- (BOOL) updateDocumentReadCount:(NSString*)documentGuid;
//tag
- (NSArray*) allTagsForTree;
- (BOOL) updateTag: (NSDictionary*) tag;
- (BOOL) updateTags: (NSArray*) tags;
- (NSArray*) tagsForUpload;
- (int) fileCountOfTag:(NSString *)tagGUID;
- (WizTag*) tagFromGuid:(NSString *)guid;
- (NSString*) tagAbstractString:(NSString*)guid;
- (BOOL) setTagLocalChanged:(NSString*)guid changed:(BOOL)changed;
//attachment
-(NSArray*) attachmentsByDocumentGUID:(NSString*) documentGUID;
- (BOOL) setAttachmentLocalChanged:(NSString *)attchmentGUID changed:(BOOL)changed;
- (BOOL) setAttachmentServerChanged:(NSString *)attchmentGUID changed:(BOOL)changed;
- (BOOL) updateAttachment:(NSDictionary *)attachment;
- (BOOL) updateAttachments:(NSArray *)attachments;
- (WizAttachment*) attachmentFromGUID:(NSString *)guid;
//folder
- (BOOL) updateLocations:(NSArray*) locations;
- (NSArray*) allLocationsForTree;
- (int) fileCountOfLocation:(NSString *)location;
- (int) filecountWithChildOfLocation:(NSString*) location;
- (NSString*) folderAbstractString:(NSString*)folderKey;
@end
