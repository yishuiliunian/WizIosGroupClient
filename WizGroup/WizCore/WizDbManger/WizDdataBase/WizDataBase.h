//
//  WizDataBase.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-19.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CppSQLite3.h"
#import <iostream>
#import "WizStrings.h"
class WizDataBase {
private:
	std::string m_strFileName;
    bool willUpdateDataBase();
    void updateDbVersion(int version);
    BOOL initDb(NSDictionary* model);
protected:
    CppSQLite3DB m_db;
public:
    WizDataBase(){};
    ~WizDataBase(){};
    //
    BOOL open(std::string strFilePath, std::string modelPath);
    virtual int getCurrentDbVersion() = 0;
    BOOL close();
};