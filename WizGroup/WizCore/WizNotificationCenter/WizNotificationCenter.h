//
//  WizNotificationCenter.h
//  WizGroup
//
//  Created by wiz on 12-9-29.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#define WizNMDidUpdataGroupList     @"WizNMDidUpdataGroupList"
#define WizNMDidDownloadDocument    @"WizNMDidDownloadDocument"
#define WizNMWillUpdateGroupList    @"WizNMWillUpdateGroupList"
//
#define WizNMDocumentKeyString      @"WizNMDocumentKeyString"
#define WizNMGuidKeyString          @"WizNMGuidKeyString"
//

#define WizNMSyncGroupStart         @"WizNMSyncGroupStart"
#define WizNMSyncGroupEnd           @"WizNMSyncGroupEnd"
#define WizNMSyncGroupError         @"WizNMSyncGroupError"
//
#define WizNMUIDidGenerateAbstract  @"WizNMUIDidGenerateAbstract"
@interface WizNotificationCenter : NSNotificationCenter
+ (NSString*)getDocumentGuidFromNc:(NSNotification*)nc;
+ (void) addDocumentGuid:(NSString*)guid toUserInfo:(NSMutableDictionary*)userInfo;
//
+ (NSString*) getGuidFromNc:(NSNotification*)nc;
+ (void) addGuid:(NSString*)guid toUserInfo:(NSMutableDictionary*)userInfo;
@end
