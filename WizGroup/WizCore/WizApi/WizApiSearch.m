//
//  WizApiSearch.m
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-15.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizApiSearch.h"

@implementation WizApiSearch
@synthesize delegate;
@synthesize keyWords;

- (void) dealloc
{
    [keyWords release];
    [super dealloc];
}

- (void) callSearch
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionaryWithCapacity:5];
    [postParams setObject:self.keyWords forKey:@"key"];
    [postParams setObject:[NSNumber numberWithInt:0] forKey:@"first"];
    [self executeXmlRpcWithArgs:postParams methodKey:SyncMethod_DocumentsByKey needToken:YES];
}

- (BOOL) start
{
    if (![super start]) {
        return NO;
    }
    [self callSearch];
    return YES;
}

- (void) onSearch:(NSArray*)array
{
    id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
    [db updateDocuments:array];
    NSMutableArray* resultArray = [NSMutableArray array];
    for (NSDictionary* each in array) {
        NSString* docGuid = [each objectForKey:DataTypeUpdateDocumentGUID];
        if (docGuid) {
            WizDocument* doc = [db documentFromGUID:docGuid];
            [resultArray addObject:doc];
        }
    }
    [self.delegate didSearchSucceed:resultArray];
    [self end];
}

- (BOOL) onError:(NSError *)error
{
    if ([super onError:error]) {
        return YES;
    }
    else
    {
        [self.delegate didSearchError:error];
        [self end];
        return NO;
    }
}

- (void) xmlrpcDoneSucced:(id)retObject forMethod:(NSString *)method
{
    if ([method isEqualToString:SyncMethod_DocumentsByKey]) {
        [self onSearch:retObject];
    }
}
@end
