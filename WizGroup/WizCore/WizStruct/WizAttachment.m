//
//  WizAttachment.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAttachment.h"

@implementation WizAttachment

@synthesize strType;
@synthesize strDataMd5;
@synthesize strDescription;
@synthesize dateModified;
@synthesize strDocumentGuid;
@synthesize bServerChanged;
@synthesize nLocalChanged;

- (void) dealloc
{
    [strType release];
    [strDataMd5 release];
    [strDescription release];
    [dateModified release];
    [strDocumentGuid release];
    [super dealloc];
}
- (NSString*) wizObjectType
{
    return @"attachment";
}
@end
