//
//  WizGlobalData.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-13.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizGlobalData : NSObject
+ (id) shareInstanceFor:(Class)aclass;
+ (id) shareInstanceFor:(Class)aclass category:(NSString*)key;
@end
