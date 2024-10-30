//
//  NdIMClientChatUtil.m
//  IMDemo
//
//  Created by mac on 2020/7/27.
//  Copyright © 2020 mac. All rights reserved.
//

#import "NdIMClientChatUtil.h"
#import "NdIMClientChatBase64.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NdIMConfigSingleton.h"

#define COMMON_FORMATTER @"yyyy-MM-dd HH:mm:ss"

@implementation NdIMClientChatUtil

+ (NSString *)getNetSignatureWithContent:(id)content andDate:(NSString *)gmtDate {
    NSString *normalSignature = [NSString stringWithFormat:@"%@\n%@\n%@",
                                 @"POST",
                                 [self md5Str:content],
                                 gmtDate];
    //此处用原生自带的base64
    NSData *data = [[[self hmacSha1:normalSignature hmacKey:[NdIMConfigSingleton sharedInstance].secretKey] hexLower] dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

+ (NdUCCSecurityResult *)hmacSha1:(NSString *)hashString hmacKey:(NSString *)key
{
    return [self hmacSha1WithData:[hashString dataUsingEncoding:NSUTF8StringEncoding] hmacKey:key];
}
+ (NdUCCSecurityResult *)hmacSha1WithData:(NSData *)hashData hmacKey:(NSString *)key
{
    unsigned char *digest;
    digest = malloc(CC_SHA1_DIGEST_LENGTH);
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), [hashData bytes], [hashData length], digest);
    NdUCCSecurityResult *result = [[NdUCCSecurityResult alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    free(digest);
    cKey = nil;
    
    return result;
}

+ (NSString *)md5Str:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)getNowGMTDateStr {
    NSDate *date = [NSDate date];
    
    return [self getGMTDateStr:date];
}

+ (NSString *)getGMTDateStr:(NSDate *)date {
    NSTimeZone *tzGMT = [NSTimeZone timeZoneWithName:@"GMT+0800"];
    [NSTimeZone setDefaultTimeZone:tzGMT];
    
    NSDateFormatter *iosDateFormater=[[NSDateFormatter alloc]init];
    iosDateFormater.dateFormat=@"dd MMM yyyy HH:mm:ss";
    iosDateFormater.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [iosDateFormater setTimeZone:tzGMT];// 设定时区
    return [iosDateFormater stringFromDate:date];
}

+ (NSData *)imageForCodingUpload:(UIImage *)image andMaxLen:(NSInteger)dataLength {
    CGFloat compressionQuality = 1;
    NSData *data = UIImageJPEGRepresentation(image, compressionQuality);
    while (data.length > dataLength) {
        CGFloat mSize = data.length / (1024 * 1000.0);
        compressionQuality *= pow(0.7, log(mSize)/ log(3));//大概每压缩 0.7，mSize 会缩小为原来的三分之一
        data = UIImageJPEGRepresentation(image, compressionQuality);
    }
    if (!data) {
        data = UIImagePNGRepresentation(image);
    }
    return data;
}

+ (NSString *)UUIDString
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_ref);
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

//+ (NSData *)convertCAFtoAMR:(NSString *)fielPath {
//    NSData *data = [NSData dataWithContentsOfFile:fielPath];
//    data = EncodeWAVEToAMR(data,1,16);
//    return data;
//}

+ (NSString *)getNowDateStr {
    return [self formatDate:[NSDate date] formatter:COMMON_FORMATTER];
}

+ (NSString *)formatDate:(NSDate *)date formatter:(NSString *)fromatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:fromatter];
    NSTimeZone *tzGMT = [NSTimeZone timeZoneWithName:@"GMT+0800"];
    [dateFormatter setTimeZone:tzGMT];
    return [dateFormatter stringFromDate:date];
}

+ (BOOL)isEmptyStr:(NSString *)str {
    if (!str || [str isKindOfClass:[NSNull class]] ||
        [str isEqual:@""]) {
        return YES;
    }
    return NO;
}

+ (NSString *)getNowTimeTimestamp3 {
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([datenow timeIntervalSince1970]*1000)];
    return timeSp;
}

@end

