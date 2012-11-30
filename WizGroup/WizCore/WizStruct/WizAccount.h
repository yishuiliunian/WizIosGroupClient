//
//  WizAccount.h
//  Wiz
//
//  Created by 朝 董 on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizAccount : NSObject
@property (atomic, retain) NSString* strUserId;
@property (atomic, retain) NSString* strPassword;
@property (atomic, retain) NSString* strKbguid;
@end
