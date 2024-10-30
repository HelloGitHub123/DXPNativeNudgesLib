//
//  NdHJHttpConfiguration.m
//  DITOApp
//
//  Created by leo on 2020/11/23.
//

#import "NdHJHttpConfiguration.h"

static NdHJHttpConfiguration *config = nil;
@implementation NdHJHttpConfiguration

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[NdHJHttpConfiguration alloc] init];
    });
    return config;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        _requestHeaderDict = @{};
    }
    return self;
}


@end
