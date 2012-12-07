//
//  WizXmlServer.m
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-16.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizXmlServer.h"
#import "XMLRPCConnection.h"
#import "XMLRPCResponse.h"
#import "XMLRPCRequest.h"
#import "Reachability.h"
#import "WizFileManager.h"
#import <time.h>
#import "WizSyncQueque.h"
#import "WizAccountManager.h"
NSString* const SyncMethod_ClientLogin                  = @"accounts.clientLogin";
NSString* const SyncMethod_ClientLogout                 = @"accounts.clientLogout";
NSString* const SyncMethod_CreateAccount                = @"accounts.createAccount";
NSString* const SyncMethod_ChangeAccountPassword        = @"accounts.changePassword";
NSString* const SyncMethod_GetAllCategories             = @"category.getAll";
NSString* const SyncMethod_DownloadAllTags                   = @"tag.getList";
NSString* const SyncMethod_PostTagList                  = @"tag.postList";
NSString* const SyncMethod_DocumentsByKey               = @"document.getSimpleListByKey";
NSString* const SyncMethod_DownloadDocumentList         = @"document.getSimpleList";
NSString* const SyncMethod_DocumentsByCategory          = @"document.getSimpleListByCategory";
NSString* const SyncMethod_DocumentsByTag               = @"document.getSimpleListByTag";
NSString* const SyncMethod_DocumentPostSimpleData       = @"document.postSimpleData";
NSString* const SyncMethod_DownloadDeletedList          = @"deleted.getList";
NSString* const SyncMethod_UploadDeletedList            = @"deleted.postList";
NSString* const SyncMethod_DownloadObject               = @"data.download";
NSString* const SyncMethod_UploadObject                 = @"data.upload";
NSString* const SyncMethod_AttachmentPostSimpleData     = @"attachment.postSimpleData";
NSString* const SyncMethod_DownloadAttachmentList            = @"attachment.getList";
NSString* const SyncMethod_GetUserInfo                  = @"wiz.getInfo";
NSString* const SyncMethod_GetGropKbGuids               = @"accounts.getGroupKbList";
NSString* const SyncMethod_DownloadAllObjectVersion          = @"wiz.getVersion";
NSString* const SyncMethod_DownloadDocumentListByGuids  = @"document.downloadList";
NSString* const SyncMethod_DownloadAttachmentListByGuids = @"attachment.downloadList ";
//
NSString* const WizXmlSyncStateChangedKey = @"WizXmlSyncStatueChanged";

void WizXmlServer::addCommonParams(NSMutableDictionary *postParams)
{
        [postParams setObject:@"iphone" forKey:@"client_type"];
        [postParams setObject:@"normal" forKey:@"program_type"];
        [postParams setObject:[NSNumber numberWithInt:4] forKey:@"api_version"];
    
}

 bool WizXmlServer::connectNetWork()
{
    bool isExistenceNetwork;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.wiz.cn"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork=false;
            break;
        case ReachableViaWWAN:
            isExistenceNetwork=true;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork=true;
            break;
    }
    return isExistenceNetwork;
}
bool WizXmlServer::connectViaWIFI()
{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.wiz.cn"];
    return [r currentReachabilityStatus] == ReachableViaWiFi;
}

//
BOOL WizXmlAccountServer::accountLogin(const char *userId, const char *password)
{
    if (!WizXmlServer::connectNetWork()) {
        WizLogError(@"have not network");
        dispatch_sync(dispatch_get_main_queue(), ^{
            static NSDate *lastShowTime = nil;
            if (lastShowTime == nil ||  ABS([[NSDate date] timeIntervalSinceDate:lastShowTime]) >= 60)  {
               [WizGlobals reportErrorWithString:NSLocalizedString(@"The internet network is lost!", nil)];
                lastShowTime = [[NSDate date] retain];
            }
            
        });
        return false;
    }
    NSMutableDictionary* dic = [NSMutableDictionary dictionary];
    [dic setObject:WizCStringToNSString(userId) forKey:@"user_id"];
    [dic setObject:WizCStringToNSString(password) forKey:@"password"];
    return WizXmlEventSucceed == callXmlRpcWithArgs(dic, SyncMethod_ClientLogin, WizStdStringToNSURL(serverUrl), loginData);
}

BOOL WizXmlAccountServer::verifyAccount(const char *userId, const char *password)
{
    return accountLogin(userId, password);
}

bool WizXmlAccountServer::getAccountGroupsList(WizModule::CWizGroupArray &groupsArray)
{
    NSMutableDictionary* post = [NSMutableDictionary dictionaryWithCapacity:1];
    if (IsEmptyString(loginData.token.c_str())) {
        return false;
    }
    [post setObject:WizStdStringToNSString(loginData.token) forKey:@"token"];
    return WizXmlEventSucceed == callXmlRpcWithArgs(post, SyncMethod_GetGropKbGuids, WizStdStringToNSURL(serverUrl), groupsArray);
}
//

