//
//  WizDataBase.m
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-19.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizDataBase.h"
#define PRIMARAY_KEY  @"PRIMARAY_KEY"

NSDictionary* createTableModel(NSDictionary* data,NSString* tableName)
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    NSMutableString* createTableSql = [NSMutableString stringWithFormat:@"CREATE TABLE %@ (", tableName];
    for (NSString* column in [data allKeys])
    {
        [column trim];
        NSString* columnType = [data valueForKey:column];
        if ([column isEqualToString:PRIMARAY_KEY]) {
            continue;
        }
        NSString* columnSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@;",tableName ,column, columnType];
        [dictionary setObject:columnSql forKey:column];
        [createTableSql appendFormat:@"%@ %@,", column, columnType];
    }
    NSString* primaryKey = [data valueForKey:PRIMARAY_KEY];
    if (!primaryKey) {
        int lastIndex = [createTableSql  lastIndexOf:@","];
        if (NSNotFound != lastIndex) {
            [createTableSql deleteCharactersInRange:NSMakeRange(lastIndex, 1)];
        }
        [createTableSql appendString:@")"];
    }
    else
    {
        [createTableSql appendFormat:@" primary key (%@));",primaryKey];
    }
    
    [dictionary setObject:createTableSql forKey:tableName];
    return dictionary;
}
NSDictionary* getDataBaseStructFromFile(NSString*   modelPath)
{
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:modelPath];
    NSMutableDictionary* ret = [NSMutableDictionary dictionary];
    for (NSString* table in [dic allKeys]) {
        [ret setObject:createTableModel([dic valueForKey:table],table) forKey:table];
    }
    return ret;
}


void WizDataBase::updateDbVersion(int version)
{
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:WizStdStringToNSString(m_strFileName)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

bool  WizDataBase::willUpdateDataBase()
{
    int currentDbVersion = getCurrentDbVersion();
    NSInteger dbVersion = [[NSUserDefaults standardUserDefaults] integerForKey:WizStdStringToNSString((m_strFileName))];
    if (dbVersion != currentDbVersion) {
        return YES;
    }
    else
    {
        return NO;
    }
}



BOOL WizDataBase::initDb(NSDictionary* model)
{
    if (willUpdateDataBase() == false) {
        return YES;
    }
    
    for (NSString* tableName in [model allKeys])
    {
        NSDictionary*  content = [model valueForKey:tableName];
        tableName = [tableName trim];
        if (m_db.tableExists(WizNSStringToCString(tableName))) {
            for (NSString* columnName in [content allKeys])
            {
                columnName = [columnName trim];
                if ([columnName isEqualToString:tableName])
                {
                    continue;
                }
                if (!m_db.columnExists(WizNSStringToCString(tableName), WizNSStringToCString(columnName)))
                {
                    if (!m_db.execDML(WizNSStringToCString([content valueForKey:columnName])))
                    {
                        return NO;
                    }
                }
            }
        }
        else
        {
            if (m_db.execDML(WizNSStringToCString([content valueForKey:tableName]))) {
                return NO;
            } ;
        }
    }
    updateDbVersion(getCurrentDbVersion());
    return YES;
}

BOOL WizDataBase::open(std::string strFilePath, std::string modelPath)
{
    if (m_db.IsOpened()) {
        return true;
    }
    try {
        m_strFileName = strFilePath;
        if (![[NSFileManager defaultManager] fileExistsAtPath:WizStdStringToNSString(strFilePath)]) {
            updateDbVersion(-1);
        }
		m_db.open(strFilePath.c_str());
		//
        NSDictionary* model = getDataBaseStructFromFile(WizStdStringToNSString(modelPath));
		if (!initDb(model))
			return false;
		//
		
		return true;
	}
	catch (const CppSQLite3Exception& e)
	{
        WizLogError(WizStdStringToNSString(e.errorMessage()));
		return false;
	}
	catch (...) {
        WizLogError(@"Unknown exception while close DB");
		return false;
	}
}

BOOL WizDataBase::close()
{
    m_db.close();
    return YES;
}