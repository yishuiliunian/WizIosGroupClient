/*
 *  index.cpp
 *  Wiz
 *
 *  Created by Wei Shijun on 2/27/11.
 *  Copyright 2011 WizBrother. All rights reserved.
 *
 */

#include "index.h"
#include <stdlib.h>
#include <map>
#include <string.h>
#include <vector>
#include <sqlite3.h>
#include <fstream>
#include <string>
#include "CppSQLite3.h"
#include "WizMisc.h"


//static const char* g_lpszLocationSQL = "CREATE TABLE WIZ_LOCATION (\n\
//[DOCUMENT_LOCATION] CHAR(255) NOT NULL COLLATE NOCASE,\n\
//primary key (DOCUMENT_LOCATION)\n\
//)";
//
//static const char* g_lpszTagSQL = "CREATE TABLE WIZ_TAG (\n\
//TAG_GUID                       char(36)                       not null,\n\
//TAG_PARENT_GUID                 char(36),\n\
//TAG_NAME                       varchar(150),\n\
//TAG_DESCRIPTION                varchar(600),\n\
//LOCALCHANGED                     long, \n\
//DT_MODIFIED          char(19), \n\
//primary key (TAG_GUID)\n\
//)";
//static const char* g_lpsDocumentAttachSQL = "CREATE TABLE WIZ_DOCUMENT_ATTACHMENT ( \n\
//ATTACHMENT_GUID               char(36)                not null, \n\
//DOCUMENT_GUID                 char(36)                not null, \n\
//ATTACHMENT_NAME               varchar(768)            not null, \n\
//ATTACHMENT_DATA_MD5           char(32), \n\
//ATTACHMENT_DESCRIPTION        varchar(1000), \n\
//DT_MODIFIED                    char(19), \n\
//SERVER_CHANGED                int, \n\
//LOCAL_CHANGED                 int, \n\
//primary key (ATTACHMENT_GUID) \n\
//)";
//static const char* g_lpsDocumentAttachFieldSQL = "ATTACHMENT_GUID ,DOCUMENT_GUID, ATTACHMENT_NAME,ATTACHMENT_DATA_MD5,ATTACHMENT_DESCRIPTION,DT_MODIFIED,SERVER_CHANGED,LOCAL_CHANGED";
//
//static const char* g_lpszDocumentSQL = "CREATE TABLE WIZ_DOCUMENT (\n\
//DOCUMENT_GUID                  char(36)                       not null,\n\
//DOCUMENT_TITLE                 varchar(768)                   not null,\n\
//DOCUMENT_LOCATION              varchar(768),\n\
//DOCUMENT_URL                   varchar(2048),\n\
//DOCUMENT_TAG_GUIDS             varchar(2048),\n\
//DOCUMENT_TYPE                  varchar(20),\n\
//DOCUMENT_FILE_TYPE             varchar(20),\n\
//DT_CREATED                     char(19),\n\
//DT_MODIFIED                    char(19),\n\
//DOCUMENT_ATTACHEMENT_COUNT     int,\n\
//DOCUMENT_DATA_MD5              char(32),\n\
//ATTACHMENT_COUNT               int,\n\
//SERVER_CHANGED                 int,\n\
//LOCAL_CHANGED                  int,\n\
//primary key (DOCUMENT_GUID)\n\
//)";
//
//static const char* g_lpszMetaSQL = "CREATE TABLE WIZ_META (\n\
//META_NAME                       varchar(50) NOT NULL COLLATE NOCASE,\n\
//META_KEY                        varchar(50) NOT NULL COLLATE NOCASE,\n\
//META_VALUE                      varchar(3000),\n\
//primary key (META_NAME, META_KEY)\n\
//);";
//
//static const char* g_lpszDeletedGUIDSQL = "CREATE TABLE WIZ_DELETED_GUID (\n\
//DELETED_GUID                   char(36)                       not null,\n\
//GUID_TYPE                      int                            not null,\n\
//DT_DELETED                     char(19),\n\
//primary key (DELETED_GUID)\n\
//);";
//
//
//
//const char* g_lpszDocumentFieldList = "DOCUMENT_GUID, DOCUMENT_TITLE, DOCUMENT_LOCATION, DOCUMENT_URL, DOCUMENT_TAG_GUIDS, DOCUMENT_TYPE, DOCUMENT_FILE_TYPE, DT_CREATED, DT_MODIFIED, DOCUMENT_DATA_MD5, ATTACHMENT_COUNT, SERVER_CHANGED, LOCAL_CHANGED";
//const char* g_lpszDeletedGUIDFieldList = "DELETED_GUID, GUID_TYPE, DT_DELETED";
//
//const char* g_lpszUpgradeSql = "DROP TABLE WIZ_TAG";

