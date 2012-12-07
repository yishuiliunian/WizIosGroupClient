
//  WizMetaDb.m
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-19.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizMetaDb.h"
#import "WizStrings.h"
#import "WizMisc.h"
#import "WizGlobalCache.h"
#import <iterator>
using namespace WizModule;
const char* g_lpszDocumentTableName = "WIZ_DOCUMENT";
const char* g_lpszTagTableName = "WIZ_TAG";
const char* g_lpszDeletedTableName = "WIZ_DELETED_GUID";
const char* g_lpszMetaTableName = "WIZ_META";
const char* g_lpszDocumentAttachmentTableName = "WIZ_DOCUMENT_ATTACHMENT";

const char* g_lpszDocumentFieldList = "DOCUMENT_GUID, \
                                        DOCUMENT_TITLE, \
                                        DOCUMENT_LOCATION,\
                                        DOCUMENT_URL, \
                                        DOCUMENT_TAG_GUIDS,\
                                        DOCUMENT_TYPE,\
                                        DOCUMENT_FILE_TYPE,\
                                        DT_CREATED, \
                                        DT_MODIFIED, \
                                        DOCUMENT_DATA_MD5,\
                                        ATTACHMENT_COUNT,\
                                        SERVER_CHANGED,\
                                        LOCAL_CHANGED,\
                                        GPS_LATITUDE,\
                                        GPS_LONGTITUDE,\
                                        GPS_ALTITUDE,\
                                        GPS_DOP,\
                                        GPS_ADDRESS,\
                                        GPS_COUNTRY,\
                                        GPS_DESCRIPTION,\
                                        GPS_LEVEL1,\
                                        GPS_LEVEL2,\
                                        GPS_LEVEL3,\
                                        READCOUNT,\
                                        OWNER,\
                                        PROTECT";
const char* g_lpszTagField = "TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION ,LOCALCHANGED, DT_MODIFIED";
const char* g_lpszAttachmentField = "ATTACHMENT_GUID ,DOCUMENT_GUID, ATTACHMENT_NAME,ATTACHMENT_DATA_MD5,ATTACHMENT_DESCRIPTION,DT_MODIFIED,SERVER_CHANGED,LOCAL_CHANGED";

const char* g_lpszDeletedGUIDFieldList = "DELETED_GUID, GUID_TYPE, DT_DELETED";

void removeLocalDocumentAbstract(const char* documentGuid)
{
    [[WizGlobalCache shareInstance] removeDocumentAbstractForKey:WizStdStringToNSString(documentGuid)];
}

bool WizMetaDb::open(const char *dbPath)
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WizDataBaseModel" ofType:@"plist"];
    return WizDataBase::open(dbPath, WizNSStringToCString(path));
}

bool WizMetaDb::isFieldExist(const char *tableName, const char *columnName, const char *key)
{
    if (!m_db.IsOpened())
		return false;
	//
	std::string sql = std::string("select ")+columnName+" from "+ tableName+" where "+ columnName+" = '" + key + "'";
	//
	return m_db.hasRecord(sql.c_str());
}

int WizMetaDb::getCurrentDbVersion()
{
    return 1;
}
//
std::string WizMetaDb::getMeta(const char *lpszName, const char *lpszKey)
{
    if (!isMetaEists(lpszName, lpszKey)) {
        return std::string();
    }
	std::string sql = std::string("select META_VALUE from WIZ_META where META_NAME='") + lpszName + "' and META_KEY='" + lpszKey + "'";
	//
	if (!m_db.IsOpened())
		return std::string();
	//
	std::string ret;
	//
	try {
		CppSQLite3Query query = m_db.execQuery(sql.c_str());
		if (!query.eof())
		{
			ret = query.getStringField(0);
		}
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
	}
	catch (...) {
		TOLOG("Unknown exception while get tags for tree");
	}
	//
	return ret;

}
bool WizMetaDb::isMetaEists(const char *lpszName, const char *lpszKey)
{
	std::string sql = std::string("select META_NAME from WIZ_META where META_NAME='") + lpszName + "' and META_KEY='" + lpszKey + "'";
    bool ret =  m_db.hasRecord(sql.c_str());
	return ret;
}

