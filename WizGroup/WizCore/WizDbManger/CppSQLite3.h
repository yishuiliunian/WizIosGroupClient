#ifndef _CppSQLite3_H_
#define _CppSQLite3_H_

#include "sqlite3.h"
#include "WizMisc.h"
#include <cstdio>
#include <cstring>

#define CPPSQLITE_ERROR 1000

typedef long long __int64;

class CppSQLite3Exception
{
public:
    CppSQLite3Exception(const int nErrCode,
                    const char* szErrMess);

    CppSQLite3Exception(const CppSQLite3Exception&  e);

    virtual ~CppSQLite3Exception();

    const int errorCode() const { return mnErrCode; }

    const char* errorMessage() const { return mpszErrMess; }

    static const char* errorCodeAsString(int nErrCode);

private:

    int mnErrCode;
    char* mpszErrMess;
};


class CppSQLite3Buffer
{
public:

    CppSQLite3Buffer();

    ~CppSQLite3Buffer();

    const char* format(const char* szFormat, ...);

    operator const char*() { return mpBuf; }

    void clear();

private:

    char* mpBuf;
};


class CppSQLite3Binary
{
public:

    CppSQLite3Binary();

    ~CppSQLite3Binary();

    void setBinary(const unsigned char* pBuf, int nLen);
    //void setEncoded(const unsigned char* pBuf);
	//void setEncoded(const unsigned char* pBuf, int nSize);

    const unsigned char* getEncoded();
    //const unsigned char* getBinary();

    //int getBinaryLength();

    unsigned char* allocBuffer(int nLen);

    void clear();

private:

    unsigned char* mpBuf;
    int mnBinaryLen;
    int mnBufferLen;
    int mnEncodedLen;
    bool mbEncoded;
};


class CppSQLite3Query
{
public:

    CppSQLite3Query();

    CppSQLite3Query(const CppSQLite3Query& rQuery);

    CppSQLite3Query(sqlite3* pDB,
				sqlite3_stmt* pVM,
                bool bEof,
                bool bOwnVM=true);

    CppSQLite3Query& operator=(const CppSQLite3Query& rQuery);

    virtual ~CppSQLite3Query();

    int numFields();

    int fieldIndex(const char* szField);
    const char* fieldName(int nCol);
    const wchar_t* fieldName16(int nCol);

    const char* fieldDeclType(int nCol);
    int fieldDataType(int nCol);

    const char* fieldValue(int nField);
    const char* fieldValue(const char* szField);

    int getIntField(int nField, int nNullValue=0);
    int getIntField(const char* szField, int nNullValue=0);

    __int64 getInt64Field(int nField, int nNullValue=0);
    __int64 getInt64Field(const char* szField, int nNullValue=0);

	bool getBoolField(int nField, bool bNullValue=false);
    bool getBoolField(const char* szField, bool bNullValue=false);

    double getFloatField(int nField, double fNullValue=0.0);
    double getFloatField(const char* szField, double fNullValue=0.0);

	//COleDateTime getTimeField(int nField, time_t tNullValue = 0);
    //COleDateTime getTimeField(const char* szField, time_t tNullValue = 0);

	//COLORREF getColorField(int nField, COLORREF crNullValue = 0);
    //COLORREF getColorField(const char* szField, COLORREF crNullValue = 0);

    const char* getStringField(int nField, const char* szNullValue="");
    const wchar_t* getStringField16(int nField, const wchar_t* szNullValue=L"");
    const char* getStringField(const char* szField, const char* szNullValue="");
	//
	int getColumnLength(int nField);

    const unsigned char* getBlobField(int nField, int& nLen);
    const unsigned char* getBlobField(const char* szField, int& nLen);

    bool fieldIsNull(int nField);
    bool fieldIsNull(const char* szField);

    bool eof();

    void nextRow();

    void finalize();


    void checkVM();
	//
private:
	sqlite3* mpDB;
    sqlite3_stmt* mpVM;
    bool mbEof;
    int mnCols;
    bool mbOwnVM;
};


class CppSQLite3Table
{
public:

    CppSQLite3Table();

    CppSQLite3Table(const CppSQLite3Table& rTable);

    CppSQLite3Table(char** paszResults, int nRows, int nCols);

    virtual ~CppSQLite3Table();

    CppSQLite3Table& operator=(const CppSQLite3Table& rTable);

    int numFields();

    int numRows();

    const char* fieldName(int nCol);

    const char* fieldValue(int nField);
    const char* fieldValue(const char* szField);

    int getIntField(int nField, int nNullValue=0);
    int getIntField(const char* szField, int nNullValue=0);

    double getFloatField(int nField, double fNullValue=0.0);
    double getFloatField(const char* szField, double fNullValue=0.0);

    const char* getStringField(int nField, const char* szNullValue="");
    const char* getStringField(const char* szField, const char* szNullValue="");

    bool fieldIsNull(int nField);
    bool fieldIsNull(const char* szField);

    void setRow(int nRow);

    void finalize();

private:

    void checkResults();

    int mnCols;
    int mnRows;
    int mnCurrentRow;
    char** mpaszResults;
};


class CppSQLite3Statement
{
public:

    CppSQLite3Statement();

    CppSQLite3Statement(const CppSQLite3Statement& rStatement);

    CppSQLite3Statement(sqlite3* pDB, sqlite3_stmt* pVM);

    virtual ~CppSQLite3Statement();

    CppSQLite3Statement& operator=(const CppSQLite3Statement& rStatement);

    int execDML();

    CppSQLite3Query execQuery();

    void bind(int nParam, const char* szValue);
    void bind(int nParam, const int nValue);
    void bind(int nParam, const double dwValue);
    void bind(int nParam, const unsigned char* blobValue, int nLen);
    void bindNull(int nParam);

    void reset();

    void finalize();

private:

    void checkDB();
    void checkVM();

    sqlite3* mpDB;
    sqlite3_stmt* mpVM;
};


class CppSQLite3DB
{
public:

    CppSQLite3DB();

    virtual ~CppSQLite3DB();

    void open(const char* szFile);

    void close();

	bool tableExists(const char* szTable);
    bool columnExists(const char* szTable, const char* szColumn);
    
    int execDML(const char* szSQL);

    CppSQLite3Query execQuery(const char* szSQL);

    int execScalar(const char* szSQL);
    
    int updateBlob(const char* szTableName, const char* szFieldName, const unsigned char* data, int dataLength, const char* szWhere);
    int insertBlob(const char* szSQL, const unsigned char* data, int dataLength, int  dataPosition);
    
    CppSQLite3Table getTable(const char* szSQL);

    CppSQLite3Statement compileStatement(const char* szSQL);
    
    sqlite_int64 lastRowId();

    void interrupt() { sqlite3_interrupt(mpDB); }

    void setBusyTimeout(int nMillisecs);

    static const char* SQLiteVersion() { return SQLITE_VERSION; }
	//
	bool IsOpened();

	bool hasRecord(const char* lpszSQL);
    
private:

    CppSQLite3DB(const CppSQLite3DB& db);
    CppSQLite3DB& operator=(const CppSQLite3DB& db);

    sqlite3_stmt* compile(const char* szSQL);

    void checkDB();

    sqlite3* mpDB;
    int mnBusyTimeoutMs;
};





#endif

