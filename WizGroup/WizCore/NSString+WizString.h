//
//  NSString+WizString.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WizString)
- (BOOL) isBlock;
- (NSString*) fileName;
- (NSString*) fileType;
- (NSString*) stringReplaceUseRegular:(NSString*)regex;
- (NSString*) stringReplaceUseRegular:(NSString *)regex withString:(NSString*)replaceStr;
- (NSDate *) dateFromSqlTimeString;
//help
- (NSString*) trim;
- (NSString*) trimChar:(unichar) ch;
- (int) indexOfChar:(unichar)ch;
- (int) indexOf:(NSString*)find;
- (int) lastIndexOfChar: (unichar)ch;
- (int) lastIndexOf:(NSString*)find;
- (NSString*) firstLine;
- (NSString*) toHtml;
- (NSString*) pinyinFirstLetter;
- (NSString*) toValidPathComponent;

- (NSComparisonResult) compareFirstCharacter:(NSString*)string;

- (NSString *)URLEncodedString;
- (NSString*)URLDecodedString;
- (NSString*) fromHtml;
- (NSString*) nToHtmlBr;
//
- (BOOL) writeToFile:(NSString *)path useUtf8Bom:(BOOL)isWithBom error:(NSError **)error;
//
- (NSInteger) indexOf:(NSString *)find compareOptions:(NSStringCompareOptions)mask;

- (BOOL) checkHasInvaildCharacters;
- (NSString*) processHtml;
- (NSString*) htmlToText:(int)maxSize;
//
- (NSArray*)  sperateTagGuids;
- (NSString*)  removeTagguid:(NSString*)tagGuid;
- (NSString*) chinesePinYin;
- (NSComparisonResult) compareChinesePinyin:(NSString*)string;
//
- (NSString*) iso8601TimeToStringSqlTimeString;
@end
