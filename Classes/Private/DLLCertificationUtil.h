//
//  DLLCertificationUtil.h
//  Pods
//
//  Created by DLL on 16/10/21.
//
//

#import <Foundation/Foundation.h>

@interface DLLCertificationUtil : NSObject

/**
 初始化SSL客户端请求证书
 **/
+ (NSURLCredential *)createDefaultCredentialWithCertificatePath:(NSString *)cerPath andPassword:(NSString *)password;



@end
