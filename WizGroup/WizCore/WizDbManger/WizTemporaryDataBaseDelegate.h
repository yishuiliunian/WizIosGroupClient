//
//  WizTemporaryDataBaseDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizSearch.h"
#import "WizAbstract.h"

@protocol WizTemporaryDataBaseDelegate <NSObject>
- (WizAbstract*) abstractFoGuid:(NSString*)guid;
- (BOOL) clearCache;
- (BOOL) deleteAbstractByGuid:(NSString *)documentGUID;
- (BOOL) updateAbstract:(NSString*)text imageData:(NSData*)imageData guid:(NSString*)guid type:(NSString*)type kbguid:(NSString*)kbguid;
- (BOOL) deleteAbstractsByAccountUserId:(NSString*)accountUserID;
//
- (BOOL) updateWizSearch:(NSString*)keywords  notesNumber:(NSInteger)notesNumber isSerchLocal:(BOOL)isSearchLocal;
- (BOOL) deleteWizSearch:(NSString*)keywords;
- (NSArray*) allWizSearchs;
//
@end
