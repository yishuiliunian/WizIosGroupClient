//
//  WizCacheDb.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-12-4.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#include <iostream>
#import  "WizDataBase.h"
#import "WizLock.h"
#import "WizModuleTransfer.h"
using namespace WizModule;

class WizCacheDb : public WizDataBase {
private:
public:
    bool IsAbstractExist(const char* guid);

    int getCurrentDbVersion()
    {
        return 1;
    }
    
    bool open(const char* dbPath)
    {
        static CMutex m_mutex;
        CWizLock lock(m_mutex);
        NSString *path = [[NSBundle mainBundle] pathForResource:@"WizAbstractDataBaseModel" ofType:@"plist"];
        return WizDataBase::open(dbPath, WizNSStringToCString(path));
    };
    
    bool abstractFromGuid(const char* guid, WIZABSTRACT& abstract);
    bool updateAbstract(const WIZABSTRACT& abstract);
    bool deleteAbstractByGUID(const char *guid);
    
    
    WizCacheDb(){};
    WizCacheDb(const char* dbPath){open(dbPath);};
    ~WizCacheDb(){close();};
};
