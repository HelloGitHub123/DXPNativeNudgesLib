//
//  NSString+tkJson.m
//  BitBank
//
//  Created by 张蒙蒙 on 2018/5/4.
//  Copyright © 2018年 张蒙蒙. All rights reserved.
//

#import "NSString+tkJson.h"

@implementation NSString (tkJson)

- (id)JSONValue {
    
    NSData* jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    if (jsonData) {
        if ([jsonData length] > 0)
        {
            id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
            
            return jsonObj;
        }
    }
    
    return nil;
}

+ (NSString*)dictionaryToJson:(NSDictionary *)dic {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"DXPNugges Log:=== %@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

+ (NSString*)dictionaryToJsonWithBlank:(NSDictionary *)dic {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"DXPNugges Log:=== %@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
//    NSRange range = {0,jsonString.length};
//    //去掉字符串中的空格
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

+ (NSString *)stringWithoutNil:(id)string {
    NSString *tempStr = [NSString stringWithFormat:@"%@",string];
    return [NSString isBlankString:tempStr]?@"":tempStr;
}

+ (BOOL)isBlankString:(NSString *)string {
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

//json 地址斜杠处理
-(NSString*)jsonStrHandle{
    NSMutableString *responseString = [NSMutableString stringWithString:self];
        NSString *character = nil;
        for (int i = 0; i < responseString.length; i ++) {
            character = [responseString substringWithRange:NSMakeRange(i, 1)];
            if ([character isEqualToString:@"\\"])
                [responseString deleteCharactersInRange:NSMakeRange(i, 1)];
        }
    return responseString;
}

@end
