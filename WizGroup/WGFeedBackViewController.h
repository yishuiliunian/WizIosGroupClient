//
//  WGFeedBackViewController.h
//  WizGroup
//
//  Created by wiz on 12-11-13.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

@protocol WGFeedBackViewControllerDelegate;
@class WGUnderlineLabel;
@interface WGFeedBackViewController : UIViewController<UITextViewDelegate>
{
    id <WGFeedBackViewControllerDelegate> delegate;
    UITextView* mytext;
    NSString* historyFilePath;
    NSMutableDictionary* feedBackHistoryDic;
    NSMutableArray* feedBackArray;
    float textViewH;
    UIImageView* imgView;
    WGUnderlineLabel* conf_btn;
}
@property (retain, nonatomic)id <WGFeedBackViewControllerDelegate> delegate;
@property (retain, nonatomic) NSString* kbGuid;
@property (retain, nonatomic) NSString* accountUserId;
@property (retain, nonatomic)UITextView* mytext;
@property (retain, nonatomic)NSString* historyFilePath;
@property (retain, nonatomic)NSMutableDictionary* feedBackHistoryDic;
@property (retain, nonatomic)NSMutableArray* feedBackArray;
@property (retain, nonatomic)UIImageView *imgView;
@property (retain, nonatomic)WGUnderlineLabel* conf_btn;
@end

@protocol WGFeedBackViewControllerDelegate
- (void)didfinishFeedBack:(WGFeedBackViewController *)controller;
@end

