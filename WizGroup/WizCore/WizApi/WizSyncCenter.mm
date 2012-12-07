//
//  WizSyncCenter.m
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-22.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizSyncCenter.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizFileManager.h"
#import "WizXmlServer.h"
#import "WizAccountManager.h"
#import <vector>
#import <map>
#import <string>
#import "WizGlobalCache.h"
using namespace std;

@implementation NSOperationQueue(WizOperation)

+ (NSOperationQueue*)backGroupQueue
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[NSOperationQueue class] category:@"WizBackgroudOperation"];
    }
}

@end

@implementation WizXmlVerifyAccountThread
@synthesize accountPassword;
@synthesize accountUserID;
@synthesize delegate;

- (void) dealloc
{
    delegate = nil;
    [accountPassword release];
    [accountUserID release];
    [super dealloc];
}
- (void) main
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    if (self.accountUserID == nil || self.accountPassword == nil) {
        MULTIMAIN(^{
           [self.delegate didVerifyAccountFaild:self.accountUserID]; 
        });
        return;
    }
    WizXmlAccountServer server([[[WizGlobals wizServerUrl] absoluteString] UTF8String]);
    if (server.verifyAccount(WizNSStringToCString(self.accountUserID), WizNSStringToCString(self.accountPassword))) {
        MULTIMAIN(^{
            [self.delegate didVerifyAccountSucceed:self.accountUserID];
        });
    }
    else
    {
        MULTIMAIN(^{
            [self.delegate didVerifyAccountFaild:self.accountUserID];
        });
    }
    [pool drain];
}

@end


@implementation WizSyncCenter
- (id) init
{
    self = [super init];
    if (self) {
        
        
    }
    return self;
}
+ (void) startBackgroudThreads
{
    for (int i = 0; i < 3; i ++) {
        WizSyncKbThread* thread1 = [[[WizSyncKbThread alloc] init] autorelease];
        [thread1 start];
        WizSyncDownloadObjectThread* thread = [[[WizSyncDownloadObjectThread alloc] init] autorelease];
        [thread start];
    }
}

+ (id) defaultCenter
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizSyncCenter class]];
    }
}

+ (bool) syncAccount:(NSString*)accountUserId password:(NSString*)password
{
    
    if ([WizUINotifactionCenter isSyncingGuid:accountUserId]) {
        return true;
    }
    OWizSyncAccountOperation* oper = [[OWizSyncAccountOperation alloc] initWithUserId:accountUserId password:password serverUrl:[[WizGlobals wizServerUrl] absoluteString] isGroup:YES];
    [[NSOperationQueue backGroupQueue] addOperation:oper];
    [oper release];
    return true;
}

@end
typedef map<std::string, vector<id>> CWizObserverMap;

@interface WizUINotifactionCenter ()
{
    CWizObserverMap observerMap;
    
}
@property (atomic, retain) NSMutableDictionary* syncStateDic;
@end

@implementation WizUINotifactionCenter
@synthesize syncStateDic;
- (void) dealloc
{
    [syncStateDic release];
    [super dealloc];
}
+ (id) shareInstance
{
    @synchronized(self)
    {
        return [WizGlobalData shareInstanceFor:[WizUINotifactionCenter class]];
    }
}

- (id) init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didXmlSyncStateChanged:) name:WizXmlSyncStateChangedKey object:nil];
        syncStateDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}
#warning check for unwanted repeat adding observer
- (void) addObserver:(id)observer kbguid:(NSString *)kbguid
{
    CWizObserverMap::iterator  itor= observerMap.find(WizNSStringToStdString(kbguid));
    if (itor == observerMap.end()) {
        vector<id> observerVector;
        observerVector.push_back(observer);
        observerMap[WizNSStringToStdString(kbguid)] = observerVector;
    }
    else
    {
        itor->second.push_back(observer);
    }
    
}

