//
//  NdHJHttpModel.m
//  DITOApp
//
//  Created by mac on 2021/7/8.
//

#import "NdHJHttpModel.h"
#import "Nudges.h"

//#import <YYModel/YYModel.h>
 @implementation NdHJHttpModel
MJCodingImplementation
- (id)init{
    self = [super init];
    
    if (self) {
        
        if ([self respondsToSelector:@selector(hj_replacedKeyFromPropertyName)]&&[self hj_replacedKeyFromPropertyName]) {
            [self.class mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                return [self hj_replacedKeyFromPropertyName];
            }];
        }
        if ([self respondsToSelector:@selector(hj_setupObjectClassInArray)]&&[self hj_setupObjectClassInArray]) {
            [self.class mj_setupObjectClassInArray:^NSDictionary *{
                return [self hj_setupObjectClassInArray];
            }];
        }
       
        [self setupObject];
    }
    
    return self;
}
+ (id)hj_modeWIthJSon:(NSString*)jsonStr{
    NSDictionary* dic = [self dictionaryWithJsonString:jsonStr];
    return [self mj_objectWithKeyValues:dic];
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return @{};
    }
    return dic;
}
- (void)setupObject{
    //子类重写
}
- (NSDictionary *)hj_replacedKeyFromPropertyName{
    //子类重写
    return @{
              };
    return nil;
}
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
    if (property.type.typeClass == [NSString class]) {
        if ([self isEmpty:oldValue] || !oldValue) {
            return @"";
        }
    }
    return oldValue;
}

- (BOOL)isEmpty:(NSString*)text {
    if ([text isEqual:[NSNull null]]) {
        return YES;
    } else if ([text isKindOfClass:[NSNull class]]) {
        return YES;
    } else if (text == nil) {
        return YES;
    }
    return NO;
}

 
 
 
- (NSDictionary *)hj_setupObjectClassInArray{
     //子类重写
    return nil;
}

+ (void)requestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
                  httpMethod:(NdHJHttpMethod)httpMethod
              isReturnList:(BOOL)isReturnList
              responseBlock:(ndresponseHandler)responseDataBlock
{
    [self requestActionStr:actionStr paramDict:paramDict httpMethod:httpMethod needSuccessCode:YES delegate:nil retunSelf:nil
              isReturnList:isReturnList responseBlock:responseDataBlock error:nil];
}
+ (void)requestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
                  httpMethod:(NdHJHttpMethod)httpMethod
              needSuccessCode:(BOOL)needSuccessCode
              delegate:(id<NdHJVMRequestDelegate>)delegate
               retunSelf:(id)retunSelf
              isReturnList:(BOOL)isReturnList
              responseBlock:(ndresponseHandler)responseDataBlock
                   error:(ndresponseHandler)errorDataBlock
{
    NdHJHttpRequest *request = [[NdHJHttpRequest alloc] init];
    request.requestUrl = actionStr;
    request.httpMethod = httpMethod;
    request.requestParams = paramDict;

    @weakify(self);
    [[NdHJHttpSessionManager sharedInstance] sendRequest:request complete:^(NdHJHttpReponse * _Nonnull response) {
        @strongify(self);
        if ((!response.error)&&response.responseData) {
            NSError *error;
            id res = [NSJSONSerialization JSONObjectWithData:response.responseData options:NSJSONReadingAllowFragments error:nil];
            if (res) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:res options:NSJSONWritingPrettyPrinted error:&error];
                NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                NdHJHttpModel* data;
                if (isReturnList)
                {
                    data = [self mj_objectArrayWithKeyValuesArray:response.responseData];
                }
                else
                {
                  data = [self mj_objectWithKeyValues:response.responseData];

                }
                !responseDataBlock?:responseDataBlock(data,response);
                if (needSuccessCode) {
                    if ([delegate respondsToSelector:@selector(requestSuccess:method:)]&&data.code==200) {
                        [delegate requestSuccess:retunSelf method:actionStr];
                    }
                    if ([delegate respondsToSelector:@selector(requestFailure:method:)]&&data.code!=200)
                    {
                        [delegate requestFailure:retunSelf method:actionStr];

                    }
                }
                else
                {
                    if ([delegate respondsToSelector:@selector(requestSuccess:method:)]) {
                        [delegate requestSuccess:retunSelf method:actionStr];
                    }
                }
                
            }
            else{
                !errorDataBlock?:errorDataBlock(nil,response);
                if ([delegate respondsToSelector:@selector(requestFailure:method:)]){
    //                NSError *error = response.serverError;
    //                self.error = error;
                    [delegate requestFailure:retunSelf method:actionStr];
                }

            }
       
            

            
        }
        else
        {
           
            !errorDataBlock?:errorDataBlock(nil,response);
            if ([delegate respondsToSelector:@selector(requestFailure:method:)]){
//                NSError *error = response.serverError;
//                self.error = error;
                [delegate requestFailure:retunSelf method:actionStr];
            }
        }
    }];
}
 
+ (void)getRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
              responseBlock:(ndresponseHandler)responseDataBlock
{
    [self getRequestActionStr:actionStr paramDict:paramDict responseBlock:responseDataBlock error:nil];
}

