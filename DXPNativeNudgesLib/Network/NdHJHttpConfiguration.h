//
//  NdHJHttpConfiguration.h
//  DITOApp
//
//  Created by leo on 2020/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NdHJHttpConfiguration : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfig;

@property (nonatomic, copy) NSString *baseUrl;

@property (nonatomic, copy) NSDictionary *requestHeaderDict;

@end

NS_ASSUME_NONNULL_END
