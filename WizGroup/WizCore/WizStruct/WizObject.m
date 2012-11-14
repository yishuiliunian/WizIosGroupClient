//
//  WizObject.m
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"
@implementation WizObject
@synthesize strGuid;
@synthesize strTitle;
- (void) dealloc
{
    [strGuid release];
    [strTitle release];
    [super dealloc];
}
- (NSString*) wizObjectType
{
    return @"";
}
@end
