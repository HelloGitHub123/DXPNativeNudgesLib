//
//  NSString+ndJson.h
//
//
//  Created by 张蒙蒙 on 2018/5/4.
//  Copyright © 2018年 张蒙蒙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ndJson)

- (id)JSONValue;
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;
+ (NSString*)dictionaryToJsonWithBlank:(NSDictionary *)dic;
- (NSString*)jsonStrHandle;
@end
