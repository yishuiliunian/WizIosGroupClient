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
#import "XMLRPCConnection.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"

@interface XMLRPCConnection (XMLRPCConnectionPrivate)

- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data;
- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error;
- (void)connectionDidFinishLoading: (NSURLConnection *)connection;

@end

#pragma mark -

@implementation XMLRPCConnection


@synthesize connection;
@synthesize delegate;
@synthesize request;
@synthesize retData;

- (id)initWithXMLRPCRequest: (XMLRPCRequest *)req delegate: (id) callback;
{
	if (self = [super init])
	{
		self.connection = [[[NSURLConnection alloc] initWithRequest: [req request] delegate: self] autorelease];
		self.delegate = callback;
		self.request = req;
		//
		if (self.connection == nil)
		{
			if ([self.delegate respondsToSelector: @selector(xmlrpcDone:isSucceeded:retObject:forMethod:)])
			{
				NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Connection error. Failed to init NSURLConnection", NSLocalizedDescriptionKey, nil];
				NSError* err = [[NSError errorWithDomain:@"come.effigent.iphone.parseerror" code:-1 userInfo:usrInfo] retain];
				
				[self.delegate xmlrpcDone: self isSucceeded: NO retObject:err forMethod: [req method]];
                [err release];
			}
			//
			return nil;
		}
		//
		self.retData = [[[NSMutableData alloc] init] autorelease];
	}
	return self;
}

#pragma mark -

+ (XMLRPCConnection*)sendAsynchronousXMLRPCRequest: (XMLRPCRequest *)request delegate: (id) delegate;
{
    return [[[XMLRPCConnection alloc] initWithXMLRPCRequest:request delegate:delegate] autorelease];
}

#pragma mark -



- (void)cancel
{
    [self.connection cancel];
    self.connection = nil;
//    if (self.delegate)
//    {
//        NSError* error= [NSError errorWithDomain:WizErrorDomain code:NSUserCancelError userInfo:nil];
//        [self.delegate xmlrpcDone: self isSucceeded: NO retObject:error forMethod: [self.request method]];
//    }
    self.delegate = nil;
}

#pragma mark -

- (void)dealloc
{
	[connection release];
    connection = nil;
	[delegate release];
	[request release];
	[retData release];
	//
	[super dealloc];
}

@end

#pragma mark -

@implementation XMLRPCConnection (XMLRPCConnectionPrivate)


- (void)connection: (NSURLConnection *)connection didReceiveData: (NSData *)data
{
	[self.retData appendData: data];
}

- (void)connection: (NSURLConnection *)connection didFailWithError: (NSError *)error
{
	if ([self.delegate respondsToSelector: @selector(xmlrpcDone:isSucceeded:retObject:forMethod:)])
	{
		[self.delegate xmlrpcDone: self isSucceeded: NO retObject:error forMethod: [self.request method]];
	}
	//
}

- (void)connectionDidFinishLoading: (NSURLConnection *)connection
{
	if ([self.delegate respondsToSelector: @selector(xmlrpcDone:isSucceeded:retObject:forMethod:)])
	{
		XMLRPCResponse *response = [[XMLRPCResponse alloc] initWithData: self.retData];
        //wiz-dzpqzb-test
		NSObject* retObject = response.object;
		NSString* method = [self.request method];
		BOOL succeeded = !response.fault && !response.parseError && ![retObject isKindOfClass:[NSError class]];
		[self.delegate xmlrpcDone: self isSucceeded: succeeded retObject:retObject forMethod: method];
		[response release];
	}
	//
}

@end