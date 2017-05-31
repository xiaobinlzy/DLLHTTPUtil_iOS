//
//  HttpRequest.m
//  HttpUtil
//
//  Created by DLL on 14-5-26.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import "DLLHTTPRequest.h"
#import "DLLHTTPUtil.h"
#import "DLLAFNetworkingRequestOperator.h"

static NSSet<NSData *> * __trustedCertifications;
static BOOL __allowInvalideCertificates;
static BOOL __reusedConnection;

@interface DLLHTTPRequest() <DLLRequestOoperatorReporter>

@end

@implementation DLLHTTPRequest {
    dispatch_queue_t _requestQueue; // weak
    DLLRequestOperator *_operator;
}

static NSUInteger gDefaultTimeoutIntervel = 10;

@synthesize url = _url;
@synthesize timeoutIntervel = _timeoutIntervel;
@synthesize delegate = _delegate;
@synthesize tag = _tag;
@synthesize requestStatus = _requestStatus;
@synthesize params = _params;


#pragma mark - life cycle
+ (void)load {
    __reusedConnection = YES;
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [self init];
    if (self) {
        _url = [url copy];
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)urlString {
    self = [self initWithURL:[NSURL URLWithString:urlString]];
    if (self) {
    
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

+ (instancetype)requestWithURL:(NSURL *)url
{
    DLLHTTPRequest * request = [[DLLHTTPRequest alloc] initWithURL:url];
    return request;
}

+ (instancetype)requestWithURLString:(NSString *)urlString {
    DLLHTTPRequest *request = [[DLLHTTPRequest alloc] initWithURLString:urlString];
    return request;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@", [super description], [DLLHTTPUtil urlFormWithHostAddress:_url.absoluteString andParameters:_params].absoluteString];
}

#pragma mark - property
+ (void)setTrustedCertifications:(NSSet<NSData *> *)trustedCertifications {
    __trustedCertifications = [trustedCertifications copy];
}

+ (NSSet<NSData *> *)trustedCertifications {
    return [__trustedCertifications copy];
}

+ (BOOL)allowInvalideCertificates {
    return __allowInvalideCertificates;
}

+ (void)setAllowInvalideCertificates:(BOOL)allowInvalideCertificates {
    __allowInvalideCertificates = allowInvalideCertificates;
}

+ (void)setReuseConnection:(BOOL)reuseConnection {
    __reusedConnection = reuseConnection;
}

+ (BOOL)reuseConnection {
    return __reusedConnection;
}

#pragma mark - methods
- (void)setRequestHeaders:(NSDictionary *)headers
{
    _requestHeaders = [[NSMutableDictionary alloc] initWithDictionary:headers];
}

- (NSDictionary *)requestHeaders
{
    return _requestHeaders;
}

- (DLLHTTPResponse *)response {
    return _operator.response;
}

- (void)addRequestHeader:(NSString *)value forKey:(NSString *)key
{
    if (!_requestHeaders) {
        _requestHeaders = [[NSMutableDictionary alloc] init];
    }
    if (value && key) {
        [_requestHeaders setObject:value forKey:key];
    }
}

- (void)retry
{
    if (_requestQueue == NULL) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _requestQueue = dispatch_get_current_queue();
#pragma clang diagnostic pop
    }
    if (self.requestStatus == DLLHTTPRequestStateDone || self.requestStatus == DLLHTTPRequestStateCancel || self.requestStatus == DLLHTTPRequestStatePrepare) {
        _requestStatus = DLLHTTPRequestStatePrepare;
        switch (_requestMethod) {
            case DLLHTTPRequestMethodPost: {
                dispatch_async(_requestQueue, ^{
                    [self startPostRequest];
                });
                break;
            }
            case DLLHTTPRequestMethodGet: {
                dispatch_async(_requestQueue, ^{
                    [self startGetRequest];
                });
                break;
            }
            default:
                break;
        }
    } else {
        NSLog(@"请求必须已经完成，才可以重试");
    }
}

- (void)createOperator {
    _operator = nil;
    switch (_operatorType) {
        case DLLHTTPRequestOperatorTypeAFNetworking:
            _operator = [[DLLAFNetworkingRequestOperator alloc] init];
            break;
        default:
            break;
    }
    _operator.reporter = self;
}

- (void)startGetRequest
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    _requestQueue = dispatch_get_current_queue();
#pragma clang diagnostic pop
    if (_requestStatus == DLLHTTPRequestStatePrepare) {
        _requestStatus = DLLHTTPRequestStateExecuting;
        _requestMethod = DLLHTTPRequestMethodGet;
        [self onRequestStart];
        [self createOperator];
        [_operator startGet];
    }
}

- (void)startPostRequest
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    _requestQueue = dispatch_get_current_queue();
#pragma clang diagnostic pop
    if (_requestStatus == DLLHTTPRequestStatePrepare) {
        _requestStatus = DLLHTTPRequestStateExecuting;
        _requestMethod = DLLHTTPRequestMethodPost;
        [self onRequestStart];
        [self createOperator];
        [_operator startPost];
    }
}

- (void)startPostFormRequest {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    _requestQueue = dispatch_get_current_queue();
#pragma clang diagnostic pop
    if (_requestStatus == DLLHTTPRequestStatePrepare) {
        _requestStatus = DLLHTTPRequestStateExecuting;
        _requestMethod = DLLHTTPRequestMethodPostForm;
        [self onRequestStart];
        [self createOperator];
        [_operator startPostForm];
    }

}

- (void)startGetRequestWithCallback:(DLLHTTPCallback)callback {
    self.callback = callback;
    [self startGetRequest];
}

- (void)startPostRequestWithCallback:(DLLHTTPCallback)callback {
    self.callback = callback;
    [self startPostRequest];
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
    _delegate = nil;
    if (_callback) {
        _callback = nil;
    }
    if (_requestStatus == DLLHTTPRequestStateExecuting) {
        [_operator cancel];
        _requestStatus = DLLHTTPRequestStateCancel;
    }
}

- (void)onRequestStart
{
    if (_delegate && [_delegate respondsToSelector:@selector(requestStart:)]) {
        dispatch_async(_requestQueue, ^{
            [_delegate requestStart:self];
        });
    }
}


- (void)reportFinish
{
    if (_requestStatus != DLLHTTPRequestStateExecuting) {
        return;
    }
    _requestStatus = DLLHTTPRequestStateDone;
    dispatch_async(_requestQueue, ^{
        if (_delegate && [_delegate respondsToSelector:@selector(requestFinished:responseString:)]) {
            [_delegate requestFinished:self responseString:self.response.responseString];
        }
        if (_callback) {
            _callback(self, self.response.responseString, nil);
        }
        if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
            [_delegate requestEnd:self];
        }
    });
}

- (void)reportFailed:(NSError *)error
{
    if (_requestStatus != DLLHTTPRequestStateExecuting) {
        return;
    }
    _requestStatus = DLLHTTPRequestStateDone;
    dispatch_async(_requestQueue, ^{
        if (_delegate && [_delegate respondsToSelector:@selector(requestFailed:error:)]) {
            [_delegate requestFailed:self error:error];
        }
        
        if (_callback) {
            _callback(self, nil, error);
        }
        if (_delegate && [_delegate respondsToSelector:@selector(requestEnd:)]) {
            [_delegate requestEnd:self];
        }
    });
    NSLog(@"HTTP REQUEST FAILED: %@\nERROR: %@", self, error);
}

@end

@implementation NSURLRequest(HTTPS)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}

@end

