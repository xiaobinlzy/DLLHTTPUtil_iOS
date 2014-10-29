//
//  HttpUtil.h
//  HttpUtil
//
//  Created by DLL on 14-5-23.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "AFNetworking.h"
#import "DLLHTTPResponse.h"
#import "DLLHTTPRequest.h"
#import "NSString+URLEncoding.h"

@interface DLLHTTPUtil : NSObject

/** 
 初始化默认的SSL证书
 **/
+ (AFSecurityPolicy *)createDefaultSecurityPolicyWithCertificateName:(NSString *)cerName andType:(NSString *)cerType;

/**
 初始化SSL客户端请求证书
 **/
+ (NSURLCredential *)createDefaultCredentialWithCertificateName:(NSString *)cerName type:(NSString *)cerType andPassword:(NSString *)password;

/**
 获得自定义的SSL证书
 **/
+ (AFSecurityPolicy *)defaultSecurityPolciy;

/**
 SSL客户端请求证书
 **/
+ (NSURLCredential *)defaultCredential;

/**
 URL参数拼接和转码
 **/
+ (NSURL *)urlFormWithHostAddress:(NSString*)hostAddress andParameters:(NSDictionary*)parameters;

+ (NSString *)URLEncodingFromString:(NSString *)string;

+ (NSString *)URLDecodingFromString:(NSString *)string;


@end
