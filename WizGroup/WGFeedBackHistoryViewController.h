//
//  WGFeedBackHistoryViewController.h
//  WizGroup
//
//  Created by wiz on 12-11-14.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WGFeedBackHistoryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    NSString* filePath;
    NSMutableDictionary* feedBackDic;
    NSMutableArray* array;
}
@property (retain, nonatomic)NSString* filePath;
@property (retain, nonatomic)NSMutableDictionary* feedBackDic;
@property (retain, nonatomic)NSMutableArray* array;
@end
