//
//  WizModuleTransfer.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-16.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#ifndef __WizCoreFunc__WizModuleTransfer__
#define __WizCoreFunc__WizModuleTransfer__

#import <Foundation/Foundation.h>

#include <iostream>
#include <string>
#include <map>
#include <vector>
#import "WizMisc.h"
#import "WizStrings.h"
#import "WizAccountPrivilege.h"

#define CStringFromDictionaryByKey(dic,key)   ([dic objectForKey:key]!=nil?[[dic objectForKey:key] UTF8String]:"")
#define IntValueFromDictionaryByKey(dic,key) [[dic objectForKey:key] intValue]
#define CTimeStrValueFromDictionaryByKey(dic,key) [[[dic objectForKey:key] stringSql] UTF8String]

namespace WizModule {
    
class CWizSmartObject
{
public:
    CWizSmartObject()
    : m_nRef(0)
    {
    }
    virtual ~CWizSmartObject() {}
private:
    int m_nRef;
public:
    virtual int addRef()
    {
        m_nRef++;
        return m_nRef;
    }
    virtual int release()
    {
        m_nRef--;
        if (m_nRef <= 0)
        {
            delete this;
            return 0;
        }
        //
        return m_nRef;
    }
};
    
template <class T>
class CWizSmartPtr
{
    public:
    CWizSmartPtr() throw()
    {
        p = NULL;
    }
    CWizSmartPtr(T* lp) throw()
    {
        p = lp;
        if (p != NULL)
            p->addRef();
            }
    CWizSmartPtr(const CWizSmartPtr<T>& lp)
    : p(NULL)
    {
        *this = lp;
    }
    private:
    T* p;
    public:
    ~CWizSmartPtr() throw()
    {
        if (p)
            p->release();
    }
    operator T*() const throw()
    {
        return p;
    }
    T& operator*() const
    {
        ATLENSURE(p!=NULL);
        return *p;
    }
    //The assert on operator& usually indicates a bug.  If this is really
    //what is needed, however, take the address of the p member explicitly.
    T** operator&() throw()
    {
        ATLASSERT(p==NULL);
        return &p;
    }

    T* operator->() const throw()
    {
        return p;
    }
    bool operator!() const throw()
    {
        return (p == NULL);
    }
    bool operator<(T* pT) const throw()
    {
        return p < pT;
    }
    bool operator!=(T* pT) const
    {
        return !operator==(pT);
    }
    bool operator==(T* pT) const throw()
    {
        return p == pT;
    }

