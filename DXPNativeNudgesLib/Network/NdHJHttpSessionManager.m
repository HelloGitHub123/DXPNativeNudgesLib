//
//  NdHJHttpSessionManager.m
//  DITOApp
//
//  Created by leo on 2020/11/23.
//

#import "NdHJHttpSessionManager.h"
#import "NdHJHttpConfiguration.h"
#import "NdSecurityUtility.h"
#import "NdHJHandelJson.h"
#import "AFNetworkReachabilityManager.h"
#import "UIImage+NdCategory.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NdIMClientChatUtil.h"
#import "NdIMConfigSingleton.h"
#import "HJNudgesManager.h"

static NdHJHttpSessionManager *manager = nil;

@interface NdHJHttpSessionManager ()
{
    AFHTTPSessionManager *_sessionManager;
}

@end

@implementation NdHJHttpSessionManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NdHJHttpSessionManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfig = [NdHJHttpConfiguration sharedInstance].sessionConfig;
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@""] sessionConfiguration:sessionConfig];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
    }
    return self;
}

- (NSNumber *)sendRequest:(NdHJHttpRequest *)request complete:(NdHJHttpReponseBlock)complete {

    if (request.requestUrl == nil) {
        return [[NSNumber alloc] initWithInt:0];
    }
    
    NSString *nudgesUrlString = [NSString stringWithFormat:@"/nudges/device/match"];
    NSString *nudgesUrlString1 = [NSString stringWithFormat:@"/nudges/contact"];
    NSString *nudgesUrlString2 = [NSString stringWithFormat:@"/nudges/socket"];
    
    if ([request.requestUrl containsString:nudgesUrlString] || [request.requestUrl containsString:nudgesUrlString1] || [request.requestUrl containsString:nudgesUrlString2]) {
        NSString *str = [self sort:request.requestParams];
        //accNbr=9202106404&adviceCode=Nudges&appId=ditoapp&channelCode=Nudges&deviceSystem=IOS&identityId=1135596&identityType=2&random=595212E7-63F3-4794-9368-05AC9E40F90E
        NSLog(@"str:%@",str);
        NSString *contentMd5 = [self getmd5WithString:str];// e9d58c5844a19dacd21bd0fa5a0637d7
        NSLog(@"contentMd5:%@",contentMd5);
        NSString *timestamp = [TKUtils timestamp]; // 1662616998718
//                NSString *timestamp = [NdIMClientChatUtil getNowGMTDateStr];
        NSString *data = [NSString stringWithFormat:@"%@\n%@\n%@",[HJNudgesManager sharedInstance].configParametersModel.appId,contentMd5,timestamp]; // hmacKey:@"MzUzOWQ2YzY4NjJmYWMzOWQ5ZGIxMjFm"]
        NSString *hmacSHA1Sign = [[[[NdIMClientChatUtil hmacSha1:data hmacKey:[NdIMConfigSingleton sharedInstance].secretKey] hexLower] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
//                NSData *signatureData =[hmacSHA1Sign dataUsingEncoding:NSUTF8StringEncoding];
//                NSLog(@"signatureData:%@",signatureData);
//                NSString *signcode = [[NSString alloc] initWithData:signatureData encoding:NSUTF8StringEncoding];
//        [serializer setValue:hmacSHA1Sign forHTTPHeaderField:@"Authorization"];
//        [serializer setValue:[TKUtils timestamp] forHTTPHeaderField:@"X-Date"];
        
        [request.requestHeaderDict setValue:hmacSHA1Sign forKey:@"Authorization"];
        [request.requestHeaderDict setValue:timestamp forKey:@"X-Date"];
      
        NSLog(@"国际化语言标识:%@",[HJNudgesManager sharedInstance].configParametersModel.locale);
        NSString *lang = [HJNudgesManager sharedInstance].configParametersModel.locale;
        [request.requestHeaderDict setValue:lang forKey:@"locale"];
      
      
        NSLog(@"token:%@",[HJNudgesManager sharedInstance].configParametersModel.token);
      NSString *token = [HJNudgesManager sharedInstance].configParametersModel.token;
      [request.requestHeaderDict setValue:token forKey:@"token"];
    }
    
  
    AFHTTPRequestSerializer *serializer = [self p_requestSerializerWithRequest:request];
    serializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
    NSString *httpMethod = [self p_httpMethod:request.httpMethod];

    NSString *url = ([request.requestUrl containsString:nudgesUrlString] || [request.requestUrl containsString:nudgesUrlString1] || [request.requestUrl containsString:nudgesUrlString2]) ? request.requestUrl : [request.baseUrl stringByAppendingString:request.requestUrl];
    
    HJLog(@"========请求体打印开始:\n%@\n========",request.requestUrl);
    HJLog(@"RequestUrl=====\n%@\n==params==\n%@\n===requestHeader====\n%@\n",url,[[request.requestParams jsonPrettyStringEncoded] jsonStrHandle],[[request.requestHeaderDict jsonPrettyStringEncoded] jsonStrHandle]);
    HJLog(@"========请求体打印结束========");

    // 对URL做特殊字符处理
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSMutableURLRequest *urlRequest = [serializer requestWithMethod:httpMethod URLString:url parameters:request.requestParams error:nil];
    
    NSURLSessionDataTask *dataTask = [_sessionManager dataTaskWithRequest:urlRequest uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id _Nullable responseObject, NSError * _Nullable error) {
        NSHTTPURLResponse *urlResp = (NSHTTPURLResponse *)response;
        //        NSLog(@"urlResp======%ld %@ %@ %@", urlResp.statusCode,httpMethod,request.requestUrl,urlResp.allHeaderFields);
        if (!IsNilOrNull_Nd(responseObject)) {

//            NSLog(@"urlResp======%ld\n%@\n%@\n%@\n%@", urlResp.statusCode,httpMethod,request.requestUrl,urlResp.allHeaderFields,[self jsonToString:responseObject]);

            NdHJHttpReponse *resp = [[NdHJHttpReponse alloc] initWithRequestId:@(dataTask.taskIdentifier)
                                                              responseData:responseObject
                                                           httpURLResponse:urlResp
                                                                     error:error
                                                                statusCode:urlResp.statusCode];
            complete ? complete(resp) : nil;
        }
    }];
    NSNumber *taskId = [NSNumber numberWithUnsignedLong:[dataTask taskIdentifier]];
//    self.requestTaskDict[taskId] = dataTask;
    [dataTask resume];
    return taskId;
    
}

- (void)cancelRequestWithTaskId:(NSNumber *)taskId {
    
    NSURLSessionDataTask *dataTask = self.requestTaskDict[taskId];
    [dataTask cancel];
    [self.requestTaskDict removeObjectForKey:taskId];
}

- (AFHTTPRequestSerializer *)p_requestSerializerWithRequest:(NdHJHttpRequest *)request {
    AFHTTPRequestSerializer *serializer = nil;
    if (request.requestSerializerType == NdHJRequestSerializerTypeJSON) {
        serializer = [AFJSONRequestSerializer serializer];
    }
    else
    {
        serializer = [AFHTTPRequestSerializer serializer];
    }
    serializer.timeoutInterval = request.timeoutInterval;
    // 请求头
    NSDictionary *headerDict = request.requestHeaderDict;
    if (headerDict != nil) {
        for (NSString *headerField in headerDict.allKeys) {
            NSString *value = headerDict[headerField];
            [serializer setValue:value forHTTPHeaderField:headerField];
        }
    }
    else
    {
        NSDictionary *header = [NdHJHttpConfiguration sharedInstance].requestHeaderDict;
        for (NSString *headerField in header.allKeys) {
            NSString *value = headerDict[headerField];
            [serializer setValue:value forHTTPHeaderField:headerField];
        }
    }
    //请求头添加signcode校验
    [serializer setValue:[TKUtils timestamp] forHTTPHeaderField:@"timestamp"];
//    [serializer setValue:[HJAppDataManager sharedInstance].authToken forHTTPHeaderField:@"auth-token"];
//    [serializer setValue:[HJAppDataManager sharedInstance].authToken forHTTPHeaderField:@"authtoken"];
//    NSString *signToken = @"";
//    if ([HJAppDataManager sharedInstance].authToken.length > 0) {
//        signToken = [HJAppDataManager sharedInstance].authToken;
//    }
//    if (NdHJHttpMethodGET == request.httpMethod) {
//        [serializer setValue:[securityUtility sha256HashFor:[[request.requestUrl substringFromIndex:10] stringByAppendingString:[NSString stringWithFormat:@"%@%@", signToken,@"32BytesString"]]] forHTTPHeaderField:@"signcode"];
//        
//    } else {
//        NSString *signParamdic = @"";
//        if ([request.requestParams allKeys].count > 0) {
//            signParamdic = [NdHJHandelJson convert2JSONWithDictionary:request.requestParams];
//        }
//      
//        
//
//        
//            NSString *signStr = [NSString stringWithFormat:@"%@%@%@%@", [request.requestUrl substringFromIndex:10],[HJUtils regexSignWithInputString:signParamdic],signToken, @"32BytesString"];
//            [serializer setValue:[securityUtility sha256HashFor:[signStr stringByReplacingOccurrencesOfString:@"null" withString:@""]]
//    }
    
    return serializer;
}

- (NSString *)p_httpMethod:(NdHJHttpMethod )method {
    switch (method) {
        case NdHJHttpMethodGET:
            return @"GET";
            break;
        case NdHJHttpMethodPOST:
            return @"POST";
            break;
        case NdHJHttpMethodPUT:
            return @"PUT";
            break;
        case NdHJHttpMethodDELETE:
            return @"DELETE";
            break;
        case NdHJHttpMethodPATCH:
            return @"PATCH";
            break;
        default:
            return @"GET";
            break;
    }
    return @"GET";
}

#pragma mark -- lazy load

- (NSMutableDictionary *)requestTaskDict {
    if (!_requestTaskDict) {
        _requestTaskDict = [NSMutableDictionary dictionary];
    }
    return _requestTaskDict;
}

#pragma mark -- 排序
- (NSString *)sort:(NSDictionary *)requestParams {
    if (!requestParams || [requestParams allKeys] == 0) {
        return @"";
    }
    //将所有的key放进数组
    NSArray *allKeyArray = [requestParams allKeys];
    //序列化器对数组进行排序的block 返回值为排序后的数组
    NSArray *afterSortKeyArray = [allKeyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id _Nonnull obj2) {
        //排序操作
        NSComparisonResult resuest = [obj1 compare:obj2];
        return resuest;
    }];
    //排序好的字典
    NSLog(@"afterSortKeyArray:%@",afterSortKeyArray);
    NSString *tempStr = @"";
    //通过排列的key值获取value
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *sortsing in afterSortKeyArray) {
        //格式化一下 防止有些value不是string
        NSString *valueString = [NSString stringWithFormat:@"%@",[requestParams objectForKey:sortsing]];
        if(valueString.length>0) {
            [valueArray addObject:valueString];
            tempStr=[NSString stringWithFormat:@"%@%@=%@&",tempStr,sortsing,valueString];
        }
    }
    //去除最后一个&符号
    if(tempStr.length>0){
        tempStr=[tempStr substringToIndex:([tempStr length]-1)];
    }
    //排序好的对应值
    //  NSLog(@"valueArray:%@",valueArray);
    //最终参数
    NSLog(@"tempStr:%@",tempStr);
    //md5加密
    // NSLog(@"tempStr:%@",[self getmd5WithString:tempStr]);
    return tempStr;
}

#define CC_MD5_DIGEST_LENGTH 16


//字符串MD5加密
- (NSString*)getmd5WithString:(NSString *)string {
    const char* original_str=[string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02x", digist[i]];//小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
   // return [outPutStr lowercaseString];
    return outPutStr;
}


//HmacSHA1加密；
- (NSString *)HmacSha1:(NSString *)key data:(NSString *)data {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    //Sha256:
    // unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    //CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    //sha1
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];

    NSString *hash = [HMAC base64EncodedStringWithOptions:0];//将加密结果进行一次BASE64编码。
    return hash;
}

@end
