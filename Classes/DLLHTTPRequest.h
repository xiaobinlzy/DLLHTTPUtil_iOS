//
//  HttpRequest.h
//  HttpUtil
//
//  Created by DLL on 14-5-26.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLLHTTPResponse.h"
#import "DLLHTTPUtil.h"
#import "NSString+URLEncoding.h"

@class DLLHTTPRequest;

typedef NS_ENUM(NSInteger, DLLHTTPRequestOperatorType) {
    DLLHTTPRequestOperatorTypeAFNetworking
};

/**
HttpRequest的回调协议
 **/
@protocol DLLHTTPRequestDelegate <NSObject>

@optional
/**
 请求完成回调
 **/
- (void)requestFinished:(DLLHTTPRequest *)request responseString:(NSString *)responseString;

/**
 请求失败回调
 **/
- (void)requestFailed:(DLLHTTPRequest *)request error:(NSError *)error;


/**
 请求开始回调
 **/
- (void)requestStart:(DLLHTTPRequest *)request;

/**
 请求完成回调
 **/
- (void)requestEnd:(DLLHTTPRequest *)request;
@end


typedef enum {
    DLLHTTPRequestStatePrepare,
    DLLHTTPRequestStateExecuting,
    DLLHTTPRequestStateDone,
    DLLHTTPRequestStateCancel,
} DLLHTTPRequestStatus;

typedef enum {
    DLLHTTPRequestMethodGet,
    DLLHTTPRequestMethodPost,
    DLLHTTPRequestMethodPostForm
} DLLHTTPRequestMethod;

typedef void (^DLLHTTPCallback) (DLLHTTPRequest * request, NSString * responseString, NSError * error);

/**
 负责请求的HttpRequest对象
 **/
@interface DLLHTTPRequest : NSObject {
    NSMutableDictionary *_requestHeaders;
}


@property (nonatomic, class, copy) NSSet<NSData *> *trustedCertifications;

@property (nonatomic, class, assign) BOOL allowInvalideCertificates;

@property (nonatomic, class, assign) BOOL reuseConnection;


#pragma mark - properties
/**
 获取请求的URL。
 **/
@property (nonatomic, readonly) NSURL *url;

/**
 获取请求的响应对象。如果请求未被响应，则为nil。
 **/
@property (nonatomic, readonly) DLLHTTPResponse *response;

/**
 请求的超时设置
 **/
@property (nonatomic, assign) NSUInteger timeoutIntervel;

/**
 代理对象负责回调。会先处理delegate，后处理block。
 **/
@property (nonatomic, weak) id<DLLHTTPRequestDelegate> delegate;

/**
 *  负责回调的block。会先处理delegate，后处理block。
 */
@property (nonatomic, copy) DLLHTTPCallback callback;

/**
 为请求添加的标签。
 **/
@property (nonatomic, assign) NSInteger tag;

/**
 请求当前的状态
 **/
@property (atomic, readonly) DLLHTTPRequestStatus requestStatus;

/**
 请求所带的参数
 **/
@property (nonatomic, strong) NSDictionary *params;

/**
 响应结果编码
 **/
@property (nonatomic, assign) NSStringEncoding responseEncoding;


@property (nonatomic, assign) DLLHTTPRequestMethod requestMethod;

/**
 *  请求使用的框架。
 */
@property (nonatomic, assign) DLLHTTPRequestOperatorType operatorType;

#pragma mark - methods
/**
 用url对请求对象进行初始化，初始化后的url不可修改。
 **/
- (instancetype)initWithURL:(NSURL *)url;

- (instancetype)initWithURLString:(NSString *)urlString;

/**
 开始GET异步请求
 **/
- (void)startGetRequest;


/**
 开始POST异步请求
 **/
- (void)startPostRequest;

/**
 *  提交Post表单
 */
- (void)startPostFormRequest;

/**
 *  开始GET异步请求
 *
 *  @param callback 回调block。
 */
- (void)startGetRequestWithCallback:(DLLHTTPCallback)callback;

/**
 *  开始POST异步请求
 *
 *  @param callback 回调callback
 */
- (void)startPostRequestWithCallback:(DLLHTTPCallback)callback;

/** 重试请求 **/
- (void)retry;


/**
 清空代理对象并且取消
 **/
- (void)clearDelegateAndCancel;

/**
 设置默认的超时时长，默认为10秒。
 **/
+ (void)setDefaultTimeoutIntervel:(NSUInteger)timeoutIntervel;

/**
 获取默认的超时时长，默认为10秒。
 **/
+ (NSInteger)defaultTimeoutIntervel;

+ (instancetype)requestWithURL:(NSURL *)url;

+ (instancetype)requestWithURLString:(NSString *)urlString;

/** 添加请求头 **/
- (void)addRequestHeader:(NSString *)value forKey:(NSString *)key;

- (void)setRequestHeaders:(NSDictionary *)headers;
- (NSDictionary *)requestHeaders;
@end

@interface NSURLRequest (HTTPS)

@end

