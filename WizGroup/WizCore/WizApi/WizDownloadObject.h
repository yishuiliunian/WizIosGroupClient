//
//  WizDownloadObject.h
//  WizCoreFunc
//
//  Created by wiz on 12-9-26.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizApi.h"

@protocol WizApiDownloadObjectDelegate <NSObject>

- (void) didDownloadObjectSucceed:(WizObject*)obj;
- (void) didDownloadObjectFaild:(WizObject*)obj;

@end

@interface WizDownloadObject : WizApi
@property (nonatomic, assign) id<WizApiDownloadObjectDelegate> delegate;
@property (nonatomic , retain) WizObject* downloadObject;
@end
