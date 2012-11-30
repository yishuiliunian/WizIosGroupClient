//
//  NSString+WizString.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+WizString.h"
#import "Pinyin/pinyin.h"
#import <wchar.h>
#import <string>
#import <stdio.h>
#import <stdlib.h>

bool IsScriptOrStyle(const wchar_t* p)
{
	if (*p == 's' || *p == 'S')
	{
		p++;
		if (*p == 'c' || *p == 'C')
		{
			p++;
			//
			if (*p == 'r' || *p == 'R')
			{
				p++;
				if (*p == 'i' || *p == 'I')
				{
					p++;
					if (*p == 'p' || *p == 'P')
					{
						p++;
						if (*p == 't' || *p == 'T')
						{
							p++;
							if (isspace(*p)
								|| *p == '>')
							{
								return true;
							}
						}
					}
				}
			}
		}
		else if (*p == 't' || *p == 'T')
		{
			p++;
			if (*p == 'y' || *p == 'Y')
			{
				p++;
				//
				if (*p == 'l' || *p == 'L')
				{
					p++;
					if (*p == 'e' || *p == 'E')
					{
						p++;
						if (isspace(*p)
                            || *p == '>')
						{
							return true;
						}
					}
				}
			}
		}
	}
	//
	return false;
}
//
bool IsSpaceString(const wchar_t* pTextBegin, const wchar_t* pTextEnd)
{
	while (pTextBegin < pTextEnd)
	{
		if (*pTextBegin == ' '
			|| *pTextBegin == '\t'
			|| *pTextBegin == '\r'
			|| *pTextBegin == '\n')
		{
			pTextBegin++;
			continue;
		}
		//
		return false;
	}
	//
	return true;
}
//
bool IsInScriptOrStyleTag(const wchar_t* p, const wchar_t* pTextBegin)
{
	while (pTextBegin >= p)
	{
		if (*pTextBegin == '<')
		{
			pTextBegin++;
			return IsScriptOrStyle(pTextBegin);
		}
		else
		{
			pTextBegin--;
		}
	}
	//
	return false;
}
//
bool FindTextBegin(const wchar_t* p, const wchar_t*& pTextBegin, const wchar_t*& pTextEnd)
{
	const wchar_t* pBegin = p;
	//
	while (1)
	{
		p = wcschr(p, '>');
		if (NULL == p)
			return false;
		//
		p++;
		pTextBegin = p;
		//
		pTextEnd = wcschr(pTextBegin, '<');
		if (NULL == pTextEnd)
			return false;
		//
		p = pTextEnd;
		//
		if (pTextEnd - pTextBegin <= 1)	//empty text tag
			continue;
		//
		if (IsSpaceString(pTextBegin, pTextEnd))
			continue;
		//
		if (IsInScriptOrStyleTag(pBegin, pTextBegin))
			continue;
		//
		return true;
	}
}

void FindAllText(std::wstring& html, int maxSize)
{
    std::wstring strRet;
    if (maxSize > 0) {
        strRet.reserve(maxSize * 2);
    }
    else
    {
        strRet.reserve(html.length());
    }
	//
	const wchar_t* p = html.c_str();
	//
	while (1)
	{
		const wchar_t* pTextBegin = NULL;
		const wchar_t* pTextEnd = NULL;
		//
		if (FindTextBegin(p, pTextBegin, pTextEnd))
		{
			//
			strRet =  strRet + std::wstring(L" ") + std::wstring(pTextBegin, pTextEnd);
            if (strRet.length() >= maxSize && maxSize > 0) {
                break;
            }
			//
			p = pTextEnd;
			//
			continue;
		}
		else
		{
			break;
		}
	}
	//
	html = strRet;
}

void AddWizTagToHtml(std::wstring& html)
{
	std::wstring strRet;
    
	strRet.reserve(html.length() * 2);
	//
	const wchar_t* p = html.c_str();
	//
	while (1)
	{
		const wchar_t* pTextBegin = NULL;
		const wchar_t* pTextEnd = NULL;
		//
		if (FindTextBegin(p, pTextBegin, pTextEnd))
		{
			strRet += std::wstring(p, pTextBegin);
			//
			strRet += L"<wiz>" + std::wstring(pTextBegin, pTextEnd) + L"</wiz>";
			//
			p = pTextEnd;
			//
			continue;
		}
		else
		{
			strRet += p;
			break;
		}
	}
	//
	html = strRet;
}


