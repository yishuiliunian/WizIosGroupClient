//
//  WizSyncQueque.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-12-5.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#ifndef __WizCoreFunc__WizSyncQueque__
#define __WizCoreFunc__WizSyncQueque__
#import "WizModuleTransfer.h"
#include <iostream>
using namespace WizModule;
bool g_HasSyncKbInfo();
void g_AddSyncKbInfo(WIZSYNCINFODATA& syncInfo);
bool g_GetSyncKbInfo(WIZSYNCINFODATA& data);
void g_RemoveSyncKbInfo(const WIZSYNCINFODATA& data);
//downloadqueue
void g_AddDownloadObjectInMain(WIZSYNCDOWNLOADOBJECT& object);
void g_AddDownloadObjectInBack(WIZSYNCDOWNLOADOBJECT& object);
bool g_GetDownloadObject(WIZSYNCDOWNLOADOBJECT& object);
void g_RemoveDownloadObject(const WIZSYNCDOWNLOADOBJECT& object);
//
void g_AddDocumentGenerateAbstractData(WIZDOCUMENTGENERATEABSTRACTDATA& object);
void g_RemoveDocumentGenerateAbstractData(const WIZDOCUMENTGENERATEABSTRACTDATA& object);
bool g_GetDocumentGenerateAbstractData(WIZDOCUMENTGENERATEABSTRACTDATA& data);
#endif /* defined(__WizCoreFunc__WizSyncQueque__) */