- (void) changedSyncStateWithGuid:(const char*)guid state:(int)state
{
    @synchronized(self)
    {
       [self.syncStateDic setObject:WizCStringToNSString(guid) forKey:[NSNumber numberWithInt:state]]; 
    }
}

- (void) changedSyncState:(NSString*)guid statue:(NSNumber*)syncStatue
{
    [self.syncStateDic setObject:syncStatue forKey:guid];
}

- (bool) isSyncingGuid:(NSString*)guid
{
    NSNumber* number = [self.syncStateDic objectForKey:guid];
    if (number == nil) {
        return false;
    }
    if ([number integerValue] != WizXmlSyncStateEnd) {
        return true;
    }
    return false;
}

- (void) removeObserver:(NSObject*)object forKbguid:(NSString*)kbguid
{
    CWizObserverMap::iterator  itor= observerMap.find(WizNSStringToStdString(kbguid));
    if (itor != observerMap.end()) {
        for (vector<id>::iterator obItor = itor->second.begin(); obItor != itor->second.end(); ) {
            if ([*obItor isEqual:object]) {
                obItor = itor->second.erase(obItor);
            }
            else
            {
                obItor++;
            }
        }
    }
}

+ (bool) isSyncingGuid:(NSString *)guid
{
    return [[WizUINotifactionCenter shareInstance] isSyncingGuid:guid];
}

- (void) sendMessageToSyncKbObserver:(id)observer  state:(WizXmlSyncState)state guid:(NSString*)guid
{
    switch (state) {
        case WizXmlSyncStateStart:
            [observer OnSyncKbBegin:guid];
            break;
        case WizXmlSyncStateEnd:
            [observer OnSyncKbEnd:guid];
            break;
        default:
            break;
    }
 
}

- (void) sendMessageToDownloadDocumentObserver:(id)observer  state:(WizXmlSyncState)state guid:(NSString*)guid
{
    switch (state) {
        case WizXmlSyncStateEnd:
            [observer didDownloadDocumentSucceed:guid];
            break;
        case WizXmlSyncStateError:
            [observer didDownloadDocumentFaild:guid];
            break;
        case WizXmlSyncStateStart:
            [observer didDownloadDocumentStart:guid];
        default:
            break;
    }
}

- (void) sendMessageToUploadDocumentObserver:(id)observer  state:(WizXmlSyncState)state guid:(NSString*)guid
{
    switch (state) {
        case WizXmlSyncStateEnd:
            [observer didUploadDocumentSucceed:guid];
            break;
        case WizXmlSyncStateError:
            [observer didUploadDocumentFaild:guid];
            break;
        case WizXmlSyncStateStart:
            [observer didUploadDocumentStart:guid];
        default:
            break;
    }
}

- (void) didXmlSyncStateChanged:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSString* guid = [userInfo objectForKey:@"guid"];
    NSNumber* state = [userInfo objectForKey:@"state"];
    //
    [self changedSyncState:guid statue:state];
    //
    NSLog(@"the %@ is on state %d",guid, [state integerValue]);
    CWizObserverMap::iterator itor = observerMap.find(WizNSStringToStdString(guid));
    if (itor != observerMap.end()) {
        for (vector<id>::const_iterator observerItor = itor->second.begin(); observerItor != itor->second.end(); observerItor++) {
            id observer = *observerItor;
            if ([observer conformsToProtocol:@protocol(WizXmlSyncKbDelegate)])
            {
                [self sendMessageToSyncKbObserver:observer state:[state integerValue] guid:guid];
            }
            if ([observer conformsToProtocol:@protocol(WizXmlDownloadDocumentDelegate)]) {
                [self sendMessageToDownloadDocumentObserver:observer state:[state integerValue] guid:guid];
            }
            if ([observer conformsToProtocol:@protocol(WizXmlUploadDocumentDelegate)]) {
                [self sendMessageToDownloadDocumentObserver:observer state:[state integerValue] guid:guid];
            }
        }
    }
}
@end


@implementation WizXmlOperation

