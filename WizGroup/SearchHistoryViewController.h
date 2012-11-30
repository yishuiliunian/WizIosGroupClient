//
//  SearchHistoryView.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WizSearchHistoryDelegate <NSObject>

- (void) didSelectedSearchHistory:(NSString*)keyWords;

@end

@interface SearchHistoryView : UITableViewController
{
    NSMutableArray* history;
    id <WizSearchHistoryDelegate> historyDelegate;
}
@property (nonatomic, retain) NSMutableArray* history;
@property (nonatomic, assign) id <WizSearchHistoryDelegate> historyDelegate;
- (void) reloadData;
- (void) addSearchHistory:(NSString*)keyWords notesNumber:(int)count isSearchLoal:(BOOL)isSearchLocal;
@end
