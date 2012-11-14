//
//  WizSyncDownload.m
//  WizCoreFunc
//
//  Created by wiz on 12-9-28.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizSyncDownload.h"
#import "WizDownloadObject.h"
#import "WizNotificationCenter.h"

#define WizSyncDocumentMaxToolCount 4

@interface WizSyncDownload () <WizApiDelegate, WizApiDownloadObjectDelegate>
{
    NSMutableArray* downloadTools;
    NSMutableArray* downloadObjectQueque;
}
@end

@implementation WizSyncDownload
@synthesize kbguid;
@synthesize accountUserId;

- (void) dealloc
{
    [kbguid release];
    [accountUserId release];
    [downloadTools release];
    [downloadObjectQueque release];
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        downloadTools = [[NSMutableArray alloc] init];
        downloadObjectQueque = [[NSMutableArray alloc] init];
    }
    return self;
}
- (WizDownloadObject*) getAvailbelDownloadTool
{
    if ([downloadTools count] <= WizSyncDocumentMaxToolCount) {
        WizDownloadObject* upload = [[WizDownloadObject alloc]initWithKbguid:self.kbguid accountUserId:self.accountUserId apiDelegate:self];
        upload.delegate = self;
        [downloadTools addObject:upload];
        [upload release];
        return upload;
    }
    else
    {
        for (WizDownloadObject* eachTool in downloadTools) {
            if (eachTool.statue == WizApiStatueNormal) {
                return eachTool;
            }
        }
    }
    return nil;
}

- (void) didDownloadObjectFaild:(WizObject *)obj
{
    @synchronized(downloadObjectQueque)
    {
        [downloadObjectQueque removeAllObjects];
    }
}
- (void) didDownloadObjectSucceed:(WizObject *)obj
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [WizNotificationCenter addDocumentGuid:obj.strGuid toUserInfo:userInfo];
    [[WizNotificationCenter defaultCenter] postNotificationName:WizNMDidDownloadDocument object:nil userInfo:userInfo];
}

- (void) startDownload
{
    WizDownloadObject* downloadTool = [self getAvailbelDownloadTool];
    if (nil != downloadTool) {
        @synchronized(downloadObjectQueque)
        {
            if ([downloadObjectQueque count]) {
                WizObject* dObj = [downloadObjectQueque lastObject];
                downloadTool.downloadObject = dObj;
                [downloadObjectQueque removeLastObject];
                [downloadTool start];
            }
        }                                                                                                                              
    }
}
- (BOOL) isDownloadWizObject:(WizObject*)obj
{
    for (WizObject* each in downloadObjectQueque) {
        if ([each.strGuid isEqualToString:obj.strGuid]) {
            return YES;
        }
    }
    for (WizDownloadObject* each in downloadTools) {
        if ([each.downloadObject.strGuid isEqualToString:obj.strGuid]) {
            return YES;
        }
    }
    return NO;
}
- (void) shouldDownload:(WizObject*)obj
{
    @synchronized(downloadObjectQueque)
    {
        if (![self isDownloadWizObject:obj]) {
            [downloadObjectQueque addObject:obj];
        }
        else
        {
            return;
        }
    }
    [self startDownload];
}

- (void) wizApiEnd:(WizApi *)api withSatue:(enum WizApiStatue)statue
{
    if (WizApistatueError != statue) {
        [self startDownload];
    }
    else
    {
        
    }
}

- (void) stopDownload
{
    @synchronized(downloadObjectQueque)
    {
        [downloadObjectQueque removeAllObjects];
    }
    @synchronized(downloadTools)
    {
        for (WizDownloadObject* each in downloadTools) {
            [each cancel];
        }
    }
}
@end
