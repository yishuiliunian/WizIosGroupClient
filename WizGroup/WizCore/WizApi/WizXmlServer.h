//
//  WizXmlServer.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-16.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iostream>
#import "XMLRPCConnection.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"
#import "WizStrings.h"
#import "WizSyncCenter.h"
#import "WizMetaDb.h"
#import "WizLock.h"
#import "WizFileManager.h"
#import "WizSyncQueque.h"


#define NSStringFromStdString(__str) [NSString stringWithUTF8String:__str.c_str()]

extern NSString* const SyncMethod_ClientLogin;
extern NSString* const SyncMethod_ClientLogout;
extern NSString* const SyncMethod_CreateAccount;
extern NSString* const SyncMethod_ChangeAccountPassword;
extern NSString* const SyncMethod_GetAllCategories;
extern NSString* const SyncMethod_DownloadAllTags;
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
extern NSString* const SyncMethod_DownloadAttachmentList;
extern NSString* const SyncMethod_GetUserInfo;
extern NSString* const SyncMethod_GetGropKbGuids;
extern NSString* const SyncMethod_DownloadAllObjectVersion;
extern NSString* const SyncMethod_DownloadDocumentListByGuids;
extern NSString* const SyncMethod_DownloadAttachmentListByGuids;

extern NSString* const WizXmlSyncStateChangedKey;




typedef NS_ENUM(int, WizXmlEvent) {
    WizXmlEventSucceed = 1,
    WizXmlEventError = 0,
    WizXmlEventUnknow = -1
};

typedef NS_ENUM(NSInteger, WizXmlSyncState) {
    WizXmlSyncStateStart = 1,
    WizXmlSyncStateEnd = 0,
    WizXmlSyncStateDownloadAllVersions = 2,
    WizXmlSyncStateUploadDeletedList =3,
    WizXmlSyncStateDownloadDeletedList = 4,
    WizXmlSyncStateDownloadTagList = 5,
    WizXmlSyncStateUploadTagList = 6,
    WizXmlSyncStateDownloadDocumentList = 7,
    WizXmlSyncStateDownloadAttachmentList = 8,
    WizXmlSyncStateUploadDocument = 9,
    WizXmlSyncStateUploadAttachment = 10,
    WizXmlSyncStateError = -1
};

typedef NS_ENUM(int , WizXmlSyncError)
{
    WizXmlSyncErrorTokenUnactive = 301,
};

class CWizStates {
    std::string guid;
    WizXmlSyncState lastState;
public:
    CWizStates(const char* guid_, WizXmlSyncState toState, WizXmlSyncState fromState)
    {
        guid = guid_;
        lastState = fromState;
        [[WizUINotifactionCenter shareInstance] changedSyncStateWithGuid:guid_ state:toState];
    };
    ~CWizStates()
    {
        [[WizUINotifactionCenter shareInstance] changedSyncStateWithGuid:guid.c_str() state:lastState];
    }
};


class IWizXmlSyncEvents
{
private:
    bool m_bStop;
    int m_nLastError;
public:
    virtual void SetStop(bool b){m_bStop = b;};
    virtual bool IsStop(){return m_bStop;};
    virtual int GetLastErrorCode(){return m_nLastError;};
    virtual void SetLastErrorCode(int errorCode){m_nLastError = errorCode;};
    void OnState(const char* guid, WizXmlSyncState state) {
        NSString* nGuid = WizCStringToNSString(guid);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:nGuid forKey:@"guid"];
            [userInfo setObject:[NSNumber numberWithInt:state] forKey:@"state"];
            [[NSNotificationCenter defaultCenter] postNotificationName:WizXmlSyncStateChangedKey  object:nil userInfo:userInfo];
        });
    };
    void OnWarning(const char* text){};
    void OnError(WizXmlSyncError errorCode)
    {
        if (errorCode == 301) {
            SetStop(true);
        }
        m_nLastError = errorCode;
    };
    void OnError(NSError* error)
    {
        OnError(error.code);
        WizLogError(error.description);
    };
    
};

