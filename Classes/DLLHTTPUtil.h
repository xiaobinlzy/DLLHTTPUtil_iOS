//
//  HttpUtil.h
//  HttpUtil
//
//  Created by DLL on 14-5-23.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLLHTTPResponse.h"
#import "DLLHTTPRequest.h"
#import "NSString+URLEncoding.h"

@interface DLLHTTPUtil : NSObject

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

+ (NSDictionary *)paramsOfURLParameters:(NSString *)parameters withEncoding:(NSStringEncoding)encoding;

@end
