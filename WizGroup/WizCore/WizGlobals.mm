//
//  WizGlobals.m
//  Wiz
//
//  Created by Wei Shijun on 3/4/11.
//  Copyright 2011 WizBrother. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import "WizGlobals.h"

#import <mach/mach.h>

#include "stdio.h"
#import "pinyin.h"
#define ATTACHMENTTEMPFLITER @"attchmentTempFliter"
#define MD5PART 10*1024

NSString* const WizCrashHanppend    = @"WizCrashHanppend";


void logTofile(char*sourceFile, char*functionName ,int lineNumber,NSString* format,...)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	va_list ap;
	NSString *print, *file, *function;
	va_start(ap,format);
	file = [[NSString alloc] initWithBytes: sourceFile length: strlen(sourceFile) encoding: NSUTF8StringEncoding];
	function = [NSString stringWithCString:functionName encoding:NSUTF8StringEncoding];
	print = [[NSString alloc] initWithFormat: format arguments: ap];
	va_end(ap);
    NSString* string = [NSString stringWithFormat:@"%@:%d %@; %@", [file lastPathComponent], lineNumber, function, print];
    [WizGlobals toLog:string];
	[print release];
	[file release];
	[pool release];
}


@implementation WizGlobals
static NSArray*  pptArray;
static NSArray*  docArray;
static NSArray*  audioArray;
static NSArray* textArray;
static NSArray* imageArray;
static NSArray* excelArray;
static NSArray* htmlArray;
/**
 *得到本机现在用的语言
 * en:英文  zh-Hans:简体中文   zh-Hant:繁体中文    ja:日本  ......
 */
+ (NSString*)getPreferredLanguage
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}

+ (BOOL) isChineseEnviroment
{
    NSString* currentLanguage = [[WizGlobals getPreferredLanguage] lowercaseString];
    if ([currentLanguage isEqualToString:[@"zh-Hans" lowercaseString]]) {
        return YES;
    }
    else
    {
        return NO;
    }
}
+ (float) WizDeviceVersion
{
//    return 4.0f;
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+(BOOL) DeviceIsPad
{
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
	{
		UIDevice* device = [UIDevice currentDevice];
		UIUserInterfaceIdiom deviceId = device.userInterfaceIdiom;
		return(deviceId == UIUserInterfaceIdiomPad);	
	}
	
	return(NO);
}

+(BOOL) WizDeviceIsPad
{
	BOOL b =[self DeviceIsPad];
	return b;
}
+(NSString*) md5:(NSData *)input {
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input.bytes, input.length, md5Buffer);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH *2];
    for(int i =0; i <CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    return  output;
}
+ (void) decorateViewWithShadowAndBorder:(UIView*)view
{
    CALayer* layer = [view layer];
    layer.borderColor = [UIColor grayColor].CGColor;
    layer.borderWidth = 0.5f;
    layer.shadowColor = [UIColor grayColor].CGColor;
    layer.shadowOffset = CGSizeMake(2, 2);
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 2;
    layer.cornerRadius = 5;

}
+ (UIView*) noNotesRemindFor:(NSString*)string
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 480)];
    UIImageView* pushDownRemind = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"documentWithoutData"]];
    pushDownRemind.frame = CGRectMake(120, 100, 80, 80);
    [view addSubview:pushDownRemind];
    CALayer* layer = [pushDownRemind layer];
    layer.borderColor = [UIColor whiteColor].CGColor;
    layer.borderWidth = 0.5f;
    layer.shadowColor = [UIColor grayColor].CGColor;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowOpacity = 0.5;
    layer.shadowRadius = 0.5;
    [pushDownRemind release];
    UITextView* remind = [[UITextView alloc] initWithFrame:CGRectMake(80, 200, 160, 480)];
    remind.text = string;
    remind.backgroundColor = [UIColor clearColor];
    remind.textColor = [UIColor grayColor];
    [view addSubview:remind];
    remind.textAlignment = UITextAlignmentCenter;
    [remind release];
    
    return [view autorelease];
}
+ (UIView*) noNotesRemind
{
    UIImageView* pushDownRemind = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pushDownRemind"]];
    UITextView* remind = [[UITextView alloc] initWithFrame:CGRectMake(80, 250, 160, 480)];
    remind.text = NSLocalizedString(@"You can pull down to sync notes or tap the plus (+) icon to create a new a note", nil);
    remind.backgroundColor = [UIColor clearColor];
    remind.textColor = [UIColor grayColor];
    [pushDownRemind addSubview:remind];
    remind.textAlignment = UITextAlignmentCenter;
    [remind release];
    pushDownRemind.tag = 10001;
    return [pushDownRemind autorelease];
}
+ (BOOL) checkObjectIsDocument:(NSString*)type
{
    return [type isEqualToString:@"document"];
}
+ (BOOL) checkObjectIsAttachment:(NSString*)type
{
    return [type isEqualToString:@"attachment"];
}
+ (NSString*) documentKeyString
{
    return @"document";
}
+ (NSString*) attachmentKeyString
{
    return @"attachment";
}
+(NSString*)fileMD5:(NSString*)path  
{  
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];  
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist  
    
    CC_MD5_CTX md5;  
    
    CC_MD5_Init(&md5);  
    
    BOOL done = NO;  
    while(!done)  
    {  
        NSData* fileData = [handle readDataOfLength: MD5PART ];  
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);  
        if( [fileData length] == 0 ) done = YES;  
    }  
    unsigned char digest[CC_MD5_DIGEST_LENGTH];  
    CC_MD5_Final(digest, &md5);  
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",  
                   digest[0], digest[1],   
                   digest[2], digest[3],  
                   digest[4], digest[5],  
                   digest[6], digest[7],  
                   digest[8], digest[9],  
                   digest[10], digest[11],  
                   digest[12], digest[13],  
                   digest[14], digest[15]];  
    return s;  
} 

