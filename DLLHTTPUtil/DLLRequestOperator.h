//
//  DLLRequestOperator.h
//  DLLHTTPUtil
//
//  Created by DLL on 15/3/25.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLLHTTPRequest.h"


@protocol DLLRequestOoperatorReporter <NSObject>

- (void)reportFinish;

- (void)reportFailed:(NSError *)error;

@end


@interface DLLRequestOperator : NSObject {
    DLLHTTPResponse *_response;
    DLLHTTPRequest<DLLRequestOoperatorReporter> *_reporter;
}

@property (assign, nonatomic) DLLHTTPRequest<DLLRequestOoperatorReporter> *reporter;
@property (readonly, nonatomic) DLLHTTPResponse *response;

- (void)startPost;

- (void)startGet;

- (void)cancel;

- (void)reportRequestEnd;

@end