    // Release the interface and set to NULL
    void Release() throw()
    {
        T* pTemp = p;
        if (pTemp)
        {
            p = NULL;
            pTemp->Release();
        }
    }
    T* operator=(T* lp) throw()
    {
        if(*this!=lp)
        {
            return static_cast<T*>(SmartPtrAssign((CWizSmartObject**)&p, lp));
        }
        return *this;
    }
    T* operator=(const CWizSmartPtr<T>& lp) throw()
    {
        if(*this!=lp)
        {
            return static_cast<T*>(SmartPtrAssign((CWizSmartObject**)&p, lp));
        }
        return *this;
    }
    //
    static CWizSmartObject* SmartPtrAssign(CWizSmartObject** pp, CWizSmartObject* lp)
    {
        if (pp == NULL)
            return NULL;
        
        if (lp != NULL)
            lp->addRef();
        if (*pp)
            (*pp)->release();
        *pp = lp;
        return lp;
    }
};

class CWizDataBase : public CWizSmartObject
{
    int m_nBufferSize;
    int m_nDataSize;
    unsigned char* m_pBuffer;
protected:
    CWizDataBase()
    : m_pBuffer(NULL)
    , m_nBufferSize(0)
    , m_nDataSize(0)
    {
    }
    CWizDataBase(const unsigned char* buf, int len)
    : m_pBuffer(NULL)
    , m_nBufferSize(0)
    , m_nDataSize(0)
    {
        setData(buf, len);
    }
    CWizDataBase(NSData* data)
    : m_pBuffer(NULL)
    , m_nBufferSize(0)
    , m_nDataSize(0)
    {
    }
public:
    virtual ~CWizDataBase()
    {
        if (m_pBuffer)
        {
            m_nBufferSize = 0;
            m_nDataSize = 0;
            delete m_pBuffer;
            m_pBuffer = NULL;
        }
    }
    void setData(const unsigned char* buf, int len)
    {
        m_nDataSize = len;
        //
        if (m_pBuffer)
        {
            if (m_nBufferSize >= len)
            {
                memcpy(m_pBuffer, buf, len);
                return;
            }
            else
            {
                delete [] m_pBuffer;
                m_pBuffer = NULL;
            }
        }
        //
        m_pBuffer = new unsigned char[len];
        memcpy(m_pBuffer, buf, len);
        m_nBufferSize = m_nDataSize;
    }
public:
    int getDataSize() const { return m_nDataSize; }
    const unsigned char* getBuffer() const 
    { 
        static const char* nullPtr = "";
        if (!m_pBuffer)
            return (const unsigned char*)nullPtr;
        //
        return m_pBuffer;
    }
    //
    static CWizSmartPtr<CWizDataBase> createData()
    {
        return new CWizDataBase();
    }
    static CWizSmartPtr<CWizDataBase> createData(const unsigned char* buf, int len)
    {
        return new CWizDataBase(buf, len);
    }
};

class CWizData
{
    CWizSmartPtr<CWizDataBase> spData;
public:
    CWizData()
    {
        spData = CWizDataBase::createData();
    }
    void fromNSData(NSData* data)
    {
        setData((const unsigned char*)[data bytes], data.length);
    }
    void setData(const unsigned char* buf, int len)
    {
        spData->setData(buf, len);
    }
    int getDataSize() const { return spData->getDataSize(); }
    const unsigned char* getBuffer() const 
    { 
        return spData->getBuffer();
    }
    NSData* toNSData()
    {
        return [NSData dataWithBytes:getBuffer() length:getDataSize()];
    }
};
        
            
    struct WIZUSERDATA
    {
        int apiVersion;
        std::string displayName;
        std::string email;
        std::string language;
        std::string mobile;
        std::string nickName;
        std::string userGuid;
        WIZUSERDATA(){};
        WIZUSERDATA(NSDictionary* user)
        {
            displayName = CStringFromDictionaryByKey(user, @"displayname");
            email =CStringFromDictionaryByKey(user, @"email");
//            mobile = [[user objectForKey:@"mobile"] UTF8String];
//            nickName = [[user objectForKey:@"nickname"] UTF8String];
//            userGuid = [[user objectForKey:@"user_guid"] UTF8String];
        };
    };

    struct WIZLOGINGDATA
    {
        
        //
        std::string token;
        int apiVersion;
        std::string downloadUrl;
        std::string emailVerify;
        std::string wizEmail;
        bool enableGroup;
        std::string inviteCode;
        std::string kapiUrl;
        std::string kbguid;
        std::string returnMessage;
        std::string serverUrl;
        int uploadSizeLimit;
        std::string upload_url;
        int userLever;
        std::string userLeverName;
        std::string userPhotoUrl;
        int userPoints;
        std::string userType;
        std::string vipDate;
        WIZUSERDATA userData;
        void fromWizServerObject(NSDictionary* dic)
        {
            kapiUrl = CStringFromDictionaryByKey(dic, @"kapi_url");
            apiVersion = IntValueFromDictionaryByKey(dic, @"api_version");
            downloadUrl = CStringFromDictionaryByKey(dic, @"download_url");
            emailVerify  = CStringFromDictionaryByKey(dic, @"email_verify");
            enableGroup = [[dic objectForKey:@"enable_group"] boolValue];
            inviteCode = [[dic objectForKey:@"invite_code"] UTF8String];
            kapiUrl =  [[dic objectForKey:@"kapi_url"] UTF8String];
            kbguid = [[dic objectForKey:@"kb_guid"] UTF8String];
            wizEmail = [[dic objectForKey:@"mywiz_email"] UTF8String];
            returnMessage = [[dic objectForKey:@"return_message"] UTF8String];
            serverUrl =  [[dic objectForKey:@"server"] UTF8String];
            token = [[dic objectForKey:@"token"] UTF8String];
            uploadSizeLimit = [[dic objectForKey:@"upload_size_limit"]intValue];
            upload_url = [[dic objectForKey:@"upload_url"] UTF8String];
            userLeverName = [[dic objectForKey:@"user_level_name"] UTF8String];
            userLever = [[dic objectForKey:@"user_level"] intValue];
            userPhotoUrl = [[dic objectForKey:@"user_photo_url"] UTF8String];
            userPoints = [[dic objectForKey:@"user_points"] intValue];
            userType = [[dic objectForKey:@"user_type"] UTF8String];
            
            NSDictionary* user = [dic objectForKey:@"user"];
            userData = WizModule::WIZUSERDATA(user);
        };
    } ;
    
