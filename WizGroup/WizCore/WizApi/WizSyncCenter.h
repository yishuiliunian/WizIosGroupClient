//
//  WizSyncCenter.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-22.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizModuleTransfer.h"
@interface NSOperationQueue (WizOperation)
+ (NSOperationQueue*) backGroupQueue;
@end
@protocol WizXmlDownloadDocumentDelegate <NSObject>

- (void) didDownloadDocumentSucceed:(NSString*)docGuid;
- (void) didDownloadDocumentFaild:(NSString*)docGuid;
- (void) didDownloadDocumentStart:(NSString*)docguid;
@end


@protocol  WizXmlUploadDocumentDelegate <NSObject>

- (void) didUploadDocumentSucceed:(NSString*)docguid;
- (void) didUploadDocumentFaild:(NSString*)docguid;
- (void) didUploadDocumentStart:(NSString*)docguid;

@end

@protocol WizXmlSyncKbDelegate <NSObject>

- (void) OnSyncKbBegin:(NSString*)kbguid;
- (void) OnSyncKbEnd:(NSString*)kbguid;

@end

//

@protocol WizXmlVerifyAccountDelegate <NSObject>

- (void) didVerifyAccountSucceed:(NSString*)accountUserId;
- (void) didVerifyAccountFaild:(NSString*)accountUserId;

@end

@protocol WizXmlSearchDelegate <NSObject>

- (void) didSearchedSucceed:(WizModule::CWizDocumentDataArray)array;
- (void) didSearchedFailed;

@end

@interface WizXmlVerifyAccountThread : NSThread
@property (nonatomic, retain) NSString* accountUserID;
@property (nonatomic, retain) NSString* accountPassword;
@property (nonatomic, assign) id<WizXmlVerifyAccountDelegate> delegate;
@end

@interface WizUINotifactionCenter : NSObject
- (void) addObserver:(id)observer kbguid:(NSString*)kbguid;
+ (bool) isSyncingGuid:(NSString*)guid;
- (void) changedSyncStateWithGuid:(const char*)guid state:(int)state;
- (void) changedSyncState:(NSString*)guid statue:(NSNumber*)syncStatue;
+ (id) shareInstance;
@end


@interface WizSyncCenter : NSObject
+ (id) defaultCenter;
+ (void) startBackgroudThreads;
+ (bool) syncAccount:(NSString*)accountUserId password:(NSString*)password;
@end


//
@interface WizXmlOperation : NSOperation
{
    std::string accountUserID;
    std::string accountPassword;
    std::string workKbguid;
    std::string token;
    std::string kbApiurl;
}
- (id) initWithUserID:(const char*)userId password:(const char*)password kbguid:(const char*)kbguid;
- (void) getKbServerUrlFaild;
- (void) getKbServerUrlSucceed;
@end

@interface WizXmlSearchServer : WizXmlOperation
@property (nonatomic, retain) NSString* keyWords;
@property (nonatomic, assign) id<WizXmlSearchDelegate> delegate;
@end


@interface OWizSyncAccountOperation : NSOperation
{
    NSString* accountUserId;
    NSString* accountPassword;
    NSString* serverUrl;
    BOOL isGroup;
}
- (id) initWithUserId:(NSString*)userId password:(NSString*)password serverUrl:(NSString*)url isGroup:(BOOL)isGroup;
@end

@interface WizSyncKbThread : NSThread
@end
@interface WizSyncDownloadObjectThread : NSThread
@end