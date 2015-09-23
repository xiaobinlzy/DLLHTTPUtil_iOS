//
//  HttpRequest.m
//  HttpUtil
//
//  Created by DLL on 14-5-26.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import "DLLHTTPRequest.h"
#import "DLLHTTPResponse.h"
#import "DLLHTTPUtil.h"
#import "DLLAFNetworkingRequestOperator.h"
#import "DLLASIHTTPRequestOperator.h"
@interface DLLHTTPRequest()

@end

@implementation DLLHTTPRequest {
    dispatch_queue_t _queue;
    dispatch_queue_t _requestQueue;
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
        _queue = dispatch_queue_create("dllhttprequest.dispatch.queue", DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}

+ (instancetype)requestWithURL:(NSString *)url
{
    id request = [[DLLHTTPRequest alloc] initWithURL:url];
    return [request autorelease];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@", [super description], [DLLHTTPUtil urlFormWithHostAddress:_url andParameters:_params].absoluteString];
}

- (void)dealloc
{
    [_url release];
    [_params release];
    [_requestHeaders release];
    [_operator release];
    [_callback release];
    dispatch_release(_queue);
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

- (DLLHTTPResponse *)response {
    return _operator.response;
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
    if (_requestQueue == NULL) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        _requestQueue = dispatch_get_current_queue();
#pragma clang diagnostic pop
    }
    dispatch_async(_queue, ^{
        if (self.requestStatus == DLLHTTPRequestStateDone || self.requestStatus == DLLHTTPRequestStateCancel || self.requestStatus == DLLHTTPRequestStatePrepare) {
            _requestStatus = DLLHTTPRequestStatePrepare;
            switch (self.requestMethod) {
                case DLLHTTPRequestMethodPost:
                    dispatch_async(_requestQueue, ^{
                        [self startPostRequest];
                    });
                    break;
                case DLLHTTPRequestMethodGet:
                    dispatch_async(_requestQueue, ^{
                        [self startGetRequest];
                    });
                    break;
                default:
                    break;
            }
        } else {
            NSLog(@"请求必须已经完成，才可以重试");
        }
    });
}

- (void)createOperator {
    [_operator release];
    switch (_operatorType) {
        case DLLHTTPRequestOperatorTypeASI:
            _operator = [[DLLASIHTTPRequestOperator alloc] init];
            break;
        case DLLHTTPRequestOperatorTypeAFNetworking:
            _operator = [[DLLAFNetworkingRequestOperator alloc] init];
            break;
        default:
            break;
    }
    _operator.request = self;
}

- (void)startGetRequest
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    _requestQueue = dispatch_get_current_queue();
#pragma clang diagnostic pop
    dispatch_async(_queue, ^{
        if (_requestStatus == DLLHTTPRequestStatePrepare) {
            _requestStatus = DLLHTTPRequestStateExecuting;
            _requestMethod = DLLHTTPRequestMethodGet;
            [self onRequestStart];
            [self createOperator];
            [_operator startGet];
        }
    });
}

- (void)startPostRequest
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    _requestQueue = dispatch_get_current_queue();
#pragma clang diagnostic pop
    dispatch_async(_queue, ^{
        if (_requestStatus == DLLHTTPRequestStatePrepare) {
            _requestStatus = DLLHTTPRequestStateExecuting;
            _requestMethod = DLLHTTPRequestMethodPost;
            [self onRequestStart];
            [self createOperator];
            [_operator startPost];
        }
        
    });
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
    dispatch_async(_queue, ^{
        if (_requestStatus == DLLHTTPRequestStateExecuting) {
            [_operator cancel];
            _requestStatus = DLLHTTPRequestStateCancel;
        }
    });
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
    dispatch_async(_queue, ^{
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
    });
}

- (void)reportFailed:(NSError *)error
{
    dispatch_async(_queue, ^{
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
    });
}

@end
