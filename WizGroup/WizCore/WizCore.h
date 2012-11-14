//
//  WizCore.h
//  WizCore
//
//  Created by wiz on 12-7-31.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WizCore : NSObject
+ (void) addNewDocument:(NSString*)sourceFilesPath  document:(WizDocument*)doc toKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId;
@end
