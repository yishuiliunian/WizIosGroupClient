//
//  WGNavigationBarNew.m
//  WizGroup
//
//  Created by wiz on 12-10-30.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGNavigationBarNew.h"


@implementation WGNavigationBarNew
@synthesize titleLabel;
@synthesize barItem;

- (void) dealloc
{
    [titleLabel release];
    [barItem release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        barItem = [[UINavigationItem alloc]initWithTitle:@""];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIImage* image = [UIImage imageNamed:@"app_nuvigationbar_baackground"];
    self.titleLabel.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
    [image drawInRect:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
    [titleLabel drawRect:CGRectMake(0.0, 0.0, self.frame.size.width, 40)];
    barItem.titleView = titleLabel;
    [self pushNavigationItem:barItem animated:YES];
}

@end