+ (BOOL) checkFileIsEncry:(NSString*)filePath
{
    NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData* data  = [file readDataOfLength:4];
    if (data.length < 4) {
        return YES;
    }
    unsigned char* sd =(unsigned char*)[data bytes];
    if (sd[0] == 90 && sd[1] == 73 && sd[2] == 87 && sd[3] == 82) {
        return YES;
    }
    else {
        return NO;
    }
}
+(float) heightForWizTableFooter:(int)exisitCellCount
{
    float currentTableHeight = exisitCellCount*44.0;
    if (currentTableHeight < 44.0*6) {
        return 44.0*9 - currentTableHeight;
    }
    else
    {
        return 100.0;
    }
}

+ (NSString*) folderStringToLocal:(NSString*) str
{
    NSArray* strArr = [str componentsSeparatedByString:@"/"];
    NSMutableString* ret = [NSMutableString string];
    for (NSString* each in strArr) {
        if ([each isEqualToString:@""]) {
            continue;
        }
        NSString* localStr = NSLocalizedString(each, nil);
        [ret appendFormat:@"/%@",localStr];
    }
    return ret;
}

+(int)currentTimeZone
{
	static int hours = 100;
	if (hours == 100)
	{
		NSTimeZone* tz = [NSTimeZone systemTimeZone];
		int seconds = [tz secondsFromGMTForDate:[NSDate date]];
		//
		hours = seconds / 60 / 60;
	}
	//
	return hours;
}
+(long long) getFileSize: (NSString*)filePath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        return [attributes fileSize];
    }
    //
    return 0;
}

