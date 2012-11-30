//
//  WizTag.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"

static NSString *const DataTypeUpdateTagTitle                  =@"tag_name";
static NSString *const DataTypeUpdateTagGuid                   =@"tag_guid";
static NSString *const DataTypeUpdateTagParentGuid             =@"tag_group_guid";
static NSString *const DataTypeUpdateTagDescription            =@"tag_description";
static NSString *const DataTypeUpdateTagVersion                =@"version";
static NSString *const DataTypeUpdateTagDtInfoModifed          =@"dt_info_modified";
static NSString *const DataTypeUpdateTagLocalchanged           =@"local_changed";

@interface WizTag : WizObject

@property (nonatomic, retain) NSString* strParentGUID;
@property (nonatomic, retain) NSString* strDescription;
@property (nonatomic, retain) NSString* strNamePath;
@property (nonatomic, retain) NSDate*   dateInfoModified;
@property (assign) BOOL blocalChanged;

@end
