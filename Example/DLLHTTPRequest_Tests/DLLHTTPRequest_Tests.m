//
//  DLLHTTPRequest_Tests.m
//  DLLHTTPRequest_Tests
//
//  Created by DLL on 2016/11/7.
//  Copyright © 2016年 xiaobinlzy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <DLLHTTPRequest/DLLHTTPRequest.h>

@interface DLLHTTPRequest_Tests : XCTestCase

@end

@implementation DLLHTTPRequest_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSString *paramString = @"abc=123=456";
    NSDictionary *result = [DLLHTTPUtil paramsOfURLParameters:paramString withEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", result);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
