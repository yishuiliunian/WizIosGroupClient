//
//  CommonString.m
//  Wiz
//
//  Created by Wei Shijun on 3/23/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "CommonString.h"
NSString* getTagDisplayName(NSString* tagName)
{
    if ([tagName isEqualToString:@"$public-documents$"])
        return WizTagPublic;
    else if ([tagName isEqualToString:@"$share-with-friends$"])
        return WizTagProtected;
    else
        return tagName;
    
    
}