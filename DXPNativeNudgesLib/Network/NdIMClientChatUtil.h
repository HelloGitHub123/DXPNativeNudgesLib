//
//  NdIMClientChatUtil.h
//  IMDemo
//
//  Created by mac on 2020/7/27.
//  Copyright © 2020 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#pragma mark - NdUCCSecurityResult
@interface NdUCCSecurityResult : NSObject

@property (strong, nonatomic, readonly) NSData *data;
@property (strong, nonatomic, readonly) NSString *utf8String;
@property (strong, nonatomic, readonly) NSString *hex;
@property (strong, nonatomic, readonly) NSString *hexLower;
@property (strong, nonatomic, readonly) NSString *base64;

- (id)initWithBytes:(unsigned char[])initData length:(NSUInteger)length;

@end

#pragma mark - UCCSecurityEncoder
@interface NdUCCSecurityEncoder : NSObject
- (NSString *)base64:(NSData *)data;
- (NSString *)hex:(NSData *)data useLower:(BOOL)isOutputLower;
@end


#pragma mark - NdUCCSecurityDecoder
@interface NdUCCSecurityDecoder : NSObject
- (NSData *)base64:(NSString *)data;
- (NSData *)hex:(NSString *)data;
@end

@interface NdIMClientChatUtil : NSObject

+ (NSString *)getNetSignatureWithContent:(id)content andDate:(NSString *)gmtDate;

+ (NSData *)imageForCodingUpload:(UIImage *)image andMaxLen:(NSInteger)dataLength;

+ (NSString *)UUIDString;

+ (NSString *)md5Str:(NSString *)str;

//+ (NSData *)convertCAFtoAMR:(NSString *)fielPath;

+ (NSString *)getNowGMTDateStr;

+ (NSString *)getGMTDateStr:(NSDate *)date;

+ (NSString *)getNowDateStr;

+ (NSString *)formatDate:(NSDate *)date formatter:(NSString *)fromatter;

+ (BOOL)isEmptyStr:(NSString *)str;

// 当前时间戳。毫秒
+ (NSString *)getNowTimeTimestamp3;

// 临时
+ (NdUCCSecurityResult *)hmacSha1:(NSString *)hashString hmacKey:(NSString *)key;

@end