    struct WIZALLVERSION
    {
        int64_t apiVersion;
        int64_t attachmentVersion;
        int64_t deletedVersion;
        int64_t documentVersion;
        int64_t tagVersion;
        int64_t taggroupVersion;
        int64_t styleVersion;
        WIZALLVERSION(){};
        void fromWizServerObject(NSDictionary* dic)
        {
            apiVersion = IntValueFromDictionaryByKey(dic, @"api_version");
            attachmentVersion = IntValueFromDictionaryByKey(dic, @"attachment_version");
            deletedVersion = IntValueFromDictionaryByKey(dic, @"deleted_version");
            documentVersion = IntValueFromDictionaryByKey(dic, @"document_version");
            tagVersion = IntValueFromDictionaryByKey(dic, @"tag_version");
            taggroupVersion = IntValueFromDictionaryByKey(dic, @"taggroup_version");
            styleVersion = IntValueFromDictionaryByKey(dic, @"style_version");
        };
    };
    
    
    struct WIZDOCUMENTATTACH
    {
        std::string strUrl;
        std::string strDocumentGuid;
        std::string strGuid;
        std::string strDataMd5;
        std::string strDataModifiedDate;
        std::string strName;
        std::string strDescription;
        std::string strInfoMd5;
        std::string strInfoModifiedDate;
        int     nServerChanged;
        int     nLocalChanged;
        int nAttachmentData;
        int nZipSie;
        int64_t nVersion;
        int nAttachmentInfo;
        void fromWizServerObject(NSDictionary* dic)
        {
            strGuid = [[dic objectForKey:@"attachment_guid"]UTF8String];
            strDocumentGuid = [[dic objectForKey:@"attachment_document_guid"]UTF8String];
            strName = [[dic objectForKey:@"attachment_name"]UTF8String];
            strDataModifiedDate = CTimeStrValueFromDictionaryByKey(dic, @"dt_data_modified");
            strDataMd5 = [[dic objectForKey:@"data_md5"]UTF8String];
            nAttachmentData = [[dic objectForKey:@"attachment_data"]intValue];
            nAttachmentInfo = [[dic objectForKey:@"attachment_info"]intValue];
            nVersion = IntValueFromDictionaryByKey(dic, @"version");
            strDescription = CStringFromDictionaryByKey(dic, @"attachment_description");
            nAttachmentInfo = IntValueFromDictionaryByKey(dic, @"attachment_info");
            strUrl = CStringFromDictionaryByKey(dic, @"attachment_url");
            nZipSie = IntValueFromDictionaryByKey(dic, @"attachment_zip_size");
            strInfoModifiedDate = CTimeStrValueFromDictionaryByKey(dic, @"dt_info_modified");
            strInfoMd5 = CStringFromDictionaryByKey(dic, @"info_md5");
        }
        NSDictionary* toWizServerObject()
        {
            NSMutableDictionary* attach = [NSMutableDictionary dictionary];
            [attach setObject:WizStdStringToNSString(strGuid)             forKey:@"attachment_guid"];
            [attach setObject:WizStdStringToNSString(strDocumentGuid)           forKey:@"attachment_document_guid"];
            [attach setObject:WizStdStringToNSString(strName)            forKey:@"attachment_name"];
            [attach setObject:[WizStdStringToNSString(strDataModifiedDate) dateFromSqlTimeString]                  forKey:@"dt_modified"];
            [attach setObject:WizStdStringToNSString(strDataMd5)                       forKey:@"data_md5"];
            [attach setObject:WizStdStringToNSString(strDataMd5)                        forKey:@"attachment_zip_md5"];
            [attach setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_info"];
            [attach setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_data"];
            return attach;
        }
        
    };
    
    struct WIZDOCUMENTDATA
    {
        std::string strGUID;
        std::string strTitle;
        std::string strCategory;
        std::string strLocation;
        std::string strDataMd5;
        std::string strURL;
        std::string strTagGUIDs;
        std::string strDateCreated;
        std::string strDateModified;
        std::string strType;
        std::string strFileType;
        std::string strOwner;
        std::string strKbguid;
        std::string strStyleGuid;
        int nAttachmentCount;
        int nServerChanged;
        int nLocalChanged;
        int nProtected;
        int nReadCount;
        int64_t nVersion;
        double gpsLatitude;
        double gpsLongtitude;
        double gpsAltitude;
        double gpsDop;
        std::string gpsAddress;
        std::string gpsCountry;
        std::string gpsDescription;
        std::string gpsLevel1;
        std::string gpsLevel2;
        std::string gpsLevel3;
        
        WIZDOCUMENTDATA()
        : nAttachmentCount(0)
        , nServerChanged(0)
        , nLocalChanged(0)
        , nProtected(0)
        , nReadCount(0)
        , gpsLatitude(0)
        , gpsLongtitude(0)
        , gpsAltitude(0)
        , gpsDop(0)
        {
            
        }
        void fromWizServerObject(NSDictionary* dic)
        {
            strGUID = [[dic objectForKey:@"document_guid"]UTF8String];
            strTitle = [[dic objectForKey:@"document_title"]UTF8String];
            strCategory = [[dic objectForKey:@"document_category"]UTF8String];
            strDataMd5 = [[dic objectForKey:@"data_md5"]UTF8String];
            strTagGUIDs = [[dic objectForKey:@"document_tag_guids"]UTF8String];
            strDateCreated = CTimeStrValueFromDictionaryByKey(dic, @"dt_created");
            strDateModified = CTimeStrValueFromDictionaryByKey(dic, @"dt_modified");
            strType = [[dic objectForKey:@"document_type"]UTF8String];
            strFileType = [[dic objectForKey:@"document_filetype"]UTF8String];
            nAttachmentCount = [[dic objectForKey:@"document_attachment_count"]intValue];
            gpsLatitude = [[dic objectForKey:@"gps_latitude"]floatValue];
            gpsLongtitude = [[dic objectForKey:@"gps_longitude"]floatValue];
            nVersion = IntValueFromDictionaryByKey(dic, @"version");
            //
            strLocation = CStringFromDictionaryByKey(dic, @"document_location");
            strURL = CStringFromDictionaryByKey(dic, @"document_url");
            strOwner = CStringFromDictionaryByKey(dic, @"document_owner");
            strKbguid = CStringFromDictionaryByKey(dic, @"kb_guid");
            strStyleGuid = CStringFromDictionaryByKey(dic, @"style_guid");
            nProtected = IntValueFromDictionaryByKey(dic, @"document_protect");
        }
        NSDictionary* toWizServerObject(bool isWithData)
        {
            NSMutableDictionary* dic = [NSMutableDictionary dictionary];
            [dic setObject:WizStdStringToNSString(strGUID) forKey:@"document_guid"];
            [dic setObject:WizStdStringToNSString(strTitle) forKey:@"document_title"];
            [dic setObject:WizStdStringToNSString(strType) forKey:@"document_type"];
            [dic setObject:WizStdStringToNSString(strFileType) forKey:@"document_filetype"];
            [dic setObject:[WizStdStringToNSString(strDateModified) dateFromSqlTimeString] forKey:@"dt_modified"];
            [dic setObject:WizStdStringToNSString(strLocation) forKey:@"document_category"];
            [dic setObject:[NSNumber numberWithInt:1] forKey:@"document_info"];
            [dic setObject:WizStdStringToNSString(strDataMd5) forKey:@"document_zip_md5"];
            [dic setObject:[WizStdStringToNSString(strDateCreated) dateFromSqlTimeString] forKey:@"dt_created"];
            [dic setObject:[NSNumber numberWithInt:isWithData] forKey:@"with_document_data"];
            [dic setObject:[NSNumber numberWithInt:nAttachmentCount] forKey:@"document_attachment_count"];
            [dic setObject:[NSNumber numberWithFloat:gpsLatitude] forKey:@"gps_latitude"];
            [dic setObject:[NSNumber numberWithFloat:gpsLongtitude] forKey:@"gps_longitude"];
            [dic setObject:WizStdStringToNSString(strTagGUIDs) forKey:@"document_tag_guids"];
            return dic;
        }
    };
    
    struct WIZTAGDATA
    {
        std::string strName;
        std::string strGUID;
        std::string strParentGUID;
        std::string strDescription;
        std::string strNamePath;
        std::string strDtInfoModified;
        int         nLocalchanged;
        int64_t     nVersion;
        WIZTAGDATA():nLocalchanged(0){};
        void fromWizServerObject(NSDictionary* dic)
        {
            strName = CStringFromDictionaryByKey(dic, @"tag_name");
            strGUID = CStringFromDictionaryByKey(dic, @"tag_guid");
            strParentGUID = CStringFromDictionaryByKey(dic, @"tag_group_guid");
            strDescription = CStringFromDictionaryByKey(dic, @"tag_description");
            strDtInfoModified = CTimeStrValueFromDictionaryByKey(dic, @"dt_info_modified");
            nVersion = IntValueFromDictionaryByKey(dic, @"version");
        };
        
        NSDictionary* toWizServerObject()
        {
            NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:5];
            [dic setObject:WizStdStringToNSString(strGUID) forKey:@"tag_guid"];
            [dic setObject:WizStdStringToNSString(strParentGUID) forKey:@"tag_group_guid"];
            [dic setObject:WizStdStringToNSString(strName) forKey:@"tag_name"];
            [dic setObject:WizStdStringToNSString(strDescription) forKey:@"tag_description"];
            [dic setObject:[WizStdStringToNSString(strDtInfoModified) dateFromSqlTimeString] forKey:@"dt_info_modified"];
            return dic;
        };
    };
    