@implementation NSString (WizString)


- (NSComparisonResult) compareFirstCharacter:(NSString*)string
{
    return [[self pinyinFirstLetter] compare:[string pinyinFirstLetter]];
}

//
- (NSString*) pinyinFirstLetter
{
    return [WizGlobals pinyinFirstLetter:self];
}
- (BOOL) isBlock
{
    return nil == self ||[self isEqualToString:@""];
}
- (NSString*) fileName
{
    return [[self componentsSeparatedByString:@"/"] lastObject];
}
- (NSString*) fileType
{
    NSString* fileName = [self fileName];
    if (fileName == nil || [fileName isBlock]) {
        return nil;
    }
    return [[fileName componentsSeparatedByString:@"."] lastObject];
}

- (NSString*) stringReplaceUseRegular:(NSString *)regex withString:(NSString*)replaceStr
{
    @try {
        if (self) {
            NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
            return [reg stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:replaceStr];
        }

    }
    @catch (NSException *exception) {
        return self;
    }
    @finally {
            
    }
    
}

- (NSString*) stringReplaceUseRegular:(NSString*)regex
{
    @try {
        if (self) {
            NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
            return [reg stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@""];
        }
    }
    @catch (NSException *exception) {
        return self;
    }
    @finally {
        
    }
    
}

- (NSDate *) dateFromSqlTimeString
{
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    @synchronized(formatter)
    {
        if (self.length < 19) {
            return nil;
        }
         NSDate* date = [formatter dateFromString:self];
        return date ;
    }
}
//
-(NSString*) trim
{
	NSString* ret = [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];	
	return ret;
}
-(NSString*) trimChar: (unichar)ch
{
	NSString* str = [NSString stringWithCharacters:&ch length: 1];
	NSCharacterSet* cs = [NSCharacterSet characterSetWithCharactersInString: str];
	//
	return [self stringByTrimmingCharactersInSet: cs];	
}

-(int) indexOfChar:(unichar)ch
{
	NSString* str = [NSString stringWithCharacters:&ch length: 1];
	//
	return [self indexOf: str];
}
-(int) indexOf:(NSString*)find
{
	NSRange range = [self rangeOfString:find options:NSCaseInsensitiveSearch];
	if (range.location == NSNotFound)
		return NSNotFound;
	//
	return range.location;
}

- (NSInteger) indexOf:(NSString *)find compareOptions:(NSStringCompareOptions)mask
{
    NSRange range = [self rangeOfString:find options:mask];
    if (range.location == NSNotFound) {
        return NSNotFound;
    }
    return range.location;
}
-(int) lastIndexOfChar: (unichar)ch
{
	NSString* str = [NSString stringWithCharacters:&ch length: 1];
	//
	return [self lastIndexOf: str];
}
-(int) lastIndexOf:(NSString*)find
{
	NSRange range = [self rangeOfString:find options:NSBackwardsSearch|NSCaseInsensitiveSearch];
	if (range.location == NSNotFound)
		return NSNotFound;
	//
	return range.location;
}