+ (void)postRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
              responseBlock:(ndresponseHandler)responseDataBlock
{
    [self postRequestActionStr:actionStr paramDict:paramDict responseBlock:responseDataBlock error:nil];

}

+ (void)postRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
              delegate:(id<NdHJVMRequestDelegate>)delegate
               retunSelf:(id)retunSelf
              responseBlock:(ndresponseHandler)responseDataBlock
                   error:(ndresponseHandler)errorDataBlock
{
    [self requestActionStr:actionStr
                 paramDict:paramDict
                httpMethod:NdHJHttpMethodPOST
           needSuccessCode:YES
                  delegate:delegate
                 retunSelf:retunSelf
              isReturnList:NO
             responseBlock:responseDataBlock
                     error:errorDataBlock];

}

+ (void)postRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
             needSuccessCode:(BOOL)needSuccessCode
              delegate:(id<NdHJVMRequestDelegate>)delegate
               retunSelf:(id)retunSelf
              responseBlock:(ndresponseHandler)responseDataBlock
                   error:(ndresponseHandler)errorDataBlock
{
    [self requestActionStr:actionStr
                 paramDict:paramDict
                httpMethod:NdHJHttpMethodPOST
           needSuccessCode:needSuccessCode
                  delegate:delegate
                 retunSelf:retunSelf
              isReturnList:NO
             responseBlock:responseDataBlock
                     error:errorDataBlock];

}


+ (void)getRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
              responseBlock:(ndresponseHandler)responseDataBlock
                      error:(ndresponseHandler)errorDataBlock

{
    [self requestActionStr:actionStr paramDict:paramDict httpMethod:NdHJHttpMethodGET needSuccessCode:YES delegate:nil  retunSelf:nil  isReturnList:NO responseBlock:responseDataBlock error:errorDataBlock];

}
+ (void)getRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
              delegate:(id<NdHJVMRequestDelegate>)delegate
               retunSelf:(id)retunSelf
              responseBlock:(ndresponseHandler)responseDataBlock
                   error:(ndresponseHandler)errorDataBlock
{
    [self requestActionStr:actionStr
                 paramDict:paramDict
                httpMethod:NdHJHttpMethodGET
           needSuccessCode:YES
                  delegate:delegate
                 retunSelf:retunSelf
              isReturnList:NO
             responseBlock:responseDataBlock
                     error:errorDataBlock];

}

+ (void)getRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
            needSuccessCode:needSuccessCode
              delegate:(id<NdHJVMRequestDelegate>)delegate
               retunSelf:(id)retunSelf
              responseBlock:(ndresponseHandler)responseDataBlock
                   error:(ndresponseHandler)errorDataBlock
{
    [self requestActionStr:actionStr
                 paramDict:paramDict
                httpMethod:NdHJHttpMethodGET
           needSuccessCode:needSuccessCode
                  delegate:delegate
                 retunSelf:retunSelf
              isReturnList:NO
             responseBlock:responseDataBlock
                     error:errorDataBlock];

}

+ (void)postRequestActionStr:(NSString *)actionStr
                   paramDict:(id)paramDict
               responseBlock:(ndresponseHandler)responseDataBlock
                       error:(ndresponseHandler)errorDataBlock{
    [self requestActionStr:actionStr paramDict:paramDict httpMethod:NdHJHttpMethodPOST needSuccessCode:YES delegate:nil  retunSelf:nil  isReturnList:NO responseBlock:responseDataBlock error:errorDataBlock];

}
@end

@implementation NdHJHttpListModel
+ (void)getListRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
              responseBlock:(ndresponseListHandler)responseDataBlock
{
    [self getListRequestActionStr:actionStr paramDict:paramDict responseBlock:responseDataBlock error:nil];
}

+ (void)postListRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
              responseBlock:(ndresponseListHandler)responseDataBlock
{
    [self postListRequestActionStr:actionStr paramDict:paramDict responseBlock:responseDataBlock error:nil];
}

+ (void)getListRequestActionStr:(NSString *)actionStr
                      paramDict:(id)paramDict
                  responseBlock:(ndresponseListHandler)responseDataBlock
                          error:(ndresponseHandler)errorDataBlock
{
    [self requestActionStr:actionStr paramDict:paramDict httpMethod:NdHJHttpMethodGET needSuccessCode:YES delegate:nil  retunSelf:nil isReturnList:YES responseBlock:responseDataBlock error:errorDataBlock];

}

+ (void)postListRequestActionStr:(NSString *)actionStr
                       paramDict:(id)paramDict
                   responseBlock:(ndresponseListHandler)responseDataBlock
                           error:(ndresponseHandler)errorDataBlock
{
    [self requestActionStr:actionStr paramDict:paramDict httpMethod:NdHJHttpMethodPOST needSuccessCode:YES delegate:nil  retunSelf:nil  isReturnList:YES responseBlock:responseDataBlock error:errorDataBlock];

}
@end

@implementation NdHJHttpDicModel
@end

@implementation NdHJHttpStrModel
@end
