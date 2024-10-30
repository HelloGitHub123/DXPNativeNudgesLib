//
//  NdHJHttpReponse.m
//  DITOApp
//
//  Created by leo on 2020/11/23.
//

#import "NdHJHttpReponse.h"
#import "Nudges.h"

@interface NdHJHttpReponse ()

@property (nonatomic, copy) NSNumber *requestId;
@property (nonatomic, strong) NSError *serverError;
@property (nonatomic, copy) id responseObject;
@property (nonatomic, strong) NSHTTPURLResponse *httpURLResponse;
@end

@implementation NdHJHttpReponse

- (instancetype)initWithRequestId:(NSNumber *)requestId responseData:(NSData *)responseData httpURLResponse:(NSHTTPURLResponse *)httpURLResponse error:(NSError *)error statusCode:(NSInteger)statusCode {
    self = [super init];
    if (self) {
        self.statusCode = statusCode;
        self.requestId = requestId;
        self.responseData = responseData;
        self.httpURLResponse = httpURLResponse;
        self.error = error;
        [self handleResponseData];
    }
    return self;
}

- (void)handleResponseData {
    //请求响应移除loading
//    [MBProgressHUD hideLoading];
//    [MBProgressHUD hideWindowLoading];

    if (self.error) {
        NSData * data = self.error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSError *err;
        
        if (data) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
            HJLog(@"========响应体打印开始:%@========",[self.httpURLResponse.URL absoluteString]);
            @try {
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"ResponseUrl======Fail===\nStatusCode:%ld\n==RequestUrl:\n%@\n==HeaderFields:\n%@\n==Error!ResponseBody:\n==ITRACING_TRACE_ID:\n%@\n%@\n",self.httpURLResponse.statusCode,[self.httpURLResponse.URL absoluteString], self.httpURLResponse.allHeaderFields,[ self.httpURLResponse.allHeaderFields objectForKey:@"ITRACING_TRACE_ID"],[[dic jsonPrettyStringEncoded] jsonStrHandle]);
                } else {
                    NSLog(@"ResponseUrl======Fail===StatusCode:%ld==RequestUrl:%@==HeaderFields:%@==ResponseBody:%@",self.httpURLResponse.statusCode,[self.httpURLResponse.URL absoluteString], self.httpURLResponse.allHeaderFields,dic);
                }
            } @catch (NSException *exception) {
            } @finally {
            }
            HJLog(@"========响应体打印结束========");
            
            NSString *message = dic[@"message"];
            if (message.length > 0) {
                [[TKUtils keyWindow] makeToast:message duration:1.5f position:CSNdToastPositionCenter];
            } else {
//                [[TKUtils keyWindow] makeToast:@"The system is busy" duration:1.5f position:CSNdToastPositionCenter];
            }
            
            NSString *code = dic[@"code"];
            if ([code isKindOfClass:[NSString class]]) {
                NSArray *temp = [code componentsSeparatedByString:@"-"];
                if (temp.count) {
                    if (!isEmptyString_Nd(message)) {
                        self.serverError = [NSError errorWithDomain:message code:[[temp lastObject] integerValue] userInfo:dic];
                    }
                }
            }
        } else {
            if (-1020 == self.error.code) {
                [[TKUtils keyWindow] makeToast:@"Service is currently unavailable. Please try again later." duration:1.5f position:CSNdToastPositionCenter];
            }
        }
        return;
    }
    
    if (self.responseData.length > 0) {
        id res = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:nil];
        self.responseObject = res;
        HJLog(@"========响应体打印开始:%@========",[self.httpURLResponse.URL absoluteString]);
        @try {
            if ([res isKindOfClass:[NSDictionary class]]) {
                NSLog(@"ResponseUrl======Success\n===StatusCode:%ld\n==RequestUrl:%@==\nHeaderFields:%@==\n%@\nResponseBody:\n%@\n",self.httpURLResponse.statusCode,[self.httpURLResponse.URL absoluteString], [[self.httpURLResponse.allHeaderFields jsonPrettyStringEncoded] jsonStrHandle],[self.httpURLResponse.URL absoluteString],[[res jsonPrettyStringEncoded] jsonStrHandle]);
            } else {
                NSLog(@"ResponseUrl======Success===StatusCode:%ld==RequestUrl:%@==HeaderFields:%@==ResponseBody:%@",self.httpURLResponse.statusCode,[self.httpURLResponse.URL absoluteString], self.httpURLResponse.allHeaderFields,res);
            }
        } @catch (NSException *exception) {
        }
        HJLog(@"========响应体打印结束========");
        if ([res isKindOfClass:[NSDictionary class]] && res[@"resultDesc"]) {
            [[TKUtils topViewController].navigationController.view makeToast:res[@"resultDesc"] duration:1.5f position:CSNdToastPositionCenter];
        }
        
        NSDictionary *dict = self.httpURLResponse.allHeaderFields;
        //        HJLog("url=====%@==code===%ld=allHeaderFields====%@",[self.httpURLResponse.URL absoluteString],self.httpURLResponse.statusCode,dict);
        if ([dict.allKeys containsObject:@"Auth-Token"] || [dict.allKeys containsObject:@"AUTH-TOKEN"]) {
            //TODO:-- 有autoToken，本地化，赋值给全局
//            NSString *authToken = dict[@"Auth-Token"];
//            kHJAppDataSetCache(kAuthToken, authToken);
//            [HJAppDataManager sharedInstance].authToken = authToken;
        }
        if ([dict.allKeys containsObject:@"Refresh_token"]) {
            
            //TODO:-- 有autoToken，本地化，赋值给全局
//            NSString *refreshToken = dict[@"Refresh_token"];
//            kHJAppDataSetCache(kRefreshToken, refreshToken);
//            [HJAppDataManager sharedInstance].refreshToken = refreshToken;
        }
    }
}

@end