-(NSString*) toValidPathComponent
{
	NSMutableString* name = [[[NSMutableString alloc] initWithString:self] autorelease];
	//
	[name replaceOccurrencesOfString:@"\\" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"/" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"'" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"\"" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@":" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"*" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"?" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"<" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@">" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"|" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"!" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	//
	if ([name length] > 50)
	{
		return [name substringToIndex:50];
	}
	//
	return name;
}

-(NSString*) firstLine
{
	NSString* text = [self trim];
	int index = [text indexOfChar:'\n'];
	if (NSNotFound == index)
		return text;
	return [[text substringToIndex:index] trim];
}

- (NSString*) fromHtml
{
    if (!self) {
        return nil;
    }
    NSMutableString* name = [[NSMutableString alloc] initWithString:self];
	//
	[name replaceOccurrencesOfString:@"" withString:@"\r" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"&gt;" withString:@"<" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"&lt;" withString:@">" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"<br>" withString:@"\n" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"&nbsp;&nbsp;&nbsp;&nbsp;" withString:@"\t" options:0 range:NSMakeRange(0, [name length])];
	return [name autorelease];
}

- (NSString*) nToHtmlBr
{
    return [self stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
}

-(NSString*) toHtml
{
    if (!self) {
        return nil;
    }
	NSMutableString* name = [[NSMutableString alloc] initWithString:self];
	//
	[name replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"<" withString:@"&gt;" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@">" withString:@"&lt;" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"\n" withString:@"<br>" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;&nbsp;&nbsp;" options:0 range:NSMakeRange(0, [name length])];
    [name replaceOccurrencesOfString:@" " withString:@"&nbsp;" options:0 range:NSMakeRange(0, [name length])];
    
	return [name autorelease];
	
}

- (NSString *)URLEncodedString{    
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}
- (NSString*)URLDecodedString{
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)self,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}

- (BOOL) checkHasInvaildCharacters
{
    static NSRegularExpression* regular = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError* error = nil;
        regular = [[NSRegularExpression regularExpressionWithPattern:@"[\\,/,:,<,>,*,?,\",&,\"]" options:NSRegularExpressionCaseInsensitive error:&error] retain];
        NSLog(@"regular %@",regular);
    });
    NSArray* regularArray = [regular  matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (regularArray && [regularArray count]) {
        return YES;
    }
    return NO;
}

- (BOOL) writeToFile:(NSString *)path useUtf8Bom:(BOOL)isWithBom error:(NSError **)error
{
    
    char BOM[] = {static_cast<char>(0xEF), static_cast<char>(0xBB), static_cast<char>(0xBF)};
    NSMutableData* data = [NSMutableData data];
    [data appendBytes:BOM length:3];
    [data appendData:[self dataUsingEncoding:NSUTF8StringEncoding]];
    NSFileManager* fileNamger = [NSFileManager defaultManager];
    if ([fileNamger fileExistsAtPath:path]) {
        [fileNamger removeItemAtPath:path error:nil];
    }
    [fileNamger createFileAtPath:path contents:data attributes:nil];
    return YES;
}
+(NSString*)getStringFromWChar:(const wchar_t*) inStr
{
    setlocale(LC_CTYPE, "UTF-8");
    int strLength = wcslen(inStr);
    int bufferSize = (strLength+1)*4;
    char *stTmp = (char*)malloc(bufferSize);
    memset(stTmp, 0, bufferSize);
    wcstombs(stTmp, inStr, strLength);
    NSString* ret = [[[NSString alloc] initWithBytes:stTmp length:strlen(stTmp) encoding:NSUTF8StringEncoding] autorelease];
    free(stTmp);
    return ret;
}

- (std::wstring) getWCharFromString
{

    const char  *cString;
    cString = [self cStringUsingEncoding:NSUTF8StringEncoding];
    setlocale(LC_CTYPE, "UTF-8");
    int iLength = mbstowcs(NULL, cString, 0);
    int bufferSize = (iLength+1)*sizeof(wchar_t);
    wchar_t *stTmp = (wchar_t*)malloc(bufferSize);
    memset(stTmp, 0, bufferSize);
    mbstowcs(stTmp, cString, iLength);
    stTmp[iLength] = 0;
    std::wstring wstr(stTmp);
    free(stTmp);
    return wstr;
}

NSRange (^htmlTagRangeClose)(NSString*, NSString*) = ^(NSString* string,NSString* tag)
{
    if( nil == string)
    {
        return NSMakeRange(NSNotFound, NSNotFound);
    }
    NSString* patterns = [NSString stringWithFormat:@"<%@[^>]*>([\\s\\S]*)</%@>",tag,tag];
    NSRegularExpression*  headRegular = [NSRegularExpression regularExpressionWithPattern:patterns options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange headRange = NSMakeRange(0, 0);
    NSArray* heads = [headRegular matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    for (NSTextCheckingResult* eachResult in heads)
    {
        if ([eachResult range].length > headRange.length)
        {
            headRange = [eachResult range];
        }
    }
    
    return headRange;
};

NSRange (^indexOfHtmlTag)(NSString*, NSString*, BOOL) = ^(NSString* string,NSString* tag,BOOL needFirst)
{
    if( nil == string)
    {
        return NSMakeRange(NSNotFound, NSNotFound);
    }
    NSString* patterns = [NSString stringWithFormat:@"%@",tag];
    NSRegularExpression*  headRegular = [NSRegularExpression regularExpressionWithPattern:patterns options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray* heads = [headRegular matchesInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, string.length)];
    if(heads && [heads count])
    {
        return [[heads objectAtIndex:0] range];
    }
    return NSMakeRange(NSNotFound, NSNotFound);
};

- (NSString*) getBody
{
    NSRange  bodyRange = htmlTagRangeClose(self,@"body");
    if (bodyRange.length == 0 ) {
        NSInteger  lastIndexOfHtml = [self lastIndexOf:@"</html>"];
        NSInteger lastIndexOfHead = [self lastIndexOf:@"</head>"];
        NSRange htmlRange = indexOfHtmlTag(self,@"<html[^>]*>",YES);
        NSInteger subStartPos = 0;
        NSInteger subEndPos = lastIndexOfHtml == NSNotFound? self.length:lastIndexOfHtml;
        //
        if (lastIndexOfHead != NSNotFound) {
            subStartPos = lastIndexOfHead + 7;
        }
        else
        {
            if (htmlRange.length != NSNotFound) {
                subStartPos = htmlRange.location + htmlRange.length;
            }
        }
        return [NSString stringWithFormat:@"<body>%@</body>",[self substringWithRange:NSMakeRange(subStartPos, subEndPos-subStartPos)]];
    }
    return [self substringWithRange:bodyRange];
}
- (NSString*) processHtml
{
    if (nil == self) {
        return nil;
    }
    std::wstring str = [[self getBody] getWCharFromString];
    AddWizTagToHtml(str);
    return [[NSString getStringFromWChar:str.c_str()] stringReplaceUseRegular:@"<body[^>]*>"];
}

- (NSString*) htmlToText:(int)maxSize
{
    if (nil == self) {
        return nil;
    }
    NSString* bodyStr = [self getBody];
    std::wstring str = [bodyStr getWCharFromString];
    FindAllText(str, maxSize);
    return [NSString getStringFromWChar:str.c_str()];
}

- (NSArray*) sperateTagGuids
{
    NSArray* array = [self componentsSeparatedByString:@"*"];
    return array;
}

- (NSString*) constructTagGuids:(NSArray*)tags
{
    NSMutableString* tagGuids = [NSMutableString string];
    for (int i = 0; i < [tags count]; ++i) {
        NSString* guid = [ tags objectAtIndex:i];
        [tagGuids appendString:guid];
        if (i != [tags count] - 1) {
            [tagGuids appendString:@"*"];
        }
    }
    return tagGuids;
}

- (NSString*) removeTagguid:(NSString *)tagGuid
{
    NSMutableArray* tags = [NSMutableArray arrayWithArray:[self sperateTagGuids]];
    NSInteger indexOfTag = NSNotFound;
    for (int i = 0; i < [tags count]; ++i) {
        if ([[tags objectAtIndex:i] isEqualToString:tagGuid]) {
            indexOfTag = i;
            break;
        }
    }
    if (indexOfTag != NSNotFound) {
        [tags removeObjectAtIndex:indexOfTag];
    }
    return [self constructTagGuids:tags];
}
- (NSString*) chinesePinYin
{
    NSMutableString* pinYinResult = [NSMutableString string];
    for (int i = 0; i < self.length; i++) {
        NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([self characterAtIndex:i])]uppercaseString];
        [pinYinResult appendString:singlePinyinLetter];
    }
    return pinYinResult;

}
- (NSComparisonResult) compareChinesePinyin:(NSString*)string
{
    return [[self chinesePinYin] compare:[string chinesePinYin]];
}

- (NSString*) iso8601TimeToStringSqlTimeString
{
	NSMutableString* val = [[NSMutableString alloc] initWithString:self];
	//XXXXXXXXTXX:XX:XX
	[val replaceOccurrencesOfString:@"T" withString:@" " options:0 range:NSMakeRange(0, [val length])];
	[val insertString:@"-" atIndex:6];
	[val insertString:@"-" atIndex:4];
	//
	NSString* ret = [NSString stringWithString:val];
	//
	[val release];
	//
	return ret;
}
@end
