//
//  WizApi.h
//  WizCore
//
//  Created by wiz on 12-8-1.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLRPCConnection.h"
#import "XMLRPCRequest.h"
#import "WizDbManager.h"

extern NSString* const SyncMethod_ClientLogin;
extern NSString* const SyncMethod_ClientLogout;
extern NSString* const SyncMethod_CreateAccount;
extern NSString* const SyncMethod_ChangeAccountPassword;
extern NSString* const SyncMethod_GetAllCategories;
extern NSString* const SyncMethod_GetAllTags;
extern NSString* const SyncMethod_PostTagList;
extern NSString* const SyncMethod_DocumentsByKey;
extern NSString* const SyncMethod_DownloadDocumentList;
extern NSString* const SyncMethod_DocumentsByCategory;
extern NSString* const SyncMethod_DocumentsByTag;
extern NSString* const SyncMethod_DocumentPostSimpleData;
extern NSString* const SyncMethod_DownloadDeletedList;
extern NSString* const SyncMethod_UploadDeletedList;
extern NSString* const SyncMethod_DownloadObject;
extern NSString* const SyncMethod_UploadObject;
extern NSString* const SyncMethod_AttachmentPostSimpleData;
extern NSString* const SyncMethod_GetAttachmentList;
extern NSString* const SyncMethod_GetUserInfo;
extern NSString* const SyncMethod_GetGropKbGuids;
extern NSString* const SyncMethod_GetAllObjectVersion;

typedef NS_ENUM(NSInteger, WizApiStatue)
{
    WizApiStatueNormal = 0,
    WizApiStatueBusy = 1,
    WizApistatueError =2
};
const static NSInteger WizApiAttemptTimeMax = 5;

@class WizApi;
@protocol WizApiDelegate
- (void) wizApiDidChangedStatue:(WizApiStatue)statue forKey:(NSString*)key;
- (void) wizApiEnd:(WizApi*)api withSatue:(enum WizApiStatue)statue;
@end

@interface WizApi : NSObject
{
    NSInteger attemptTime;
}
@property (nonatomic, assign)   id<WizApiDelegate> apiDelegate;
@property (nonatomic, readonly) WizApiStatue statue;
@property (nonatomic ,retain)   XMLRPCConnection* connection;
@property (nonatomic, retain)   NSString* kbGuid;
@property (nonatomic, retain)   NSString* accountUserId;
- (BOOL) start;
- (void) end;
- (void) cancel;
- (BOOL) onError:(NSError*)error;
- (void) xmlrpcDoneSucced:(id)retObject forMethod:(NSString*)method;
-(BOOL)executeXmlRpcWithArgs:(NSMutableDictionary*)postParams  methodKey:(NSString*)methodKey  needToken:(BOOL)isNeedToken;
- (void) reduceAttempTime;
- (id<WizMetaDataBaseDelegate>) groupDataBase;
//
- (void) changeStatue:(WizApiStatue) statue;
- (NSString*) apiStatueKey;
//
- (NSInteger) listCount;

- (id) initWithKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId apiDelegate:(id<WizApiDelegate>)delegate;
@end