bool WizXmlAccountServer::accountLoginAndGetAccountGroupsList(const char *userId, const char *password, WizModule::CWizGroupArray &groupsArray)
{
    if (!accountLogin(userId, password)) {
        WizLogError(@"login error !");
        return false;
    }
    if (!getAccountGroupsList(groupsArray)) {
        WizLogError(@"get groups array error !");
        return false;
    }
    return true;
};

bool WizXmlAccountServer::getTokenAndGroupKapiurl(const char *userId, const char *password, const char *kbguid, std::string &token, std::string &kapirul)
{
    CWizGroupArray array;
    if (!accountLoginAndGetAccountGroupsList(userId, password, array)) {
        return false;
    }
    token = loginData.token;
    if (loginData.kbguid == string(kbguid)) {
        kapirul = loginData.kapiUrl;
        return true;
    }
    for (CWizGroupArray::const_iterator itor = array.begin(); itor != array.end(); itor++) {
        if (itor->kbGuid == string(kbguid)) {
            kapirul = itor->kbApiUrl;
            return true;
        }
    }
    return false;
}
//
static CMutex kapirulMapLock;

bool WizXmlAccountServer::getTokenAndKapiurl(const char *userId, const char *password, const char *kbguid, std::string &token, std::string &kapirul)
{
    if (!accountLogin(userId, password)) {
        WizLogError(@"login error !");
        return false;
    }
    token = loginData.token;
    if (string(kbguid) == WizGlobalPersonalKbguid || string(kbguid) == loginData.kbguid || IsEmptyString(kbguid) || kbguid == NULL ) {
        kapirul = loginData.kapiUrl;
        return true;
    }
    CWizLock lock(kapirulMapLock);
    //find kapiurl in cache
    typedef std::map<std::string, std::string>  CWizStringMap;
    static CWizStringMap kapiUrlMap;
    CWizStringMap::const_iterator apiUrlItor = kapiUrlMap.find(kbguid);
    if (apiUrlItor != kapiUrlMap.end()) {
        kapirul = apiUrlItor->second;
        return true;
    }
    //find over and failed
    CWizGroupArray array;
    if (!getAccountGroupsList(array)) {
        WizLogError(@"get group list error ！");
        return false;
    }
    bool isSucceed = false;
    for (CWizGroupArray::const_iterator itor = array.begin(); itor != array.end(); itor++) {
        kapiUrlMap.insert(CWizStringMap::value_type(itor->kbGuid, itor->kbApiUrl));
        if (itor->kbGuid == string(kbguid)) {
            kapirul = itor->kbApiUrl;
            isSucceed = true;
        }
    }
    return isSucceed;
}

void WizXmlDbServer::addCommonParams(NSMutableDictionary *postParams)
{
    WizXmlServer::addCommonParams(postParams);
    NSString* tokenL = NSStringFromStdString(token);
    NSString* kbguidL = NSStringFromStdString(kbguid);
    if (kbguid == WizGlobalPersonalKbguid) {
        kbguidL = nil;
    }
    if (tokenL != nil) {
        [postParams setObject:tokenL forKey:@"token"];
    }
    if (kbguidL != nil) {
        [postParams setObject:kbguidL forKey:@"kb_guid"];
    }
}

bool WizXmlDbServer::getAllVersion(WizModule::WIZALLVERSION &loginData)
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    return WizXmlEventSucceed == callXmlRpcWithArgs(postParams, SyncMethod_DownloadAllObjectVersion, WizStdStringToNSURL(serverUrl), loginData);
}
template <class TRet>
bool WizXmlDbServer::getWizObjectList(int64_t first, int64_t count, NSString* syncMethod, TRet &ret)
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithCapacity:2];
    [postParams setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    [postParams setObject:[NSNumber numberWithInt:first] forKey:@"version"];
    return WizXmlEventSucceed == callXmlRpcWithArgs(postParams, syncMethod, WizStdStringToNSURL(serverUrl), ret);
}

bool WizXmlDbServer::getTagsList(int64_t first, int64_t count, CWizTagDataArray &tagDataArray)
{
    return getWizObjectList(first, count,SyncMethod_DownloadAllTags, tagDataArray);
}

bool WizXmlDbServer::getDeletedGUIDslist(int64_t first, int64_t count, CWizDeletedGUIDDataArray &deletedGuidArray)
{
    return getWizObjectList(first, count, SyncMethod_DownloadDeletedList,deletedGuidArray);
}

bool WizXmlDbServer::getDocumentsList(int64_t first, int64_t count, CWizDocumentDataArray &docArray)
{
    return getWizObjectList(first, count, SyncMethod_DownloadDocumentList,docArray);
}

bool WizXmlDbServer::getAttachmentsList(int64_t first, int64_t count, CWizDocumentAttachmentArray &attachArray)
{
    return getWizObjectList(first, count, SyncMethod_DownloadAttachmentList,attachArray);
}