bool WizMetaDb::setMeta(const char *lpszValue, const char *lpszName, const char *lpszKey)
{
	std::string sql;

	if (isMetaEists(lpszName, lpszKey))
	{
		sql = "update WIZ_META set META_VALUE=" + WizStringToSQLString(lpszValue) + " where META_NAME='" + lpszName + "' and META_KEY='" + lpszKey + "'";
	}
	else
	{
		sql = std::string("insert into WIZ_META (META_NAME, META_KEY, META_VALUE) values('") + lpszName + "', '" + lpszKey + "', " + WizStringToSQLString(lpszValue) + ")";
	}
	//
	//
	try
	{
		m_db.execDML(sql.c_str());
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		TOLOG(sql.c_str());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while update meta");
		return false;
	}
	//
	return true;
}
//
static std::string const WizSyncLocalVersion = "SYNC_VERSION";
static std::string const WizSyncLocalVersionDocument = "DOCUMENT";
static std::string const WizSyncLocalVersionAttachment = "ATTACHMENT";
static std::string const WizSyncLocalVersionTag = "TAG";
static std::string const WizSyncLocalVersionDeletedGuid = "DELETED_GUID";

int64_t WizMetaDb::getSyncVersion(const char *lpszKey)
{
    std::string version = getMeta(WizSyncLocalVersion.c_str(), lpszKey);
    if (IsEmptyString(version.c_str())) {
        return 0;
    }
    else
    {
        return WizStringToInt(version.c_str());
    }
}

bool WizMetaDb::setSyncVersion(const char *lpszKey, int lpszValue)
{
    return setMeta(WizIntToStdString(lpszValue).c_str(), WizSyncLocalVersion.c_str(), lpszKey);
}


int64_t WizMetaDb::getDocumentVersion()
{
    return getSyncVersion(WizSyncLocalVersionDocument.c_str());
}

int64_t WizMetaDb::getTagVersion()
{
    return getSyncVersion(WizSyncLocalVersionTag.c_str());
}

int64_t WizMetaDb::getDeletedVersion()
{
    return getSyncVersion(WizSyncLocalVersionDeletedGuid.c_str());
}

int64_t WizMetaDb::getAttachmentVersion()
{
    return getSyncVersion(WizSyncLocalVersionAttachment.c_str());
}

bool WizMetaDb::setDocumentVersion(int64_t ver)
{
    return setSyncVersion(WizSyncLocalVersionDocument.c_str(), ver);
}

bool WizMetaDb::setTagVersion(int64_t ver)
{
    return setSyncVersion(WizSyncLocalVersionTag.c_str(), ver);
}

bool WizMetaDb::setDeletdVersion(int64_t ver)
{
    return setSyncVersion(WizSyncLocalVersionDeletedGuid.c_str(), ver);
}

bool WizMetaDb::setAttachmentVersion(int64_t ver)
{
    return setSyncVersion(WizSyncLocalVersionAttachment.c_str(), ver);
}

//
bool WizMetaDb::SQLToDocuments(const char *lpszSQL, CWizDocumentDataArray &arrayDocument)
{
	if (!m_db.IsOpened())
		return false;
	//
	try {
		CppSQLite3Query query = m_db.execQuery(lpszSQL);
		while (!query.eof())
		{
			WIZDOCUMENTDATA data;
			data.strGUID = query.getStringField(0);
			data.strTitle = query.getStringField(1);
			data.strLocation = query.getStringField(2);
			data.strURL = query.getStringField(3);
			data.strTagGUIDs = query.getStringField(4);
			data.strType = query.getStringField(5);
			data.strFileType = query.getStringField(6);
			data.strDateCreated = query.getStringField(7);
			data.strDateModified = query.getStringField(8);
			data.strDataMd5 = query.getStringField(9);
			data.nAttachmentCount = query.getIntField(10);
			data.nServerChanged = query.getIntField(11);
			data.nLocalChanged = query.getIntField(12);
            data.gpsLatitude = query.getFloatField(13);
            data.gpsLongtitude = query.getFloatField(14);
            data.gpsAltitude = query.getFloatField(15);
            data.gpsDop = query.getFloatField(16);
            data.gpsAddress = query.getStringField(17);
            data.gpsCountry = query.getStringField(18);
            data.gpsDescription = query.getStringField(19);
            data.gpsLevel1 = query.getStringField(20);
            data.gpsLevel2 = query.getStringField(21);
            data.gpsLevel3 = query.getStringField(22);
            data.nReadCount = query.getIntField(23);
            data.strOwner = query.getStringField(24);
            data.nProtected = query.getInt64Field(25);
            //
			arrayDocument.push_back(data);
			//
			query.nextRow();
		}
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		TOLOG(lpszSQL);
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while close DB");
		return false;
	}
}

