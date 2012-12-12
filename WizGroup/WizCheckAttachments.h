//
//  WizCheckAttachments.h
//  Wiz
//
//  Created by wiz on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizPadCheckAttachmentDelegate.h"
#import "WizModuleTransfer.h"
using namespace WizModule;
@interface WizCheckAttachments : UITableViewController <UIAlertViewDelegate,UIDocumentInteractionControllerDelegate>
{
    id <WizPadCheckAttachmentDelegate> checkAttachmentDelegate;
    
}
@property (nonatomic, assign) std::string docGuid;
@property (nonatomic, assign) id <WizPadCheckAttachmentDelegate> checkAttachmentDelegate;
@property (nonatomic,  assign) std::string kbguid;
@property (nonatomic, assign) std::string accountUserId;
- (void) downloadDone:(NSNotification*)nc;
@end
