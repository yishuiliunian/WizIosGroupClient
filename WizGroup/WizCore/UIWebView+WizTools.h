//
//  UIWebView+WizTools.h
//  Wiz
//
//  Created by 朝 董 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIWebViewWidthForIphoneLandscape    @"480px"
#define UIWebViewWidthForIphonePotrait      @"320px"

@interface UIWebView (WizTools)
- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
- (void)removeAllHighlights;
- (BOOL) containImages;
- (NSString*) bodyText;
- (void) loadReadJavaScript;
- (void) setTableAndImageWidth:(NSString*)width;
- (void) setCurrentPageWidth:(NSString*)width;
@end
