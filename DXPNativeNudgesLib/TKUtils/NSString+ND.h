//
//  NSString+ND.h
//  IMDemo
//
//  Created by mac on 2020/6/9.
//  Copyright © 2020 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (ND)

+ (NSString *)ndStringWithoutNil:(id)string;
+ (BOOL)isNDBlankString:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