//CIndex::CIndex()
//{
//}
//CIndex::~CIndex()
//{
//}
//
//bool CIndex::dropTable(const char *lpszTableName, const char *lpszTableSql)
//{
//    if (!m_db.tableExists(lpszTableName))
//		return false;
//	//
//	try {
//		m_db.execDML(lpszTableSql);
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while close DB");
//		return false;
//	}
//}
//
//
//bool CIndex::upgradeDB()
//{
//    if (dropTable("WIZ_TAG", g_lpszUpgradeSql)) {
//        checkTable("WIZ_TAG", g_lpszTagSQL);
//        return true;
//    } 
//    return false;
//}
//
//bool CIndex::Open(const char* lpszFileName)
//{
//
//	if (m_db.IsOpened())
//		return true;
//	//
//	try {
//		m_db.open(lpszFileName);
//		//
//		if (!InitDB())
//			return false;
//		//
//		m_strFileName = lpszFileName;
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while close DB");
//		return false;
//	}
//}
//void CIndex::Close()
//{
//	if (!m_db.IsOpened())
//		return;
//	//
//	try {
//		m_db.close();
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//	}
//	catch (...) {
//		TOLOG("Unknown exception while close DB");
//	}
//}
//
//bool CIndex::IsOpened()
//{
//	return m_db.IsOpened();
//}
//
//bool  CIndex::checkTable(const char* lpszTableName, const char* lpszTableSQL)
//{
//	if (m_db.tableExists(lpszTableName))
//		return true;
//	//
//	try {
//		m_db.execDML(lpszTableSQL);
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while close DB");
//		return false;
//	}
//}
//
//bool CIndex::InitDB()
//{
//	if (!m_db.IsOpened())
//		return false;
//	//
//	if (!checkTable("WIZ_LOCATION", g_lpszLocationSQL))
//		return false;
//	if (!checkTable("WIZ_TAG", g_lpszTagSQL))
//		return false;
//	if (!checkTable("WIZ_DOCUMENT", g_lpszDocumentSQL))
//		return false;
//	if (!checkTable("WIZ_META", g_lpszMetaSQL))
//		return false;
//	if (!checkTable("WIZ_DELETED_GUID", g_lpszDeletedGUIDSQL))
//        return false;
//    if (!checkTable("WIZ_DOCUMENT_ATTACHMENT", g_lpsDocumentAttachSQL))
//        return false;
//	//
//	return true;
//}
//bool CIndex::SQLToStringArray(const char* lpszSQL, CWizStdStringArray& arrayLocation)
//{
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		CppSQLite3Query query = m_db.execQuery(lpszSQL);
//		while (!query.eof())
//		{
//			std::string str = query.getStringField(0);
//			arrayLocation.push_back(str);
//			//
//			query.nextRow();
//		}
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while close DB");
//		return false;
//	}
//}
//
//int CountOfCharInString(const std::string& str, char c)
//{
//	int count = 0;
//	for (std::string::const_iterator it = str.begin();
//		 it != str.end();
//		 it++)
//	{
//		if (*it == c)
//			count++;
//	}
//	//
//	return count;
//}
//
//const char* FOLDER_MY_MOBILES = "/My Mobiles/";
//
//bool CIndex::GetAllLocations(CWizStdStringArray& arrayLocation)
//{
//	if (!m_db.IsOpened())
//		return false;
//	//
//	//std::string sql = "select DOCUMENT_LOCATION from WIZ_LOCATION";
//    std::string sql = "select distinct DOCUMENT_LOCATION from WIZ_DOCUMENT";
//	//
//	if (!SQLToStringArray(sql.c_str(), arrayLocation))
//		return false;
//	//
//	for (CWizStdStringArray::const_iterator it = arrayLocation.begin();
//		 it != arrayLocation.end();
//		 it++)
//	{
//		if (*it == "/My Mobiles/")
//			return true;
//	}
//	//
//	arrayLocation.push_back("/My Mobiles/");
//	//
//	return true;
//}
//
//bool CIndex::GetRootLocations(CWizStdStringArray& arrayLocation)
//{
//	CWizStdStringArray arrayAllLocation;
//	if (!GetAllLocations(arrayAllLocation))
//		return false;
//	//
//	for (CWizStdStringArray::const_iterator it = arrayAllLocation.begin();
//		 it != arrayAllLocation.end();
//		 it++)
//	{
//		if (2 == CountOfCharInString(*it, '/'))
//		{
//			arrayLocation.push_back(*it);
//		}
//	}
//	//
//	return true;
//}
//
//bool CIndex::GetChildLocations(const char* lpszParentLocation, CWizStdStringArray& arrayLocation)
//{
//	std::string strParentLocation(lpszParentLocation);
//	//
//	CWizStdStringArray arrayAllLocation;
//	if (!GetAllLocations(arrayAllLocation))
//		return false;
//	//
//	for (CWizStdStringArray::const_iterator it = arrayAllLocation.begin();
//		 it != arrayAllLocation.end();
//		 it++)
//	{
//		std::string location = *it;
//		if (location.length() > strParentLocation.length()
//			&& 0 == strncasecmp(location.c_str(), strParentLocation.c_str(), strParentLocation.length()))
//		{
//			location.erase(0, strParentLocation.length());
//			if (location.length() - 1 == location.find('/'))
//			{
//				arrayLocation.push_back(*it);
//			}
//		}
//	}
//	//
//	return true;
//}
//bool CIndex::IsLocationExists(const char* lpszLocation)
//{
//	std::string sql = "select DOCUMENT_LOCATION from WIZ_LOCATION where DOCUMENT_LOCATION=" + WizStringToSQLString(lpszLocation);
//	//
//	return m_db.hasRecord(sql.c_str());
//}
//
//bool CIndex::AddLocation(const char* lpszLocation)
//{
//	if (IsLocationExists(lpszLocation))
//		return true;
//	//
//	std::string sql = "insert into WIZ_LOCATION (DOCUMENT_LOCATION) values (" + WizStringToSQLString(lpszLocation) + ")";
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while close DB");
//		return false;
//	}
//}
//
//bool CIndex::AddLocation(const char* lpszParentLocation, const char* lpszLocationName)
//{
//	std::string location(lpszParentLocation);
//	//
//	if (location.empty())
//	{
//		location += "/";
//	}
//	//
//	location += lpszLocationName;
//	//
//	location += "/";
//	//
//	return AddLocation(location.c_str());
//}
//
//bool CIndex::IsDocumentExists(const char* lpszGUID)
//{
//	if (!IsOpened())
//		return false;
//	//
//	std::string sql = std::string("select DOCUMENT_GUID from WIZ_DOCUMENT where DOCUMENT_GUID = '") + lpszGUID + "'";
//	//
//	return m_db.hasRecord(sql.c_str());
//}
//
////bool CIndex::updateDocumentAttach(const WIZDOCUMENTATTACH& data)
////{
////    std::string sql;
////    WIZDOCUMENTATTACH dataExists;
////    if(DocumentAttachFromGUID(data.strAttachGuid , WIZDOCUMENTATTACH& data)) {
////        sql = std::string("update WIZ_DOCUMENT_ATTACH set ");
////    }
////    return 1;
////}
//
//bool CIndex::updateAttachment(const WIZDOCUMENTATTACH &attach)
//{
//    std::string sql;
//    WIZDOCUMENTATTACH dataExists;
//    if(AttachFromGUID(attach.strAttachmentGuid.c_str(), dataExists))
//    {
//        if(dataExists.loaclChanged)
//            return true;
//        std::string strServerChanged = ( dataExists.serverChanged==1 || attach.strDataMd5 != dataExists.strDataMd5) ? "1":"0";
//        std::string strLocalChanged = (attach.loaclChanged==1 || dataExists.loaclChanged) ? "1" : "0";
//        sql = std::string("update WIZ_DOCUMENT_ATTACHMENT set DOCUMENT_GUID=") + WizStringToSQLString(attach.strDocumentGuid)
//        + ", ATTACHMENT_NAME=" + WizStringToSQLString(attach.strAttachmentName)
//        + ", ATTACHMENT_DATA_MD5=" + WizStringToSQLString(attach.strDataMd5)
//        + ", ATTACHMENT_DESCRIPTION=" + WizStringToSQLString(attach.strDescription)
//        + ", DT_MODIFIED=" + WizStringToSQLString(attach.strDataModified)
//        + ", SERVER_CHANGED=" + strServerChanged
//        + ", LOCAL_CHANGED=" + strLocalChanged 
//        + " where ATTACHMENT_GUID = " + WizStringToSQLString(attach.strAttachmentGuid);
//        
//    }
//    else
//    {
//		std::string strLocalChanged = attach.loaclChanged==1 ? "1" : "0";
//		std::string strServerChanged = attach.serverChanged==1 ? "1" : "0";
//		sql = std::string("insert into WIZ_DOCUMENT_ATTACHMENT (ATTACHMENT_GUID ,DOCUMENT_GUID, ATTACHMENT_NAME,ATTACHMENT_DATA_MD5,ATTACHMENT_DESCRIPTION,DT_MODIFIED,SERVER_CHANGED,LOCAL_CHANGED) values(")
//        + WizStringToSQLString(attach.strAttachmentGuid) + ", "
//        + WizStringToSQLString(attach.strDocumentGuid)+ ", "
//        + WizStringToSQLString(attach.strAttachmentName)+ ", "
//        + WizStringToSQLString(attach.strDataMd5)+ ", "
//        + WizStringToSQLString(attach.strDescription)+ ", "
//        + WizStringToSQLString(attach.strDataModified)+ ", "
//        + strServerChanged+ ", "
//        + strLocalChanged
//        + ")";
//
//    }
//    try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		TOLOG(sql.c_str());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while update document");
//		return false;
//	}
//	//
//	return true;
//}
//
//
//
//bool CIndex::UpdateDocument(const WIZDOCUMENTDATA& data)
//{
//	std::string sql;
//	//
//	WIZDOCUMENTDATA dataExists;
//	if (DocumentFromGUID(data.strGUID.c_str(), dataExists))
//	{
//		if (dataExists.nLocalChanged && !data.nLocalChanged)
//			return true;
//		//
//		std::string strServerChanged = (dataExists.nServerChanged==1 || data.strDataMd5 != dataExists.strDataMd5) ? "1" : "0";
//		std::string strLocalChanged = (data.nLocalChanged==1 || dataExists.nLocalChanged) ? "1" : "0";
//		//
//		sql = std::string("update WIZ_DOCUMENT set DOCUMENT_TITLE=") + WizStringToSQLString(data.strTitle) 
//		+ ", DOCUMENT_LOCATION=" + WizStringToSQLString(data.strLocation)
//		+ ", DOCUMENT_URL=" + WizStringToSQLString(data.strURL)
//		+ ", DOCUMENT_TAG_GUIDS=" + WizStringToSQLString(data.strTagGUIDs)
//		+ ", DOCUMENT_TYPE=" + WizStringToSQLString(data.strType)
//		+ ", DOCUMENT_FILE_TYPE=" + WizStringToSQLString(data.strFileType)
//		+ ", DT_CREATED=" + WizStringToSQLString(data.strDateCreated)
//		+ ", DT_MODIFIED=" + WizStringToSQLString(data.strDateModified)
//		+ ", DOCUMENT_DATA_MD5=" + WizStringToSQLString(data.strDataMd5)
//		+ ", ATTACHMENT_COUNT=" + WizIntToStdString(data.nAttachmentCount)
//		+ ", SERVER_CHANGED=" + strServerChanged
//		+ ", LOCAL_CHANGED=" + strLocalChanged
//		+ " where DOCUMENT_GUID=" + WizStringToSQLString(data.strGUID);
//	}
//	else
//	{
//		bool bLocalChanged = data.nLocalChanged ? true : false;
//		bool bServerChanged = true;
//		std::string strLocalChanged = bLocalChanged ? "1" : "0";
//		std::string strServerChanged = bServerChanged ? "1" : "0";
//		
//		sql = std::string("insert into WIZ_DOCUMENT (DOCUMENT_GUID, DOCUMENT_TITLE, DOCUMENT_LOCATION, DOCUMENT_URL, DOCUMENT_TAG_GUIDS, DOCUMENT_TYPE, DOCUMENT_FILE_TYPE, DT_CREATED, DT_MODIFIED, DOCUMENT_DATA_MD5, ATTACHMENT_COUNT, SERVER_CHANGED, LOCAL_CHANGED) values (")
//		+ WizStringToSQLString(data.strGUID) + ", "
//		+ WizStringToSQLString(data.strTitle) + ", "
//		+ WizStringToSQLString(data.strLocation) + ", "
//		+ WizStringToSQLString(data.strURL) + ", "
//		+ WizStringToSQLString(data.strTagGUIDs) + ", "
//		+ WizStringToSQLString(data.strType) + ", "
//		+ WizStringToSQLString(data.strFileType) + ", "
//		+ WizStringToSQLString(data.strDateCreated) + ", "
//		+ WizStringToSQLString(data.strDateModified) + ", "
//		+ WizStringToSQLString(data.strDataMd5) + ", "
//		+ WizIntToStdString(data.nAttachmentCount) + ", "
//		+ strServerChanged + ", "
//		+ strLocalChanged + ""
//		+ ") ";
//	}
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		TOLOG(sql.c_str());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while update document");
//		return false;
//	}
//	//
//	return true;
//}
//
//
//
//
//std::string CIndex::GetNextDocumentForDownload()
//{
//	std::string sql = "select DOCUMENT_GUID from WIZ_DOCUMENT where SERVER_CHANGED=1 order by DT_MODIFIED desc limit 0, 1";
//	CWizStdStringArray arr;
//	SQLToStringArray(sql.c_str(), arr);
//	if (arr.empty())
//		return std::string();
//	//
//	return arr[0];
//}
//
////
////bool CIndex::SQLToDocumentAttachs(const char *lpszSQL, CWizDocumentDataArray &arrayDocument)
////{
////    if (!m_db.IsOpened()) return false;
////    try {
////        CppSQLite3Query query = m_db.execQuery(lpszSQL);
////        while (!query.eof()) {
////            WIZDOCUMENTATTACH data;
////            
////        }
////    } catch (<#catch parameter#>) {
////        <#statements#>
////    }
////}
//
//bool CIndex::SQLToAttachments(const char* lpszSQL, CWizDocumentAttachmentArray& arratAttach)
//{
//    if(!m_db.IsOpened())
//        return false;
//    try {
//        CppSQLite3Query query = m_db.execQuery(lpszSQL);
//        while (!query.eof()) {
//            WIZDOCUMENTATTACH data;
//            
//            
////           5,,,SERVER_CHANGED,LOCAL_CHANGED
//            data.strAttachmentGuid = query.getStringField(0);
//            data.strDocumentGuid = query.getStringField(1);
//            data.strAttachmentName = query.getStringField(2);
//            data.strDataMd5 = query.getStringField(3);
//            data.strDescription = query.getStringField(4);
//            data.strDataModified = query.getStringField(5);
//            data.serverChanged = query.getIntField(6);
//            data.loaclChanged = query.getIntField(7);
//            
//            arratAttach.push_back(data);
//			//
//			query.nextRow();
//        }
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		TOLOG(lpszSQL);
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while close DB");
//		return false;
//	}
//}
//
//bool CIndex::SqlToTags(const char *sql, CWizTagDataArray &array)
//{
//    if(!m_db.IsOpened())
//        return false;
//    try {
//        CppSQLite3Query query = m_db.execQuery(sql);
//		while (!query.eof())
//		{
//            WIZTAGDATA data;
//			data.strGUID = query.getStringField(0);
//			data.strParentGUID = query.getStringField(1);
//			data.strName = query.getStringField(2);
//			data.strDescription = query.getStringField(3);
//            data.localchanged = query.getIntField(4);
//            data.strDtInfoModified = query.getStringField(5);	
//			array.push_back(data);
//			query.nextRow();
//        }
//        return true;
//    }
//    catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		TOLOG(sql);
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while close DB");
//		return false;
//	}
//}
//
//bool CIndex::SQLToDocuments(const char* lpszSQL, CWizDocumentDataArray& arrayDocument)
//{
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		CppSQLite3Query query = m_db.execQuery(lpszSQL);
//		while (!query.eof())
//		{
//			WIZDOCUMENTDATA data;
//			data.strGUID = query.getStringField(0);
//			data.strTitle = query.getStringField(1);
//			data.strLocation = query.getStringField(2);
//			data.strURL = query.getStringField(3);
//			data.strTagGUIDs = query.getStringField(4);
//			data.strType = query.getStringField(5);
//			data.strFileType = query.getStringField(6);
//			data.strDateCreated = query.getStringField(7);
//			data.strDateModified = query.getStringField(8);
//			data.strDataMd5 = query.getStringField(9);
//			data.nAttachmentCount = query.getIntField(10);
//			data.nServerChanged = query.getIntField(11);
//			data.nLocalChanged = query.getIntField(12);
//			//
//			arrayDocument.push_back(data);
//			//
//			query.nextRow();
//		}
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		TOLOG(lpszSQL);
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while close DB");
//		return false;
//	}
//}
//bool CIndex::GetRecentDocuments(CWizDocumentDataArray& arrayDocument)
//{
//	std::string sql = std::string("select ") + g_lpszDocumentFieldList + " from WIZ_DOCUMENT order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100";
//	//
//	return SQLToDocuments(sql.c_str(), arrayDocument);
//}
//bool CIndex::GetDocumentsForUpdate(CWizDocumentDataArray& arrayDocument)
//{
//	std::string sql = std::string("select ") + g_lpszDocumentFieldList + " from WIZ_DOCUMENT where LOCAL_CHANGED=1";
//	//
//	return SQLToDocuments(sql.c_str(), arrayDocument);
//}
//
//bool CIndex::GetAttachmentForUpload(CWizDocumentAttachmentArray& arrayAttach)
//{
//    std::string sql = std::string("select ") + g_lpsDocumentAttachFieldSQL + " from WIZ_DOCUMENT_ATTACHMENT where LOCAL_CHANGED=1";
//    return SQLToAttachments(sql.c_str(), arrayAttach);
//}
//
//bool CIndex::GetDocumentsByLocation(const char* lpszParentLocation, CWizDocumentDataArray& arrayDocument)
//{
//	std::string sql = std::string("select ") + g_lpszDocumentFieldList + " from WIZ_DOCUMENT where DOCUMENT_LOCATION=" + WizStringToSQLString(lpszParentLocation) + " order by max(DT_CREATED, DT_MODIFIED) desc";
//	//
//	return SQLToDocuments(sql.c_str(), arrayDocument);
//}
//
//bool CIndex::GetDocumentsByTag(const char* lpszTagGUID, CWizDocumentDataArray& arrayDocument)
//{
//	std::string sql = std::string("select ") + g_lpszDocumentFieldList + " from WIZ_DOCUMENT where DOCUMENT_TAG_GUIDS like '%" + lpszTagGUID + "%' order by DOCUMENT_TITLE";
//	//
//	return SQLToDocuments(sql.c_str(), arrayDocument);
//}
//bool CIndex::GetDocumentsByKey(const char* lpszKeywords, CWizDocumentDataArray& arrayDocument)
//{
//	std::string keywords = std::string("%") + lpszKeywords + "%";
//	//
//	std::string sql = std::string("select ") + g_lpszDocumentFieldList + " from WIZ_DOCUMENT where DOCUMENT_TITLE like " + WizStringToSQLString(keywords.c_str()) + " order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100";
//	//
//	return SQLToDocuments(sql.c_str(), arrayDocument);
//}
//bool CIndex::DocumentFromGUID(const char* lpszGUID, WIZDOCUMENTDATA& data)
//{
//	std::string sql = std::string("select ") + g_lpszDocumentFieldList + " from WIZ_DOCUMENT where DOCUMENT_GUID='" + lpszGUID + "'";
//	//
//	CWizDocumentDataArray arrayDocument;
//	if (!SQLToDocuments(sql.c_str(), arrayDocument))
//		return false;
//	//
//	if (1 != arrayDocument.size())
//		return false;
//	//
//	data = arrayDocument[0];
//	//
//	return true;
//}
//
//bool CIndex::TagFromGUID(const char *lpszGUID, WIZTAGDATA &data)
//{
//    std::string sql = std::string("select TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION  ,LOCALCHANGED, DT_MODIFIED from WIZ_TAG where TAG_GUID = '") + lpszGUID + "'";
//	//
//	CWizTagDataArray arrayDocument;
//	if (!SqlToTags(sql.c_str(), arrayDocument))
//		return false;
//	//
//	if (1 != arrayDocument.size())
//		return false;
//	//
//	data = arrayDocument[0];
//	//
//	return true;
//}
//
//
//bool CIndex::AttachFromGUID(const char *guid, WIZDOCUMENTATTACH& dataExist)
//{
//    std::string sql = std::string("select ") + g_lpsDocumentAttachFieldSQL + " from WIZ_DOCUMENT_ATTACHMENT where ATTACHMENT_GUID='" + guid +"'";
//    
//    CWizDocumentAttachmentArray arrayAttach;
//    if(! SQLToAttachments(sql.c_str(), arrayAttach))
//    {
//        return false;
//    }
//    if(1 != arrayAttach.size())
//    {
//        return false;
//    }
//    dataExist = arrayAttach[0];
//    return true;
//}
//
//bool CIndex::AttachmentsFromDocumentGUID(const char *guid, CWizDocumentAttachmentArray& array)
//{
//    std::string sql = std::string("select ") + g_lpsDocumentAttachFieldSQL + " from WIZ_DOCUMENT_ATTACHMENT where DOCUMENT_GUID='" + guid +"'";
//    if(!SQLToAttachments(sql.c_str(), array))
//        return false;
//    else return true;
//}
//
//bool CIndex::documentsWillDowload(int duration, CWizDocumentDataArray &array)
//{
//    int day = duration % 30;
//    int month = duration/30 %12;
//    int year = duration/(365);
//    std::string sql = std::string("select ") + g_lpszDocumentFieldList + " from WIZ_DOCUMENT where DT_MODIFIED >= datetime('now', '-" +WizIntToStdString(day) + " day','-" + WizIntToStdString(month) + " month','-" + WizIntToStdString(year) + " year') and SERVER_CHANGED=1";
//    if(!SQLToDocuments(sql.c_str(), array))
//        return false;
//    else
//        return true;
//}
//
//bool CIndex::IsTagExists(const char* lpszGUID)
//{
//	if (!IsOpened())
//		return false;
//	//
//	std::string sql = std::string("select TAG_GUID from WIZ_TAG where TAG_GUID = '") + lpszGUID + "'";
//	//
//	return m_db.hasRecord(sql.c_str());
//}
//bool CIndex::UpdateTag(const WIZTAGDATA& data)
//{
//	std::string sql;
//	if (IsTagExists(data.strGUID.c_str()))
//	{
//		sql = std::string("update WIZ_TAG set TAG_NAME=") + WizStringToSQLString(data.strName) 
//		+ ", TAG_DESCRIPTION=" + WizStringToSQLString(data.strDescription)
//		+ ", TAG_PARENT_GUID=" + WizStringToSQLString(data.strParentGUID)
//        + ", LOCALCHANGED=" +  WizIntToStdString(data.localchanged)
//        + ", DT_MODIFIED=" + WizStringToSQLString(data.strDtInfoModified)
//		+ " where TAG_GUID=" + WizStringToSQLString(data.strGUID);
//	}
//	else 
//	{
//		sql = std::string("insert into WIZ_TAG (TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION ,LOCALCHANGED, DT_MODIFIED ) values (")
//		+ WizStringToSQLString(data.strGUID) + ", "
//		+ WizStringToSQLString(data.strParentGUID) + ", "
//		+ WizStringToSQLString(data.strName) + ", "
//		+ WizStringToSQLString(data.strDescription) + ", "
//        + WizIntToStdString(data.localchanged) + ", "
//        + WizStringToSQLString(data.strDtInfoModified) +") ";		
//        
//	}
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while update tag");
//		return false;
//	}
//	//
//	return true;
//}
//bool CIndex::GetTagPostList(CWizTagDataArray &array)
//{
//    std::string sql;
//    sql = std::string ("select TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION  ,LOCALCHANGED, DT_MODIFIED from WIZ_TAG where LOCALCHANGED is -1");
//    //test post all tag
//    //    sql = std::string ("select TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION  ,LOCALCHANGED, DT_MODIFIED from WIZ_TAG ");
//    if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		CppSQLite3Query query = m_db.execQuery(sql.c_str());
//		while (!query.eof())
//		{
//			WIZTAGDATA data;
//			data.strGUID = query.getStringField(0);
//			data.strParentGUID = query.getStringField(1);
//			data.strName = query.getStringField(2);
//			data.strDescription = query.getStringField(3);
//            data.localchanged = query.getIntField(4);
//            data.strDtInfoModified = query.getStringField(5);	
//			array.push_back(data);
//			query.nextRow();
//		}
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while get tags for tree");
//		return false;
//	}	
//}
//
//bool CIndex::GetAllTagsPathForTree(const char* lpszParentGUID, const char* lpszParentTagPath, CWizTagDataArray& arrayTag)
//{
//	std::string strParentTagPath(lpszParentTagPath);
//	//
//	std::string sql;
//	if (IsEmptyString(lpszParentGUID))
//	{
//		sql = std::string("select TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION  ,LOCALCHANGED, DT_MODIFIED from WIZ_TAG where TAG_PARENT_GUID is NULL");
//	}
//	else {
//		sql = std::string("select TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION ,LOCALCHANGED, DT_MODIFIED  from WIZ_TAG where TAG_PARENT_GUID=") + WizStringToSQLString(lpszParentGUID);
//	}
//	//
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		CppSQLite3Query query = m_db.execQuery(sql.c_str());
//		while (!query.eof())
//		{
//			WIZTAGDATA data;
//			data.strGUID = query.getStringField(0);
//			data.strParentGUID = query.getStringField(1);
//			data.strName = query.getStringField(2);
//			data.strDescription = query.getStringField(3);
//            data.localchanged = query.getIntField(4);
//            data.strDtInfoModified = query.getStringField(5);
//			//
//			std::string strNameInPath = data.strName;
//			WizStdStringReplace(strNameInPath, "/", "-");
//			//
//			std::string strNewTagPath = strParentTagPath + strNameInPath + "/";
//			//
//			data.strNamePath = strNewTagPath;
//			
//			arrayTag.push_back(data);
//			//
//			GetAllTagsPathForTree(data.strGUID.c_str(), strNewTagPath.c_str(), arrayTag);
//			//
//			query.nextRow();
//		}
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while get tags for tree");
//		return false;
//	}	
//	
//}
//bool CIndex::GetAllTagsPathForTree(CWizTagDataArray& arrayTag)
//{
//	return GetAllTagsPathForTree(NULL, "/", arrayTag);
//}
//
//bool CIndex::SetAttachmentLocalChanged(const char *lpszAttachmentGUID, bool changed)
//{
//    std::string strChanged = changed ? "1" : "0";
//	std::string sql = std::string("update WIZ_DOCUMENT_ATTACHMENT set LOCAL_CHANGED=") + strChanged + " where ATTACHMENT_GUID='" + lpszAttachmentGUID + "'";
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while update document local_changed");
//		return false;
//	}
//}
//
//bool CIndex::SetAttachmentServerChanged(const char *lpszAttachmentGUID, bool changed)
//{
//    std::string strChanged = changed ? "1" : "0";
//	std::string sql = std::string("update WIZ_DOCUMENT_ATTACHMENT set SERVER_CHANGED=") + strChanged + " where ATTACHMENT_GUID='" + lpszAttachmentGUID + "'";
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while update document local_changed");
//		return false;
//	}
//}
//
//
//
//bool CIndex::SetDocumentLocalChanged(const char* lpszDocumentGUID, bool changed)
//{
//	std::string strChanged = changed ? "1" : "0";
//	std::string sql = std::string("update WIZ_DOCUMENT set LOCAL_CHANGED=") + strChanged + " where DOCUMENT_GUID='" + lpszDocumentGUID + "'";
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while update document local_changed");
//		return false;
//	}
//}
//bool CIndex::SetDocumentTags(const char *lpszDocumentGUID, const char *lpszTags)
//{
//    std::string tags = std::string("'")+lpszTags+"'";
//    return SetDocumentAttibute(lpszDocumentGUID, "DOCUMENT_TAG_GUIDS", tags.c_str());
//}
//
//bool CIndex::SetDocumentMD5(const char *lpszDocumentGUID, const char *lpszMD5)
//{
//    std::string md5 = std::string("'")+lpszMD5+"'";
//    return  SetDocumentAttibute(lpszDocumentGUID, "DOCUMENT_DATA_MD5", md5.c_str());
//}
//
//bool CIndex::SetDocumentAttachmentCount(const char *lpszDocumentGUID, const char *count)
//{
//    return SetDocumentAttibute(lpszDocumentGUID, "DOCUMENT_ATTACHEMENT_COUNT", count);
//}
//
//bool CIndex::SetDocumentLocation(const char *lpszDocumentGUID, const char *lpszLocation)
//{
//    std::string location = std::string("'")+lpszLocation+"'";
//    return SetDocumentAttibute(lpszDocumentGUID, "DOCUMENT_LOCATION", location.c_str());
//}
//
//bool CIndex::SetDocumentModifiedDate(const char *lpszDocumentGUID, const char *lpszModifiedDate)
//{
//    return SetDocumentAttibute(lpszDocumentGUID, "DT_MODIFIED", lpszModifiedDate);
//}
//
//bool CIndex::SetDocumentAttibute(const char *lpszDocumentGUID, const char *lpszDocumentAttibuteName, const char *lpszAttributeValue)
//{
//    std::string sql = std::string("update WIZ_DOCUMENT set ") + lpszDocumentAttibuteName + "=" + lpszAttributeValue + " where DOCUMENT_GUID='" + lpszDocumentGUID + "'";
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while update document local_changed");
//		return false;
//	}
//}
//
//bool CIndex::SetDocumentServerChanged(const char* lpszDocumentGUID, bool changed)
//{
//	std::string strChanged = changed ? "1" : "0";
//	std::string sql = std::string("update WIZ_DOCUMENT set SERVER_CHANGED=") + strChanged + " where DOCUMENT_GUID='" + lpszDocumentGUID + "'";
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while update document server_changed");
//		return false;
//	}	
//}
//
//bool CIndex::NewDocument(const char* lpszGUID, const char* lpszTitle, const char* lpszType, const char* lpszFileType, const char* lpszLocation)
//{
//	if (!lpszLocation || !(*lpszLocation))
//	{
//		lpszLocation = "/My Notes/";
//	}
//	//
//	WIZDOCUMENTDATA data;
//	data.strGUID = lpszGUID;
//	data.strTitle = lpszTitle;
//	data.strLocation = lpszLocation;
//	data.strDataMd5 = "";
//	data.strDateCreated = WizGetCurrentTimeSQLString();
//	data.strDateModified = data.strDateCreated;
//	data.strType = lpszType;
//	data.strFileType = lpszFileType;
//	data.nAttachmentCount = 0;
//	data.nServerChanged = 0;
//	data.nLocalChanged = 1;
//	//
//	if (!UpdateDocument(data))
//		return false;
//	//
//	return SetDocumentServerChanged(lpszGUID, false);
//}
//bool CIndex::NewNote(const char* lpszGUID, const char* lpszTitle, const char* lpszLocation)
//{
//	return NewDocument(lpszGUID, lpszTitle, "note", ".txt", lpszLocation);
//}
//
//bool CIndex::NewPhoto(const char* lpszGUID, const char* lpszTitle, const char* lpszLocation)
//{
//	return NewDocument(lpszGUID, lpszTitle, "photo", ".jpg", lpszLocation);
//}
//
//bool CIndex::ChangeDocumentType(const char* lpszGUID, const char* lpszTitle, const char* lpszType, const char* lpszFileType)
//{
//	std::string sql = std::string("update WIZ_DOCUMENT set DOCUMENT_TYPE='") + lpszType 
//    + "', DOCUMENT_FILE_TYPE='" + lpszFileType 
//    + "', DT_MODIFIED='" + WizGetCurrentTimeSQLString() 
//    + "', DOCUMENT_TITLE=" + WizStringToSQLString(lpszTitle) 
//    + ", LOCAL_CHANGED=1 where DOCUMENT_GUID='" + lpszGUID + "'";
//	//
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while editing document");
//		return false;
//	}	
//}
//
//bool CIndex::DeleteDocument(const char* lpszDocumentGUID)
//{
//	std::string sql = std::string("delete from WIZ_DOCUMENT where DOCUMENT_GUID='") + lpszDocumentGUID + "'";
//	
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while deleting document");
//		return false;
//	}	
//}
//bool CIndex::DeleteTag(const char* lpszTagGUID)
//{
//	std::string sql = std::string("delete from WIZ_TAG where TAG_GUID='") + lpszTagGUID + "'";
//	
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while deleting tag");
//		return false;
//	}	
//}
//
//bool CIndex::DeleteAttachment(const char *lpszAttachGUID)
//{
//    std::string sql = std::string("delete from WIZ_DOCUMENT_ATTACHMENT where ATTACHMENT_GUID='") + lpszAttachGUID + "'";
//	
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while deleting tag");
//		return false;
//	}	
//}
//
//bool CIndex::AddTagsToDocumentByGuid(const char *documentGuid, const char *tagsGuid)
//{
//    std::string sql = std::string("update WIZ_DOCUMENT set DOCUMENT_TAG_GUIDS=") + WizStringToSQLString(tagsGuid) +
//    +" where DOCUMENT_GUID=" + WizStringToSQLString(documentGuid) ;
//    
//    SetDocumentLocalChanged(documentGuid, 1);
//    
//    try {
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while update document");
//		return false;
//	}
//	//
//	return true;
//    
//}
//
//
//bool CIndex::IsMetaExists(const char* lpszName, const char* lpszKey)
//{
//	std::string sql = std::string("select META_NAME from WIZ_META where META_NAME='") + lpszName + "' and META_KEY='" + lpszKey + "'";
//    bool ret =  m_db.hasRecord(sql.c_str());
//	return ret;
//}
//std::string CIndex::GetMeta(const char* lpszName, const char* lpszKey)
//{
//	if (!IsMetaExists(lpszName, lpszKey))
//		return std::string();
//	//
//	std::string sql = std::string("select META_VALUE from WIZ_META where META_NAME='") + lpszName + "' and META_KEY='" + lpszKey + "'";
//	//
//	if (!m_db.IsOpened())
//		return std::string();
//	//
//	std::string ret;
//	//
//	try {
//		CppSQLite3Query query = m_db.execQuery(sql.c_str());
//		if (!query.eof())
//		{
//			ret = query.getStringField(0);
//		}
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//	}
//	catch (...) {
//		TOLOG("Unknown exception while get tags for tree");
//	}		
//	//
//	return ret;
//}
//bool CIndex::SetMeta(const char* lpszName, const char* lpszKey, const char* lpszValue)
//{
//	std::string sql;
//    
//	if (IsMetaExists(lpszName, lpszKey))
//	{
//		sql = "update WIZ_META set META_VALUE=" + WizStringToSQLString(lpszValue) + " where META_NAME='" + lpszName + "' and META_KEY='" + lpszKey + "'";
//	}
//	else 
//	{
//		sql = std::string("insert into WIZ_META (META_NAME, META_KEY, META_VALUE) values('") + lpszName + "', '" + lpszKey + "', " + WizStringToSQLString(lpszValue) + ")";
//	}
//	//
//	//
//	try 
//	{
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		TOLOG(sql.c_str());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while update meta");
//		return false;
//	}
//	//
//	return true;
//}
//
//bool CIndex::SQLToDeletedGUIDs(const char* lpszSQL, CWizDeletedGUIDDataArray& arrayGUID)
//{
//	if (!m_db.IsOpened())
//		return false;
//	//
//	try {
//		CppSQLite3Query query = m_db.execQuery(lpszSQL);
//		while (!query.eof())
//		{
//			WIZDELETEDGUIDDATA data;
//			data.strGUID = query.getStringField(0);
//			data.strType = query.getStringField(1);
//			data.strDateDeleted = query.getStringField(2);
//			//
//			arrayGUID.push_back(data);
//			//
//			query.nextRow();
//		}
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		TOLOG(lpszSQL);
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while query deleted guid");
//		return false;
//	}
//}
//bool CIndex::LogDeletedGUID(const char* lpszGUID, const char* lpszType)
//{
//	std::string sql = std::string("insert into WIZ_DELETED_GUID (DELETED_GUID, GUID_TYPE, DT_DELETED) values ('") + lpszGUID + "', '" + lpszType + "', '" + WizGetCurrentTimeSQLString() + "')";
//	//
//	try 
//	{
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		TOLOG(sql.c_str());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while adding deleted guid");
//		return false;
//	}
//}
//bool CIndex::fileCountInLocation(const char *lpszLocation, int &count)
//{
//    std::string lpszSQL = std::string("select count(*) from WIZ_DOCUMENT where DOCUMENT_LOCATION = '") + lpszLocation +("'");
//    
//    try {
//		CppSQLite3Query query = m_db.execQuery(lpszSQL.c_str());
//		while (!query.eof())
//		{
//			count = query.getIntField(0);
//            query.nextRow();
//		}
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		TOLOG(lpszSQL.c_str());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while query deleted guid");
//		return false;
//	}
//
//    
//}
//bool CIndex::fileCountWithChildInlocation(const char *lpszLocation, int &count)
//{
//        std::string lpszSQL = std::string("select count(*) from WIZ_DOCUMENT where DOCUMENT_LOCATION like '") + lpszLocation +("%'");
//        
//        try {
//                CppSQLite3Query query = m_db.execQuery(lpszSQL.c_str());
//                while (!query.eof())
//                    {
//                            count = query.getIntField(0);
//                            query.nextRow();
//                        }
//                return true;
//            }
//        catch (const CppSQLite3Exception& e)
//        {
//                TOLOG(e.errorMessage());
//                TOLOG(lpszSQL.c_str());
//                return false;
//            }
//        catch (...) {
//                TOLOG("Unknown exception while query deleted guid");
//                return false;
//            }    
//}
//bool CIndex::ClearDeletedGUIDs()
//{
//	std::string sql = "delete from WIZ_DELETED_GUID";
//	
//	try 
//	{
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		TOLOG(sql.c_str());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while clear deleted guid");
//		return false;
//	}	
//}
//
//bool CIndex::HasDeletedGUIDs()
//{
//	return m_db.hasRecord("select from WIZ_DELETED_GUID");
//}
//
//bool CIndex::GetAllDeletedGUIDs(CWizDeletedGUIDDataArray& arrayGUID)
//{
//	std::string sql = std::string("select ") + g_lpszDeletedGUIDFieldList + " from WIZ_DELETED_GUID";
//	return SQLToDeletedGUIDs(sql.c_str(), arrayGUID);
//}
//bool CIndex::RemoveDeletedGUID(const char* lpszGUID)
//{
//	std::string sql = std::string("delete from WIZ_DELETED_GUID where DELETED_GUID='") + lpszGUID + "'";
//	//
//	try 
//	{
//		m_db.execDML(sql.c_str());
//		return true;
//	}
//	catch (const CppSQLite3Exception& e)
//	{
//		TOLOG(e.errorMessage());
//		TOLOG(sql.c_str());
//		return false;
//	}
//	catch (...) {
//		TOLOG("Unknown exception while removing deleted guid");
//		return false;
//	}
//}
//
//
//
//int WizStdStringReplace(std::string& str, const char* lpszStringToReplace, const char* lpszNewString)
//{
//	if (IsEmptyString(lpszStringToReplace))
//		return 0;
//	//
//	int count = 0;
//	//
//	int oldLen = strlen(lpszStringToReplace);
//	int newLen = IsEmptyString(lpszNewString) ? 0 : strlen(lpszNewString);
//	//
//	intptr_t index = str.find(lpszStringToReplace);
//	while (index != std::string::npos)
//	{
//		str.replace(index, oldLen, lpszNewString);
//		//
//		index = str.find(lpszStringToReplace, index + newLen);
//		//
//		count++;
//	}
//	//
//	return count;
//}
//
//std::string WizStringToSQLString(const char* lpsz)
//{
//	if (!lpsz || !*lpsz)
//		return std::string("NULL");
//	//
//	std::string str(lpsz);
//	//
//	WizStdStringReplace(str, "'", "''");
//	//
//	str = "'" + str + "'";
//	//
//	return str;
//}
//
//std::string WizStringToSQLString(const std::string& str)
//{
//	return WizStringToSQLString(str.c_str());
//}
//
//bool WizIsSpaceChar(char ch)
//{
//	return ch == ' '
//	|| ch == '\n'
//	|| ch == '\r'
//	|| ch == '\t';
//}
//
//std::string WizStdStringTrimLeft(const std::string& str) 
//{
//    std::string t = str;
//    for (std::string::iterator i = t.begin(); i != t.end(); i++) 
//	{
//        if (!WizIsSpaceChar(*i)) 
//		{
//            t.erase(t.begin(), i);
//            break;
//        }
//    }
//    return t;
//}
//
//std::string WizStdStringTrimRight(const std::string& str) 
//{
//    if (str.begin() == str.end()) {
//        return str;
//    }
//	
//    std::string t = str;
//    for (std::string::iterator i = t.end() - 1; i != t.begin(); i--) 
//	{
//        if (!WizIsSpaceChar(*i)) {
//            t.erase(i + 1, t.end());
//            break;
//        }
//    }
//    return t;
//}
//
//std::string WizIntToStdString(int n)
//{
//	char sz[20] = {0};
//	sprintf(sz, "%d", n);
//	return std::string(sz);
//}
//std::string WizStdStringTrim(const std::string& str) 
//{
//    std::string t = str;
//	
//    std::string::iterator i;
//    for (i = t.begin(); i != t.end(); i++) 
//	{
//        if (!WizIsSpaceChar(*i)) 
//		{
//            t.erase(t.begin(), i);
//            break;
//        }
//    }
//	
//    if (i == t.end()) 
//	{
//        return t;
//    }
//	
//    for (i = t.end() - 1; i != t.begin(); i--) 
//	{
//        if (!WizIsSpaceChar(*i)) 
//		{
//            t.erase(i + 1, t.end());
//            break;
//        }
//    }
//	
//    return t;
//}
//
//std::string WizGetCurrentTimeSQLString()
//{
//	time_t tNow;
//	time(&tNow);
//	//
//	struct tm* ptm = localtime(&tNow);
//	//
//	int year = 1900 + ptm->tm_year;
//	int month = 1 + ptm->tm_mon;
//	int day = ptm->tm_mday;
//	int hour = ptm->tm_hour;
//	int minute = ptm->tm_min;
//	int second = ptm->tm_sec;
//	//
//	char buffer[40];
//	sprintf(buffer, "%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second);
//	//
//	return std::string(buffer);
//}