- (id) initWithUserID:(const char *)userId password:(const char *)password kbguid:(const char *)kbguid
{
    self = [super init];
    if (self) {
        accountUserID = userId;
        accountPassword = password;
        workKbguid = kbguid;
    }
    return self;
}
- (void) getKbServerUrlFaild
{
    
}
- (void) getKbServerUrlSucceed
{
    
}
- (void) main
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    WizXmlAccountServer accountServer([WizGlobals wizServerUrlStdString]);
    if (!accountServer.accountLogin(accountUserID.c_str(), accountPassword.c_str())) {
        [self getKbServerUrlFaild];
    }
    else
    {
        token = accountServer.loginData.token;
        if (workKbguid == WizGlobalPersonalKbguid || workKbguid == "" || workKbguid == accountServer.loginData.kbguid ) {
            kbApiurl = accountServer.loginData.kapiUrl;
        }
        else
        {
            CWizGroupArray groupsArray;
            if (!accountServer.getAccountGroupsList(groupsArray)) {
                [self getKbServerUrlFaild];
            }
            else
            {
                for (CWizGroupArray::iterator itor = groupsArray.begin(); itor != groupsArray.end(); itor++) {
                    if (itor->kbGuid == workKbguid) {
                        kbApiurl = itor->kbApiUrl;
                    }
                }
            }
        }
        [self getKbServerUrlSucceed];
   }
   [pool drain];
}
@end




@implementation WizXmlSearchServer
@synthesize keyWords;
@synthesize delegate;
- (void) dealloc
{
    [keyWords release];
    [super dealloc];
}

- (void) sendSucceedMassage:(CWizDocumentDataArray)array
{
    MULTIMAIN(^{
        [self.delegate didSearchedSucceed:array];
    });
}

- (void) sendFaildMassage
{
    MULTIMAIN(^{
        [self.delegate didSearchedFailed];
    });
}

- (void) getKbServerUrlSucceed
{
    WizXmlDbServer dbServer(token, workKbguid, kbApiurl);
    CWizDocumentDataArray docArray;
    if (!dbServer.getDocumentListByKey(0, 200, WizNSStringToCString(keyWords), docArray)) {
        [self sendFaildMassage];
    }
    [self sendSucceedMassage:docArray];
}

- (void) getKbServerUrlFaild
{
    [self sendFaildMassage];
}

@end


@interface WizXmlDownloadServer :WizXmlOperation

@property (nonatomic, retain) NSString* documentGuid;

@end

@implementation WizXmlDownloadServer
@synthesize documentGuid;

- (void) dealloc
{
    [documentGuid release];
    [super dealloc];
}

- (void) getKbServerUrlSucceed
{
    WIZSYNCINFODATA syncData;
    CWizStates state([self.documentGuid UTF8String], WizXmlSyncStateEnd, WizXmlSyncStateStart);

    NSString* dbPath = [[WizFileManager shareManager] metaDataBasePathForAccount:WizStdStringToNSString(accountUserID.c_str()) kbGuid:WizStdStringToNSString(workKbguid.c_str())];
    
    syncData.kbGuid = workKbguid;
    syncData.token = token;
    syncData.serverUrl = kbApiurl;
    syncData.dbPath = WizNSStringToStdString(dbPath);
    WizXmlSyncKb syncKb(syncData);
    
    NSString* downloadTempFile = [[WizFileManager shareManager] downloadObjectTempFilePath:documentGuid accountUserId:WizStdStringToNSString(accountUserID)];
    if (!syncKb.downloadDocument(WizNSStringToCString(documentGuid), WizNSStringToCString(downloadTempFile)))
    {
        WizLogError(@"download document error");
    }
    NSString* objectPath = [[WizFileManager shareManager] wizObjectFilePath:documentGuid accountUserId:WizStdStringToNSString(accountUserID)];
    if (![[WizFileManager shareManager] unzipWizObjectData:downloadTempFile toPath:objectPath]) {
        WizLogError(@"unzip error");
    }
    [[WizFileManager shareManager] deleteFile:downloadTempFile];
}
@end

