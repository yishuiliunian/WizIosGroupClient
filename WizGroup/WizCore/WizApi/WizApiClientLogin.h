//
//  WizApiClientLogin.h
//  WizCore
//
//  Created by wiz on 12-9-24.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"
@protocol WizApiLoginDelegate <NSObject>

- (void) didClientLoginSucceed:(NSString*)accountUserId  retObject:(id)ret;
- (void) didClientLoginFaild:(NSError*)error;

@end


@interface WizApiClientLogin : WizApi
@property (nonatomic, retain) NSString* password;
@property (nonatomic, assign) id<WizApiLoginDelegate> delegate;
@end
