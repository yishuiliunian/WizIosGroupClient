//
//  WizClock.cpp
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-30.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#include "WizLock.h"

CMutex::CMutex()
{
    pthread_mutex_init(&m_mutex, NULL);
}

CMutex::~CMutex()
{
    pthread_mutex_destroy(&m_mutex);
}

void CMutex::Lock() const
{
    pthread_mutex_lock(&m_mutex);
}

void CMutex::Unlock() const
{
    pthread_mutex_unlock(&m_mutex);
}

CWizLock::CWizLock(const IWizLockable& m) : m_lock(m)
{
    m_lock.Lock();
}

CWizLock::~CWizLock()
{
    m_lock.Unlock();
}