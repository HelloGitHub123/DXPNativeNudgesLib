//
//  NSString+ndDate.h
//  TestNudges
//
//  Created by biaozi on 2022/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ndDate)

+ (NSString *)getCurrentTimestamp;
+ (NSString *)getCreateTime;
@end

NS_ASSUME_NONNULL_END