bool WizXmlDbServer::postTagsList(const WizModule::CWizTagDataArray &tagArray, WizModule::WIZSERVERRESPONSEDATA &reseponse)
{
    NSMutableArray* tagsPostArray = [NSMutableArray array];
    std::vector<WIZTAGDATA>::const_iterator itor = tagArray.begin();
    while (itor != tagArray.end()) {
        WIZTAGDATA tagData = (*itor);
        NSDictionary* dic = tagData.toWizServerObject();
        [tagsPostArray addObject:dic];
        itor++;
    }
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [postParams setObject:tagsPostArray forKey:@"tags"];
    
    return WizXmlEventSucceed == callXmlRpcWithArgs(postParams, SyncMethod_PostTagList, WizStdStringToNSURL(serverUrl), reseponse);
}

bool WizXmlDbServer::postDeletedGUIDsList(const WizModule::CWizDeletedGUIDDataArray &deletedArray, WizModule::WIZSERVERRESPONSEDATA &reseponse)
{
    NSMutableArray* deletedPostArray = [NSMutableArray array];
    std::vector<WIZDELETEDGUIDDATA>::const_iterator itor = deletedArray.begin();
    while (itor != deletedArray.end()) {
        WIZDELETEDGUIDDATA deletedGuid = (*itor);
        NSDictionary* dic = deletedGuid.toWizServerObject();
        [deletedPostArray addObject:dic];
        itor++;
    }
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    return WizXmlEventSucceed == callXmlRpcWithArgs(postParams, SyncMethod_UploadDeletedList, WizStdStringToNSURL(serverUrl), reseponse);
}

bool WizXmlDbServer::postDocumentInfo(WizModule::WIZDOCUMENTDATA &docData, bool isWithData ,WizModule::WIZSERVERRESPONSEDATA &reseponse)
{
    NSDictionary* dic = docData.toWizServerObject(isWithData);
    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithDictionary:dic];
    return WizXmlEventSucceed == callXmlRpcWithArgs(postParams, SyncMethod_DocumentPostSimpleData, WizStdStringToNSURL(serverUrl), reseponse);
}
bool WizXmlDbServer::postAttachmentInfo(WizModule::WIZDOCUMENTATTACH &attachData, WizModule::WIZSERVERRESPONSEDATA &reseponse)
{
    NSDictionary* attach = attachData.toWizServerObject();
    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithDictionary:attach];
    return WizXmlEventSucceed == callXmlRpcWithArgs(postParams, SyncMethod_AttachmentPostSimpleData, WizStdStringToNSURL(serverUrl), reseponse);
}
bool WizXmlDbServer::downloadDocumentsListByGuids(const WizModule::CWizStringArray &guids, WizModule::CWizDocumentQueryArray& docsArray)
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    NSMutableArray* docGuidsArray = [NSMutableArray array];
    for (CWizStringArray::const_iterator itor = guids.begin(); itor != guids.end(); itor++) {
        [docGuidsArray addObject:WizStdStringToNSString(*itor)];
    }
    [postParams setObject:docGuidsArray forKey:@"document_guids"];
    return WizXmlEventSucceed == callXmlRpcWithArgs(postParams, SyncMethod_DownloadDocumentListByGuids, WizStdStringToNSURL(serverUrl), docsArray);
}

bool WizXmlDbServer::downloadAttachmentListByGuids(const WizModule::CWizStringArray &guids, WizModule::CWizDocumentAttachmentQueryArray &attachArray)
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    NSMutableArray* attachGuidsArray = [NSMutableArray array];
    for (CWizStringArray::const_iterator itor = guids.begin(); itor != guids.end(); itor++) {
        [attachGuidsArray addObject:WizStdStringToNSString(*itor)];
    }
    [postParams setObject:attachGuidsArray forKey:@"attachment_guids"];
    return WizXmlEventSucceed == callXmlRpcWithArgs(postParams, SyncMethod_DownloadAttachmentListByGuids, WizStdStringToNSURL(serverUrl), attachArray);
}


bool WizXmlDbServer::postWizObjectData(NSData *data, int64_t objSize, const char *objDataMd5, const char *objType, const char* objGuid,int64_t partCount, int64_t partSN, WIZSERVERRESPONSEDATA& response)
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:[NSNumber numberWithInt:objSize] forKey:@"obj_size"];
    [postParams setObject:[NSNumber numberWithInt:partCount] forKey:@"part_count"];
    [postParams setObject:[NSNumber numberWithInt:partSN] forKey:@"part_sn"];
    [postParams setObject:[NSNumber numberWithInt:data.length] forKey:@"part_size"];
    //
    [postParams setObject:data forKey:@"data"];
    //
    [postParams setObject:WizCStringToNSString(objDataMd5) forKey:@"obj_md5"];
    [postParams setObject:WizCStringToNSString(objGuid) forKey:@"obj_guid"];
    [postParams setObject:WizCStringToNSString(objType) forKey:@"obj_type"];
    //
    NSString* dataMd5 = [WizGlobals md5:data];
    [postParams setObject:dataMd5 forKey:@"part_md5"];
    //
    return WizXmlEventSucceed == callXmlRpcWithArgs(postParams, SyncMethod_UploadObject, WizStdStringToNSURL(serverUrl), response);
}

