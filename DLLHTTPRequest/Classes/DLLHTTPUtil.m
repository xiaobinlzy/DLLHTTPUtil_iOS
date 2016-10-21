//
//  HttpUtil.m
//  HttpUtil
//
//  Created by DLL on 14-5-23.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import "DLLHTTPUtil.h"
#import "DLLCertificationUtil.h"

@implementation DLLHTTPUtil

+ (void)createDefaultSecurityPolicyWithCertificatePath:(NSString *)cerPath {
    [DLLCertificationUtil createDefaultSecurityPolicyWithCertificatePath:cerPath];
}

+ (NSURLCredential *)createDefaultCredentialWithCertificatePath:(NSString *)cerPath andPassword:(NSString *)password {
    return [DLLCertificationUtil createDefaultCredentialWithCertificatePath:cerPath andPassword:password];
}

+ (NSURLCredential *)defaultCredential {
    return [DLLCertificationUtil defaultCredential];
}



+ (NSURL*) urlFormWithHostAddress:(NSString*)hostAddress andParameters:(NSDictionary*)parameters
{
    return [self urlFormWithHostAddress:hostAddress andParameters:parameters encoding:NSUTF8StringEncoding];
}

+ (NSURL *)urlFormWithHostAddress:(NSString *)hostAddress andParameters:(NSDictionary *)parameters encoding:(NSStringEncoding)encoding
{
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:hostAddress];
    if (nil != parameters && [parameters count] > 0) {
        [urlString appendString:[urlString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&"];
        for (id key in parameters) {
            NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:encoding];
            id value = [parameters objectForKey:key];
            if (![value isKindOfClass:NSString.class]) {
                value = [NSString stringWithFormat:@"%@", value];
            }
            
            [urlString appendFormat:@"%@=%@&", encodedKey, [value URLEncodedStringWithEncoding:CFStringConvertNSStringEncodingToEncoding(encoding)]];
        }
        [urlString deleteCharactersInRange:NSMakeRange([urlString length] - 1, 1)];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
    
}



+ (NSString *)URLEncodingFromString:(NSString *)string
{
    return [string URLEncodedString];
}

+ (NSString *)URLDecodingFromString:(NSString *)string
{
    return [string URLDecodedString];
}

+ (NSString *)URLDecodingFromString:(NSString *)string encoding:(NSStringEncoding)encoding
{
    return [string stringByReplacingPercentEscapesUsingEncoding:encoding];
}

+ (NSDictionary *)paramsOfURL:(NSString *)url encoding:(NSStringEncoding)encoding
{
    NSUInteger paramIndex = [url rangeOfString:@"?"].location;
    if (paramIndex != NSNotFound && url.length > paramIndex + 1) {
        NSString *paramString = [url substringFromIndex:paramIndex + 1];
        return [self paramsOfURLParameters:paramString withEncoding:encoding];
    }
    return nil;
}

+ (NSDictionary *)paramsOfURLParameters:(NSString *)parameters withEncoding:(NSStringEncoding)encoding {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *nameValuePairs = [parameters componentsSeparatedByString:@"&"];
    for (NSString *nameValueString in nameValuePairs) {
        NSArray *nameValue = [nameValueString componentsSeparatedByString:@"="];
        if (nameValue.count == 2) {
            if ([nameValue firstObject] && [nameValue lastObject]) {
                [result setObject:[self URLDecodingFromString:[nameValue lastObject] encoding:encoding]
                           forKey:[self URLDecodingFromString:[nameValue firstObject] encoding:encoding]];
            }
        }
    }
    return result;
}

+ (NSDictionary *)paramsOfURL:(NSString *)url
{
    return [self paramsOfURL:url encoding:NSUTF8StringEncoding];
}

+ (NSString *)URL:(NSString *)URL appendWithPath:(NSString *)path {
    if ([URL hasSuffix:@"/"]) {
        URL = [URL substringToIndex:URL.length - 1];
    }
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    return [NSString stringWithFormat:@"%@/%@", URL, path];
}

@end