    struct WIZDELETEDGUIDDATA
    {
        std::string strGUID;
        std::string strType;
        std::string strDateDeleted;
        int64_t nVersion;
        void fromWizServerObject(NSDictionary* dic)
        {
            strGUID = [[dic objectForKey:@"deleted_guid"]UTF8String];
            strType = [[dic objectForKey:@"guid_type"]UTF8String];
            strDateDeleted = CTimeStrValueFromDictionaryByKey(dic, @"dt_deleted");
            nVersion = IntValueFromDictionaryByKey(dic, @"version");
        }
        NSDictionary* toWizServerObject()
        {
            NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:3];
            [dic setObject:WizStdStringToNSString(strGUID) forKey:@"deleted_guid"];
            [dic setObject:WizStdStringToNSString(strType) forKey:@"guid_type"];
            [dic setObject:[WizStdStringToNSString(strDateDeleted) dateFromSqlTimeString]  forKey:@"dt_deleted"];
            return dic;
        }
    };
    
    struct WIZOBJECTDATA
    {
        std::string strGUID;
        std::string strType;
        std::string strObjMD5;
        std::string strData;
        std::string strPartMD5;
        int nStartPos;
        int nPartSize;
        int nPartCount;
        int nObjSize;
        int nPartSN;
        void fromWizServerObject(NSDictionary* dic)
        {
            strGUID = [[dic objectForKey:@"obj_guid"]UTF8String];
            strType = [[dic objectForKey:@"obj_type"]UTF8String];
            strObjMD5 = [[dic objectForKey:@"obj_md5"]UTF8String];
            strData = [[dic objectForKey:@"data"]UTF8String];
            strPartMD5 = [[dic objectForKey:@"part_md5"]UTF8String];
            nStartPos = [[dic objectForKey:@"start_pos"]intValue];
            nPartSize = [[dic objectForKey:@"part_size"]intValue];
            nPartCount = [[dic objectForKey:@"part_count"]intValue];
            nObjSize = [[dic objectForKey:@"obj_size"]intValue];
            nPartSN = [[dic objectForKey:@"part_sn"]intValue];
        }
    };
    