bool WizXmlDbServer::downloadWizObjectData(const char *objGuid, const char *objType, int64_t startPos, int64_t requestSize, WIZDOWNLOADOBJECTDATA& response)
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:WizCStringToNSString(objGuid) forKey:@"obj_guid"];
    [postParams setObject:WizCStringToNSString(objType) forKey:@"obj_type"];
    [postParams setObject:[NSNumber numberWithInt:startPos] forKey:@"start_pos"];
    [postParams setObject:[NSNumber numberWithInt:requestSize] forKey:@"part_size"];
    return WizXmlEventSucceed == callXmlRpcWithArgs(postParams, SyncMethod_DownloadObject, WizStdStringToNSURL(serverUrl), response );
}

bool WizXmlDbServer::getDocumentListByKey(int64_t first, int64_t count, const char *key, WizModule::CWizDocumentDataArray &docArray)
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:[NSNumber numberWithInt:count] forKey:@"count"];
    [postParams setObject:[NSNumber numberWithInt:first] forKey:@"first"];
    [postParams setObject:WizCStringToNSString(key) forKey:@"key"];
    return WizXmlEventSucceed == callXmlRpcWithArgs(postParams, SyncMethod_DocumentsByKey, WizStdStringToNSURL(serverUrl), docArray);
}

//
//
//
//
#define WizDownloadListCount 200

bool WizXmlSyncKb::onUpdateAttachment(WizModule::WIZDOCUMENTATTACH &attach)
{
    attach.nLocalChanged = false;
    attach.nServerChanged = true;
    return metaDb.updateAttachment(attach);
}

bool WizXmlSyncKb::onUpdateDocument(WizModule::WIZDOCUMENTDATA &doc)
{

    WIZDOCUMENTDATA docExist;
    if (!metaDb.documentFromGUID(doc.strGUID.c_str(), docExist)) {
        doc.nLocalChanged = WizEditDocumentTypeNoChanged;
        doc.nServerChanged = true;
        metaDb.updateDocument(doc);
    }
    else
    {
        switch (docExist.nLocalChanged) {
            case WizEditDocumentTypeNoChanged:
            {
                doc.nLocalChanged = WizEditDocumentTypeNoChanged;
                doc.nServerChanged = true;
                break;
            }
            case WizEditDocumentTypeInfoChanged:
            {
                NSDate* dateExist = [WizStdStringToNSString(docExist.strDateModified) dateFromSqlTimeString];
                NSDate* docServer = [WizStdStringToNSString(doc.strDateModified) dateFromSqlTimeString];
                if ([dateExist isEarlierThanDate:docServer]) {
                    doc.nLocalChanged = WizEditDocumentTypeNoChanged;
                    doc.nServerChanged = true;
                    metaDb.updateDocument(doc);
                }
                break;
            }
                
            case WizEditDocumentTypeAllChanged:
            {
                if (docExist.strDataMd5 != doc.strDataMd5) {
#warning complic solve
                }
                break;
            }
                
            default:
                break;
        }
    }
    return true;
}

bool WizXmlSyncKb::onUpdateTag(WizModule::WIZTAGDATA &tag)
{
    tag.nLocalchanged = false;
    return metaDb.updateTag(tag);
}

bool WizXmlSyncKb::onUpdateDeletedGuid(WizModule::WIZDELETEDGUIDDATA &deletedGuid)
{
    return true;
}

bool WizXmlSyncKb::getAllTagsList()
{
    int64_t localVersion = metaDb.getTagVersion();
    while (localVersion < allVersions.tagVersion) {
        CWizTagDataArray tagArray;
        if (xmlServer.getTagsList(localVersion+1, WizDownloadListCount, tagArray)) {
            
            if (tagArray.size() > 0) {
                int64_t serverVersion = 0;
                std::vector<WIZTAGDATA>::const_iterator itor = tagArray.begin();
                while (itor != tagArray.end()) {
                    WIZTAGDATA data = (*itor);
                    serverVersion = serverVersion > data.nVersion ? serverVersion : data.nVersion;
                    //
                    if (!onUpdateTag(data)) {
                        WizLogError(@"update tag error %@", WizStdStringToNSString(data.strGUID), WizStdStringToNSString(data.strName));
                        return false;
                    }
                    //
                    itor++;
                }
                metaDb.setTagVersion(serverVersion);
            }
            else
            {
                metaDb.setTagVersion(allVersions.tagVersion);
            }
        }
        else
        {
            return false;
        }
        localVersion = metaDb.getTagVersion();
    }
    return true;
    
}

