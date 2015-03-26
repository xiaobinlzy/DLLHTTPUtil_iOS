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
+ (AFSecurityPolicy *)createDefaultSecurityPolicyWithCertificatePath:(NSString *)cerPath;

/**
 初始化SSL客户端请求证书
 **/
+ (NSURLCredential *)createDefaultCredentialWithCertificatePath:(NSString *)cerPath andPassword:(NSString *)password;

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
+ (NSURL *)urlFormWithHostAddress:(NSString*)hostAddress andParameters:(NSDictionary*)parameters encoding:(NSStringEncoding)encoding;

+ (NSString *)URLEncodingFromString:(NSString *)string;

+ (NSString *)URLDecodingFromString:(NSString *)string encoding:(NSStringEncoding)encoding;
+ (NSString *)URLDecodingFromString:(NSString *)string;

+ (NSString *)URL:(NSString *)URL appendWithPath:(NSString *)path;

+ (NSDictionary *)paramsOfURL:(NSString *)url encoding:(NSStringEncoding)encoding;
+ (NSDictionary *)paramsOfURL:(NSString *)url;

@end
