//
//  DLLAFNetworkingRequestOperator.m
//  DLLHTTPUtil
//
//  Created by DLL on 15/3/25.
//  Copyright (c) 2015年 DLL. All rights reserved.
//

#import "DLLAFNetworkingRequestOperator.h"
#import "DLLHTTPUtil.h"
#import <AFNetworking/AFNetworking.h>

@implementation DLLAFNetworkingRequestOperator {
    AFHTTPSessionManager *_manager;
}

- (void)startGet {
    [super startGet];
    _manager = [self createAFNetworkingManager];
    [_manager GET:_reporter.url.absoluteString parameters:_reporter.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self requestFinishWithTask:task responseObject:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self requestFailedWithTask:task error:error];
    }];
}

- (void)startPost {
    [super startPost];
    _manager = [self createAFNetworkingManager];
    [_manager POST:_reporter.url.absoluteString parameters:_reporter.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self requestFinishWithTask:task responseObject:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self requestFailedWithTask:task error:error];
    }];
}

- (void)startPostForm {
    [super startPostForm];
    _manager = [self createAFNetworkingManager];
    
    NSMutableDictionary *files = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *params = [_reporter.params mutableCopy];
    for (NSString *key in _reporter.params) {
        if ([key hasPrefix:@"file_"] && key.length > 5) {
            NSString *name = [key substringFromIndex:5];
            [files setObject:[_reporter.params objectForKey:key] forKey:name];
            [params removeObjectForKey:key];
        } else {
            NSString *value = [_reporter.params objectForKey:key];
            if ([value isKindOfClass:NSString.class]) {
                [params setObject:value forKey:key];
            }
        }
    }
    [_manager POST:_reporter.url.absoluteString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString *name in files) {
            [formData appendPartWithFileURL:[NSURL fileURLWithPath:[files objectForKey:name]] name:name error:nil];
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self requestFinishWithTask:task responseObject:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self requestFailedWithTask:task error:error];
    }];
}

- (void)requestFinishWithTask:(NSURLSessionDataTask *)task responseObject:(id)responseObject {
    _manager = nil;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    _response = [[DLLHTTPResponse alloc] initWithStatusCode:httpResponse.statusCode responseData:responseObject stringEncoding:_reporter.responseEncoding responseHeaders:httpResponse.allHeaderFields responseString:[[NSString alloc] initWithData:responseObject encoding:_reporter.responseEncoding]];
    [_reporter reportFinish];
    [self reportRequestEnd];
}

- (void)requestFailedWithTask:(NSURLSessionDataTask *)task error:(NSError *)error {
    _manager = nil;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    _response = [[DLLHTTPResponse alloc] initWithStatusCode:httpResponse.statusCode responseData:nil stringEncoding:_reporter.responseEncoding responseHeaders:httpResponse.allHeaderFields responseString:nil];
    [_reporter reportFailed:error];
    [self reportRequestEnd];
}

- (void)cancel {
    [super cancel];
    _reporter = nil;
    [[_manager operationQueue] cancelAllOperations];
}

- (AFHTTPSessionManager *)createAFNetworkingManager {
    AFSecurityPolicy *securityPolicy = [DLLHTTPUtil defaultSecurityPolciy];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = securityPolicy;
    manager.requestSerializer.timeoutInterval = _reporter.timeoutIntervel;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLCredential *defaultCredential = [DLLHTTPUtil defaultCredential];
    if (defaultCredential) {
        [manager setTaskDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
            *credential = defaultCredential;
            return NSURLSessionAuthChallengeUseCredential;
        }];
    }
    for (NSString *key in _reporter.requestHeaders) {
        [manager.requestSerializer setValue:[_reporter.requestHeaders objectForKey:key] forHTTPHeaderField:key];
    }
    
    manager.responseSerializer.stringEncoding = _reporter.responseEncoding;
    return manager;
}

@end
