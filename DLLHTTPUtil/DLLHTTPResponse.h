//
//  HttpResponse.h
//  HttpUtil
//
//  Created by DLL on 14-5-26.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DLLHTTPResponse : NSObject

/**
 响应状态吗
 **/
@property (nonatomic, readonly) NSInteger statusCode;

/**
 响应字符串
 **/
@property (nonatomic, readonly) NSString *responseString;

/**
 响应字节码
 **/
@property (nonatomic, readonly) NSData *responseData;

/**
 Http响应头
 **/
@property (nonatomic, readonly) NSDictionary *headers;

- (instancetype)initWithStatusCode:(NSInteger)statusCode responseData:(NSData *)responseData stringEncoding:(NSStringEncoding)stringEncoding responseHeaders:(NSDictionary *)headers responseString:(NSString *)responseString;



@end