bool WizXmlSyncKb::getAllDocumentsList()
{
    int64_t localVersion = metaDb.getDocumentVersion();
    while (localVersion < allVersions.documentVersion) {
        CWizDocumentDataArray docArray;
        if (xmlServer.getDocumentsList(localVersion+1, WizDownloadListCount, docArray) ) {
            
            if (docArray.size() > 0) {
                int64_t serverVersion = 0;
                std::vector<WIZDOCUMENTDATA>::const_iterator itor = docArray.begin();
                while (itor != docArray.end()) {
                    WIZDOCUMENTDATA data= (*itor);
                    serverVersion = serverVersion > data.nVersion ? serverVersion : data.nVersion;
                    //
                    if (!onUpdateDocument(data)) {
                        WizLogError(@"update document error %@ %@",WizStdStringToNSString(data.strGUID), WizStdStringToNSString(data.strTitle));
                        return false;
                    }
                    //
                    itor++;
                }
                metaDb.setDocumentVersion(serverVersion);
            }
            else
            {
                metaDb.setDocumentVersion(allVersions.documentVersion);
            }
        }
        else
        {
            return false;
        }
        localVersion = metaDb.getDocumentVersion();
    }
    return true;
}


bool WizXmlSyncKb::getAllAttachmentsList()
{
    int64_t localVersion = metaDb.getAttachmentVersion();
    while (localVersion < allVersions.attachmentVersion) {
        CWizDocumentAttachmentArray attachArray;
        if (xmlServer.getAttachmentsList(localVersion+1, WizDownloadListCount, attachArray) ) {
            
            if (attachArray.size() > 0) {
                int64_t serverVersion = 0;
                std::vector<WIZDOCUMENTATTACH>::const_iterator itor = attachArray.begin();
                while (itor != attachArray.end()) {
                    WIZDOCUMENTATTACH  data= (*itor);
                    serverVersion = serverVersion > data.nVersion ? serverVersion : data.nVersion;
                    //
                    if (!onUpdateAttachment(data)) {
                        WizLogError(@"update attachent error %@",WizStdStringToNSString(data.strGuid));
                        return false;
                    }
                    //
                    itor++;
                }
                metaDb.setAttachmentVersion(serverVersion);
            }
            else
            {
                metaDb.setAttachmentVersion(allVersions.documentVersion);
            }
        }
        else
        {
            return false;
        }
        localVersion = metaDb.getAttachmentVersion();
    }
    return true;
}

bool WizXmlSyncKb::getAllDeletedGuidsList()
{
    int64_t localVersion = metaDb.getDeletedVersion();
    while (localVersion < allVersions.deletedVersion) {
        CWizDeletedGUIDDataArray deletedGuidsArray;
        if (xmlServer.getDeletedGUIDslist(localVersion+1, WizDownloadListCount, deletedGuidsArray)) {
            
            if (deletedGuidsArray.size() > 0) {
                int64_t serverVersion = 0;
                std::vector<WIZDELETEDGUIDDATA>::const_iterator itor = deletedGuidsArray.begin();
                while (itor != deletedGuidsArray.end()) {
                    WIZDELETEDGUIDDATA data = (*itor);
                    serverVersion = serverVersion > data.nVersion ? serverVersion : data.nVersion;
                    //
                    if (!onUpdateDeletedGuid(data)) {
                        WizLogError(@"update deleted guid error %@",WizStdStringToNSString(data.strGUID));
                        return false;
                    }
                    //
                    itor++;
                }
                metaDb.setDeletdVersion(serverVersion);
            }
            else
            {
                metaDb.setDeletdVersion(allVersions.deletedVersion);
            }
        }
        else
        {
            return false;
        }
        localVersion = metaDb.getDeletedVersion();
    }
    return true;
}

bool WizXmlSyncKb::uploadAllEditedAttachments()
{
    CWizDocumentAttachmentArray attachArray;
    if (!metaDb.attachmentsForUpload(attachArray)) {
        WizLogError(@"get will upload attachment error!");
        return false;
    }
    if (attachArray.empty() || !privilege.canUploadDocumentAndAttachment()) {
        return true;
    }
    CWizStringArray guidsArray;
    for (CWizDocumentAttachmentArray::const_iterator itor = attachArray.begin(); itor != attachArray.end(); itor++) {
        guidsArray.push_back(itor->strGuid);
    }
    
    CWizDocumentAttachmentQueryArray queryArray;
    if (!xmlServer.downloadAttachmentListByGuids(guidsArray, queryArray)) {
        WizLogError(@"get attachment query error！");
        return false;
    }
    CWizDocumentAttachmentsMap serverAttachments(queryArray);
    if (attachArray.size() > 0 && privilege.canUploadDocumentAndAttachment()) {
        for (CWizDocumentAttachmentArray::iterator itor = attachArray.begin(); itor != attachArray.end(); itor++) {
            OnState(itor->strGuid.c_str(), WizXmlSyncStateStart);
            string uploadFilePath = CWizFileManager::shareInstance()->objectFilePath(itor->strGuid.c_str(), accountUserId);
            if (!uploadAttachment(*itor, uploadFilePath.c_str(), serverAttachments)) {
                OnState(itor->strGuid.c_str(), WizXmlSyncStateError);
                if (!IsStop()) {
                    continue;
                }
            
            }
            else
            {
                OnState(itor->strGuid.c_str(), WizXmlSyncStateEnd);
            }
        }
    }
    return true;
}

