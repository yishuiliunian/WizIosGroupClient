//
//  WizClock.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-30.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#ifndef __WizCoreFunc__WizClock__
#define __WizCoreFunc__WizClock__

#include <iostream>
#include <pthread.h>

class IWizLockable {
    
    
public:
    virtual ~IWizLockable(){};
    virtual void Lock() const = 0;
    virtual void Unlock() const = 0;
};

class CMutex : public IWizLockable {
    
public:
    CMutex();
    ~CMutex();
    
    virtual void Lock() const;
    virtual void Unlock() const;
private:
    mutable pthread_mutex_t m_mutex;
};

class CWizLock {
public:
    CWizLock(const IWizLockable&);
    ~CWizLock();
private:
    const IWizLockable& m_lock;
};

#endif /* defined(__WizCoreFunc__WizClock__) */