    struct WIZDOWNLOADOBJECTDATA
    {
        CWizData data;
        int64_t dataSize;
        std::string dataMd5;
        int64_t objSize;
        int64_t returnCode;
        std::string returnMessage;
        bool isEOF;
        void fromWizServerObject(NSDictionary* dic)
        {
            NSData* downloadData = [dic objectForKey:@"data"];
            data.fromNSData(downloadData);
            dataSize = downloadData.length;
            objSize = IntValueFromDictionaryByKey(dic, @"obj_size");
            dataMd5 = CStringFromDictionaryByKey(dic, @"part_md5");
            returnCode = IntValueFromDictionaryByKey(dic, @"return_code");
            isEOF = [[dic objectForKey:@"eof"] boolValue];
            returnMessage = CStringFromDictionaryByKey(dic, @"return_message");
        }
    };
    struct WIZSERVERRESPONSEDATA
    {
        int nCode;
        std::string strMessage;
       void fromWizServerObject(NSDictionary* dic)
        {
            
//            NSString* message = [dic objectForKey:@"return_message"];
//            if(message) {strMessage = [message UTF8String];}
//            NSNumber* number = [dic objectForKey:@"return_code"];
//            if (number) {nCode = [number integerValue];}
        }
    };
    
    class CWizTagDataArray : public std::vector<WIZTAGDATA>
    {
        public:
        void fromWizServerObject(id obj)
        {
            if ([obj isKindOfClass:[NSArray class]]) {
                for (NSDictionary* tag in obj) {
                    WIZTAGDATA tagData;
                    tagData.fromWizServerObject(tag);
                    push_back(tagData);
                }
            }
        }
    };
    
