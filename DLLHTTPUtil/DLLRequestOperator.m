//
//  DLLRequestOperator.m
//  DLLHTTPUtil
//
//  Created by DLL on 15/3/25.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLRequestOperator.h"

@implementation DLLRequestOperator

@synthesize reporter = _reporter;
@synthesize response = _response;


- (void)startGet {
    [_reporter retain];
}

- (void)startPost {
    [_reporter retain];
}

- (void)cancel {
    [self reportRequestEnd];
}

- (void)reportRequestEnd {
    [_reporter autorelease];
}

- (void)dealloc {
    [_response release];
    [super dealloc];
}

@end