class WizXmlServer {
//    bool isStoped;
//    int lastErrorCode;
//    bool isStop(){return isStoped;};
//    void setStop(bool stop){isStoped = stop;};
//    void setLastErrorCode(int code){lastErrorCode = code;};
public:
//    int LastErrorCode(){return lastErrorCode;};
    virtual void addCommonParams(NSMutableDictionary* postParams);
    //
    static bool connectNetWork();
    static bool connectViaWIFI();
    //
    void setIWizXmlSyncEvents(IWizXmlSyncEvents& event)
    {
        m_events = event;
    }
    
private:
   IWizXmlSyncEvents m_events; 
    template<class TRet>
    BOOL doCallXmlRpcWithArgs(NSMutableDictionary* postParams, NSString* methodKey, XMLRPCRequest* request, TRet& ret, NSError** error)
    {
        if (!request) {
            *error = [NSError errorWithDomain:WizErrorDomain code:0 userInfo:nil];
            return NO;
        }
        else
        {
            addCommonParams(postParams);
            NSArray* args = [NSArray arrayWithObject:postParams];
            [request setMethod:methodKey withObjects:args];
            NSData* data = [XMLRPCConnection sendSynchronousRequest:request returningResponse:nil error:error];
            if (*error == nil && data) {
                XMLRPCResponse* response = [[XMLRPCResponse alloc] initWithData:data];
                BOOL isSucceed = !response.fault && !response.parseError && ![response.object isKindOfClass:[NSError class]];
                
                if (!isSucceed) {
                    m_events.OnError(response.object);
                }
                else
                {
                    ret.fromWizServerObject(response.object);
                }
                [response release];
                return isSucceed;
            }
            else
            {
                if(*error != nil)
                {
                    m_events.OnError(*error);
                }
                else
                {
                   m_events.OnError(301); 
                }
                
                return NO;
            }
        }
        
    }
    
public:
    
    template<class TRet>
    BOOL callXmlRpcWithArgs(NSMutableDictionary* postParams, NSString* methodKey, NSURL* url, TRet& ret, NSError** error )
    {
        XMLRPCRequest* request = [[XMLRPCRequest alloc] initWithHost:url];
        BOOL isSucceed = doCallXmlRpcWithArgs(postParams, methodKey, request, ret, error);
        [request release];
        return isSucceed;
    }
    template<class TRet>
    WizXmlEvent callXmlRpcWithArgs(NSMutableDictionary* postParams, NSString* methodKey, NSURL* url, TRet& ret)
    {
        NSError* error = nil;
        if (callXmlRpcWithArgs(postParams, methodKey, url, ret, &error)) {
            return WizXmlEventSucceed;
        }
        else
        {
            if (error == nil) {
                return WizXmlEventUnknow;
            }
            else
            {
                if (error.code == 0) {
                    return WizXmlEventUnknow;
                }
                else
                {
                    return error.code;
                }
            }
        }
    }
};


//

class WizXmlAccountServer
: public WizXmlServer
{
private:
    std::string  serverUrl;
public:
    WizModule::WIZLOGINGDATA loginData;
    //
    WizXmlAccountServer(){};
    WizXmlAccountServer(const char* serverUrl_):serverUrl(serverUrl_){};
    //
    BOOL accountLogin(const char* userId, const char* password);
    BOOL verifyAccount(const char* userId, const char* password);
    //
    bool getAccountGroupsList(WizModule::CWizGroupArray& groupsArray);
    //
    bool accountLoginAndGetAccountGroupsList(const char* userId, const char* password, CWizGroupArray& groupsArray);
    bool getTokenAndPersonalKapiUrl(const char* userId, const char* password, std::string& token, std::string* kapiurk);
    bool getTokenAndGroupKapiurl(const char* userId, const char* password,const char* kbguid ,std::string& token, std::string& kapirul);
    bool getTokenAndKapiurl(const char* userId, const char* password,const char* kbguid ,std::string& token, std::string& kapirul);
};



using namespace WizModule;

class WizXmlDbServer:public WizXmlServer  {
    std::string token;
    std::string serverUrl;
    std::string kbguid;
    //
    template<class TRet>
    bool getWizObjectList(int64_t first, int64_t count , NSString* syncMethod,TRet& ret);
public:
    std::string workingKbguid(){return kbguid;};
    //
    WizModule::WIZALLVERSION allVersionsData;
    virtual void addCommonParams(NSMutableDictionary *postParams);
    //
    WizXmlDbServer(){};
    WizXmlDbServer(std::string token_, std::string kbguid_,std::string serverUrl_)
    :token(token_),serverUrl(serverUrl_),kbguid(kbguid_){};
    //
    bool getAllVersion(WIZALLVERSION& loginData);
    bool getTagsList(int64_t first, int64_t count, CWizTagDataArray& tagDataArray);
    bool getDocumentsList(int64_t first, int64_t count, CWizDocumentDataArray& docArray);
    bool getAttachmentsList(int64_t first, int64_t count, CWizDocumentAttachmentArray& attachArray);
    bool getDeletedGUIDslist(int64_t first, int64_t count, CWizDeletedGUIDDataArray& deletedGuidArray);
    //
    bool postTagsList(const CWizTagDataArray& tagArray, WIZSERVERRESPONSEDATA& reseponse);
    bool postDeletedGUIDsList(const CWizDeletedGUIDDataArray& deletedArray, WIZSERVERRESPONSEDATA& reseponse);
    bool postDocumentInfo(WIZDOCUMENTDATA& docData,bool isWithData , WIZSERVERRESPONSEDATA& reseponse);
    bool postAttachmentInfo( WIZDOCUMENTATTACH& attachData, WIZSERVERRESPONSEDATA& reseponse);
    //download by guids
    bool downloadDocumentsListByGuids(const CWizStringArray& guids, CWizDocumentQueryArray& docsArray);
    bool downloadAttachmentListByGuids(const CWizStringArray& guids, CWizDocumentAttachmentQueryArray& attachArray);
    //
    bool postWizObjectData(NSData* data,int64_t objSize, const char* objDataMd5, const char* objType, const char* objGuid, int64_t partCount ,int64_t partSN,WIZSERVERRESPONSEDATA& response);
    bool downloadWizObjectData(const char* objGuid, const char* objType, int64_t startPos, int64_t requstSize, WIZDOWNLOADOBJECTDATA& response);
    //
    bool getDocumentListByKey(int64_t first, int64_t count, const char* key, CWizDocumentDataArray& docArray);
};


