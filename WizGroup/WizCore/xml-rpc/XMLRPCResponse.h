//
//  Cocoa XML-RPC Client Framework
//  XMLRPCResponse.h
//
//  Created by Eric Czarny on Wed Jan 14 2004.
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

#import <Foundation/Foundation.h>

@class GDataXMLNode;

@interface XMLRPCResponse : NSObject {
	id object;
	BOOL fault;
	BOOL parseError;
}

@property (nonatomic, retain) id object;
@property (readonly) BOOL fault;
@property (readonly) BOOL parseError;

- (id)initWithData: (NSData *)data;

- (NSNumber *)faultCode;
- (NSString *)faultString;

#pragma mark -
-(id) decodeValueNode: (GDataXMLNode*) nodeValue;
-(id) decodeArrayNode: (GDataXMLNode*) nodeArray;
-(id) decodeStructNode: (GDataXMLNode*) nodeStruct;


@end