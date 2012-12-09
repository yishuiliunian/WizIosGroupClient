//
//  WGReadViewController.h
//  WizGroup
//
//  Created by wiz on 12-10-8.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <string>
#import "WizModuleTransfer.h"
using namespace WizModule;
@protocol WGReadListDelegate <NSObject>

- (std::string) currentDocumentGuid;
- (BOOL) shouldCheckNextDocument;
- (void) moveToNextDocument;
- (BOOL) shouldCheckPreDocument;
- (void) moveToPreDocument;

@end

@interface WGReadViewController : UIViewController
@property (assign, nonatomic) id<WGReadListDelegate> listDelegate;
@property (nonatomic, assign) std::string kbguid;
@property (nonatomic, assign) std::string accountUserId;
@end
