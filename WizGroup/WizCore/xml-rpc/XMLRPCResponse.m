//
//  Cocoa XML-RPC Client Framework
//  XMLRPCConnection.m
//
//  Created by Eric J. Czarny on Thu Jan 15 2004.
//  Copyright (c) 2004 Divisible by Zero.
//

//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without 
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or 
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "XMLRPCResponse.h"
#import "GDataXMLNode.h"
#import "XMLRPCExtensions.h"
#import "NSString+WizString.h"


@implementation XMLRPCResponse


@synthesize object;
@synthesize fault;
@synthesize parseError;


-(id) reportParserError
{
	NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Parse Error. XML-RPC responsed.", NSLocalizedDescriptionKey, nil];
	return [NSError errorWithDomain:GDataParaseErrorDomain  code:GDataParaseErrorCodeNormal userInfo:usrInfo] ;
}


-(id) reportCallError: (NSString*)msg faultCode:(int)faultCode
{
	NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:msg, NSLocalizedDescriptionKey, nil];
	return [NSError errorWithDomain:WizErrorDomain code:faultCode userInfo:usrInfo];
}


-(id) decodeStructNode: (GDataXMLNode*) nodeStruct
{
	NSMutableDictionary* ret = [NSMutableDictionary dictionary];
	//
	NSArray* children = [nodeStruct children];
	//
	for (int i = 0; i < [children count]; i++)
	{
		GDataXMLNode* nodeMember = [children objectAtIndex:i];
		NSString* childNodeNname = [nodeMember name];
		if (![childNodeNname isEqualToString:@"member"])
			return [self reportParserError];
		//
		GDataXMLNode* nodeName = [nodeMember childAtIndex:0];
		if (!nodeName)
			return [self reportParserError];
		GDataXMLNode* nodeValue = [nodeMember childAtIndex:1];
		if (!nodeValue)
			return [self reportParserError];
		//
		id value = [self decodeValueNode: nodeValue];
		if ([value isKindOfClass: [NSError class]])
			return value;
		NSString* memberName = [nodeName stringValue];
		[ret setValue:value forKey:memberName];
	}
	//
	return ret;
}

-(id) decodeArrayNode: (GDataXMLNode*) nodeArray
{
	GDataXMLNode* nodeData = [nodeArray childAtIndex:0];
	if (!nodeData)
	{
		return [self reportParserError];
	}
	//
	NSMutableArray* ret = [NSMutableArray array];
	//
	NSArray* children = [nodeData children];
	//
	for (int i = 0; i < [children count]; i++)
	{
		GDataXMLNode* nodeValue = [children objectAtIndex:i];
		NSString* childNodeNname = [nodeValue name];
		if (![childNodeNname isEqualToString:@"value"])
			return [self reportParserError];
		//
		id value = [self decodeValueNode: nodeValue];
		if ([value isKindOfClass: [NSError class]])
			 return value;
		//
		[ret addObject:value];
	}
	//
	return ret;
}


