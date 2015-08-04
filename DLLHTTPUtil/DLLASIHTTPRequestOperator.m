//
//  DLLASIHTTPRequestOperator.m
//  DLLHTTPUtil
//
//  Created by DLL on 15/3/25.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLASIHTTPRequestOperator.h"
#import "DLLHTTPUtil.h"

@interface DLLASIHTTPRequestOperator () <ASIHTTPRequestDelegate>

@end


@implementation DLLASIHTTPRequestOperator {
    ASIHTTPRequest *_asiRequest;
}

- (void)startGet {
    [super startGet];
    _asiRequest = [self createASIHttpRequestWithMethod:DLLHTTPRequestMethodGet];
    [_asiRequest startAsynchronous];
}

- (void)startPost {
    [super startPost];
    _asiRequest = [self createASIHttpRequestWithMethod:DLLHTTPRequestMethodPost];
    [_asiRequest startAsynchronous];
}

- (ASIHTTPRequest *)createASIHttpRequestWithMethod:(DLLHTTPRequestMethod)method {
    ASIHTTPRequest *request = nil;
    switch (method) {
        case DLLHTTPRequestMethodGet:
            request = [ASIHTTPRequest requestWithURL:[DLLHTTPUtil urlFormWithHostAddress:_request.url andParameters:_request.params]];
            break;
        case DLLHTTPRequestMethodPost:
            request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:_request.url]];
            for (NSString *key in _request.params) {
                id value = [_request.params objectForKey:key];
                if ([value isKindOfClass:[NSArray class]]) {
                    NSArray * array = (NSArray *) value;
                    for (id item in array) {
                        [(ASIFormDataRequest *)request addPostValue:item forKey:key];
                    }
                } else {
                    [(ASIFormDataRequest *)request addPostValue:value forKey:key];
                }
            }
            
            break;
        default:
            break;
    }
    request.delegate = self;
    request.timeOutSeconds = _request.timeoutIntervel;
    request.defaultResponseEncoding = _request.responseEncoding;
    request.allowCompressedResponse = YES;
    for (NSString *key in _request.requestHeaders) {
        [request addRequestHeader:key value:[_request.requestHeaders objectForKey:key]];
    }
    return request;
}

- (void)cancel {
    [super cancel];
    [_asiRequest clearDelegatesAndCancel];
}

#pragma mark - asi http request delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [_response release];
    _response = [[DLLHTTPResponse alloc] initWithStatusCode:request.responseStatusCode responseData:request.responseData stringEncoding:request.responseEncoding responseHeaders:request.responseHeaders responseString: request.responseString];
    [_request reportFinish];
    [self reportRequestEnd];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_response release];
    _response = [[DLLHTTPResponse alloc] initWithStatusCode:request.responseStatusCode responseData:request.responseData stringEncoding:request.responseEncoding responseHeaders:request.responseHeaders responseString:request.responseString];
    [_request reportFailed:request.error];
    [self reportRequestEnd];
}


@end
