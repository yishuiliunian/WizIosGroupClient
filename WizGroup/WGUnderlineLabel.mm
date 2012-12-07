//
//  WGUnderlineLabel.m
//  WizGroup
//
//  Created by wiz on 12-11-16.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGUnderlineLabel.h"
#import "WizGlobals.h"
#import <QuartzCore/QuartzCore.h>

@implementation WGUnderlineLabel
@synthesize label;
@synthesize imgView;

- (void)dealloc
{
    [super dealloc];
    [label release];
    [imgView release];
}

-(id)initWithTitle:(NSString*)title Frame:(CGRect)frame{
    if(self = [super initWithFrame:frame]) {
        float zoom;
        CGSize size = self.frame.size;
        float endX = size.width;
        float endY = size.height;
        
        UIFont *font = [UIFont systemFontOfSize:17];
        CGSize fontSize = [title sizeWithFont:font];
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, endY/2.0 - fontSize.height/2.0, endX, fontSize.height)];
        label.font = [UIFont systemFontOfSize:17];
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = UITextAlignmentCenter;
        label.text = title;
        if (![WizGlobals isChineseEnviroment]) {
            zoom = 0.15;
        }else{
            zoom = 0.26;
        }
        NSInteger len = label.text.length;
        [self addSubview:label];
        
        float lineLength = fontSize.width * len * zoom;
        imgView = [[UIImageView alloc]initWithFrame:CGRectMake( endX/2-lineLength/2.0,label.frame.origin.y + fontSize.height - 3,lineLength, 3.5)];
        imgView.image = [UIImage imageNamed:@"separatline"];
        [self addSubview:imgView];
    }
    return self;
}


@end
