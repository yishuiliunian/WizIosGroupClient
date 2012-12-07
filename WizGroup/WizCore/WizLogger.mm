//
//  WizLogger.m
//  WizGroup
//
//  Created by wiz on 12-10-30.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WizLogger.h"

#import "WizFileManager.h"

@interface WizLogger()
{
    NSCondition* _signal;
    NSMutableArray* _queue;
    
}
@property (nonatomic, assign) WizLogLevel minLogLevel;
+ (WizLogger*) shareInstance;
@end

@implementation WizLogger
@synthesize minLogLevel;
- (void) dealloc
{
    [_queue release];
    [_signal release];
    [super dealloc];
}

+ (WizLogger*) shareInstance
{
    static WizLogger* shareInstance = nil;
    @synchronized(self)
    {
        if (shareInstance == nil) {
            shareInstance = [[WizLogger alloc] init];
        }
    }
    return shareInstance;
}

- (id) init
{
    self = [super init];
    if (self) {
        _signal = [[NSCondition alloc] init];
        _queue = [[NSMutableArray alloc] init];
        minLogLevel = WizLogLevelDebug;
        [NSThread detachNewThreadSelector:@selector(threadProc) toTarget:self withObject:nil];
    }
    return self;
}

- (void) logToFile:(NSArray*)items
{
    NSString* filePath = [WizFileManager logFilePath];
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [fileHandle seekToEndOfFile];
    NSMutableString* log = [NSMutableString string];
    for (NSDictionary* each in items) {
        
        NSString* str = [each objectForKey:@"Message"];
        NSDate* date = [each objectForKey:@"Date"];
        NSString* threadName = [each objectForKey:@"ThreadName"];
        NSString* functionName = [each objectForKey:@"FunctionName"];
        NSNumber* level = [each objectForKey:@"Level"];
        [log appendFormat:@"%@--%@--%@--%d--%@\n",date,threadName,functionName,[level integerValue], str];
    }
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandle closeFile];
}

- (BOOL) checkFileCreated
{
    NSString* filePath = [WizFileManager logFilePath];
    if (![[WizFileManager shareManager] fileExistsAtPath:filePath]) {
        [[WizFileManager shareManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    else
    {
        NSDictionary* attribute = [[WizFileManager shareManager] attributesOfItemAtPath:filePath error:nil];
        int64_t fileSize = 0;
        if (attribute) {
            fileSize = [attribute fileSize];
        }
        if (fileSize > 60 * 1024) {
            [[WizFileManager shareManager] deleteFile:filePath];
            [[WizFileManager shareManager] createFileAtPath:filePath contents:nil attributes:nil];
        }
    }
    return YES;
}

- ( void ) threadProc
{
    do
    {
        NSAutoreleasePool* pool = [ [ NSAutoreleasePool alloc ] init ];
        for ( int i = 0; i < 20; i++ )
        {
            [ _signal lock ];
            while ( [_queue count ] == 0 )
                [ _signal wait];
            NSArray* items = [ NSArray arrayWithArray: _queue ];
            [ _queue removeAllObjects ];
            [ _signal unlock ];
            if ( [ items count ] > 0 && [ self checkFileCreated] )
                [ self logToFile: items ];
        }
        [ pool release ];
        
    } while ( YES );
}
- ( void ) appendLogEntry: ( NSDictionary* )entry
{
    [ _signal lock ];
    [ _queue addObject: entry ];
    [ _signal signal ];
    [ _signal unlock ];
}
@end



void writeCinLog( const char* function,        // 记录日志所在的函数名称
                 WizLogLevel level,            // 日志级别，Debug、Info、Warn、Error
                 NSString* format,            // 日志内容，格式化字符串
                 ... )                        // 格式化字符串的参数
{
    WizLogger* manager = [WizLogger shareInstance]; // CinLoggerManager是单件的日志管理器
    
    if ( manager.minLogLevel > level || ! format ) // 先检查当前程序设置的日志输出级别。如果这条日志不需要输出，就不用做字符串格式化
        return;
    
    va_list args;
    va_start( args, format );
    NSString* str = [ [ NSString alloc ] initWithFormat: format arguments: args ];
    va_end( args );
    NSThread* currentThread = [ NSThread currentThread ];
    NSString* threadName = [ currentThread name ];
    NSString* functionName = [ NSString stringWithUTF8String: function ];
    if ( ! threadName )
        threadName = @"";
    if ( ! functionName )
        functionName = @"";
    if ( ! str )
        str = @"";
    
    NSDictionary* entry = [ [ NSDictionary alloc ] initWithObjectsAndKeys:
                           @"LogEntry", @"Type",
                           str, @"Message",                                                // 日志内容
                           [ NSDate date ], @"Date",                                    // 日志生成时间
                           [ NSNumber numberWithUnsignedInteger: level ], @"Level",        // 本条日志级别
                           threadName, @"ThreadName",                                    // 本条日志所在的线程名称
                           functionName, @"FunctionName",                                // 本条日志所在的函数名称
                           nil ];
    [ str release ];
    [ manager appendLogEntry: entry ];
    [ entry release ];
}

