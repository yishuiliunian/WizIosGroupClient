//
//  WizApiSearch.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-15.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizApi.h"

@protocol WizSearchDelegate <NSObject>

- (void) didSearchSucceed:(NSArray*)array;
- (void) didSearchError:(NSError*)error;

@end

@interface WizApiSearch : WizApi
@property (nonatomic, assign) id<WizSearchDelegate> delegate;
@property (nonatomic, retain) NSString* keyWords;
@end
