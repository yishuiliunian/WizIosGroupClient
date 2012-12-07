//
//  WizAccountPrivilege.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-27.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <string>
using namespace std;

class WizAccountPrivilege {
    std::string userID;
    int privilege;
public:
    WizAccountPrivilege():privilege(10000){};
    WizAccountPrivilege(const char* lpszUserId, int nPrivilege):userID(lpszUserId),privilege(nPrivilege){};
    bool canEditAllTags() { return privilege <= 10;};
    bool canEditAllDocuments() { return privilege <= 50;};
    bool canEditAllAttachments(){ return privilege <= 50;};
    bool canEditDocument(const char* documentOwner)
    {
        if (canEditAllDocuments()) {
            return true;
        }
        else if (privilege <= 100 && std::string(documentOwner) == userID)
        {
            return true;
        }
        else {
            return false;
        }
    };
    bool canUploadDeletedList(){ return privilege <= 100;};
    bool canUploadTagList() {return privilege <= 10;};
    bool canUploadDocumentAndAttachment() { return privilege <=100;};
    bool canDownloadList(){return privilege < 10000;};
};
