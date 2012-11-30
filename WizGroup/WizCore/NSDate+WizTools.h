//
//  NSDate+WizTools.h
//  Wiz
//
//  Created by 朝 董 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate-Utilities.h"

@interface NSDate (WizTools)
+ (NSDateFormatter*) shareSqlDataFormater;
- (NSString*) stringYearAndMounth;
- (NSString*) stringLocal;
- (NSString*) stringSql;
@end
