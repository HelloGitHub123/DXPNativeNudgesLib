//
//  NdHJHttpRequest.m
//  DITOApp
//
//  Created by leo on 2020/11/23.
//

#import "NdHJHttpRequest.h"
#import "Nudges.h"

@implementation NdHJHttpRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        _baseUrl = [NdHJHttpConfiguration sharedInstance].baseUrl;
        [self.requestHeaderDict addEntriesFromDictionary: [NdHJHttpConfiguration sharedInstance].requestHeaderDict];
//        NSString *authToken = [HJAppDataManager sharedInstance].authToken;
        [self.requestHeaderDict setValue:@"ios" forKey:@"Device-Type"];
        [self.requestHeaderDict setValue:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] forKey:@"appVersion"];
//        if (authToken.length) {
//            [self.requestHeaderDict setValue:authToken forKey:@"auth-token"];
            [self.requestHeaderDict setValue:@"1" forKey:@"deviceType"];
            [self.requestHeaderDict setValue:@"ios" forKey:@"terminal-Type"];
//        }
        
        _requestSerializerType = NdHJRequestSerializerTypeJSON;
        _timeoutInterval = 60.0;
        _httpMethod = NdHJHttpMethodGET;
    }
    return self;
}

#pragma mark -- lazy load

- (NSMutableDictionary *)requestHeaderDict {
    if (!_requestHeaderDict) {
        _requestHeaderDict = [NSMutableDictionary dictionary];
    }
    return _requestHeaderDict;
}
@end
