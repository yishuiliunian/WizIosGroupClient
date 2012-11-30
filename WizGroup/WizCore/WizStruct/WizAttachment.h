//
//  WizAttachment.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"
static NSString *const DataTypeUpdateAttachmentDescription     =@"attachment_description";
static NSString *const DataTypeUpdateAttachmentDocumentGuid    =@"attachment_document_guid";
static NSString *const DataTypeUpdateAttachmentGuid            =@"attachment_guid";
static NSString *const DataTypeUpdateAttachmentTitle           =@"attachment_name";
static NSString *const DataTypeUpdateAttachmentDataMd5         =@"data_md5";
static NSString *const DataTypeUpdateAttachmentDateModified    =@"dt_data_modified";
static NSString *const DataTypeUpdateAttachmentServerChanged   =@"sever_changed";
static NSString *const DataTypeUpdateAttachmentLocalChanged    =@"local_changed";

enum WizAttachmentEditType
{
    WizAttachmentEditTypeNoChanged = 0,
    WizAttachmentEditTypeLocalChanged = 1    
};
@interface WizAttachment : WizObject
@property (nonatomic, retain)     NSString* strType;
@property (nonatomic, retain)     NSString* strDataMd5;
@property (nonatomic, retain)     NSString* strDescription;
@property (nonatomic, retain)     NSDate*   dateModified;
@property (nonatomic, retain)     NSString* strDocumentGuid;
@property (assign) BOOL                     bServerChanged;
@property (assign) enum WizAttachmentEditType      nLocalChanged;

@end