bool WizXmlSyncKb::uploadAllEditedDocuments()
{
    CWizDocumentDataArray docArray;
    if(!metaDb.documentForUpload(docArray))
    {
        WizLogError(@"get upload docments error!");
        return false;
    }
    if (docArray.empty() || !privilege.canUploadDocumentAndAttachment()) {
        return true;
    }

    CWizStringArray guids;
    for (CWizDocumentDataArray::iterator itor = docArray.begin(); itor != docArray.end(); itor++)
    {
        guids.push_back(itor->strGUID);
    }
    CWizDocumentQueryArray docsOnServe;
    if (!xmlServer.downloadDocumentsListByGuids(guids, docsOnServe)) {
        WizLogError(@"download server docs error");
        return false;
    }
    CWizDocumentsMap serverDocsMap(docsOnServe);
    
    for (CWizDocumentDataArray::iterator itor = docArray.begin(); itor != docArray.end(); itor++) {
        OnState(itor->strGUID.c_str(), WizXmlSyncStateStart);
        string uploadFilePath = CWizFileManager::shareInstance()->objectFilePath(itor->strGUID, accountUserId);
        if (!uploadDocument(*itor, uploadFilePath.c_str(),serverDocsMap)){
            OnState(itor->strGUID.c_str(), WizXmlSyncStateError);
            if (!IsStop()) {
                continue;
            }
        }
        else
        {
            OnState(itor->strGUID.c_str(), WizXmlSyncStateEnd);
        }
    }
    
    return true;
}

bool WizXmlSyncKb::postAllDeletedGuids()
{
    CWizDeletedGUIDDataArray deletedGuidsArray;
    if (!metaDb.uploadDeletedGuids(deletedGuidsArray)) {
        return false;
    }
    WIZSERVERRESPONSEDATA response;
    if (deletedGuidsArray.size() == 0) {
        return true;
    }
    if (!xmlServer.postDeletedGUIDsList(deletedGuidsArray, response)) {
        return false;
    }
    return true;
}

bool WizXmlSyncKb::postAllTagsList()
{
    CWizTagDataArray tagArray;
    if (!metaDb.uploadTags(tagArray)) {
        WizLogError(@"get need uploadTags error");
        return false;
    }
    if (tagArray.size() == 0) {
        return true;
    }
    
    WIZSERVERRESPONSEDATA response;
    if (!xmlServer.postTagsList(tagArray, response)) {
        return false;
    }
    return true;
}

bool WizXmlSyncKb::doSync()
{
    if (!privilege.canDownloadList()) {
        WizLogError(@"no privilege to download anything");
        return false;
    }

    OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateDownloadAllVersions);
    if (!xmlServer.getAllVersion(allVersions) && !isOnlyUpload) {
        WizLogError(@"get all version error!");
        return false;
    }
    if (IsStop()) {
        return false;
    }
    OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateDownloadDeletedList);
    if (!getAllDeletedGuidsList()) {
        WizLogError(@"get deleted guids list error");
        return false;
    }
    if (IsStop()) {
        return false;
    }
    if (privilege.canUploadDeletedList() ) {
        OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateUploadDeletedList);
        if (!postAllDeletedGuids()) {
            WizLogError(@"post deleted guids list error");
            return false;
        }
    }
    if (IsStop()) {
        return false;
    }
    OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateDownloadTagList);
    if (!getAllTagsList() ) {
        WizLogError(@"get all tags list error");
        return false;
    }
    if (IsStop()) {
        return false;
    }
    if (privilege.canUploadTagList()) {
        OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateUploadTagList);
        if (!postAllTagsList()) {
            WizLogError(@"post all tags list error");
            return false;
        }
    }
    if (IsStop()) {
        return false;
    }
    //upload documents and attachments
    OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateUploadDocument);
    if (!uploadAllEditedDocuments()) {
        WizLogError(@"upload edited documents error!");
        return false;
    }
   if (IsStop()) {
        return false;
    }
    OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateUploadAttachment);
    if (!uploadAllEditedAttachments()) {
        WizLogError(@"upload edited attachments error!");
        return false;
    }
    //
    if (isOnlyUpload) {
        return true;
    }
    OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateDownloadDocumentList);
    if (!getAllDocumentsList() && !isOnlyUpload) {
        WizLogError(@"get document list error");
        return false;
    }
    if (IsStop()) {
        return false;
    }
    OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateDownloadAttachmentList);
    if (!getAllAttachmentsList() && !isOnlyUpload) {
        WizLogError(@"get attachment list error");
        return false;
    }
    if (IsStop()) {
        return false;
    }
    return true;
}

