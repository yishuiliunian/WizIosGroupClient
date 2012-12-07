#ifndef _INDEX_H_
#define _INDEX_H_

#include "CppSQLite3.h"
#include <string>
#include <vector>
#import "WizModuleTransfer.h"

class CIndex
{
//public:
//	CIndex();
//	~CIndex();
//private:
//	CppSQLite3DB m_db;
//	std::string m_strFileName;
//private:
//	bool InitDB();
//	bool checkTable(const char* lpszTableName, const char* lpszTableSQL);
//    bool dropTable(const char* lpszTableName, const char* lpszTableSql);
//public:
//	bool Open(const char* lpszFileName);
//	void Close();
//	bool IsOpened();
//    bool upgradeDB();
//	//
//	bool NewDocument(const char* lpszGUID, const char* lpszTitle, const char* lpszType, const char* lpszFileType, const char* lpszLocation);
//	bool NewNote(const char* lpszGUID, const char* lpszTitle, const char* lpszLocation);
//	bool NewPhoto(const char* lpszGUID, const char* lpszTitle, const char* lpszLocation);
//	bool ChangeDocumentType(const char* lpszGUID, const char* lpszTitle, const char* lpszType, const char* lpszFileType);
//	//
//	bool IsDocumentExists(const char* lpszGUID);
//	bool UpdateDocument(const WizModule:: WIZDOCUMENTDATA& data);
//	bool DocumentFromGUID(const char* lpszGUID, WIZDOCUMENTDATA& data); 
//	bool SQLToDocuments(const char* lpszSQL, CWizDocumentDataArray& arrayDocument);
//	//
//	bool GetAllLocations(CWizStdStringArray& arrayLocation);
//	bool GetRootLocations(CWizStdStringArray& arrayLocation);
//	bool GetChildLocations(const char* lpszParentLocation, CWizStdStringArray& arrayLocation);
//	//
//	bool IsLocationExists(const char* lpszLocation);
//	bool AddLocation(const char* lpszParentLocation, const char* lpszLocationName);
//	bool AddLocation(const char* lpszLocation);
//	//
//	bool IsTagExists(const char* lpszGUID);
//	bool UpdateTag(const WIZTAGDATA& data);
//	bool GetAllTagsPathForTree(const char* lpszParentGUID, const char* lpszParentTagPath, CWizTagDataArray& arrayTag);
//	bool GetAllTagsPathForTree(CWizTagDataArray& arrayTag);
//    bool SqlToTags(const char* sql, CWizTagDataArray& array);
//    bool TagFromGUID(const char* lpszGUID, WIZTAGDATA& data);
//	//
//	bool GetDocumentsByLocation(const char* lpszParentLocation, CWizDocumentDataArray& arrayDocument);
//	bool GetDocumentsByTag(const char* lpszTagGUID, CWizDocumentDataArray& arrayDocument);
//	bool GetDocumentsByKey(const char* lpszKeywords, CWizDocumentDataArray& arrayDocument);
//	//
//	bool GetRecentDocuments(CWizDocumentDataArray& arrayDocument);
//	bool GetDocumentsForUpdate(CWizDocumentDataArray& arrayDocument);
//	//
//    bool SetDocumentMD5(const char *lpszDocumentGUID, const char *lpszMD5);
//	bool SetDocumentLocalChanged(const char* lpszDocumentGUID, bool changed);
//	bool SetDocumentServerChanged(const char* lpszDocumentGUID, bool changed);
//    bool SetDocumentAttachmentCount(const char* lpszDocumentGUID, const char* count);
//    bool SetDocumentAttibute(const char* lpszDocumentGUID, const char* lpszDocumentAttibuteName, const char* lpszAttributeValue);
//    bool SetDocumentTags(const char* lpszDocumentGUID, const char* lpszTags);
//    bool SetDocumentLocation(const char* lpszDocumentGUID, const char* lpszLocation);
//    bool SetDocumentModifiedDate(const char* lpszDocumentGUID, const char* lpszModifiedDate);
//	//
//	bool SQLToStringArray(const char* lpszSQL, CWizStdStringArray& arrayLocation);
//	//
//    
//	bool DeleteDocument(const char* lpszDocumentGUID);
//	bool DeleteTag(const char* lpszTagGUID);
//    bool DeleteAttachment(const char* lpszAttachGUID);
//	//
//	bool IsMetaExists(const char* lpszName, const char* lpszKey);
//	std::string GetMeta(const char* lpszName, const char* lpszKey);
//	bool SetMeta(const char* lpszName, const char* lpszKey, const char* lpszValue);
//	//
//	bool SQLToDeletedGUIDs(const char* lpszSQL, CWizDeletedGUIDDataArray& arrayGUID);
//	bool LogDeletedGUID(const char* lpszGUID, const char* lpszType);
//	bool GetAllDeletedGUIDs(CWizDeletedGUIDDataArray& arrayGUID);
//	bool RemoveDeletedGUID(const char* lpszGUID);
//	bool ClearDeletedGUIDs();
//	bool HasDeletedGUIDs();
//	//
//    bool GetAttachmentForUpload(CWizDocumentAttachmentArray& arrayAttach);
//    bool AttachFromGUID(const char* guid, WIZDOCUMENTATTACH& dataExist);
//    bool updateAttachment(const WIZDOCUMENTATTACH& attach);
//    bool SQLToAttachments(const char* lpszSQL, CWizDocumentAttachmentArray& arratAttach);
//    bool AttachmentsFromDocumentGUID(const char* guid, CWizDocumentAttachmentArray& array);
//    bool SetAttachmentServerChanged(const char* lpszAttachmentGUID, bool changed);
//    bool SetAttachmentLocalChanged(const char* lpszAttachmentGUID, bool changed);
//    //
//    bool GetTagPostList(CWizTagDataArray& array);
//    
//    bool AddTagsToDocumentByGuid(const char* documentGuid, const char* tagsGuid);
//    //    bool IsDocumentAttacgExists(const char* lpszGUID);
//    //	bool DocumentAttachFromGUID(const char* lpszGUID, WIZDOCUMENTATTACH& data); 
//    //	bool SQLToDocumentAttachs(const char* lpszSQL, CWizDocumentDataArray& arrayDocument);
//    //    bool updateDocumentAttach(const WIZDOCUMENTATTACH& data);
//	std::string GetNextDocumentForDownload();
//    
//    bool fileCountInLocation(const char* lpszLocation, int& count);
//    bool fileCountWithChildInlocation(const char* lpszLocation, int& count);
//    bool documentsWillDowload(int duration, CWizDocumentDataArray& array);
};


#endif

