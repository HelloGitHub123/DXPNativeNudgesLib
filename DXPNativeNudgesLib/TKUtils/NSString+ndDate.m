//
//  NSString+ndDate.m
//  TestNudges
//
//  Created by biaozi on 2022/10/18.
//

#import "NSString+ndDate.h"

#define COMMON_FORMATTER @"yyyy-MM-dd HH:mm:ss"

@implementation NSString (ndDate)

+ (NSString *)getCurrentTimestamp {
    //获取系统当前的时间戳 13位，毫秒级；10位，秒级
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSDecimalNumber *timeNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", time]];
    NSDecimalNumber *baseNumber = [NSDecimalNumber decimalNumberWithString:@"1000"];
    NSDecimalNumber *result = [timeNumber decimalNumberByMultiplyingBy:baseNumber];
    return [NSString stringWithFormat:@"%ld", (long)[result integerValue]];
}

+ (NSString *)getCreateTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:COMMON_FORMATTER];
    return [dateFormatter stringFromDate:[NSDate date]];
}
@end
