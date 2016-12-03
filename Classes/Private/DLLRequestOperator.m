//
//  DLLRequestOperator.m
//  DLLHTTPUtil
//
//  Created by DLL on 15/3/25.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLRequestOperator.h"

@interface DLLRequestOperator ()
@property (strong, nonatomic) DLLHTTPRequest<DLLRequestOoperatorReporter> *retainReporter;
@end

@implementation DLLRequestOperator {
}

@synthesize reporter = _reporter;
@synthesize response = _response;

- (void)startGet {
    self.retainReporter = self.reporter;
}

- (void)startPost {
    self.retainReporter = self.reporter;
}

- (void)startPostForm {
    self.retainReporter = self.reporter;
}

- (void)cancel {
    [self reportRequestEnd];
}

- (void)reportRequestEnd {
    __autoreleasing id autorelease = self.retainReporter;
    self.retainReporter = nil;
    autorelease = nil;
}


@end