bool WizXmlSyncKb::sync()
{
    OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateStart);
    if (!doSync()) {
        OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateError);
        return false;
    }
    else
    {
        OnState(xmlServer.workingKbguid().c_str(), WizXmlSyncStateEnd);
        CWizDocumentDataArray array;
        metaDb.recentDocuments(array);
        for (CWizDocumentDataArray::const_iterator itor = array.begin(); itor != array.end(); itor++) {
            WIZSYNCDOWNLOADOBJECT data;
            data.objectGuid = itor->strGUID;
            data.objectType = "document";
            data.accountPassword = "654321";
            data.kbguid = xmlServer.workingKbguid();
            data.accountUserId = accountUserId;
            data.serverUrl = [WizGlobals wizServerUrlStdString];
            g_AddDownloadObjectInMain(data);
        }
        return true;
    }

}


#define WizDownloadObjectSize   (200*1024)

bool WizXmlSyncKb::callDownloadObject(const char *guid, const char *type, const char *filePath)
{
    NSString* downloadTempPath = WizCStringToNSString(filePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadTempPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadTempPath error:nil];
    }
    if (![[NSFileManager defaultManager] createFileAtPath:downloadTempPath contents:nil attributes:nil])
    {
        WizLogError(@"can't create file %@",downloadTempPath);
        return false;
    }
    NSFileHandle* fileHandler = [NSFileHandle fileHandleForWritingAtPath:downloadTempPath];
    [fileHandler seekToFileOffset:0];
    bool eof = false;
    while(!eof)
    {
        int64_t startPos = [fileHandler seekToEndOfFile];
        WIZDOWNLOADOBJECTDATA data;
        if(!xmlServer.downloadWizObjectData(guid, type, startPos, WizDownloadObjectSize, data))
        {
            WizLogError(@"download object data error %@",downloadTempPath);
            return false;
        }
        NSData* dData = data.data.toNSData();
        [fileHandler writeData:dData];
        eof = data.isEOF;
    }
    [fileHandler closeFile];
    return true;
}

bool WizXmlSyncKb::downloadAttachment(const char *guid, const char *tempFilePath)
{
    if (!callDownloadObject(guid, "attachment", tempFilePath)) {
        WizLogError(@"download objcect error %@",WizCStringToNSString(guid));
        return false;
    }
    metaDb.setDocumentServerChanged(guid, false);
    return true;
}

bool WizXmlSyncKb::downloadDocument(const char *guid, const char *tempFilePath)
{
    if (!callDownloadObject(guid, "document", tempFilePath)) {
        WizLogError(@"download objcect error %@",WizCStringToNSString(guid));
        return false;
    }
    metaDb.setDocumentServerChanged(guid, false);
    return true;
}

#define WizSyncUploadObjectSize     (100*1024)

bool WizXmlSyncKb::callUploadObject(const char *guid, const char *type, const char *filePath)
{
    NSString* dataFilePath = WizCStringToNSString(filePath);
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataFilePath]) {
        
        WizLogError(@"upload file not found !%@",dataFilePath);
        return false;
    }
    NSString* fileMd5 = [WizGlobals fileMD5:dataFilePath];
    std::string cFileMd5 = WizNSStringToStdString(fileMd5);
    //
    NSFileHandle* fileHandler = [NSFileHandle fileHandleForReadingAtPath:dataFilePath];
    int64_t fileSize = [fileHandler seekToEndOfFile];
    [fileHandler seekToFileOffset:0];
    //
    int64_t partCount = fileSize % WizSyncUploadObjectSize == 0 ? fileSize/WizSyncUploadObjectSize : fileSize/WizSyncUploadObjectSize +1;
    int64_t partSN = 0;
    bool hasNext = true;
    while (hasNext) {
        NSData* data = [fileHandler readDataOfLength:WizSyncUploadObjectSize];
        int64_t currentPos = [fileHandler offsetInFile];
        if (currentPos == fileSize || data.length != WizSyncUploadObjectSize) {
            hasNext = false;
        }
        if (data.length != WizSyncUploadObjectSize) {
            partSN = partCount -1;
        }
        else
        {
            partSN = currentPos/WizSyncUploadObjectSize -1;
        }
        
        WizModule::WIZSERVERRESPONSEDATA response;
        if (!xmlServer.postWizObjectData(data, fileSize, cFileMd5.c_str(), type, guid, partCount, partSN, response)) {
            WizLogError(@"upload object error ! %@",dataFilePath);
            return false;
        }
    }
    [fileHandler closeFile];
    return true;
}

