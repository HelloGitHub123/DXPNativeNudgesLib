//
//  NdSecurityUtility.h
//  POO_IOS
//
//  Created by leo on 2021/2/26.
//  Copyright © 2021 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NdSecurityUtility : NSObject
//SHA256加密
+ (NSString*)sha256HashFor:(NSString *)input;
@end

NS_ASSUME_NONNULL_END
