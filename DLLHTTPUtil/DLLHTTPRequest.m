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
@synthesize requestHeaders = _requestHeaders;


#pragma mark - life cycle

- (instancetype)initWithURL:(NSString *)url
{
    self = [self init];
    if (self) {
        _url = [url retain];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timeoutIntervel = gDefaultTimeoutIntervel;
        _state = DLLHTTPRequestStatePrepare;
        _responseEncoding = NSUTF8StringEncoding;
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
    [_requestHeaders release];
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
                [[self createAFNetworkingManager] GET:_url parameters:_params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    [self reportFinish];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    [self reportFailed:error];
                    NSLog(@"%@", operation.responseString);
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
                [[self createAFNetworkingManager] POST:_url parameters:_params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    [self reportFinish];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    [self reportFailed:error];
                }];
            } else {
                [[self createASIHTTPPostRequestWithParams:self.params] startAsynchronous];
            }
        }
    }
}

- (AFHTTPRequestOperationManager *)createAFNetworkingManager
{
    AFSecurityPolicy *securityPolicy = [DLLHTTPUtil defaultSecurityPolciy];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy = securityPolicy;
    manager.requestSerializer.timeoutInterval = _timeoutIntervel;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    manager.responseSerializer.stringEncoding = _responseEncoding;
    for (NSString *key in _requestHeaders) {
        [manager.requestSerializer setValue:[_requestHeaders objectForKey:key] forHTTPHeaderField:key];
    }
    NSURLCredential *credential = [DLLHTTPUtil defaultCredential];
    if (credential != nil) {
        manager.credential = credential;
    }
    
    manager.responseSerializer.stringEncoding = self.responseEncoding;
    return manager;
}


- (ASIHTTPRequest *)createASIHTTPGetRequestWithParams:(NSDictionary *)params
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[DLLHTTPUtil urlFormWithHostAddress:_url andParameters:params]];
    [self initializeASIHttpRequest:request];
    return request;
}

- (ASIHTTPRequest *)createASIHTTPPostRequestWithParams:(NSDictionary *)params
{
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:_url]];
    for (NSString *key in params) {
        [request addPostValue:[params objectForKey:key] forKey:key];
    }
    [self initializeASIHttpRequest:request];
    return [request autorelease];
}

- (void)initializeASIHttpRequest:(ASIHTTPRequest *)request
{
    request.delegate = self;
    request.timeOutSeconds = _timeoutIntervel;
    request.defaultResponseEncoding = self.responseEncoding;
    request.allowCompressedResponse = YES;
    for (NSString *key in _requestHeaders) {
        [request addRequestHeader:key value:[_requestHeaders objectForKey:key]];
    }
    _requestPointer = [request retain];
    
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
    _response = [[DLLHTTPResponse alloc] initWithStatusCode:request.responseStatusCode responseData:request.responseData stringEncoding:request.responseEncoding responseHeaders:request.responseHeaders responseString: request.responseString];
    [self reportFinish];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    _response = [[DLLHTTPResponse alloc] initWithStatusCode:request.responseStatusCode responseData:request.responseData stringEncoding:request.responseEncoding responseHeaders:request.responseHeaders responseString:request.responseString];
    [self reportFailed:request.error];
}

- (void)reportFinish
{
    if (_state != DLLHTTPRequestStateExecuting) {
        return;
    }
    _state = DLLHTTPRequestStateDone;
    if (_delegate && [_delegate respondsToSelector:@selector(requestFinished:responseString:)]) {
        [_delegate requestFinished:self responseString:_response.responseString];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
        [_delegate requestEnd:self];
    }
    [self autorelease];

}

- (void)reportFailed:(NSError *)error
{
    if (_state != DLLHTTPRequestStateExecuting) {
        return;
    }
    _state = DLLHTTPRequestStateDone;
    if (_delegate && [_delegate respondsToSelector:@selector(requestFailed:error:)]) {
        [_delegate requestFailed:self error:error];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
        [_delegate requestEnd:self];
    }
    [self autorelease];

}

@end
