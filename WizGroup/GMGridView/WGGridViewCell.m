//
//  WGGridViewCell.m
//  WizGroup
//
//  Created by wiz on 12-10-18.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGGridViewCell.h"
#import "JSBadgeView.h"
#import <QuartzCore/QuartzCore.h>
#import "WizNotificationCenter.h"
#import "WizSyncCenter.h"
#import "WizDbManager.h"
#import "WGGlobalCache.h"

#define FONT_SIZE   16

@interface WGGridViewCell () <WizUnreadCountDelegate, WGIMageCacheObserver>
{
    JSBadgeView* badgeView;
    CGSize _size;
    UIImageView* coverView;
    UIActivityIndicatorView* activityIndicatorView;
    //
    NSInteger countItem;
}
@end

@implementation WGGridViewCell
@synthesize imageView = _imageView;
@synthesize textLabel = _textLabel;
@synthesize kbguid;
@synthesize accountUserId;
@synthesize activityIndicator = activityIndicatorView;
//计算文本所占高度
//2个参数：宽度和文本内容
-(CGFloat)calculateTextHeight:(CGFloat)widthInput Content:(NSString *)strContent{
    
    @synchronized(self)
    {
        CGSize constraint = CGSizeMake(widthInput, 20000.0f);
        CGSize size = [strContent sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeCharacterWrap];
        CGFloat height = size.height;
        return height;
    }
}


- (void) dealloc

{
    [[WizNotificationCenter defaultCenter] removeObserver:self];
//    [self removeObserver:self forKeyPath:@"textLabel.text" context:nil];
    [coverView release];
    [badgeView release];
    [_textLabel release];
    [_imageView release];
    [activityIndicatorView release];
    [kbguid release];
    [accountUserId release];
    [super dealloc];
}

- (id) initWithSize:(CGSize)size
{
    self = [self init];
    if (self) {
        
        static NSInteger _count = 0;
        countItem = _count++;
        //
        _size = size;
        
        CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
        _imageView = [[UIImageView alloc] initWithFrame:imageRect];
        _imageView.backgroundColor = [UIColor colorWithRed:99/255.0 green:181.0/255.0 blue:220.0/255.0 alpha:1.0];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 60, size.width, 20)];
    

        _textLabel.textAlignment = UITextAlignmentLeft;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.highlightedTextColor = [UIColor lightGrayColor];
        _textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        _textLabel.numberOfLines = 0;
        _textLabel.frame = CGRectMake(10, 10, size.width - 40, 20);
        _textLabel.shadowColor = [UIColor lightGrayColor];
        _textLabel.shadowOffset = CGSizeMake(1, -1);
        
        
        [_imageView addSubview:_textLabel];
        
        badgeView = [[JSBadgeView alloc] initWithParentView:_imageView alignment:JSBadgeViewAlignmentTopRight];
        badgeView.hidden = YES;
        
        
        self.contentView = _imageView;
        self.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        self.deleteButtonOffset = CGPointMake(-15, -15);
        

        [_imageView bringSubviewToFront:_textLabel];

        float activityViewHeight = 40;
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((size.width - activityViewHeight), (size.height - activityViewHeight) , activityViewHeight, activityViewHeight)];
        [_imageView addSubview:activityIndicatorView];
        [_imageView bringSubviewToFront:activityIndicatorView];
        //
        WizNotificationCenter* center = [WizNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(startSync:) name:WizNMSyncGroupStart object:nil];
        [center addObserver:self selector:@selector(endSync:) name:WizNMSyncGroupEnd object:nil];
        [center addObserver:self selector:@selector(endSync:) name:WizNMSyncGroupError object:nil];
    }
    return self;
}
- (void) startSync:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter getGuidFromNc:nc];
    if ([guid isEqualToString:self.kbguid]) {
        MULTIMAIN(^(void)
          {
              [activityIndicatorView startAnimating];
          });
    }
}
- (void) endSync:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter getGuidFromNc:nc];
    if ([guid isEqualToString:self.kbguid]) {
        MULTIMAIN(^(void)
      {
            [activityIndicatorView stopAnimating];
      });
    }
    [self setBadgeCount];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void) didGetUnreadCountForKbguid:(NSString*)guid  unreadCount:(int64_t)count
{
    if (![guid isEqualToString:self.kbguid]) {
        return;
    }
    if (count <= 0) {
        badgeView.hidden = YES;
    }
    else
    {
        badgeView.hidden = NO;
        if (count > 9) {
            badgeView.badgeText = [NSString stringWithFormat:@"N"];
        }
        else
        {
            badgeView.badgeText = [NSString stringWithFormat:@"%lld",count];
        }
    }
}

- (void) didGetImage:(UIImage *)image forKbguid:(NSString *)guid
{
    if (![guid isEqualToString:self.kbguid]) {
        return;
    }
    _imageView.image = image;
}

- (void) setBadgeCount
{
    badgeView.hidden = YES;
    if (self.kbguid == nil) {
        return;
    }
    [WGGlobalCache getUnreadCountByKbguid:self.kbguid accountUserId:self.accountUserId observer:self];
    [[WGGlobalCache shareInstance] getAbstractImageForKbguid:self.kbguid accountUserId:self.accountUserId observer:self];
}

@end
