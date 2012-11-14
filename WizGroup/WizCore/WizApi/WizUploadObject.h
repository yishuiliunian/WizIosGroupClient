//
//  WizUploadObject.h
//  WizCoreFunc
//
//  Created by wiz on 12-9-26.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizApi.h"

@protocol WizUploadObjectDelegate <NSObject>
- (void) didUploadWizObjectDone:(WizObject*)object;
- (void) didUPloadWizObjectFaild:(WizObject*)object;
@end

@interface WizUploadObject : WizApi
@property (nonatomic, assign) id<WizUploadObjectDelegate> delegate;
@property (nonatomic, retain) WizObject* uploadObject;

@end
