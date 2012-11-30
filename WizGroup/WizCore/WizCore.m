//
//  WizCore.m
//  WizCore
//
//  Created by wiz on 12-7-31.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizCore.h"
#import "WizFileManager.h"
#import "WizDbManger/WizDbManager.h"

@implementation WizCore
+ (void) addNewDocument:(NSString*)sourceFilesPath  document:(WizDocument*)doc toKbguid:(NSString*)kbguid accountUserId:(NSString*)accountUserId
{
    doc.nLocalChanged = WizEditDocumentTypeAllChanged;
    NSDictionary* docAttributes = [doc getModelDictionary];
    NSString* documentAimPath = [[WizFileManager shareManager] wizObjectFilePath:doc.strGuid accountUserId:accountUserId];
    
    
    NSError* error = nil;
    NSArray* contents = [[WizFileManager shareManager] contentsOfDirectoryAtPath:sourceFilesPath error:&error];
    for (NSString* each in contents) {
        NSString* sourcePath = [sourceFilesPath stringByAppendingPathComponent:each];
        NSString* aimPath = [documentAimPath stringByAppendingPathComponent:each];
        [[WizFileManager shareManager] copyItemAtPath:sourcePath toPath:aimPath error:&error];
        if (error) {
            NSLog(@"error is %@",error);
        }
    }
    
    id<WizMetaDataBaseDelegate> db = [[WizDbManager shareInstance] getMetaDataBaseForAccount:kbguid kbGuid:accountUserId];
    [db updateDocument:docAttributes];
}
@end
