//
//  NdSecurityUtility.m
//  POO_IOS
//
//  Created by leo on 2021/2/26.
//  Copyright © 2021 mac. All rights reserved.
//

#import "NdSecurityUtility.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NdSecurityUtility

//SHA256加密
+ (NSString*)sha256HashFor:(NSString*)input{
    
    if (0 == input.length) {
        return @"";
    }
    
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    ret = (NSMutableString *)[ret lowercaseString];
//    NSLog(@"sha256HashFor====%@ sha256===%@", input, ret);
    return ret;
}

@end
