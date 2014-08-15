//
//  HttpResponse.m
//  HttpUtil
//
//  Created by DLL on 14-5-26.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import "DLLHTTPResponse.h"

@implementation DLLHTTPResponse

@synthesize statusCode = _statusCode;
@synthesize responseString = _responseString;
@synthesize responseData = _responseData;
@synthesize headers = _headers;


- (instancetype)initWithStatusCode:(NSInteger)statusCode responseData:(NSData *)responseData stringEncoding:(NSStringEncoding)stringEncoding responseHeaders:(NSDictionary *)headers responseString:(NSString *)responseString
{
    self = [super init];
    if (self) {
        _statusCode = statusCode;
        _responseData = [responseData retain];
        _responseString = [responseString copy];
        _headers = [headers copy];
    }
    return self;
}

- (void)dealloc
{
    [_responseData release];
    [_responseString release];
    [_headers release];
    [super dealloc];
}

@end