class WizXmlSyncBase : public IWizXmlSyncEvents{
protected:
    WizXmlDbServer xmlServer;
    WizMetaDb metaDb;
    WizAccountPrivilege privilege;
    std::string accountUserId;
public:
    WizXmlSyncBase(const WIZSYNCINFODATA& syncInfo):xmlServer(syncInfo.token,syncInfo.kbGuid,syncInfo.serverUrl),accountUserId(syncInfo.accountUserId)
    {
        xmlServer.setIWizXmlSyncEvents(*this);
        privilege = syncInfo.privilege;
        metaDb.open(syncInfo.dbPath.c_str());
    };
    
    ~WizXmlSyncBase()
    {
        metaDb.close();
    };
};

class WizXmlSyncKb : public WizXmlSyncBase{
private:
    bool isOnlyUpload;
    //
    bool getAllDocumentsList();
    bool getAllTagsList();
    bool getAllDeletedGuidsList();
    bool getAllAttachmentsList();
    bool postAllTagsList();
    bool postAllDeletedGuids();
    //
    bool onUpdateDocument(WIZDOCUMENTDATA& doc);
    bool onUpdateTag(WIZTAGDATA& tag);
    bool onUpdateDeletedGuid(WIZDELETEDGUIDDATA& deletedGuid);
    bool onUpdateAttachment(WIZDOCUMENTATTACH& attach);
    //
    bool uploadAllEditedDocuments();
    bool uploadAllEditedAttachments();
    bool callUploadObject(const char* guid, const char* type, const char* filePath);
    WIZALLVERSION allVersions;
    //
    bool doSync();
    
    bool uploadDocument(WizModule::WIZDOCUMENTDATA &doc, const char* tempFilePath);
    bool uploadAttachment(WizModule::WIZDOCUMENTATTACH &attach, const char *tempFilePath);
public:
    WizXmlSyncKb(const WIZSYNCINFODATA& syncInfo ):WizXmlSyncBase(syncInfo){ isOnlyUpload = syncInfo.isOnlyUpload;};
    bool sync();
    //
    bool callDownloadObject(const char* guid, const char* type ,const char* filePath);
    bool downloadDocument(const char* guid, const char* tempFilePath);
    bool downloadAttachment(const char* guid, const char* tempFilePath);
    bool uploadDocument(WIZDOCUMENTDATA& doc, const char* tempFilePath, const CWizDocumentsMap& serverDocuments);
    bool uploadAttachment(WIZDOCUMENTATTACH& attach, const char* tempFilePath, const CWizDocumentAttachmentsMap& serverAttachments);
};
//
//
//
//
//

//
class WizXmlSyncAccount : public IWizXmlSyncEvents {
    std::string accountUserId;
    std::string accountPassword;
    std::string serverUrl;
    bool doSync( bool group , bool isOnlyUpload);
public:
    WizXmlSyncAccount(const char* accountUserId, const char* accountPassword, const char* serverUrl)
    :accountUserId(accountUserId), accountPassword(accountPassword), serverUrl(serverUrl){};
    void sync(bool group, bool isOnlyUpload)
    {
        OnState(accountUserId.c_str(), WizXmlSyncStateStart);
        if (doSync(group, isOnlyUpload)) {
            OnState(accountUserId.c_str(), WizXmlSyncStateEnd);
        }
        else
        {
            OnState(accountUserId.c_str(), WizXmlSyncStateError);
        }
    }
};