    class CWizDocumentDataArray : public std::vector<WIZDOCUMENTDATA>
    {
        
    public:
        void fromWizServerObject(id obj)
        {
            if ([obj isKindOfClass:[NSArray class]]) {
                for (NSDictionary* each in obj) {
                    WIZDOCUMENTDATA data;
                    data.fromWizServerObject(each);
                    push_back(data);
                }
            }
        }
    };
    
    class CWizDocumentAttachmentArray : public std::vector<WIZDOCUMENTATTACH>
    {
    public:
        void fromWizServerObject(id obj)
        {
            if ([obj isKindOfClass:[NSArray class]]) {
                for (NSDictionary* each in obj) {
                    WIZDOCUMENTATTACH data;
                    data.fromWizServerObject(each);
                    push_back(data);
                }
            }
        }
    };
    
    class CWizDeletedGUIDDataArray : public std::vector<WIZDELETEDGUIDDATA>
    {
    public:
        void fromWizServerObject(id obj)
        {
            if ([obj isKindOfClass:[NSArray class]]) {
                for (NSDictionary* each in obj) {
                    WIZDELETEDGUIDDATA data;
                    data.fromWizServerObject(each);
                    push_back(data);
                }
            }
        }
        
    };
    typedef std::vector<std::string> CWizStdStringArray;
        