#pragma document

bool WizMetaDb::documentFromGUID(const char *lpszGUID, WIZDOCUMENTDATA &doc)
{
    if (!lpszGUID || !*lpszGUID)
	{
		TOLOG(("DocumentGUID is empty"));
		return FALSE;
	}
	std::string sql = std::string("select ") + g_lpszDocumentFieldList + " from WIZ_DOCUMENT where DOCUMENT_GUID='" + lpszGUID + "'";
	//
	CWizDocumentDataArray arrayDocument;
	if (!SQLToDocuments(sql.c_str(), arrayDocument))
		return false;
	//
	if (1 != arrayDocument.size())
		return false;
	//
	doc = arrayDocument[0];
	//
	return true;

}



bool WizMetaDb::isDocumentExists(const char *lpszGuid)
{
	if (!m_db.IsOpened())
		return false;
	//
	std::string sql = std::string("select DOCUMENT_GUID from WIZ_DOCUMENT where DOCUMENT_GUID = '") + lpszGuid + "'";
	//
	return m_db.hasRecord(sql.c_str());
}

bool WizMetaDb::upgradeDocument(const WIZDOCUMENTDATA &data)
{
    WIZDOCUMENTDATA dataExists;
    if (documentFromGUID(data.strGUID.c_str(), dataExists)) {
		std::string strServerChanged = (dataExists.nServerChanged==1 || data.strDataMd5 != dataExists.strDataMd5) ? "1" : "0";
		std::string strLocalChanged = (data.nLocalChanged==1 || dataExists.nLocalChanged) ? "1" : "0";
		//
		std::string sql = std::string("update WIZ_DOCUMENT\
        set DOCUMENT_TITLE=") + WizStringToSQLString(data. strTitle)
		+ ", DOCUMENT_LOCATION=" + WizStringToSQLString(data.strLocation)
		+ ", DOCUMENT_URL=" + WizStringToSQLString(data.strURL)
		+ ", DOCUMENT_TAG_GUIDS=" + WizStringToSQLString(data.strTagGUIDs)
		+ ", DOCUMENT_TYPE=" + WizStringToSQLString(data.strType)
		+ ", DOCUMENT_FILE_TYPE=" + WizStringToSQLString(data.strFileType)
		+ ", DT_CREATED=" + WizStringToSQLString(data.strDateCreated)
		+ ", DT_MODIFIED=" + WizStringToSQLString(data.strDateModified)
		+ ", DOCUMENT_DATA_MD5=" + WizStringToSQLString(data.strDataMd5)
		+ ", ATTACHMENT_COUNT=" + WizIntToStdString(data.nAttachmentCount)
		+ ", SERVER_CHANGED=" + strServerChanged
		+ ", LOCAL_CHANGED=" + strLocalChanged
        + ", GPS_LATITUDE=" + WizDoubleToStSring(data.gpsLatitude)
        + ", GPS_LONGTITUDE=" + WizDoubleToStSring(data.gpsLongtitude)
        + ", GPS_ALTITUDE=" + WizDoubleToStSring(data.gpsAltitude)
        + ", GPS_DOP=" + WizDoubleToStSring(data.gpsDop)
        + ", GPS_ADDRESS=" + WizStringToSQLString(data.gpsAddress)
        + ", GPS_COUNTRY=" + WizStringToSQLString(data.gpsCountry)
        + ", GPS_DESCRIPTION=" + WizStringToSQLString(data.gpsDescription)
        + ", GPS_LEVEL1=" + WizStringToSQLString(data.gpsLevel1)
        + ", GPS_LEVEL2=" + WizStringToSQLString(data.gpsLevel2)
        + ", GPS_LEVEL3=" + WizStringToSQLString(data.gpsLevel3)
        + ", READCOUNT=" + WizIntToStdString(data.nReadCount)
        + ", OWNER=" + WizStringToSQLString(data.strOwner)
        + ", PROTECT=" + WizIntToStdString(data.nProtected)
		+ " where DOCUMENT_GUID=" + WizStringToSQLString(data.strGUID);
        
        try {
            m_db.execDML(sql.c_str());
            return true;
        }
        catch (const CppSQLite3Exception& e)
        {
            TOLOG(e.errorMessage());
            TOLOG(sql.c_str());
            return false;
        }
        catch (...) {
            TOLOG("Unknown exception while update document");
            return false;
        }
        //
        return true;

    }
    else
    {
        return false;
    }
}

