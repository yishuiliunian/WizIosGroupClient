/*
 *  WizMisc.h
 *  Wiz
 *
 *  Created by Wei Shijun on 3/2/11.
 *  Copyright 2011 WizBrother. All rights reserved.
 *
 */

#ifndef _WIZMISC_H_
#define _WIZMISC_H_

#ifdef __cplusplus
extern "C" 
{
#endif
	
	void SetLogFileName(const char* lpszFileName);
	const char* GetLogFileName();
	//
	bool IsEmptyString(const char* lpszStr);
	void TOLOG(const char* lpszText);
	//
#define CHECK_POINTER(x)	if (!(x)) { TOLOG("#x is NULL"); return; }
#define CHECK_POINTER_RETURN(x, y)	if (!(x)) { TOLOG("#x is NULL"); return y; }
	
#define CHECK_STRING(x)	if (IsEmptyString((x))) { TOLOG("#x is empty string"); return; }
#define CHECK_STRING_RETURN(x, y)	if (IsEmptyString((x))) { TOLOG("#x is empty string"); return y; }
	
	
	
	
#ifdef __cplusplus
}
#endif
#endif //_WIZMISC_H_