+ (BOOL) checkAttachmentType:(NSString*)type   isType:(NSString*)isType
{
    if (![type compare:isType options:NSCaseInsensitiveSearch]) {
        return YES;
    }
    else {
        return NO;
    }
}
+ (BOOL) checkAttachmentTypeInTypeArray:(NSString*)type  typeArray:(NSArray*)typeArray
{
    for (NSString* eachType in typeArray) {
        if ([WizGlobals checkAttachmentType:type isType:eachType]) {
            return YES;
        }
    }
    return NO;
}
+ (NSArray*) textArray
{

        textArray = [NSArray arrayWithObjects:@"txt", nil];
    
    return textArray;
}
+ (BOOL) checkAttachmentTypeIsTxt:(NSString*)attachmentType
{
    return [WizGlobals checkAttachmentTypeInTypeArray:attachmentType typeArray:[WizGlobals textArray]];
}
+ (NSArray*) audioArray
{
 
        audioArray = [NSArray arrayWithObjects:
                      @"aif",
                      @"amr",
                      @"mp3",
                      nil];
    
    return audioArray;
}
+ (BOOL) checkAttachmentTypeIsAudio:(NSString *)attachmentType
{
    return [WizGlobals checkAttachmentTypeInTypeArray:attachmentType typeArray:[WizGlobals audioArray]];
}
+ (NSArray*) imageArray
{

        imageArray = [NSArray arrayWithObjects:
                      @"png",
                      @"jpg",
                      @"jpeg",
                      @"bmp",
                      @"gif",
                      @"tiff",
                      @"eps",
                      nil];
    return imageArray;
}
+ (BOOL) checkAttachmentTypeIsImage:(NSString *)attachmentType
{

    return [WizGlobals checkAttachmentTypeInTypeArray:attachmentType typeArray:[self imageArray]];
}
+ (NSArray*) pptArray
{
        pptArray = [NSArray arrayWithObjects:
                    @"ppt",
                    @"pptx",
                    nil];
    return pptArray;
}
+ (BOOL) checkAttachmentTypeIsPPT:(NSString*)type
{
    return [WizGlobals checkAttachmentTypeInTypeArray:type typeArray:[WizGlobals pptArray]];
}
+ (NSArray*) docArray
{
    if (docArray == nil) {
        docArray = [NSArray arrayWithObjects:
                    @"doc",
                    @"docx",
                    nil];
        [docArray retain];
    }
    return docArray;
}
+ (BOOL) checkAttachmentTypeIsWord:(NSString*)type
{
    return [WizGlobals checkAttachmentTypeInTypeArray:type typeArray:[WizGlobals docArray]];
}

 + (NSArray*) htmlArray
{
    if (htmlArray == nil) {
        htmlArray = [NSArray arrayWithObjects:
                     @"html",
                     nil];
        [htmlArray retain];
    }
    return htmlArray;
}

+ (BOOL) checkAttachmentTypeIsHtml:(NSString *)attachmentType
{
    return [WizGlobals checkAttachmentTypeInTypeArray:attachmentType typeArray:[WizGlobals htmlArray]];
}
+ (NSArray*) excelArray
{
    excelArray = [NSArray arrayWithObjects:
                      @"xls",
                      @"xlsx",
                      nil];
    
    return excelArray;
}
+(void) reportMemory
{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in Mb): %u Mb", info.resident_size/1024/1024);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}
+ (BOOL) checkAttachmentTypeIsExcel:(NSString*)type
{
    return [WizGlobals checkAttachmentTypeInTypeArray:type typeArray:[WizGlobals excelArray]];
}

+ (NSURL*) wizServerUrl
{
//    return [[NSURL alloc] initWithString:@"http://192.168.79.1:8800/wiz/xmlrpc"];
//    NSString* url = [[WizSettings defaultSettings] wizServerUrl];
//    NSLog(@"url %@",url);
//    return [[[NSURL alloc] initWithString:url] autorelease];
//    return [[[NSURL alloc] initWithString:@"http://service.wiz.cn/wizkm/xmlrpc"] autorelease];
    return [[[NSURL alloc] initWithString:@"http://192.168.1.155:8800/wiz/xmlrpc"] autorelease];
//    return [[NSURL alloc] initWithString:@"http://110.75.189.20:8080/wiz/xmlrpc"];
}
+(void) showAlertView:(NSString*)title message:(NSString*)message delegate: (id)callback retView:(UIAlertView**) pAlertView
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:callback cancelButtonTitle:nil otherButtonTitles:nil];
	UIActivityIndicatorView* progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	//
	[alert addSubview:progress];
    [progress release];
	[alert show];
	CGRect rc = alert.frame;
	//
	CGPoint pt = CGPointMake(rc.size.width / 2 - 14 , rc.size.height / 2 + 10);
	//
	[progress setCenter:pt];
	[progress startAnimating];
	//
	*pAlertView = alert;
}