bool WizMetaDb::updateDocument(const WIZDOCUMENTDATA &doc)
{
    if (!m_db.IsOpened()) {
        return false;
    }
    if(isDocumentExists(doc.strGUID.c_str()))
    {
        removeLocalDocumentAbstract(doc.strGUID.c_str());
        return upgradeDocument(doc);
    }
    else
    {
        bool bLocalChanged = doc.nLocalChanged ? true : false;
        std::string strLocalChanged = bLocalChanged ? "1" : "0";
        std::string strServerChanged = bLocalChanged ? "0" : "1";
        std::string sql = std::string("insert into WIZ_DOCUMENT (")
            + g_lpszDocumentFieldList
            + ") values ("
            + WizStringToSQLString(doc.strGUID) + ", "
            + WizStringToSQLString(doc.strTitle) + ", "
            + WizStringToSQLString(doc.strLocation) + ", "
            + WizStringToSQLString(doc.strURL) + ", "
            + WizStringToSQLString(doc.strTagGUIDs) + ", "
            + WizStringToSQLString(doc.strType) + ", "
            + WizStringToSQLString(doc.strFileType) + ", "
            + WizStringToSQLString(doc.strDateCreated) + ", "
            + WizStringToSQLString(doc.strDateModified) + ", "
            + WizStringToSQLString(doc.strDataMd5) + ", "
            + WizIntToStdString(doc.nAttachmentCount) + ", "
            + strServerChanged + ", "
            + strLocalChanged + ","
            + WizDoubleToStSring(0) +","
            + WizDoubleToStSring(0)+","
            + WizDoubleToStSring(0)+","
            + WizDoubleToStSring(0)+","
            + WizStringToSQLString("")+","
            + WizStringToSQLString("")+","
            + WizStringToSQLString("")+","
            + WizStringToSQLString("")+","
            + WizStringToSQLString("")+","
            + WizStringToSQLString("")+","
            + WizIntToStdString(doc.nReadCount)+","
            + WizStringToSQLString(doc.strOwner)+","
            + WizIntToStdString(doc.nProtected)+""
            + ") ";
        try {
            m_db.execDML(sql.c_str());
            removeLocalDocumentAbstract(doc.strGUID.c_str());
            return true;
        }
        catch (const CppSQLite3Exception& e)
        {
            TOLOG(e.errorMessage());
            TOLOG(sql.c_str());
            return false;
        }
        catch (...) {
            TOLOG("Unknown exception while update document");
            return false;
        }
        //
        return true;
    }
}

bool WizMetaDb::updateDocuments(const CWizDocumentDataArray &docs)
{
#warning update is no affect
    CWizDocumentDataArray::const_iterator itor = docs.begin();
    while (itor != docs.end()) {
        if (!updateDocument(*itor))
        {
            return false;
        }
        itor++;
    }
    return true;
}

bool WizMetaDb::recentDocuments(CWizDocumentDataArray& array)
{
    return documentsArrayWithWhereFiled("order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 200", array);
}

