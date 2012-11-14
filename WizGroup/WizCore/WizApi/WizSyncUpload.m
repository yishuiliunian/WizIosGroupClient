//
//  WizSyncUpload.m
//  WizCoreFunc
//
//  Created by wiz on 12-9-28.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizSyncUpload.h"
#import "WizUploadObject.h"

#define WizSyncUploadToolsMaxCount  1

@interface WizSyncUpload() <WizApiDelegate, WizUploadObjectDelegate>
{
    NSMutableArray* uploadTools;
    NSMutableArray* uploadObjectQueque;
}
@end

@implementation WizSyncUpload
@synthesize kbguid;
@synthesize accountUserId;


- (void) dealloc
{
    [kbguid release];
    [accountUserId release];
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        uploadObjectQueque = [[NSMutableArray alloc] init];
        uploadTools = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) didUploadWizObjectDone:(WizObject *)object
{
    NSLog(@"did upload object succeed %@",object.strTitle);
}

- (void) didUPloadWizObjectFaild:(WizObject *)object
{
    
}
- (WizUploadObject*) getAvailableUploadTool
{
    if ([uploadTools count] <= WizSyncUploadToolsMaxCount) {
        WizUploadObject* uploadTool = [[WizUploadObject alloc] initWithKbguid:self.kbguid accountUserId:self.accountUserId apiDelegate:self];
        uploadTool.delegate = self;
        [uploadTools addObject:uploadTool];
        [uploadTool release];
        return uploadTool;
    }
    else
    {
        for (WizUploadObject* each in uploadTools) {
            if (each.statue == WizApiStatueNormal) {
                return each;
            }
        }
    }
    return nil;
}

- (void) startUpload
{
    WizUploadObject* upTool = [self getAvailableUploadTool];
    if (upTool) {
        @synchronized(uploadObjectQueque)
        {
            if ([uploadObjectQueque count]) {
                WizObject* upObj = nil;
                for (WizObject* each in uploadObjectQueque) {
                    if ([each isKindOfClass:[WizDocument class]]) {
                        upObj = each;
                        break;
                    }
                }
                if (nil == upObj) {
                    upObj = [uploadObjectQueque lastObject];
                }
                upTool.uploadObject = upObj;
                [uploadObjectQueque removeObject:upObj];
                [upTool start];
            }
        }
    }
}

- (void) shouldUpload:(WizObject*)obj
{
    @synchronized(uploadObjectQueque)
    {
        [uploadObjectQueque addObject:obj];
    }
    [self startUpload];
}

- (void) wizApiEnd:(WizApi *)api withSatue:(enum WizApiStatue)statue
{
    if (statue != WizApistatueError) {
        [self startUpload];
    }
}

- (void) stopUpload
{
    @synchronized(uploadObjectQueque)
    {
        [uploadObjectQueque removeAllObjects];
    }
    @synchronized(uploadTools)
    {
        for (WizUploadObject* each in uploadTools) {
            [each cancel];
        }
    }
}

@end
