//
//  WizLogger.h
//  WizGroup
//
//  Created by wiz on 12-10-30.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef  enum WizLogLevel {
    WizLogLevelDebug = 0,
    WizLogLevelInfo = 1,
    WizLogLevelWarning = 2,
    WizLogLevelError = 3
} WizLogLevel ;


void writeCinLog( const char* function,        // 记录日志所在的函数名称
                 WizLogLevel level,            // 日志级别，Debug、Info、Warn、Error
                 NSString* format,            // 日志内容，格式化字符串
                 ... ) ;                      // 格式化字符串的参数


@interface WizLogger : NSObject

@end


#define WizLogDebug(format,...)        writeCinLog(__FUNCTION__,WizLogLevelDebug,format,##__VA_ARGS__)
#define WizLogInfo(format,...)        writeCinLog(__FUNCTION__,WizLogLevelInfo,format,##__VA_ARGS__)
#define WizLogWarn(format,...)        writeCinLog(__FUNCTION__,WizLogLevelWarning,format,##__VA_ARGS__)
#define WizLogError(format,...)        writeCinLog(__FUNCTION__,WizLogLevelError,format,##__VA_ARGS__)