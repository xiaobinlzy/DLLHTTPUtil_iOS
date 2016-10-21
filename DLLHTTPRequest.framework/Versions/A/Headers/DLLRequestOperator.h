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
    DLLHTTPRequest<DLLRequestOoperatorReporter> __weak *_reporter;
    DLLHTTPResponse *_response;
}

@property (weak, nonatomic) DLLHTTPRequest<DLLRequestOoperatorReporter> *reporter;
@property (readonly, nonatomic) DLLHTTPResponse *response;

- (void)startPost;

- (void)startGet;

- (void)startPostForm;

- (void)cancel;

- (void)reportRequestEnd;

@end

