//
//  WizGroup.m
//  Wiz
//
//  Created by 朝 董 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizGroup.h"
#import <Foundation/Foundation.h>
#import "NSDate+WizTools.h"


@implementation WizGroup

@synthesize  accountUserId;
@synthesize dateCreated;
@synthesize dateModified;
@synthesize dateRoleCreated;
@synthesize kbguid;
@synthesize kbId;
@synthesize kbName;
@synthesize kbNote;
@synthesize kbSeo;
@synthesize kbType;
@synthesize ownerName;
@synthesize roleNote;
@synthesize serverUrl;
@synthesize userGroup;
@synthesize orderIndex;

- (void) dealloc
{
    [accountUserId release];
    [dateCreated release];
    [dateModified release];
    [dateRoleCreated release];
    [kbguid release];
    [kbId release];
    [kbName release];
    [kbNote release];
    [kbSeo release];
    [kbType release];
    [ownerName release];
    [roleNote release];
    [serverUrl release];
    [super dealloc];
}

- (BOOL) canNewDocument
{
    return self.userGroup <= 100;
}

- (BOOL) canEditCurrentDocument:(NSString*)documentOwner      currentUser:(NSString*)userId
{
    if (self.userGroup <= 50 ) {
        return YES;
    }
    else if (self.userGroup == 100 && [documentOwner isEqualToString:userId])
    {
        return YES;
    }
    return NO;
}
- (BOOL) canEditTag
{
    if (self.userGroup <= 10 ) {
        return YES;
    }
    return NO;
}
- (void) getDataFromDic:(NSDictionary*)dic
{
    self.kbguid = [dic valueForKey:KeyOfKbKbguid];
    NSString* name = [dic valueForKey:KeyOfKbName];
    
    if (!name) {
        name = NSLocalizedString(@"My Data", nil);
    }
    self.kbName = name;
    NSString* type = [dic valueForKey:KeyOfKbType];
    if (!type) {
        type = KeyOfKbTypePrivate;
    }
    NSNumber* right = [dic valueForKey:KeyOfKbRight];
    if (!right)
    {
        self.userGroup = WizGroupUserRightAll;
    }
    else
    {
        self.userGroup =[right intValue];
    }
   self.kbType = type;
}
@end
