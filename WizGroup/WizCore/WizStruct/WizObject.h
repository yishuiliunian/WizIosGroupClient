//
//  WizObject.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizObject : NSObject
@property (atomic, retain) NSString* strGuid;
@property (nonatomic, retain) NSString* strTitle;
- (NSString*) wizObjectType;
@end
