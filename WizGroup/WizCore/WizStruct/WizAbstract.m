//
//  WizAbstract.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAbstract.h"
@implementation WizAbstract
@synthesize uiImage;
@synthesize strText;
- (void) dealloc
{
    [uiImage release];
    [strText release];
    [super dealloc];
}
@end
