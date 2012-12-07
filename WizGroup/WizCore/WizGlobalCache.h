//
//  WizGlobalCache.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-12-4.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizModuleTransfer.h"
@interface WizGlobalCache : NSCache
- (void) clearCacheForDocument:(NSString*)guid;
+ (id) shareInstance;
- (void) setAbstract:(WizModule::WIZABSTRACT&)abstract forKey:(NSString*)key;
- (void) removeDocumentAbstractForKey:(NSString*)documentGuid;
@end
