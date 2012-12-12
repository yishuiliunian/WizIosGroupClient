//
//  DocumentInfoViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizModuleTransfer.h"
@class WizDocument;
@interface DocumentInfoViewController : UITableViewController
{
    BOOL isEditTheDoc;
}
@property (nonatomic, assign) WizModule::WIZDOCUMENTDATA doc;
@property (nonatomic, assign) BOOL isEditTheDoc;
@end
