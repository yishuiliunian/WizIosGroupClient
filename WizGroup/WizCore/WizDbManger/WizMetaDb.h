//
//  WizMetaDb.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-19.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizDataBase.h"
#import "WizModuleTransfer.h"
using namespace WizModule;

class WizMetaDb : public WizDataBase {
private:
    std::string getMeta(const char* lpszName, const char* lpszKey);//
    bool isMetaEists(const char* lpszName, const char* lpszKey);//
    bool setMeta(const char* lpszValue, const char* lpszName, const char* lpszKey);//
    int64_t getSyncVersion(const char* lpszKey);//
    bool setSyncVersion(const char* lpszKey, int lpszValue);//
    //
    bool upgradeDocument(const WizModule::WIZDOCUMENTDATA& doc);//
    bool SQLToDocuments(const char* lpszSQL, CWizDocumentDataArray& arrayDocument);//
    bool isFieldExist(const char* tableName, const char* columnName ,const char* key);
    
    //tag
    bool sqlToTags(const char* sql, CWizTagDataArray& array);
    bool sqlToAttachments(const char* sql, CWizDocumentAttachmentArray& array);
    //deleted guid
    bool sqlToDeletedGuids(const char* sql, CWizDeletedGUIDDataArray& array);
public:
    bool open(const char* dbPath);
    WizMetaDb(){};
    WizMetaDb(const char* dbPath){open(dbPath);};
    ~WizMetaDb(){close();};
    
    virtual int getCurrentDbVersion();//test
    int64_t getDocumentVersion();//test
    int64_t getTagVersion();//test
    int64_t getDeletedVersion();//test
    int64_t getAttachmentVersion();//test
    //
    bool  setDocumentVersion(int64_t ver);//test
    bool setTagVersion(int64_t ver);//test
    bool setDeletdVersion(int64_t ver);//test
    bool setAttachmentVersion(int64_t ver);//test
    //
    bool deletedGUIDsForUpload(const CWizDeletedGUIDDataArray& array);//test
    bool deletedGuidWithWhereField(const char* whereField, const CWizDeletedGUIDDataArray& array);//test
    bool clearDeletedGUIDs();
    //document
    //
    bool documentFromGUID(const char* lpszGUID,WIZDOCUMENTDATA& doc);//test
    bool isDocumentExists(const char* lpszGuid);//test
    bool updateDocument(const WIZDOCUMENTDATA& doc);//test
    bool updateDocuments(const CWizDocumentDataArray& docs);//
    bool recentDocuments(CWizDocumentDataArray& array);//
    bool documentsArrayWithWhereFiled(const char* where ,CWizDocumentDataArray& array);//
    bool documentsByTag(const char* lpszTagGUID, CWizDocumentDataArray& array);//
    bool documentsByNotag(CWizDocumentDataArray& array);//
    bool documentsByKey(const char* lpszKeyWords, CWizDocumentDataArray& array);//
    bool documentsByLocation(const char* lpszLocation, CWizDocumentDataArray& array);//
    bool documentForUpload(CWizDocumentDataArray& array);//
    bool unreadDocuments(CWizDocumentDataArray& array);
    bool setDocumentServerChanged(const char* lpszGUID, bool isChanged);
    bool setDocumentLocalChanged(const char* lpszGUID, WizEditDocumentType changed);
    bool deleteDocument(const char* lpszGUID);
    
    bool updateDocumentReadCount(const char* lpszGUID, bool isClear);
    bool readCountOfDocument(const char* lpszGUID, int& readCount);
    //tag
    bool allTagsForTree(CWizTagDataArray& tagArray);
    bool isTagExist(const char* tagGuid);
    bool updateTag(const WIZTAGDATA& tagData);
    bool uploadTags(CWizTagDataArray& tagArray);
    bool deleteTag(const char* lpszGUID);
    //deletedGuids
    bool isDeletedGuidExist(const char* deletedGuid);
    bool uploadDeletedGuids(CWizDeletedGUIDDataArray& deletedGuidsArray);
    bool logDeletedGuid(const char* lpszGuid, const char* lpszType);
    //attachment
    bool deleteAttachment(const char* guid);
    bool attachmentsForDocument(const char* lpszDocGuid, CWizDocumentAttachmentArray& array);
    bool attachmentsForUpload(CWizDocumentAttachmentArray& array);
    bool isAttachmentExist(const char* attachGuid);
    bool updateAttachment(const WIZDOCUMENTATTACH& attachData);
    //

};