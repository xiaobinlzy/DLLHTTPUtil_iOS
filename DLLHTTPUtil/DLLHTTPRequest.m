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
@synthesize requestStatus = _requestStatus;
@synthesize params = _params;


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
        _requestStatus = DLLHTTPRequestStatePrepare;
        _responseEncoding = NSUTF8StringEncoding;
    }
    return self;
}

+ (instancetype)requestWithURL:(NSString *)url
{
    id request = [[DLLHTTPRequest alloc] initWithURL:url];
    return [request autorelease];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@", [super description], self.url];
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
- (void)setRequestHeaders:(NSDictionary *)headers
{
    [_requestHeaders release];
    _requestHeaders = [[NSMutableDictionary alloc] initWithDictionary:headers];
}

- (NSDictionary *)requestHeaders
{
    return _requestHeaders;
}

- (void)addRequestHeader:(NSString *)value forKey:(NSString *)key
{
    if (!_requestHeaders) {
        _requestHeaders = [[NSMutableDictionary alloc] init];
    }
    [_requestHeaders setObject:value forKey:key];
}

- (void)retry
{
    if (self.requestStatus == DLLHTTPRequestStateDone || self.requestStatus == DLLHTTPRequestStateCancel || self.requestStatus == DLLHTTPRequestStatePrepare) {
        _requestStatus = DLLHTTPRequestStatePrepare;
        switch (self.requestMethod) {
            case DLLHTTPRequestMethodPost:
                [self startPostRequest];
                break;
            case DLLHTTPRequestMethodGet:
                [self startGetRequest];
                break;
            default:
                break;
        }
    } else {
        NSLog(@"请求必须已经完成，才可以重试");
    }
}

- (void)startGetRequest
{
    @synchronized (self) {
        _requestMethod = DLLHTTPRequestMethodGet;
        if (_requestStatus == DLLHTTPRequestStatePrepare) {
            _requestStatus = DLLHTTPRequestStateExecuting;
            [self onRequestStart];
            if ([self.url hasPrefix:@"https://"]) {
                
                [[self createAFNetworkingManager] GET:_url parameters:_params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [_response release];
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    [self reportFinish];
                    [self autorelease];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [_response release];
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    [self reportFailed:error];
                    [self autorelease];
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
        _requestMethod = DLLHTTPRequestMethodPost;
        if (_requestStatus == DLLHTTPRequestStatePrepare) {
            _requestStatus = DLLHTTPRequestStateExecuting;
            [self onRequestStart];
            if ([self.url hasPrefix:@"https://"]) {
                [[self createAFNetworkingManager] POST:_url parameters:_params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [_response release];
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    [self reportFinish];
                    [self autorelease];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [_response release];
                    _response = [[DLLHTTPResponse alloc] initWithStatusCode:operation.response.statusCode responseData:operation.responseData stringEncoding:operation.responseStringEncoding responseHeaders:nil responseString:operation.responseString];
                    [self reportFailed:error];
                    [self autorelease];
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
    [_requestPointer release];
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
        if (_requestStatus == DLLHTTPRequestStateExecuting) {
            _requestStatus = DLLHTTPRequestStateCancel;
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
    [_response release];
    _response = [[DLLHTTPResponse alloc] initWithStatusCode:request.responseStatusCode responseData:request.responseData stringEncoding:request.responseEncoding responseHeaders:request.responseHeaders responseString: request.responseString];
    [self reportFinish];
    [self autorelease];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_response release];
    _response = [[DLLHTTPResponse alloc] initWithStatusCode:request.responseStatusCode responseData:request.responseData stringEncoding:request.responseEncoding responseHeaders:request.responseHeaders responseString:request.responseString];
    [self reportFailed:request.error];
    [self autorelease];
}


- (void)reportFinish
{
    if (_requestStatus != DLLHTTPRequestStateExecuting) {
        return;
    }
    _requestStatus = DLLHTTPRequestStateDone;
    if (_delegate && [_delegate respondsToSelector:@selector(requestFinished:responseString:)]) {
        [_delegate requestFinished:self responseString:_response.responseString];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
        [_delegate requestEnd:self];
    }
    
}

- (void)reportFailed:(NSError *)error
{
    if (_requestStatus != DLLHTTPRequestStateExecuting) {
        return;
    }
    _requestStatus = DLLHTTPRequestStateDone;
    if (_delegate && [_delegate respondsToSelector:@selector(requestFailed:error:)]) {
        [_delegate requestFailed:self error:error];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
        [_delegate requestEnd:self];
    }
    
}

@end
