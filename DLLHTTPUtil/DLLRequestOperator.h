//
//  DLLRequestOperator.h
//  DLLHTTPUtil
//
//  Created by DLL on 15/3/25.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLLHTTPRequest.h"



@interface DLLRequestOperator : NSObject {
    DLLHTTPResponse *_response;
    DLLHTTPRequest *_request;
}

@property (assign, nonatomic) DLLHTTPRequest *request;
@property (readonly, nonatomic) DLLHTTPResponse *response;

- (void)startPost;

- (void)startGet;

- (void)cancel;

- (void)reportRequestEnd;

@end

