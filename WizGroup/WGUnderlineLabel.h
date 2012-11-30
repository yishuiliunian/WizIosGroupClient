//
//  WGUnderlineLabel.h
//  WizGroup
//
//  Created by wiz on 12-11-16.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WGUnderlineLabel:UIButton
{
    UILabel* label;
    UIImageView* imgView;
}

@property (retain, nonatomic)UILabel* label;
@property (retain, nonatomic)UIImageView* imgView;
-(id)initWithTitle:(NSString*)title Frame:(CGRect)frame;

@end