bool WizMetaDb::documentsArrayWithWhereFiled(const char* where ,CWizDocumentDataArray& array)
{
    if (!m_db.IsOpened()) {
        return false;
    }
    if (!where || where == NULL) {
        where = "";
    }
    std::string sql = std::string("select ")
                        + g_lpszDocumentFieldList
                        + std::string(" from WIZ_DOCUMENT ")
                        + where;
    try {
#pragma write(add)
//        m_db.execQuery(sql.c_str());
        SQLToDocuments(sql.c_str(), array);
        return true;
    }
    catch (const CppSQLite3Exception& e)
    {
        TOLOG(e.errorMessage());
        TOLOG(sql.c_str());
        return false;
    }
    catch (...) {
        TOLOG("Unknown exception while documentsArray withWhereFile");
        return false;
    }
}

bool WizMetaDb::documentsByTag(const char* lpszTagGUID, CWizDocumentDataArray& array)
{
    std::string sqlWhere = "where DOCUMENT_TAG_GUIDS like '" + std::string(lpszTagGUID) + "' order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100";
    std::cout<<sqlWhere;
    return documentsArrayWithWhereFiled(sqlWhere.c_str(), array);
}

bool WizMetaDb::deleteDocument(const char *lpszGUID)
{
    std::string sql = std::string("delete * from ") + g_lpszDocumentTableName + " where DOCUMENT_GUID = " + WizStringToSQLString(lpszGUID) + ";";
    try {
        m_db.execDML(sql.c_str());
        return logDeletedGuid(lpszGUID, "document");
    } catch (CppSQLite3Exception& e) {
        TOLOG(e.errorMessage());
        TOLOG(sql.c_str());
        return false;
    }
    catch(...)
    {
        TOLOG("delete document error");
        return false;
    }
}

bool WizMetaDb::documentsByNotag(CWizDocumentDataArray& array)
{
    return documentsArrayWithWhereFiled("where DOCUMENT_TAG_GUIDS=\"\" or DOCUMENT_TAG_GUIDS is null ", array);
}
bool WizMetaDb::documentsByKey(const char* lpszKeyWords, CWizDocumentDataArray& array)
{
    std::string sqlWhere = "where DOCUMENT_TITLE like '%" + std::string(lpszKeyWords) + "%' order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100";
    return documentsArrayWithWhereFiled(sqlWhere.c_str(), array);
}
bool WizMetaDb::documentsByLocation(const char* lpszLocation, CWizDocumentDataArray& array)
{
    std::string sqlWhere = "where DOCUMENT_LOCATION= " + std::string(lpszLocation) + " order by max(DT_CREATED, DT_MODIFIED) desc";
    return documentsArrayWithWhereFiled(sqlWhere.c_str(), array);
}

bool WizMetaDb::documentForUpload(CWizDocumentDataArray& array)
{
    return documentsArrayWithWhereFiled("where LOCAL_CHANGED !=0 ", array);
}

bool WizMetaDb::unreadDocuments(CWizDocumentDataArray& array)
{
    return documentsArrayWithWhereFiled("where READCOUNT < 1 order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 30", array);
}
bool WizMetaDb::setDocumentServerChanged(const char* lpszGUID, bool isChanged)
{
	std::string strChanged = isChanged? "1" : "0";
	std::string sql = std::string("update WIZ_DOCUMENT set SERVER_CHANGED=") + strChanged + " where DOCUMENT_GUID='" + lpszGUID+ "'";
	if (!m_db.IsOpened())
		return false;
	//
	try {
		m_db.execDML(sql.c_str());
        removeLocalDocumentAbstract(lpszGUID);
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while update document server_changed");
		return false;
	}
}
bool WizMetaDb::setDocumentLocalChanged(const char* lpszGUID, WizEditDocumentType changed)
{
	std::string strChanged = changed ? "1" : "0";
	std::string sql = std::string("update WIZ_DOCUMENT set LOCAL_CHANGED=") + strChanged + " where DOCUMENT_GUID='" + lpszGUID + "'";
	if (!m_db.IsOpened())
		return false;
	//
	try {
		m_db.execDML(sql.c_str());
        removeLocalDocumentAbstract(lpszGUID);
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while update document local_changed");
		return false;
	}
}
bool WizMetaDb::updateDocumentReadCount(const char* lpszGUID , bool isClear)
{
    int originCount = 0;
    if (!isClear) {
        readCountOfDocument(lpszGUID, originCount);
        originCount++;
    }
    std::string sql = std::string("update WIZ_DOCUMENT set READCOUNT =")+ WizIntToStdString(originCount) +";";
    try {
		m_db.execDML(sql.c_str());
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while update document readcount");
		return false;
	}
}

