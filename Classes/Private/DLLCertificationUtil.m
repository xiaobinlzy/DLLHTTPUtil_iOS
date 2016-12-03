//
//  DLLCertificationUtil.m
//  Pods
//
//  Created by DLL on 16/10/21.
//
//

#import "DLLCertificationUtil.h"

@implementation DLLCertificationUtil


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

+ (AFSecurityPolicy *)setDefaultSecurityPolicyWithCertificatePath:(NSString *)cerPath {
    if (__securityPolicy != nil) {
        __securityPolicy = nil;
    }
    if (cerPath) {
        NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
        __securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        [__securityPolicy setAllowInvalidCertificates:YES];
        [__securityPolicy setPinnedCertificates:[NSSet setWithArray:[NSArray arrayWithObject:cerData]]];
    } else {
        __securityPolicy = [AFSecurityPolicy defaultPolicy];
    }
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


@end
