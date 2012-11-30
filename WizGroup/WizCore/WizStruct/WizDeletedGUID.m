//
//  WizDeletedGUID.m
//  Wiz
//
//  Created by wiz on 12-6-15.
//
//

#import "WizDeletedGUID.h"

@implementation WizDeletedGUID
@synthesize strType;
@synthesize dateDeleted;
-(void) dealloc
{
    [strType release];
    [dateDeleted release];
    [super dealloc];
}
- (NSString*) wizObjectType
{
    return @"deletedGUID";
}
@end
