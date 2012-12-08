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
@property (nonatomic, assign) WIZDOCUMENTDATA document;
@property (nonatomic, assign)    id <WizPadCheckAttachmentDelegate> checkAttachmentDelegate;
@property (nonatomic, retain) NSString* kbguid;
@property (nonatomic, retain) NSString* accountUserId;
- (void) downloadDone:(NSNotification*)nc;
@end
