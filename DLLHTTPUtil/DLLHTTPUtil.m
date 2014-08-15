//
//  HttpUtil.m
//  HttpUtil
//
//  Created by DLL on 14-5-23.
//  Copyright (c) 2014年 DLL. All rights reserved.
//

#import "DLLHTTPUtil.h"

@implementation DLLHTTPUtil

static AFSecurityPolicy *__securityPolicy;

+ (AFSecurityPolicy *)defaultSecurityPolciy
{
    if (__securityPolicy == nil) {
        @synchronized (self) {
            __securityPolicy = [[AFSecurityPolicy defaultPolicy] retain];
        }
    }
    return __securityPolicy;
}

+ (AFSecurityPolicy *)createDefaultSecurityPolicyWithCertificateName:(NSString *)cerName andType:(NSString *)cerType
{
    if (__securityPolicy != nil) {
        @synchronized (self) {
            [__securityPolicy release];
            __securityPolicy = nil;
        }
    }
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:cerName ofType:cerType];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    __securityPolicy = [[AFSecurityPolicy alloc] init];
    [__securityPolicy setAllowInvalidCertificates:YES];
    [__securityPolicy setSSLPinningMode:AFSSLPinningModeCertificate];
    [__securityPolicy setPinnedCertificates:[NSArray arrayWithObject:cerData]];
    return __securityPolicy;
}

+ (NSURL*) urlFormWithHostAddress:(NSString*)hostAddress andParameters:(NSDictionary*)parameters
{
    [parameters retain];
    [hostAddress retain];
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:hostAddress];
    if (nil != parameters && [parameters count] > 0) {
        [urlString appendString:[urlString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&"];
        for (id key in parameters) {
            NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [urlString appendFormat:@"%@=%@&", encodedKey, [[parameters objectForKey:key] URLEncodedString]];
        }
        [urlString deleteCharactersInRange:NSMakeRange([urlString length] - 1, 1)];
    }
    [hostAddress release];
    [parameters release];
    NSURL *url = [NSURL URLWithString:urlString];
    [urlString release];
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

@end
