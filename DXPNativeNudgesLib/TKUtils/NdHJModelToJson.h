//
//  NdHJModelToJson.h
//  MPTCLPMall
//
//  Created by Lee on 2022/3/31.
//  Copyright © 2022 OO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NdHJModelToJson : NSObject

//通过对象返回一个NSDictionary，键是属性名称，值是属性值。

+ (NSDictionary*)getObjectData:(id)obj;


//将getObjectData方法返回的NSDictionary转化成JSON

+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error;


//直接通过NSLog输出getObjectData方法返回的NSDictionary

+ (void)print:(id)obj;

@end

NS_ASSUME_NONNULL_END