bool WizMetaDb::readCountOfDocument(const char *lpszGUID, int &readCount)
{
    if (!m_db.IsOpened() || !lpszGUID) {
        return false;
    }
    std::string sql = "select READCOUNT from WIZ_DOCUMENT where DOCUMENT_GUID = " + std::string(lpszGUID);
    try {
		 CppSQLite3Query query = m_db.execQuery(sql.c_str());
        if (!query.eof()) {
            readCount = query.getInt64Field(0);
        }
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while read readcount of document");
		return false;
	}
   
}


#pragma deletedGUID
bool WizMetaDb::deletedGUIDsForUpload(const CWizDeletedGUIDDataArray& array)
{
    return deletedGuidWithWhereField(NULL, array);
}

bool WizMetaDb::deletedGuidWithWhereField(const char* whereField, const CWizDeletedGUIDDataArray& array)
{
    if (!m_db.IsOpened()) {
        return false;
    }
    if (!whereField) {
        whereField = "";
    }
    std::string sql = std::string("SELECT DELETED_GUID, GUID_TYPE, DT_DELETED from WIZ_DELETED_GUID ") + whereField;
    try {
        m_db.execQuery(sql.c_str());
        return true;
    }
    catch (const CppSQLite3Exception& e)
    {
        TOLOG(e.errorMessage());
        TOLOG(sql.c_str());
        return false;
    }
    catch (...) {
        TOLOG("Unknown exception while find deletedGuid");
        return false;
    }
}


bool WizMetaDb::clearDeletedGUIDs()
{
#warning wrong
    if (!m_db.IsOpened()) {
        return false;
    }
    std::string sql = std::string("delete from WIZ_DELETED_GUID");
    try {
        TOLOG(sql.c_str());
        m_db.execDML(sql.c_str());
        return true;
    }
    catch (const CppSQLite3Exception& e)
    {
        TOLOG(e.errorMessage());
        TOLOG(sql.c_str());
        return false;
    }
    catch (...) {
        TOLOG("Unknown exception while clear deletedGuids");
        return false;
    }
}


bool WizMetaDb::uploadDeletedGuids(WizModule::CWizDeletedGUIDDataArray &deletedGuidsArray)
{
    std::string sql = std::string("select ") + g_lpszDeletedGUIDFieldList + " from " + g_lpszDeletedTableName + ";";
    return sqlToDeletedGuids(sql.c_str(), deletedGuidsArray);
}


// tag
bool WizMetaDb::sqlToTags(const char *sql, WizModule::CWizTagDataArray &array)
{
    if(!m_db.IsOpened())
        return false;
    try {
        CppSQLite3Query query = m_db.execQuery(sql);
		while (!query.eof())
		{
            WIZTAGDATA data;
			data.strGUID = query.getStringField(0);
			data.strParentGUID = query.getStringField(1);
			data.strName = query.getStringField(2);
			data.strDescription = query.getStringField(3);
            data.nLocalchanged= query.getIntField(4);
            data.strDtInfoModified = query.getStringField(5);
			array.push_back(data);
			query.nextRow();
        }
        return true;
    }
    catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		TOLOG(sql);
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while sql to tags");
		return false;
	}
}

bool WizMetaDb::isTagExist(const char *tagGuid)
{
    return isFieldExist(g_lpszTagTableName, "TAG_GUID", tagGuid);
}


