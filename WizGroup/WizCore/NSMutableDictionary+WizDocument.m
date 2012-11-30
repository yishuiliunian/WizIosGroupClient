//
//  NSMutableDictionary+WizDocument.m
//  Wiz
//
//  Created by 朝 董 on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableDictionary+WizDocument.h"

@implementation NSMutableDictionary (WizDocument)
- (BOOL) setObjectNotNull:(id)object   forKey:(id)key
{
    if (object) {
        [self setObject:object forKey:key];
        return YES;
    }
    else {
        return NO;
    }
}
@end
