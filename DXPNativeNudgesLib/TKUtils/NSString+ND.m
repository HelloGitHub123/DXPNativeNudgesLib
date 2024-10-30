//
//  NSString+ND.m
//  IMDemo
//
//  Created by mac on 2020/6/9.
//  Copyright © 2020 mac. All rights reserved.
//

#import "NSString+ND.h"

@implementation NSString (ND)

+ (NSString *)ndStringWithoutNil:(id)string {
    NSString *tempStr = [NSString stringWithFormat:@"%@",string];
    return [NSString isNDBlankString:tempStr]?@"":tempStr;
}

+ (BOOL)isNDBlankString:(NSString *)string {
    if (string == nil || string == NULL ) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([string isEqualToString:@"<null>"]){
        return YES;
    }
    if ([string isEqualToString:@"(null)"]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
