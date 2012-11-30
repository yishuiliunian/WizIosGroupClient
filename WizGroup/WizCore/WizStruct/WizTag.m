//
//  WizTag.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTag.h"
@implementation WizTag
@synthesize strParentGUID;
@synthesize strDescription;
@synthesize strNamePath;
@synthesize dateInfoModified;
@synthesize blocalChanged;

- (void) dealloc
{
    [strParentGUID release];
    [strDescription release];
    [strNamePath release];
    [dateInfoModified release];
    [super dealloc];
}

- (NSString*) wizObjectType
{
    return @"tag";
}
@end