    struct WIZSYNCINFODATA
    {
        std::string token;
        std::string serverUrl;
        std::string kbGuid;
        std::string dbPath;
        std::string accountUserId;
        bool isOnlyUpload;
        WizAccountPrivilege privilege;
        friend const bool operator== (const WIZSYNCINFODATA& data1, const WIZSYNCINFODATA data2)
        {
            if(data1.kbGuid == data2.kbGuid && data1.accountUserId == data2.accountUserId)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
    };
    
    struct WIZGROUPDATA
        {
            std::string accountUserId;
            std::string dateCreate;
            std::string dateModified;
            std::string dateRoleCreaated;
            std::string kbGuid;
            std::string kbId;
            std::string kbName;
            std::string kbNote;
            std::string kbSeo;
            std::string kbType;
            std::string kbOwnerName;
            std::string kbRoleNote;
            std::string kbServerUrl;
            std::string kbApiUrl;
            int         kbUserGroup;
            
            void fromWizServerObject(id obj)
            {
                if([obj isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary* dic = (NSDictionary*)obj;
                    dateCreate = CTimeStrValueFromDictionaryByKey(dic, @"dt_created");
                    dateModified = CTimeStrValueFromDictionaryByKey(dic, @"dt_modified");
                    dateRoleCreaated = CTimeStrValueFromDictionaryByKey(dic, @"dt_role_created");
                    kbGuid = CStringFromDictionaryByKey(dic, @"kb_guid");
                    kbName = CStringFromDictionaryByKey(dic, @"kb_name");
                    kbNote = CStringFromDictionaryByKey(dic, @"kb_note");
                    kbSeo = CStringFromDictionaryByKey(dic, @"kb_seo");
                    kbType = CStringFromDictionaryByKey(dic, @"kb_type");
                    kbOwnerName = CStringFromDictionaryByKey(dic, @"owner_name");
                    kbRoleNote = CStringFromDictionaryByKey(dic, @"role_note");
                    kbServerUrl = CStringFromDictionaryByKey(dic, @"server_url");
                    kbUserGroup = IntValueFromDictionaryByKey(dic, @"user_group");
                    NSString* apiUrl = [dic objectForKey:@"kapi_url"];
                    if(nil == apiUrl)
                    {
                        kbApiUrl = [[[WizGlobals wizServerUrl] absoluteString] UTF8String];
                    }
                    else
                    {
                        kbApiUrl = [apiUrl UTF8String];
                    }
                }
            }
            NSDictionary* toWizObjcModule()
            {
                NSMutableDictionary* dic = [NSMutableDictionary dictionary];
                [dic setObject:WizStdStringToNSString(kbGuid) forKey:@"kb_guid"];
                [dic setObject:WizStdStringToNSString(kbName) forKey:@"kb_name"];
                [dic setObject:WizStdStringToNSString(kbNote) forKey:@"kb_note"];
                [dic setObject:WizStdStringToNSString(kbSeo) forKey:@"kb_seo"];
                [dic setObject:WizStdStringToNSString(kbType) forKey:@"kb_type"];
                [dic setObject:WizStdStringToNSString(kbOwnerName) forKey:@"owner_name"];
                [dic setObject:WizStdStringToNSString(kbRoleNote) forKey:@"role_note"];
                [dic setObject:WizStdStringToNSString(kbServerUrl) forKey:@"server_url"];
                [dic setObject:WizStdStringToNSString(kbApiUrl) forKey:@"kapi_url"];
                [dic setObject:[NSNumber numberWithInt:kbUserGroup] forKey:@"user_group"];
                [dic setObject:[WizStdStringToNSString(dateCreate) dateFromSqlTimeString] forKey:@"dt_created"];
                [dic setObject:[WizStdStringToNSString(dateModified) dateFromSqlTimeString] forKey:@"dt_modified"];
                [dic setObject:[WizStdStringToNSString(dateRoleCreaated) dateFromSqlTimeString] forKey:@"dt_role_created"];
                return dic;
            }
        };
        