-(id) decodeValueNode: (GDataXMLNode*) nodeValue
{
	NSString* nodeName = [nodeValue name];
	if (![nodeName isEqualToString:@"value"])
	{
		return [self reportParserError];
	}
	//
	int childCount = [nodeValue childCount];
	if (0 == childCount)
	{
		return [nodeValue stringValue];
	}
	else if (childCount > 1)
	{
		return [self reportParserError];
	}
	//
	GDataXMLNode* nodeData = [nodeValue childAtIndex:0];
	if (!nodeData)
	{
		return [self reportParserError];
	}
	//
	if (GDataXMLTextKind == [nodeData kind] )
	{
		return [nodeData stringValue];
	}
	//
	NSString* valueType = [nodeData name];
	if ([valueType isEqualToString:@"string"])
	{
		return [nodeData stringValue];
	}
	else if ([valueType isEqualToString:@"int"]
			 || [valueType isEqualToString:@"i4"])
	{
		NSString* val = [nodeData stringValue];
		return [NSNumber numberWithInt: [val intValue]];
	}
	else if ([valueType isEqualToString:@"boolean"]
			 || [valueType isEqualToString:@"bool"])
	{
		NSString* val = [nodeData stringValue];
		BOOL b =  ([val isEqualToString:@"true"]
				  || [val isEqualToString:@"1"]) ? YES : NO;
		return [NSNumber numberWithBool:b];
	}
	else if ([valueType isEqualToString:@"double"])
	{
		NSString* val = [nodeData stringValue];
		return [NSNumber numberWithDouble: [val doubleValue]];
	}
	else if ([valueType isEqualToString:@"base64"])
	{
		NSString* val = [nodeData stringValue];
		return [NSData dataWithBase64EncodedString: val];
	}
	else if ([valueType isEqualToString:@"dateTime.iso8601"])
	{
		NSString* val = [nodeData stringValue];
		//
		NSString* sqlTime = [val iso8601TimeToStringSqlTimeString];
		//
        static NSDateFormatter* formatter = nil;
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        NSDate* date = [formatter dateFromString:sqlTime];
        return date ;
	}
	else if ([valueType isEqualToString:@"array"])
	{
		return [self decodeArrayNode: nodeData];
	}
	else if ([valueType isEqualToString:@"struct"])
	{
		return [self decodeStructNode: nodeData];
	}
	else if ([valueType isEqualToString:@"ex:i8"])
	{
		return [nodeData stringValue];
	}
	else if ([valueType isEqualToString:@"ex:nil"])
	{
		return nil;
	}
	else {
		return [self reportParserError];
	}
	//
	return [self reportParserError];
}

-(id) decodeXML: (NSData*) data fault: (BOOL*)pvbFault
{
    
    static NSString* documentDirectory= nil;
    if (nil == documentDirectory) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentDirectory = [[paths objectAtIndex:0] retain];
    }
	NSString* filename = [documentDirectory stringByAppendingPathComponent:@"xml-rpc-response.xml"];
	[data writeToFile:filename atomically:NO];
	//
	*pvbFault = NO;
	//
	NSString* str = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

	NSError* error;
	GDataXMLDocument* doc = [[[GDataXMLDocument alloc] initWithXMLString:str options:0 error:&error] autorelease];
	[str release];
	//
	
	GDataXMLElement* elem = [doc rootElement];
	//
	GDataXMLNode* nodeChild = [elem childAtIndex:0];
	if (!nodeChild)
	{
		return [self reportParserError];
	}
	NSString* childName = [nodeChild name];
	if ([childName isEqualToString:@"fault"])
	{
		*pvbFault = YES;
		//
		GDataXMLNode* nodeValue = [nodeChild childAtIndex:0];
		if (!nodeValue)
		{
			return [self reportParserError];
		}
		//
		NSDictionary* error = [self decodeValueNode: nodeValue];
		//
        NSNumber* faultCode = [error valueForKey:@"faultCode"];
		NSString* msg = [error valueForKey:@"faultString"];
		//
		return [self reportCallError:msg faultCode:[faultCode intValue]];
	}
	else if ([childName isEqualToString:@"params"])
	{
		GDataXMLNode* nodeParam = [nodeChild childAtIndex:0];
		if (!nodeParam)
		{
			return [self reportParserError];
		}
		//
		GDataXMLNode* nodeValue = [nodeParam childAtIndex:0];
		if (!nodeValue)
		{
			return [self reportParserError];
		}
		//
		return [self decodeValueNode: nodeValue];
	}
	doc = nil;
	return nil;

}

- (id)initWithData: (NSData *)data
{
	if (self = [super init])
	{
		parseError = NO;
		fault = NO;
		//
		BOOL isFault = NO;
		//
		self.object = [self decodeXML:data fault:&isFault] ;
		//
		if( [self.object isKindOfClass:[NSError class]] )
		{
			parseError = TRUE;
		}
		//
		fault = isFault;
	}
	
	return self;
}

#pragma mark -

- (NSNumber *)faultCode
{
	if (self.fault)
	{
		return [self.object objectForKey: @"faultCode"];
	}
	
	return nil;
}

- (NSString *)faultString
{
	if (self.fault)
	{
		return [self.object objectForKey: @"faultString"];
	}
	
	return nil;
}


#pragma mark -

- (void)dealloc
{
	[object release];
	
	[super dealloc];
}

@end