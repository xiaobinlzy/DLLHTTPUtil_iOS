//
//  HttpRequest.m
//  HttpUtil
//
//  Created by DLL on 14-5-26.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import "DLLHTTPRequest.h"
#import "DLLHTTPResponse.h"
#import "ASIHTTPRequest.h"
#import "DLLHTTPUtil.h"

@interface DLLHTTPRequest() <ASIHTTPRequestDelegate>

@end

@implementation DLLHTTPRequest {
    ASIHTTPRequest *_requestPointer;
}

static NSUInteger gDefaultTimeoutIntervel = 10;

@synthesize url = _url;
@synthesize response = _response;
@synthesize timeoutIntervel = _timeoutIntervel;
@synthesize delegate = _delegate;
@synthesize tag = _tag;
@synthesize state = _state;
@synthesize params = _params;


#pragma mark - life cycle

- (instancetype)initWithURL:(NSString *)url
{
    self = [super init];
    if (self) {
        _url = [url retain];
        _timeoutIntervel = gDefaultTimeoutIntervel;
        _state = DLLHTTPRequestStatePrepare;
    }
    return self;
}

+ (instancetype)requestWithURL:(NSString *)url
{
    id request = [[DLLHTTPRequest alloc] initWithURL:url];
    return [request autorelease];
}

- (void)dealloc
{
    [_url release];
    [_response release];
    [_params release];
    [_requestPointer release];
    [super dealloc];
}

#pragma mark - methods
- (void)startGetRequest
{
    @synchronized (self) {
        if (_state == DLLHTTPRequestStatePrepare) {
            _state = DLLHTTPRequestStateExecuting;
            [self onRequestStart];
            if ([self.url hasPrefix:@"https://"]) {
                AFSecurityPolicy *securityPolicy = [DLLHTTPUtil defaultSecurityPolciy];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.securityPolicy = securityPolicy;
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                manager.requestSerializer.timeoutInterval = _timeoutIntervel;
                [manager GET:_url parameters:_params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if (_state != DLLHTTPRequestStateExecuting) {
                        [self autorelease];
                        return;
                    }
                    _state = DLLHTTPRequestStateDone;
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    if (_delegate && [_delegate respondsToSelector:@selector(requestFinished:responseString:)]) {
                        [_delegate requestFinished:self responseString:_response.responseString];
                    }
                    if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
                        [_delegate requestEnd:self];
                    }
                    [self autorelease];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if (_state != DLLHTTPRequestStateExecuting) {
                        [self autorelease];
                        return;
                    }
                    _state = DLLHTTPRequestStateDone;
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    if (_delegate && [_delegate respondsToSelector:@selector(requestFailed:error:)]) {
                        [_delegate requestFailed:self error:operation.error];
                    }
                    if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
                        [_delegate requestEnd:self];
                    }
                    [self autorelease];
                }];
            } else {
                [[self createASIHTTPGetRequestWithParams:self.params] startAsynchronous];
            }
        }
    }
}

- (void)startPostRequest
{
    @synchronized (self) {
        if (_state == DLLHTTPRequestStatePrepare) {
            _state = DLLHTTPRequestStateExecuting;
            [self onRequestStart];
            if ([self.url hasPrefix:@"https://"]) {
                AFSecurityPolicy *securityPolicy = [DLLHTTPUtil defaultSecurityPolciy];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                manager.securityPolicy = securityPolicy;
                manager.requestSerializer.timeoutInterval = _timeoutIntervel;

                [manager POST:_url parameters:_params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    
                } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if (_state != DLLHTTPRequestStateExecuting) {
                        [self autorelease];
                        return;
                    }
                    _state = DLLHTTPRequestStateDone;
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    if (_delegate && [_delegate respondsToSelector:@selector(requestFinished:responseString:)]) {
                        [_delegate requestFinished:self responseString:_response.responseString];
                    }
                    if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
                        [_delegate requestEnd:self];
                    }
                    [self autorelease];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    if (_state != DLLHTTPRequestStateExecuting) {
                        [self release];
                        return;
                    }
                    _state = DLLHTTPRequestStateDone;
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    if (_delegate && [_delegate respondsToSelector:@selector(requestFailed:error:)]) {
                        [_delegate requestFailed:self error:operation.error];
                    }
                    if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
                        [_delegate requestEnd:self];
                    }
                    [self autorelease];
                }];
            } else {
                [[self createASIHTTPPostRequestWithParams:self.params] startAsynchronous];
            }
        }
    }
}

- (AFHTTPRequestOperation *)createAfHttpRequestOperation
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
    request.timeoutInterval = _timeoutIntervel;
    request.HTTPMethod = @"POST";
    [request setHTTPShouldHandleCookies:YES];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    return [operation autorelease];
}

- (ASIHTTPRequest *)createASIHTTPGetRequestWithParams:(NSDictionary *)params
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[DLLHTTPUtil urlFormWithHostAddress:_url andParameters:params]];
    request.allowCompressedResponse = YES;
    _requestPointer = [request retain];
    request.delegate = self;
    request.timeOutSeconds = _timeoutIntervel;
    return request;
}

- (ASIHTTPRequest *)createASIHTTPPostRequestWithParams:(NSDictionary *)params
{
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:_url]];
    request.allowCompressedResponse = YES;
    _requestPointer = [request retain];
    request.delegate = self;
    request.timeOutSeconds = _timeoutIntervel;
    for (NSString *key in params) {
        [request addPostValue:[params objectForKey:key] forKey:key];
    }
    return [request autorelease];
}

+ (void)setDefaultTimeoutIntervel:(NSUInteger)timeoutIntervel
{
    gDefaultTimeoutIntervel = timeoutIntervel;
}

+ (NSInteger)defaultTimeoutIntervel
{
    return gDefaultTimeoutIntervel;
}


- (void)clearDelegateAndCancel
{
    @synchronized (self) {
        if (_state == DLLHTTPRequestStateExecuting) {
            _state = DLLHTTPRequestStateCancel;
            if (_requestPointer) {
                [_requestPointer clearDelegatesAndCancel];
                [self autorelease];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
                [_delegate requestEnd:self];
            }
            _delegate = nil;
        }
    }
}

- (void)onRequestStart
{
    if (_delegate && [_delegate respondsToSelector:@selector(requestStart:)]) {
        [_delegate requestStart:self];
    }
    [self retain];
}

#pragma mark - asi http request delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    @synchronized (self) {
        if (_state != DLLHTTPRequestStateExecuting) {
            return;
        }
        _state = DLLHTTPRequestStateDone;
        _response = [[DLLHTTPResponse alloc] initWithStatusCode:request.responseStatusCode responseData:request.responseData stringEncoding:request.responseEncoding responseHeaders:request.responseHeaders responseString: request.responseString];
        if (_delegate && [_delegate respondsToSelector:@selector(requestFinished:responseString:)]) {
            [_delegate requestFinished:self responseString:request.responseString];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
            [_delegate requestEnd:self];
        }
        [self autorelease];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    @synchronized (self) {
        if (_state != DLLHTTPRequestStateExecuting) {
            return;
        }
        _state = DLLHTTPRequestStateDone;
        _response = [[DLLHTTPResponse alloc] initWithStatusCode:request.responseStatusCode responseData:request.responseData stringEncoding:request.responseEncoding responseHeaders:request.responseHeaders responseString:request.responseString];
        if (_delegate && [_delegate respondsToSelector:@selector(requestFailed:error:)]) {
            [_delegate requestFailed:self error:request.error];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
            [_delegate requestEnd:self];
        }
        [self autorelease];
    }
}

@end
