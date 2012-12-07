//
//  WizSyncQueque.cpp
//  WizCoreFunc
//
//  Created by dzpqzb on 12-12-5.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#include "WizSyncQueque.h"
#import "WizLock.h"

template<class TInput>
class CWizSyncQueue {
    CMutex syncMutexLock;
    vector<TInput> syncInfoQueue;
    vector<TInput> syncWoringQueue;
    typedef typename vector<TInput>::iterator TInputIterator;
    //
    bool hasSyncInfo(const TInput& syncInfo)
    {
        for (TInputIterator itor = syncInfoQueue.begin(); itor != syncInfoQueue.end(); itor++) {
            if (*itor == syncInfo) {
                return true;
            }
        }
        for (TInputIterator itor = syncWoringQueue.begin(); itor != syncWoringQueue.end(); itor++) {
            if (*itor == syncInfo) {
                return true;
            }
        }
        return false;
    }
public:
    static CWizSyncQueue<WIZSYNCINFODATA>* shareSyncKbQueue(){
        static CWizSyncQueue<WIZSYNCINFODATA>* shareInstance = NULL;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shareInstance = new CWizSyncQueue<WIZSYNCINFODATA>();
        });
        return shareInstance;
    };
    bool getSyncInfo(TInput& syncInfo)
    {
        CWizLock lock(syncMutexLock);
        if (!(syncInfoQueue.empty())) {
            syncInfo = syncInfoQueue[0];
            syncInfoQueue.erase(syncInfoQueue.begin());
            syncWoringQueue.push_back(syncInfo);
            return true;
        }
        return false;
    }
    void removeSyncInfo(const TInput& syncInfo)
    {
        CWizLock lock(syncMutexLock);
        for (TInputIterator itor = syncWoringQueue.begin(); itor != syncWoringQueue.end(); ) {
            if (*itor == syncInfo) {
                itor = syncWoringQueue.erase(itor);
            }
            else
            {
                itor++;
            }
        }
    }
    bool isAllSyncDone()
    {
        CWizLock lock(syncMutexLock);
        if (syncInfoQueue.empty() && syncWoringQueue.empty()) {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    void addSyncInfo(TInput& syncInfo){
        CWizLock lock(syncMutexLock);
        if (hasSyncInfo(syncInfo)) {
            return;
        }
        
        syncInfoQueue.push_back(syncInfo);
    };
    
};

void g_AddSyncKbInfo(WIZSYNCINFODATA& syncInfo){
    CWizSyncQueue<WIZSYNCINFODATA>::shareSyncKbQueue()->addSyncInfo(syncInfo);
}
bool g_HasSyncKbInfo()
{
    return CWizSyncQueue<WIZSYNCINFODATA>::shareSyncKbQueue()->isAllSyncDone();
}
bool g_GetSyncKbInfo(WIZSYNCINFODATA& data)
{
    return CWizSyncQueue<WIZSYNCINFODATA>::shareSyncKbQueue()->getSyncInfo(data);
}

void g_RemoveSyncKbInfo(const WIZSYNCINFODATA& data)
{
    return CWizSyncQueue<WIZSYNCINFODATA>::shareSyncKbQueue()->removeSyncInfo(data);
}

static CWizSyncQueue<WIZSYNCDOWNLOADOBJECT> mainDownloadQueue;
static CWizSyncQueue<WIZSYNCDOWNLOADOBJECT> backDownloadQueue;

void g_AddDownloadObjectInMain(WIZSYNCDOWNLOADOBJECT& object)
{
    mainDownloadQueue.addSyncInfo(object);
}

void g_AddDownloadObjectInBack(WIZSYNCDOWNLOADOBJECT& object)
{
    backDownloadQueue.addSyncInfo(object);
}

bool g_GetDownloadObject(WIZSYNCDOWNLOADOBJECT& object)
{
    if (mainDownloadQueue.getSyncInfo(object)) {
        return true;
    }
    if (backDownloadQueue.getSyncInfo(object)) {
        return true;
    }
    return false;
}

void g_RemoveDownloadObject(const WIZSYNCDOWNLOADOBJECT& object)
{
    mainDownloadQueue.removeSyncInfo(object);
    backDownloadQueue.removeSyncInfo(object);
}

static CWizSyncQueue<WIZDOCUMENTGENERATEABSTRACTDATA> generateAbstractQueue;
void g_AddDocumentGenerateAbstractData(WIZDOCUMENTGENERATEABSTRACTDATA& object)
{
    generateAbstractQueue.addSyncInfo(object);
}
void g_RemoveDocumentGenerateAbstractData(const WIZDOCUMENTGENERATEABSTRACTDATA& object)
{
    generateAbstractQueue.removeSyncInfo(object);
}

bool g_GetDocumentGenerateAbstractData(WIZDOCUMENTGENERATEABSTRACTDATA& data)
{
    return  generateAbstractQueue.getSyncInfo(data);
}