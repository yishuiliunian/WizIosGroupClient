//
//  WizSearch.m
//  Wiz
//
//  Created by wiz on 12-7-20.
//
//

#import "WizSearch.h"

@implementation WizSearch
@synthesize bSearchLocal;
@synthesize strKeyWords;
@synthesize nNotesNumber;
@synthesize dateLastSearched;
- (void) dealloc
{
    [strKeyWords release];
    [dateLastSearched release];
    [super dealloc];
}
@end