@implementation OWizSyncAccountOperation
- (void) dealloc
{
    [accountPassword release];
    [accountUserId release];
    [serverUrl release];
    [super dealloc];
}
- (id) initWithUserId:(NSString*)userId password:(NSString*)password serverUrl:(NSString*)url isGroup:(BOOL)isGroup_
{
    self = [super init];
    if (self) {
        accountUserId = [userId retain];
        accountPassword = [password retain];
        serverUrl = [url retain];
        isGroup = isGroup;
    }
    return self;
}
- (void) main
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    WizXmlSyncAccount account = WizXmlSyncAccount(WizNSStringToCString(accountUserId), WizNSStringToCString(accountPassword), WizNSStringToCString(serverUrl));
    account.sync(isGroup, false);
    [pool drain];
}
@end



@implementation WizSyncKbThread

- (void) main
{
    while (1) {
        WizModule::WIZSYNCINFODATA syncInfoData;
        if (g_GetSyncKbInfo(syncInfoData)) {
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
            WizXmlSyncKb syncKb(syncInfoData);
            syncKb.sync();
            g_RemoveSyncKbInfo(syncInfoData);
            [pool drain];
        }
        else
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
       
    }
}

@end


@implementation WizSyncDownloadObjectThread

- (BOOL) downloadObject:(const WIZSYNCDOWNLOADOBJECT&)data
{
    WizXmlAccountServer server(data.serverUrl.c_str());
    std::string token;
    std::string kapiurl;
    if (!server.getTokenAndKapiurl(data.accountUserId.c_str(), data.accountPassword.c_str(), data.kbguid.c_str(), token, kapiurl)) {
        return false;
    }
    WIZSYNCINFODATA syncInfo;
    syncInfo.accountUserId = data.accountUserId;
    syncInfo.kbGuid = data.kbguid;
    syncInfo.dbPath  = CWizFileManager::shareInstance()->metaDatabasePath(data.kbguid, data.accountUserId);
    syncInfo.isOnlyUpload = NO;
    syncInfo.serverUrl = kapiurl;
    syncInfo.token = token;
    WizXmlSyncKb syncServer(syncInfo);
    syncServer.OnState(data.objectGuid.c_str(), WizXmlSyncStateStart);
    if (data.objectType == "document") {
        std::string downloadFilePath = CWizFileManager::shareInstance()->objectFilePath(data.objectGuid, data.accountUserId);
        if (!syncServer.downloadDocument(data.objectGuid.c_str(), downloadFilePath.c_str())) {
            syncServer.OnState(data.objectGuid.c_str(), WizXmlSyncStateError);
            return false;
        }
    }
    syncServer.OnState(data.objectGuid.c_str(), WizXmlSyncStateEnd);
    return true;
}

- (void) main
{
    while (true) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        WIZSYNCDOWNLOADOBJECT data;
        if (g_GetDownloadObject(data)) {
            if (![self downloadObject:data]) {
                WizLogError(@"download object error,%s",data.objectGuid.c_str());
            }
            if (data.objectType == "document") {
                WIZDOCUMENTGENERATEABSTRACTDATA genData;
                genData.guid = data.objectGuid;
                genData.accountUserID = data.accountUserId;
                g_AddDocumentGenerateAbstractData(genData);
            }
            g_RemoveDownloadObject(data);
        }
        else
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        [pool drain];
    }
}
@end


@interface WizSyncOneKbOperation : NSOperation
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* kbguid;
@property (nonatomic, assign) BOOL isOnlyUpload;
@end

@implementation WizSyncOneKbOperation
@synthesize accountUserId;
@synthesize kbguid;
@synthesize isOnlyUpload;
- (void) main
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    WizXmlAccountServer accountServer([WizGlobals wizServerUrlStdString]);
    NSString* password = [[WizAccountManager defaultManager] accountPasswordByUserId:self.accountUserId];
    
    [pool drain];
}
@end