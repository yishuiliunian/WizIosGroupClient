//
//  WGCreateNoteViewController.h
//  WizGroup
//
//  Created by wiz on 12-11-28.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <string>
@interface WGCreateNoteViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, assign) std::string kbGuid;
@property (nonatomic, assign) std::string accountUserId;
@property (retain, nonatomic)UIScrollView* backgroundView;
@property (retain, nonatomic)UITextField* titilView;
@property (retain, nonatomic)UITextView* contentView;
@property (retain, nonatomic)UIImageView* lineView;
@property (retain, nonatomic)UIButton* keyboardBack_btn;
@end
