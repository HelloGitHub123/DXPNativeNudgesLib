//
//  NSString+tkJson.h
//  BitBank
//
//  Created by 张蒙蒙 on 2018/5/4.
//  Copyright © 2018年 张蒙蒙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (tkJson)

- (id)JSONValue;

+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

+ (NSString*)dictionaryToJsonWithBlank:(NSDictionary *)dic;

+ (NSString *)stringWithoutNil:(id)string;

+ (BOOL)isBlankString:(NSString *)string;
-(NSString*)jsonStrHandle;
@end