bool WizXmlSyncKb::uploadDocument(WizModule::WIZDOCUMENTDATA &doc, const char *tempFilePath)
{
    if (doc.nLocalChanged == WizEditDocumentTypeAllChanged) {
        if (!callUploadObject(doc.strGUID.c_str(), "document", tempFilePath)) {
            WizLogError(@"upload document data error ");
            return false;
        }
    }
    WizModule::WIZSERVERRESPONSEDATA response;
    if (!xmlServer.postDocumentInfo(doc, true,response))
    {
        WizLogError(@"upload document info error !");
        return false;
    }
    return true;
}

bool WizXmlSyncKb::uploadDocument(WizModule::WIZDOCUMENTDATA &doc, const char* tempFilePath, const CWizDocumentsMap& serverDocuments)
{
    
    CWizDocumentsMap::const_iterator itor = serverDocuments.find(doc.strGUID);
    if (itor == serverDocuments.end()) {
        return uploadDocument(doc, tempFilePath);
    }
    NSDate* localDate = [WizStdStringToNSString(doc.strDateModified) dateFromSqlTimeString];
    NSDate* serverDate = [WizStdStringToNSString(itor->second.dateDataModified) dateFromSqlTimeString];
    if (![localDate isEarlierThanDate:serverDate]) {
        return uploadDocument(doc, tempFilePath);
    }
    return true;
}

bool WizXmlSyncKb::uploadAttachment(WizModule::WIZDOCUMENTATTACH &attach, const char *tempFilePath)
{
    if (!callUploadObject(attach.strGuid.c_str(), "attachment", tempFilePath)) {
        WizLogError(@"upload attachment data error %@",WizStdStringToNSString(attach.strGuid));
        return false;
    }
    WizModule::WIZSERVERRESPONSEDATA response;
    if (!xmlServer.postAttachmentInfo(attach, response)) {
        WizLogError(@"upload attachment info error %@", WizStdStringToNSString(attach.strGuid));
        return false;
    }
    return true;
}

bool WizXmlSyncKb::uploadAttachment(WizModule::WIZDOCUMENTATTACH &attach, const char *tempFilePath, const WizModule::CWizDocumentAttachmentsMap &serverAttachments)
{
    CWizDocumentAttachmentsMap::const_iterator itor = serverAttachments.find(attach.strGuid);
    if (itor == serverAttachments.end()) {
        return uploadAttachment(attach, tempFilePath);
    }
    
    NSDate* localDate = [WizStdStringToNSString(attach.strDataModifiedDate) dateFromSqlTimeString];
    NSDate* serverDate = [WizStdStringToNSString(itor->second.dateDataModified) dateFromSqlTimeString];
    if (![localDate isEarlierThanDate:serverDate]) {
        return uploadAttachment(attach, tempFilePath);
    }
    return true;
}


//
//
//
//
//只同步一个kb
bool WizXmlSyncAccount::doSync( bool group , bool isOnlyUpload)
{
    if (!WizXmlServer::connectNetWork()) {
        WizLogError(@"can't get network");
        dispatch_async(dispatch_get_main_queue(), ^{
            [WizGlobals reportErrorWithString:NSLocalizedString(@"The interner network is lost!", nil)];
        });
        return false;
    }
    WizXmlAccountServer accountServer(serverUrl.c_str());
    if (!accountServer.accountLogin(accountUserId.c_str(), accountPassword.c_str())) {
        WizLogError(@"login error");
        return false;
    }
    // add synckb data
    if (group) {
        CWizGroupArray groupArray;
        if (!accountServer.getAccountGroupsList(groupArray)) {
            WizLogError(@"get group list error");
            return false;
        }
        [[WizAccountManager defaultManager] updateGroup:groupArray forAccount:WizStdStringToNSString(accountUserId)];
        for (CWizGroupArray::iterator itor = groupArray.begin(); itor != groupArray.end(); ++itor) {
            WIZSYNCINFODATA data;
            data.token = accountServer.loginData.token;
            data.kbGuid = itor->kbGuid;
            data.privilege = WizAccountPrivilege(accountUserId.c_str(),itor->kbUserGroup);
            data.dbPath = CWizFileManager::shareInstance()->metaDatabasePath(itor->kbGuid, accountUserId);
            data.accountUserId = accountUserId;
            data.serverUrl = itor->kbApiUrl;
            data.isOnlyUpload = isOnlyUpload;
            g_AddSyncKbInfo(data);
        }
    }
    else
    {
        WIZSYNCINFODATA data;
        data.token = accountServer.loginData.token;
        data.kbGuid = WizGlobalPersonalKbguid;
        data.privilege = WizAccountPrivilege(accountUserId.c_str(),0);
        data.dbPath = CWizFileManager::shareInstance()->getPersonalDatabasePath(accountUserId);
        data.accountUserId = accountUserId;
        data.serverUrl = accountServer.loginData.kapiUrl;
        data.isOnlyUpload = isOnlyUpload;
        g_AddSyncKbInfo(data);
    }
    while (true) {
        if (!g_HasSyncKbInfo()) {
            break;
        }
        else
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    return true;
}
