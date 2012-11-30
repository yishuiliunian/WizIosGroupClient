/*
 *  WizMisc.cpp
 *  Wiz
 *
 *  Created by Wei Shijun on 3/2/11.
 *  Copyright 2011 WizBrother. All rights reserved.
 *
 */

#include "WizMisc.h"

#include <vector>
#include <fstream>
#include <string>


extern"C" bool IsEmptyString(const char* lpszStr)
{
	if (!lpszStr)
		return true;
	if (!*lpszStr)
		return true;
	return false;
}

static std::string g_strLogFileName;

extern "C" void SetLogFileName(const char* lpszFileName)
{
	g_strLogFileName = lpszFileName;
}

extern "C" const char* GetLogFileName()
{
	return g_strLogFileName.c_str();
}

extern "C" void TOLOG(const char* lpszText)
{
	if (IsEmptyString(GetLogFileName()))
		return;
	//
	std::ofstream outf(GetLogFileName(), std::ios::out | std::ios::app);
	if (outf.fail())
		return;
	//
	time_t now = 0;
	time(&now);
	struct tm* ptm = gmtime(&now);
	outf << asctime(ptm);
	//
	outf << lpszText << std::endl;
	//
	outf.close();
}

