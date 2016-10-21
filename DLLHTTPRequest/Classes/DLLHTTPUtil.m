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
static NSURLCredential *__credential;

+ (AFSecurityPolicy *)defaultSecurityPolciy {
    if (__securityPolicy == nil) {
        @synchronized (self) {
            __securityPolicy = [AFSecurityPolicy defaultPolicy];
        }
    }
    return __securityPolicy;
}

+ (AFSecurityPolicy *)createDefaultSecurityPolicyWithCertificatePath:(NSString *)cerPath {
    if (__securityPolicy != nil) {
        __securityPolicy = nil;
    }
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    __securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    [__securityPolicy setAllowInvalidCertificates:YES];
    [__securityPolicy setPinnedCertificates:[NSSet setWithArray:[NSArray arrayWithObject:cerData]]];
    return __securityPolicy;
}

+ (NSURLCredential *)defaultCredential {
    return __credential;
}

OSStatus extractIdentityAndTrust(CFDataRef inP12data, SecIdentityRef *identity, SecTrustRef *trust, NSString* password) {
    OSStatus securityError = errSecSuccess;
    
    CFStringRef pwd = (__bridge CFStringRef) password;
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { pwd };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inP12data, options, &items);
    
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemTrust);
        *trust = (SecTrustRef)tempTrust;
    }
    
    if (options) {
        CFRelease(options);
    }
    
    return securityError;
}



+ (NSURLCredential *)createDefaultCredentialWithCertificatePath:(NSString *)cerPath andPassword:(NSString *)password
{
    if (__credential != nil) {
        __credential = nil;
    }
    NSData *p12data = [NSData dataWithContentsOfFile:cerPath];
    CFDataRef inP12data = (__bridge CFDataRef)p12data;
    
    SecIdentityRef myIdentity;
    SecTrustRef myTrust;
    extractIdentityAndTrust(inP12data, &myIdentity, &myTrust, password);
    
    SecCertificateRef myCertificate;
    SecIdentityCopyCertificate(myIdentity, &myCertificate);
    const void *certs[] = { myCertificate };
    CFArrayRef certsArray = CFArrayCreate(NULL, certs, 1, NULL);
    
    __credential = [[NSURLCredential alloc] initWithIdentity:myIdentity certificates:(__bridge NSArray*)certsArray persistence:NSURLCredentialPersistencePermanent];
    return __credential;
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