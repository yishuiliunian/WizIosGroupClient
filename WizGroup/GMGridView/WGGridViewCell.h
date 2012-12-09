//
//  WGGridViewCell.h
//  WizGroup
//
//  Created by wiz on 12-10-18.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "GMGridViewCell.h"
#import <string>
using namespace std;
@interface WGGridViewCell : GMGridViewCell
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UILabel*      textLabel;
@property (nonatomic, assign) std::string     kbguid;
@property (nonatomic, assign) std::string     accountUserId;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;
- (id) initWithSize:(CGSize)size;
- (void) setBadgeCount;
@end