bool WizMetaDb::updateTag(const WizModule::WIZTAGDATA &data)
{
	std::string sql;
	if (isTagExist(data.strGUID.c_str()))
	{
		sql = std::string("update WIZ_TAG set TAG_NAME=") + WizStringToSQLString(data.strName)
		+ ", TAG_DESCRIPTION=" + WizStringToSQLString(data.strDescription)
		+ ", TAG_PARENT_GUID=" + WizStringToSQLString(data.strParentGUID)
        + ", LOCALCHANGED=" +  WizIntToStdString(data.nLocalchanged)
        + ", DT_MODIFIED=" + WizStringToSQLString(data.strDtInfoModified)
		+ " where TAG_GUID=" + WizStringToSQLString(data.strGUID);
	}
	else
	{
		sql = std::string("insert into WIZ_TAG (TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION ,LOCALCHANGED, DT_MODIFIED ) values (")
		+ WizStringToSQLString(data.strGUID) + ", "
		+ WizStringToSQLString(data.strParentGUID) + ", "
		+ WizStringToSQLString(data.strName) + ", "
		+ WizStringToSQLString(data.strDescription) + ", "
        + WizIntToStdString(data.nLocalchanged) + ", "
        + WizStringToSQLString(data.strDtInfoModified) +") ";

	}
	//
	try {
		m_db.execDML(sql.c_str());
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
        WizLogError(@"%@",WizCStringToNSString(e.errorMessage()));
		return false;
	}
	catch (...) {
        WizLogError(@"Unknown exception while update tag");
		return false;
	}
	//
	return true;
}

bool WizMetaDb::uploadTags(WizModule::CWizTagDataArray &tagArray)
{
   std::string sql = std::string("select ") + g_lpszTagField + " from WIZ_TAG where LOCALCHANGED = 1";
    return sqlToTags(sql.c_str(), tagArray);
}

bool WizMetaDb::deleteTag(const char *lpszGUID)
{
    std::string sql = std::string("delete * from ") + g_lpszTagTableName+ " where TAG_GUID = " + WizStringToSQLString(lpszGUID) + ";";
    try {
        m_db.execDML(sql.c_str());
        return logDeletedGuid(lpszGUID, "tag");
    } catch (CppSQLite3Exception& e) {
        TOLOG(e.errorMessage());
        TOLOG(sql.c_str());
        return false;
    }
    catch(...)
    {
        TOLOG("delete attachment error");
        return false;
    }

}

// deletedGuid

bool WizMetaDb::sqlToDeletedGuids(const char *lpszSQL, WizModule::CWizDeletedGUIDDataArray &array)
{
	if (!m_db.IsOpened())
		return false;
	//
	try {
		CppSQLite3Query query = m_db.execQuery(lpszSQL);
		while (!query.eof())
		{
			WIZDELETEDGUIDDATA data;
			data.strGUID = query.getStringField(0);
			data.strType = query.getStringField(1);
			data.strDateDeleted = query.getStringField(2);
			//
			array.push_back(data);
			//
			query.nextRow();
		}
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		TOLOG(lpszSQL);
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while query deleted guid");
		return false;
	}

}


bool WizMetaDb::isDeletedGuidExist(const char *deletedGuid)
{
    return isFieldExist(g_lpszDeletedTableName, "DELETED_GUID", deletedGuid);
}

bool WizMetaDb::logDeletedGuid(const char *lpszGuid, const char *lpszType)
{
    if (!m_db.IsOpened()) {
        return false;
    }
    if (isDeletedGuidExist(lpszGuid)) {
        return true;
    }
    std::string sql = std::string("insert into WIZ_DELETED_GUID (DELETED_GUID, GUID_TYPE, DT_DELETED) values ('") + lpszGuid+ "', '" + lpszType + "', '" + WizGetCurrentTimeSQLString() + "')";
	//
	try
	{
		m_db.execDML(sql.c_str());
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		TOLOG(sql.c_str());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while adding deleted guid");
		return false;
	}

}

//attchment

bool WizMetaDb::sqlToAttachments(const char *lpszSQL, WizModule::CWizDocumentAttachmentArray &array)
{
    if(!m_db.IsOpened())
        return false;
    try {
        CppSQLite3Query query = m_db.execQuery(lpszSQL);
        while (!query.eof()) {
            WIZDOCUMENTATTACH data;
//           5,,,SERVER_CHANGED,LOCAL_CHANGED
            data.strGuid = query.getStringField(0);
            data.strDocumentGuid = query.getStringField(1);
            data.strName = query.getStringField(2);
            data.strDataMd5 = query.getStringField(3);
            data.strDescription = query.getStringField(4);
            data.strDataModifiedDate = query.getStringField(5);
            data.nServerChanged = query.getIntField(6);
            data.nLocalChanged = query.getIntField(7);
            array.push_back(data);
			//
			query.nextRow();
        }
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		TOLOG(lpszSQL);
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while close DB");
		return false;
	}

}

