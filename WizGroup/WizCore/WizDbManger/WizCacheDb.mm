//
//  WizCacheDb.cpp
//  WizCoreFunc
//
//  Created by dzpqzb on 12-12-4.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#include "WizCacheDb.h"

static const char* lpszAbstractFiledSQL = "ABSTRACT_GUID,ABSTRACT_TYPE,ABSTRACT_TEXT,ABSTRACT_IMAGE";

static const char* lpszAbstractTableName = "WIZ_ABSTRACT";

using namespace std;
bool WizCacheDb::IsAbstractExist(const char *guid)
{
    if (!m_db.IsOpened()) {
        return false;
    }
    string sql = "select ABSTRACT_GUID form WIZ_ABSTRACT where ABSTRACT_GUID=" + WizStringToSQLString(guid);
    return m_db.hasRecord(sql.c_str());
}

bool WizCacheDb::updateAbstract(const WizModule::WIZABSTRACT &abstract)
{
    if (!m_db.IsOpened()) {
        return false;
    }
    string sql;
    if (IsAbstractExist(abstract.guid.c_str())) {
        string whereFiled ="ABSTRACT_GUID=" + WizStringToSQLString(abstract.guid);
        sql = string("update ") + lpszAbstractTableName + " set " + \
             "ABSTRACT_TEXT = " + WizStringToSQLString(abstract.text)  +" where " + whereFiled;
        try {
            m_db.updateBlob(lpszAbstractTableName, "ABSTRACT_IMAGE", abstract.imageData.getBuffer(), abstract.imageData.getDataSize(), whereFiled.c_str());
            m_db.execDML(sql.c_str());
        } catch (const CppSQLite3Exception& e ) {
            
            TOLOG(e.errorMessage());
            TOLOG(sql.c_str());
            return false;
        }
        catch (...) {
            TOLOG("Unknown exception while update abstract");
            return false;
        }
    }
    else
    {
        sql = std::string("insert into ") + lpszAbstractTableName + ("(") + lpszAbstractFiledSQL + (")")
        + " values("
        + WizStringToSQLString(abstract.guid) + (",")
        + WizStringToSQLString(abstract.type) + (",")
        + WizStringToSQLString(abstract.text) + (",?)");
        try {
            m_db.insertBlob(sql.c_str(), abstract.imageData.getBuffer() , abstract.imageData.getDataSize() , 1);
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
    }
    return true;
}

bool WizCacheDb::deleteAbstractByGUID(const char *guid)
{
    std::string sql = std::string("delete from ") + lpszAbstractTableName + " where ABSTRACT_GUID='"+guid+"'";
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
}

bool WizCacheDb::abstractFromGuid(const char *guid, WizModule::WIZABSTRACT &lpszAbstract)
{
    if(!m_db.IsOpened())
        return false;
    std::string sql = std::string("select ") + lpszAbstractFiledSQL + " from " +lpszAbstractTableName+" where ABSTRACT_GUID="
    +WizStringToSQLString(guid)+(";");
    try {
        CppSQLite3Query query = m_db.execQuery(sql.c_str());
        while (!query.eof()) {
            lpszAbstract.guid = query.getStringField(0);
            lpszAbstract.text = query.getStringField(2);
            int length;
            const unsigned char * imageData = query.getBlobField(3, length);
            CWizData data;
            data.setData(imageData, length);
            lpszAbstract.imageData = data;
            return true;
        }
		return false;
	}
	catch (const CppSQLite3Exception& e)
	{
		TOLOG(e.errorMessage());
		TOLOG(sql.c_str());
		return false;
	}
	catch (...) {
		TOLOG("Unknown exception while close DB");
		return false;
	}

}