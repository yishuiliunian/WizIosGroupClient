//
//  WizGroup.h
//  Wiz
//
//  Created by 朝 董 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#define KeyOfKbKbguid               @"kb_guid"
#define KeyOfKbType                 @"kb_type"
#define KeyOfKbName                 @"kb_name"
#define KeyOfKbRight                @"user_group"
#define KeyOfKbDateCreated          @"dt_created"
#define KeyOfKbDateModified         @"dt_modified"
#define KeyOfKbDateRoleCreated      @"dt_role_created"
#define KeyOfKbSeo                  @"kb_seo"
#define KeyOfKbOwnerName            @"owner_name"
#define KeyOfKbNote                 @"kb_note"
#define KeyOfKbAccountUserId        @"KeyOfKbAccountUserId"


#define KeyOfKbTypePrivate          @"private"
#define KeyOfKbTypeGroup            @"group"
#define KeyOfKbImage                @"KeyOfKbImage"
#define KeyOfKbAbstractString       @"KeyOfKbAbstractString"
#define KeyOfKbOrderIndex           @"KeyOfKbOrderIndex"
enum WizGroupUserRightAdmin {
    WizGroupUserRightAdmin = 0,
    WizGroupUserRightSuper = 10 ,
    WizGroupUserRightEditor = 50,
    WizGroupUserRightAuthor = 100,
    WizGroupUserRightReader = 1000,
    WizGroupUserRightNone = 10000,
    WizGroupUserRightAll = -1
};

@interface WizGroup : NSObject
@property (nonatomic, retain) NSString * accountUserId;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;
@property (nonatomic, retain) NSDate * dateRoleCreated;
@property (nonatomic, retain) NSString * kbguid;
@property (nonatomic, retain) NSString * kbId;
@property (nonatomic, retain) NSString * kbName;
@property (nonatomic, retain) NSString * kbNote;
@property (nonatomic, retain) NSString * kbSeo;
@property (nonatomic, retain) NSString * kbType;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) NSString * roleNote;
@property (nonatomic, retain) NSString * serverUrl;
@property (nonatomic, assign) NSInteger userGroup;
@property (nonatomic, assign) NSInteger  orderIndex;
- (void) getDataFromDic:(NSDictionary*)dic;
- (BOOL) canNewDocument;
- (BOOL) canEditTag;
- (BOOL) canEditCurrentDocument:(NSString*)documentOwner      currentUser:(NSString*)userId;
@end
