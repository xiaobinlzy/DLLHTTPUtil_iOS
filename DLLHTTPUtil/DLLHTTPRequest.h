//
//  HttpRequest.h
//  HttpUtil
//
//  Created by DLL on 14-5-26.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DLLHTTPRequest;
@class DLLHTTPResponse;


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
    DLLHTTPRequestStateError,
    DLLHTTPRequestStateFailed
} DLLHTTPRequestState;

/**
 负责请求的HttpRequest对象
 **/
@interface DLLHTTPRequest : NSObject {

}

#pragma mark - properties
/**
 获取请求的URL。
 **/
@property (nonatomic, readonly) NSString *url;

/**
 获取请求的响应对象。如果请求未被成功响应，则为nil。
 **/
@property (nonatomic, readonly) DLLHTTPResponse *response;

/**
 请求的超时设置
 **/
@property (nonatomic, assign) NSUInteger timeoutIntervel;

/**
 代理对象负责回调
 **/
@property (nonatomic, assign) id<DLLHTTPRequestDelegate> delegate;

/**
 为请求添加的标签。
 **/
@property (nonatomic, assign) NSInteger tag;

/**
 请求当前的状态
 **/
@property (atomic, readonly) DLLHTTPRequestState state;

/**
 请求所带的参数
 **/
@property (nonatomic, retain) NSDictionary *params;

#pragma mark - methods
/**
 用url对请求对象进行初始化，初始化后的url不可修改。
 **/
- (instancetype)initWithURL:(NSString *)url;

/**
 开始GET异步请求
 **/
- (void)startGetRequest;


/**
 开始POST异步请求
 **/
- (void)startPostRequest;


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

+ (instancetype)requestWithURL:(NSString *)url;
@end
