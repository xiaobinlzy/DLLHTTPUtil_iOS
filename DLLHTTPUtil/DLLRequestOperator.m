//
//  DLLRequestOperator.m
//  DLLHTTPUtil
//
//  Created by DLL on 15/3/25.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLRequestOperator.h"

@implementation DLLRequestOperator

@synthesize request = _request;
@synthesize response = _response;


- (void)startGet {
    [_request retain];
}

- (void)startPost {
    [_request retain];
}

- (void)cancel {
    [self reportRequestEnd];
}

- (void)reportRequestEnd {
    [_request autorelease];
}

- (void)dealloc {
    [_response release];
    [super dealloc];
}

@end
