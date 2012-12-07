//
//  WizStrings.h
//  WizCoreFunc
//
//  Created by dzpqzb on 12-11-19.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iostream>
#import <sstream>
#import <string>
#import "WizMisc.h"
inline int WizStdStringReplace(std::string& str, const char* lpszStringToReplace, const char* lpszNewString)
{
	if (IsEmptyString(lpszStringToReplace))
		return 0;
	//
	int count = 0;
	//
	int oldLen = strlen(lpszStringToReplace);
	int newLen = IsEmptyString(lpszNewString) ? 0 : strlen(lpszNewString);
	//
	intptr_t index = str.find(lpszStringToReplace);
	while (index != std::string::npos)
	{
		str.replace(index, oldLen, lpszNewString);
		//
		index = str.find(lpszStringToReplace, index + newLen);
		//
		count++;
	}
	//
	return count;
}

inline std::string WizStringToSQLString(const char* lpsz)
{
	if (!lpsz || !*lpsz)
		return std::string("NULL");
	//
	std::string str(lpsz);
	//
	WizStdStringReplace(str, "'", "''");
	//
	str = "'" + str + "'";
	//
	return str;
}

inline std::string WizStringToSQLString(const std::string& str)
{
	return WizStringToSQLString(str.c_str());
}

inline bool WizIsSpaceChar(char ch)
{
	return ch == ' '
	|| ch == '\n'
	|| ch == '\r'
	|| ch == '\t';
}

inline std::string WizStdStringTrimLeft(const std::string& str)
{
    std::string t = str;
    for (std::string::iterator i = t.begin(); i != t.end(); i++)
	{
        if (!WizIsSpaceChar(*i))
		{
            t.erase(t.begin(), i);
            break;
        }
    }
    return t;
}

inline std::string WizStdStringTrimRight(const std::string& str)
{
    if (str.begin() == str.end()) {
        return str;
    }
    
    std::string t = str;
    for (std::string::iterator i = t.end() - 1; i != t.begin(); i--)
	{
        if (!WizIsSpaceChar(*i)) {
            t.erase(i + 1, t.end());
            break;
        }
    }
    return t;
}


inline std::string WizStdStringTrim(const std::string& str)
{
    std::string t = str;
    
    std::string::iterator i;
    for (i = t.begin(); i != t.end(); i++)
	{
        if (!WizIsSpaceChar(*i))
		{
            t.erase(t.begin(), i);
            break;
        }
    }
    
    if (i == t.end())
	{
        return t;
    }
    
    for (i = t.end() - 1; i != t.begin(); i--)
	{
        if (!WizIsSpaceChar(*i))
		{
            t.erase(i + 1, t.end());
            break;
        }
    }
    
    return t;
}

inline std::string WizGetCurrentTimeSQLString()
{
	time_t tNow;
	time(&tNow);
	//
	struct tm* ptm = localtime(&tNow);
	//
	int year = 1900 + ptm->tm_year;
	int month = 1 + ptm->tm_mon;
	int day = ptm->tm_mday;
	int hour = ptm->tm_hour;
	int minute = ptm->tm_min;
	int second = ptm->tm_sec;
	//
	char buffer[40];
	sprintf(buffer, "%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second);
	//
	return std::string(buffer);
}

inline std::string WizNSStringToStdString(NSString* str)
{
    return [str UTF8String];
}
inline NSString* WizStdStringToNSString(const std::string& str)
{
    return  [NSString stringWithUTF8String:str.c_str()];
}
inline NSString* WizCStringToNSString(const char* str)
{
    return [NSString stringWithUTF8String:str];
}

inline const char* WizNSStringToCString(NSString* str)
{
    if (str == nil) {
        return "";
    }
    return [str UTF8String];
}
inline NSURL* WizStdStringToNSURL(const std::string& str)
{
    return [NSURL URLWithString:WizStdStringToNSString(str)];
}
inline std::string WizIntToStdString(int n)
{
	char sz[20] = {0};
	sprintf(sz, "%d", n);
	return std::string(sz);
}
inline int WizStringToInt(const char* value)
{
    return atoi(value);
}

inline std::string WizDoubleToStSring(double d)
{
    std::stringstream doubleStr;
    doubleStr << d;
    return doubleStr.str();
}