        class CWizGroupArray : public std::vector<WIZGROUPDATA>
        {
        public:
            void fromWizServerObject(id obj)
            {
                if ([obj isKindOfClass:[NSArray class]]) {
                    for (NSDictionary* each in obj) {
                        WIZGROUPDATA data;
                        data.fromWizServerObject(each);
                        push_back(data);
                    }
                }
            }
          
        };
        class CWizStringArray : public std::vector<std::string>
        {
            
        };
       
        struct WIZDOCUMENTQUERYDATA
        {
            std::string guid;
            std::string dataMd5;
            std::string dateDataModified;
            void fromWizServerObject(id obj)
            {
                if([obj isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary* dic = (NSDictionary*)obj;
                    guid = CStringFromDictionaryByKey(dic, @"document_guid");
                    dataMd5 = CStringFromDictionaryByKey(dic, @"data_md5");
                    dateDataModified = CTimeStrValueFromDictionaryByKey(dic, @"dt_data_modified");
                }
            }
        };
        class CWizDocumentQueryArray : public std::vector<WIZDOCUMENTQUERYDATA>
        {
        public:
           void fromWizServerObject(id obj)
            {
                if([obj isKindOfClass:[NSArray class]])
                {
                    for(NSDictionary* each in obj)
                    {
                        WIZDOCUMENTQUERYDATA data;
                        data.fromWizServerObject(each);
                        push_back(data);
                    }
                }
            }
        };
        class CWizDocumentsMap : public std::map<std::string, WIZDOCUMENTQUERYDATA>
        {
        public:
            CWizDocumentsMap(const CWizDocumentQueryArray& array)
            {
                for(CWizDocumentQueryArray::const_iterator itor = array.begin(); itor != array.end(); itor++)
                {
                    insert(CWizDocumentsMap::value_type(itor->guid,*itor));
                }
            }
        };

        struct WIZDOCUMENTATTACHQUERYDATA
        {
            std::string guid;
            std::string dateDataModified;
            std::string dataMd5;
            void fromWizServerObject(id obj)
            {
                if([obj isKindOfClass:[NSDictionary class]])
                {
                    
                }
            }
        };
        
        class CWizDocumentAttachmentQueryArray : public std::vector<WIZDOCUMENTATTACHQUERYDATA>
        {
        public:
            void fromWizServerObject(id obj)
            {
                if([obj isKindOfClass:[NSArray class]])
                {
                    for(NSDictionary* each in obj)
                    {
                        WIZDOCUMENTATTACHQUERYDATA data;
                        data.fromWizServerObject(each);
                        push_back(data);
                    }
                }
            }
        };
        
        class CWizDocumentAttachmentsMap : public std::map<std::string, WIZDOCUMENTATTACHQUERYDATA>
        {
        public:
            CWizDocumentAttachmentsMap(const CWizDocumentAttachmentQueryArray& array)
            {
                for(CWizDocumentAttachmentQueryArray::const_iterator itor = array.begin(); itor != array.end(); itor++)
                {
                    insert(CWizDocumentAttachmentsMap::value_type(itor->guid,*itor));
                }
            };
        };
        
        struct WIZSYNCDOWNLOADOBJECT
        {
            std::string accountUserId;
            std::string accountPassword;
            std::string serverUrl;
            std::string kbguid;
            std::string objectGuid;
            std::string objectType;
            friend const bool operator== (const WIZSYNCDOWNLOADOBJECT& data1, const WIZSYNCDOWNLOADOBJECT data2)
            {
                if(data1.kbguid == data2.kbguid && data1.accountUserId == data2.accountUserId && data1.objectGuid == data2.objectGuid)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        };
        
        //
        struct WIZABSTRACT
        {
            std::string guid;
            CWizData imageData;
            std::string text;
            std::string type;
        };
        
        struct WIZDOCUMENTGENERATEABSTRACTDATA
        {
            std::string guid;
            std::string accountUserID;
             friend const bool operator== (const WIZDOCUMENTGENERATEABSTRACTDATA& data1, const WIZDOCUMENTGENERATEABSTRACTDATA& data2)
            {
                if(data1.guid == data2.guid)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        };

}
#endif /* defined(__WizCoreFunc__WizModuleTransfer__) */
