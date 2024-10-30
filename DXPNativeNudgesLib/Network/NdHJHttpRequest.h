//
//  NdHJHttpRequest.h
//  DITOApp
//
//  Created by leo on 2020/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NdHJRequestSerializerType) {
    NdHJRequestSerializerTypeHTTP = 0,
    NdHJRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger, NdHJHttpMethod) {
    NdHJHttpMethodGET,
    NdHJHttpMethodPOST,
    NdHJHttpMethodPUT,
    NdHJHttpMethodDELETE,
    NdHJHttpMethodPATCH
};

@interface NdHJHttpRequest : NSObject

@property (nonatomic, copy) NSString *baseUrl;

@property (nonatomic, copy) NSString *requestUrl;

@property (nonatomic, assign) NdHJRequestSerializerType requestSerializerType;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

@property (nonatomic, strong) NSMutableDictionary *requestHeaderDict;

@property (nonatomic, assign) NdHJHttpMethod httpMethod;

@property (nonatomic, copy) NSDictionary *requestParams;


@end

NS_ASSUME_NONNULL_END