#pragma mark - NdUCCSecurityResult
@implementation NdUCCSecurityResult

@synthesize data = _data;

#pragma mark - Init
- (id)initWithBytes:(unsigned char[])initData length:(NSUInteger)length
{
    self = [super init];
    if (self) {
        _data = [NSData dataWithBytes:initData length:length];
    }
    return self;
}

#pragma mark UTF8 String
// convert CocoaSecurityResult to UTF8 string
- (NSString *)utf8String
{
    NSString *result = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    return result;
}

#pragma mark HEX
// convert CocoaSecurityResult to HEX string
- (NSString *)hex
{
    NdUCCSecurityEncoder *encoder = [NdUCCSecurityEncoder new];
    return [encoder hex:_data useLower:false];
}
- (NSString *)hexLower
{
    NdUCCSecurityEncoder *encoder = [NdUCCSecurityEncoder new];
    return [encoder hex:_data useLower:true];
}

#pragma mark Base64
// convert CocoaSecurityResult to Base64 string
- (NSString *)base64
{
    NdUCCSecurityEncoder *encoder = [NdUCCSecurityEncoder new];
    return [encoder base64:_data];
}

@end

#pragma mark - NdUCCSecurityEncoder
@implementation NdUCCSecurityEncoder

// convert NSData to Base64
- (NSString *)base64:(NSData *)data
{
    return [data base64EncodedString];
}

// convert NSData to hex string
- (NSString *)hex:(NSData *)data useLower:(BOOL)isOutputLower
{
    if (data.length == 0) { return nil; }
    
    static const char HexEncodeCharsLower[] = "0123456789abcdef";
    static const char HexEncodeChars[] = "0123456789ABCDEF";
    char *resultData;
    // malloc result data
    resultData = malloc([data length] * 2 +1);
    // convert imgData(NSData) to char[]
    unsigned char *sourceData = ((unsigned char *)[data bytes]);
    NSUInteger length = [data length];
    
    if (isOutputLower) {
        for (NSUInteger index = 0; index < length; index++) {
            // set result data
            resultData[index * 2] = HexEncodeCharsLower[(sourceData[index] >> 4)];
            resultData[index * 2 + 1] = HexEncodeCharsLower[(sourceData[index] % 0x10)];
        }
    }
    else {
        for (NSUInteger index = 0; index < length; index++) {
            // set result data
            resultData[index * 2] = HexEncodeChars[(sourceData[index] >> 4)];
            resultData[index * 2 + 1] = HexEncodeChars[(sourceData[index] % 0x10)];
        }
    }
    resultData[[data length] * 2] = 0;
    
    // convert result(char[]) to NSString
    NSString *result = [NSString stringWithCString:resultData encoding:NSASCIIStringEncoding];
    sourceData = nil;
    free(resultData);
    
    return result;
}

@end

#pragma mark - NdUCCSecurityDecoder
@implementation NdUCCSecurityDecoder
- (NSData *)base64:(NSString *)string
{
    return [NSData dataWithBase64EncodedString:string];
}
- (NSData *)hex:(NSString *)data
{
    if (data.length == 0) { return nil; }
    
    static const unsigned char HexDecodeChars[] =
    {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 1, //49
        2, 3, 4, 5, 6, 7, 8, 9, 0, 0, //59
        0, 0, 0, 0, 0, 10, 11, 12, 13, 14,
        15, 0, 0, 0, 0, 0, 0, 0, 0, 0,  //79
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 10, 11, 12,   //99
        13, 14, 15
    };
    
    // convert data(NSString) to CString
    const char *source = [data cStringUsingEncoding:NSUTF8StringEncoding];
    // malloc buffer
    unsigned char *buffer;
    NSUInteger length = strlen(source) / 2;
    buffer = malloc(length);
    for (NSUInteger index = 0; index < length; index++) {
        buffer[index] = (HexDecodeChars[source[index * 2]] << 4) + (HexDecodeChars[source[index * 2 + 1]]);
    }
    // init result NSData
    NSData *result = [NSData dataWithBytes:buffer length:length];
    free(buffer);
    source = nil;
    
    return  result;
}

@end
