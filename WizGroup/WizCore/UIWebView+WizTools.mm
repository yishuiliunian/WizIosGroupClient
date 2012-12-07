//
//  UIWebView+WizTools.m
//  Wiz
//
//  Created by 朝 董 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIWebView+WizTools.h"

@implementation UIWebView (WizTools)
- (NSInteger)highlightAllOccurencesOfString:(NSString*)str
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
	NSString *jsCode = [NSString stringWithContentsOfFile:path usedEncoding:nil error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@')",str];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
    NSString *result = [self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount"];
    return [result integerValue];
}
- (void) loadIphoneReadScript:(NSString*)width;
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"iphoneRead" ofType:@"js"];
	NSString *jsCode = [NSString stringWithContentsOfFile:path usedEncoding:nil error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
    NSString* js = [NSString stringWithFormat:@"ReadCurrentPage('%@')",width];
//    NSString* js = @"ReadCurrentPage('device-width')";
    [self stringByEvaluatingJavaScriptFromString:js];
}

- (void) loadReadJavaScript
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"iphoneRead" ofType:@"js"];
	NSString *jsCode = [NSString stringWithContentsOfFile:path usedEncoding:nil error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
}

- (void) setTableAndImageWidth:(NSString*)width
{
    NSString* js = [NSString stringWithFormat:@"SetCurrentPageTableAndImageWidth('%@')",width];
    [self stringByEvaluatingJavaScriptFromString:js];
}

- (void) setCurrentPageWidth:(NSString*)width
{
    NSString* js = [NSString stringWithFormat:@"SetCurrentPageWidth('%@')",width];
    [self stringByEvaluatingJavaScriptFromString:js];
}
- (void)removeAllHighlights
{
    [self stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
}

- (BOOL) containImages
{
	NSString* script = @"function containImages() { var images = document.images; return (images && images.length > 0) ? \"1\" : \"0\"; } containImages();";
	//
	NSString* ret = [self stringByEvaluatingJavaScriptFromString:script];
	//
	if (!ret)
		return NO;
	if ([ret isEqualToString:@"1"])
		return YES;
	if ([ret isEqualToString:@"0"])
		return NO;
	
	//
	return NO;
}

- (NSString*) bodyText
{
	//NSString* script = @"function getBodyText() { var body = document.body; if (!body) return ""; if (body.innerText) return body.innerText;  return body.innerHTML.replace(/\\&lt;br\\&gt;/gi,\"\\n\").replace(/(&lt;([^&gt;]+)&gt;)/gi, \"\"); } getBodyText();";
//	NSString* script = @"function getBodyText() { var body = document.body; if (!body) return ""; if (body.innerText) return body.innerText;  return \"\"; } getBodyText();";
	//
    NSString* script = @"function getBodyText() { var body = document.body; if (!body) return ""; if (body.innerText) return body.innerText;  return \"\"; } getBodyText();";
    NSString* ret = [self stringByEvaluatingJavaScriptFromString:script];
	if (!ret)
		return @"";
	//
	/*
     while ([ret rangeOfString:@"\n\n"].location != NSNotFound)
     {
     [ret replaceOccurrencesOfString:@"\n\n" withString:@"\n" options:0 range:NSMakeRange(0, [ret length])];
     }
     */
	
	//
	return ret;
}




@end
