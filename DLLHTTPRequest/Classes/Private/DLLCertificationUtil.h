//
//  DLLCertificationUtil.h
//  Pods
//
//  Created by DLL on 16/10/21.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@interface DLLCertificationUtil : NSObject


/**
 初始化默认的SSL证书
 **/
+ (AFSecurityPolicy *)setDefaultSecurityPolicyWithCertificatePath:(NSString *)cerPath;

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


@end