bool WizMetaDb::attachmentsForDocument(const char *lpszDocGuid, WizModule::CWizDocumentAttachmentArray &array)
{
   std::string sql = std::string("select ") + g_lpszAttachmentField + " from " + g_lpszDocumentAttachmentTableName + " where DOCUMENT_GUID = " + WizStringToSQLString(lpszDocGuid) + ";";
    return sqlToAttachments(sql.c_str(), array);
}

bool WizMetaDb::attachmentsForUpload(WizModule::CWizDocumentAttachmentArray &array)
{
    std::string sql = std::string("select ") + g_lpszAttachmentField + " from " + g_lpszDocumentAttachmentTableName + " where LOCAL_CHANGED != " + WizIntToStdString(0) + ";";
    return sqlToAttachments(sql.c_str(), array);
}

bool WizMetaDb::isAttachmentExist(const char *attachGuid)
{
    return isFieldExist(g_lpszDocumentAttachmentTableName, "ATTACHMENT_GUID", attachGuid);
}

bool WizMetaDb::deleteAttachment(const char *lpszGUID)
{
    std::string sql = std::string("delete * from ") + g_lpszDocumentAttachmentTableName + " where ATTACHMENT_GUID = " + WizStringToSQLString(lpszGUID) + ";";
    try {
        m_db.execDML(sql.c_str());
        return logDeletedGuid(lpszGUID, "attachment");
    } catch (CppSQLite3Exception& e) {
        TOLOG(e.errorMessage());
        TOLOG(sql.c_str());
        return false;
    }
    catch(...)
    {
        TOLOG("delete attachment error");
        return false;
    }
}
bool WizMetaDb::updateAttachment(const WizModule::WIZDOCUMENTATTACH &attach)
{
    std::string sql;

    if(isAttachmentExist(attach.strGuid.c_str()))
    {
        sql = std::string("update WIZ_DOCUMENT_ATTACHMENT set DOCUMENT_GUID=") + WizStringToSQLString(attach.strDocumentGuid)
        + ", ATTACHMENT_NAME=" + WizStringToSQLString(attach.strName)
        + ", ATTACHMENT_DATA_MD5=" + WizStringToSQLString(attach.strDataMd5)
        + ", ATTACHMENT_DESCRIPTION=" + WizStringToSQLString(attach.strDescription)
        + ", DT_MODIFIED=" + WizStringToSQLString(attach.strDataModifiedDate)
        + ", SERVER_CHANGED=" + WizIntToStdString(attach.nServerChanged)
        + ", LOCAL_CHANGED=" + WizIntToStdString(attach.nLocalChanged)
        + " where ATTACHMENT_GUID = " + WizStringToSQLString(attach.strGuid);

    }
    else
    {
		std::string strLocalChanged = attach.nLocalChanged==1 ? "1" : "0";
		std::string strServerChanged = attach.nServerChanged==1 ? "1" : "0";
		sql = std::string("insert into WIZ_DOCUMENT_ATTACHMENT (ATTACHMENT_GUID ,DOCUMENT_GUID, ATTACHMENT_NAME,ATTACHMENT_DATA_MD5,ATTACHMENT_DESCRIPTION,DT_MODIFIED,SERVER_CHANGED,LOCAL_CHANGED) values(")
        + WizStringToSQLString(attach.strGuid) + ", "
        + WizStringToSQLString(attach.strDocumentGuid)+ ", "
        + WizStringToSQLString(attach.strName)+ ", "
        + WizStringToSQLString(attach.strDataMd5)+ ", "
        + WizStringToSQLString(attach.strDescription)+ ", "
        + WizStringToSQLString(attach.strDataModifiedDate)+ ", "
        + strServerChanged+ ", "
        + strLocalChanged
        + ")";
    }
    try {
		m_db.execDML(sql.c_str());
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		TOLOG(sql.c_str());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while update document");
		return false;
	}
	//
	return true;

}

