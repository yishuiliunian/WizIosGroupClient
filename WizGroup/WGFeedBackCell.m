//
//  WGFeedBackCell.m
//  WizGroup
//
//  Created by wiz on 12-11-14.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGFeedBackCell.h"
#import "WizDbManager.h"
#import "WGGlobalCache.h"
#import "WizNotificationCenter.h"

typedef enum WGDetailListCellLayoutType
{
    WGDetailListCellLayoutTypeFull = 0,
    WGDetailListCellLayoutTypeNoImage = 1
} WGDetailListCellLayout;



@interface WGFeedBackCell ()
{
    UILabel* titleLabel;
    UILabel* timeLabel;
    UILabel* detailLabel;
}
@end

@implementation WGFeedBackCell
@synthesize titleStr;
@synthesize timeStr;
@synthesize detailStr;

static UIFont* titleFont = nil;
static UIFont* detailFont = nil;
static UIFont* timeFont = nil;

- (void) dealloc
{
    [[WizNotificationCenter defaultCenter] removeObserver:self];
    [titleLabel release];
    [timeLabel release];
    [detailLabel release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            titleFont = [[UIFont boldSystemFontOfSize:12] retain];
            detailFont = [[UIFont systemFontOfSize:13] retain];
            timeFont = [[UIFont systemFontOfSize:13] retain];
        });
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setFont:titleFont];
        [self.contentView addSubview:titleLabel];
        
        //
        timeLabel = [[UILabel alloc] init];
        [timeLabel setFont:timeFont];
        [self.contentView addSubview:timeLabel];
        timeLabel.textColor = [UIColor lightGrayColor];

        detailLabel = [[UILabel alloc] init];
        [detailLabel setFont:detailFont];
        [self.contentView addSubview:detailLabel];
        
        [[WizNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUI:) name:WizNMUIDidGenerateAbstract object:nil];
    }
    return self;
}

- (void) loadUI
{
    static float startX = 10;
    static float startY = 10;
    CGSize cellSize = self.contentView.frame.size;
    float endX = cellSize.width - 20;
    //
    float titleWidth = 100;
    float titleHeight = 20;
    //
    float timeWidth = endX - titleWidth -startX;
    float timeHeight = 20;
    //
    float detaiWidth = endX - startX;
    float detailHeight = 50;
    //
    CGRect titleRect = CGRectMake(startX, startY, titleWidth , titleHeight);
    CGRect detailRect = CGRectMake(startX, titleHeight + startY , detaiWidth, detailHeight);
    CGRect timeRect = CGRectMake(startX + titleWidth , startY , timeWidth, timeHeight);

    titleLabel.frame = titleRect;
    titleLabel.text = titleStr;
    //
    timeLabel.frame = timeRect;
    timeLabel.text = timeStr;
    //
    detailLabel.frame = detailRect;
    detailLabel.text = detailStr;
}

- (void) drawRect:(CGRect)rect
{
    [self loadUI];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
