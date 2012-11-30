//
//  WizAccount.m
//  Wiz
//
//  Created by 朝 董 on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAccount.h"

@implementation WizAccount
@synthesize strKbguid;
@synthesize strPassword;
@synthesize strUserId;
- (void) dealloc
{
    [strKbguid release];
    [strPassword release];
    [strUserId release];
    [super dealloc];
}

@end
