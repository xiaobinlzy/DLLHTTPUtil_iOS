//
//  DLLHTTPRequestTests.m
//  DLLHTTPRequestTests
//
//  Created by xiaobinlzy on 10/21/2016.
//  Copyright (c) 2016 xiaobinlzy. All rights reserved.
//
#import <DLLHTTPRequest/DLLHTTPRequest.h>

@import XCTest;

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    __block BOOL running = YES;
    DLLHTTPRequest *request = [DLLHTTPRequest requestWithURLString:@"https://github.com"];
    [request startGetRequestWithCallback:^(DLLHTTPRequest *request, NSString *responseString, NSError *error) {
        NSLog(@"%@", error ? : responseString);
        running = NO;
    }];
    while (running) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

@end

