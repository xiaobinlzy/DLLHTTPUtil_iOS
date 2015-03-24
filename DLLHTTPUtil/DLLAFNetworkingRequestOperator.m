//
//  DLLAFNetworkingRequestOperator.m
//  DLLHTTPUtil
//
//  Created by DLL on 15/3/25.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLAFNetworkingRequestOperator.h"
#import "DLLHTTPUtil.h"

@implementation DLLAFNetworkingRequestOperator {
    AFHTTPRequestOperationManager *_manager;    // weak
}

- (void)startGet {
    [super startGet];
    _manager = [self createAFNetworkingManager];
    [_manager GET:_request.url parameters:_request.params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinishWithOperation:operation responseObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFailedWithOperation:operation error:error];
    }];
}

- (void)startPost {
    [super startPost];
    _manager = [self createAFNetworkingManager];
    [_manager POST:_request.url parameters:_request.params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self requestFinishWithOperation:operation responseObject:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self requestFailedWithOperation:operation error:error];

    }];
}

- (void)requestFinishWithOperation:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject {
    _manager = nil;
    [_response release];
    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:operation.response.allHeaderFields responseString:operation.responseString];
    [_request reportFinish];
    [self reportRequestEnd];
}

- (void)requestFailedWithOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    _manager = nil;
    [_response release];
    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:operation.response.allHeaderFields responseString:operation.responseString];
    [_request reportFailed:error];
    [self reportRequestEnd];
}

- (void)cancel {
    [super cancel];
    [_manager.operationQueue cancelAllOperations];
}

- (AFHTTPRequestOperationManager *)createAFNetworkingManager {
    AFSecurityPolicy *securityPolicy = [DLLHTTPUtil defaultSecurityPolciy];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy = securityPolicy;
    manager.requestSerializer.timeoutInterval = _request.timeoutIntervel;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    for (NSString *key in _request.requestHeaders) {
        [manager.requestSerializer setValue:[_request.requestHeaders objectForKey:key] forHTTPHeaderField:key];
    }
    NSURLCredential *credential = [DLLHTTPUtil defaultCredential];
    if (credential != nil) {
        manager.credential = credential;
    }
    
    manager.responseSerializer.stringEncoding = _request.responseEncoding;
    return manager;
}

@end