+ (NSString*) wizNoteVersion
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];  
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    return build;
}
+ (NSString*) localLanguageKey
{
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    return preferredLang;
}
+(void) reportErrorWithString:(NSString*)error
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError message:error delegate:nil cancelButtonTitle:WizStrOK otherButtonTitles:nil];
	[alert show];
	[alert release];
}
+(void) reportError:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
       [WizGlobals reportErrorWithString:[error localizedDescription]]; 
    });
}
+(void) reportWarningWithString:(NSString*)error
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrWarning message:error delegate:nil cancelButtonTitle:WizStrOK otherButtonTitles:nil];
	[alert show];
	[alert release];
}
+ (void) reportWarning:(NSError*)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
       [WizGlobals reportWarningWithString:[error localizedDescription]]; 
    });
}


+(NSString*) genGUID
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	//
	NSString* str = [NSString stringWithString:(NSString*)string];
	//
	CFRelease(string);
	//
	return [str lowercaseString];
}

+ (NSString*) encryptPassword:(NSString*)password
{
    NSString* md5P = [WizGlobals md5:[password dataUsingEncoding:NSUTF8StringEncoding]];
    NSString* md = [NSString stringWithFormat:@"md5.%@",md5P];
    return md;
}
+ (BOOL) checkPasswordIsEncrypt:(NSString*)password
{
    if (password.length > 4 &&[[password substringToIndex:4] isEqualToString:@"md5."]) {
        return YES;
    }
    else {
        return NO;
    }
}
+ (UIImage *)resizeImage:(UIImage *)image
			   scaledToSize:(CGSize)newSize 
{
    UIGraphicsBeginImageContext(newSize);    
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return newImage;
}
+ (NSInteger)fileLength:(NSString*)path
{
    NSError* error = nil;
    NSDictionary* dic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (nil == error) {
        return [dic fileSize];
    }
    [WizGlobals reportError:error];
    return NSNotFound;
}
+(NSNumber*) wizNoteAppleID
{
    return [NSNumber numberWithInt:507384718];
}
+ (UIImage*) attachmentNotationImage:(NSString*)type
{

    if ([WizGlobals checkAttachmentTypeIsAudio:type]) {
        return [UIImage imageNamed:@"icon_video_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsPPT:type])
    {
        return [UIImage imageNamed:@"icon_ppt_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsWord:type])
    {
        return [UIImage imageNamed:@"icon_word_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsExcel:type])
    {
        return [UIImage imageNamed:@"icon_excel_img"];
    }
    else if ([WizGlobals checkAttachmentTypeIsImage:type])
    {
        return [UIImage imageNamed:@"icon_image_img"];
    }
    else 
    {
        return [UIImage imageNamed:@"icon_file_img"];
    }
}

@end



BOOL DeviceIsPad(void)
{
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
	{
		UIDevice* device = [UIDevice currentDevice];
		UIUserInterfaceIdiom deviceId = device.userInterfaceIdiom;
		return(deviceId == UIUserInterfaceIdiomPad);	
	}
	
	return(NO);
}

BOOL WizDeviceIsPad(void)
{
	BOOL b = DeviceIsPad(); 
	return b;
}


@implementation UIViewController(WizScreenBounds)

- (CGSize) contentViewSize
{
    float height = [UIScreen mainScreen].bounds.size.height;
    height -=  [[UIApplication sharedApplication] statusBarFrame].size.height;
    if (!self.navigationController.navigationBarHidden) {
        height -= self.navigationController.navigationBar.frame.size.height;
    }
    return CGSizeMake(self.view.frame.size.width, height);
}

@end
