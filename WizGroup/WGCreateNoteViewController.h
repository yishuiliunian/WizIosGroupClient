//
//  WGCreateNoteViewController.h
//  WizGroup
//
//  Created by wiz on 12-11-28.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WGChooseFolderViewController.h"

@interface WGCreateNoteViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate,WGChooseFolderViewControllerDelegate>

@property (nonatomic, retain) NSString* kbGuid;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* docGuid;
//@property (nonatomic, retain) NSString* listKeyStr;
//@property (nonatomic, retain) NSString* listType;


@property (retain, nonatomic)UIScrollView* backgroundView;
@property (retain, nonatomic)UITextField* titleView;
@property (retain, nonatomic)UITextView* contentView;
@property (retain, nonatomic)UIImageView* lineView;
@property (retain, nonatomic)UIButton* keyboardBack_btn;
@end
