//
//  NdHJHttpModel.h
//  DITOApp
//
//  Created by mac on 2021/7/8.
//

#import <Foundation/Foundation.h>
#import "NdHJHttpReponse.h"
#import "NdHJRequestProtocolForVM.h"

typedef void (^ndresponseHandler)(_Nullable id dataObj,NdHJHttpReponse * _Nonnull  resp);
typedef void (^ndresponseListHandler)(NSArray <id>* _Nullable  dataObj,NdHJHttpReponse * _Nonnull  resp);

NS_ASSUME_NONNULL_BEGIN

@interface NdHJHttpModel : NSObject

//@property (assign, nonatomic) NSInteger error;
@property (copy, nonatomic) NSString *msg;
@property (nonatomic, assign) BOOL isSuccess;

//@property (strong, nonatomic) NSDictionary *data;
@property (nonatomic, copy) NSString * retMsg;
@property (nonatomic, copy) NSString * retCode;
@property (strong, nonatomic) NSError *responError;

@property (nonatomic, copy) NSString * resultMsg;
//@property (nonatomic, copy) NSString * data;
@property (nonatomic, copy) NSString * resultCode;
@property (nonatomic, assign) NSInteger  code;

@property (strong, nonatomic) NSDictionary* errDict;

@property (strong, nonatomic) NdHJHttpReponse *rawResponse;

@property (strong, nonatomic) NSDictionary* reqDict;

///init初始化时调用,子类重写
- (void)setupObject;
+ (id)hj_modeWIthJSon:(NSString*)jsonStr;
///返回要替换的字段字典
- (NSDictionary *)hj_replacedKeyFromPropertyName;
///返回对应的数组字段
- (NSDictionary *)hj_setupObjectClassInArray;
+ (void)getRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
              responseBlock:(ndresponseHandler)responseDataBlock;

+ (void)postRequestActionStr:(NSString *)actionStr
                   paramDict:(id)paramDict
               responseBlock:(ndresponseHandler)responseDataBlock;


+ (void)postRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
              delegate:(id<NdHJVMRequestDelegate>)delegate
               retunSelf:(id)retunSelf
              responseBlock:(ndresponseHandler)responseDataBlock
                       error:(ndresponseHandler)errorDataBlock;

+ (void)postRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
             needSuccessCode:(BOOL)needSuccessCode
              delegate:(id<NdHJVMRequestDelegate>)delegate
               retunSelf:(id)retunSelf
              responseBlock:(ndresponseHandler)responseDataBlock
                       error:(ndresponseHandler)errorDataBlock;

+ (void)getRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
              responseBlock:(ndresponseHandler)responseDataBlock
                      error:(ndresponseHandler)errorDataBlock;

+ (void)postRequestActionStr:(NSString *)actionStr
                   paramDict:(id)paramDict
               responseBlock:(ndresponseHandler)responseDataBlock
                       error:(ndresponseHandler)errorDataBlock;
+ (void)getRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
              delegate:(id<NdHJVMRequestDelegate>)delegate
               retunSelf:(id)retunSelf
              responseBlock:(ndresponseHandler)responseDataBlock
                      error:(ndresponseHandler)errorDataBlock;

+ (void)getRequestActionStr:(NSString *)actionStr
                  paramDict:(id)paramDict
            needSuccessCode:needSuccessCode
              delegate:(id<NdHJVMRequestDelegate>)delegate
               retunSelf:(id)retunSelf
              responseBlock:(ndresponseHandler)responseDataBlock
                      error:(ndresponseHandler)errorDataBlock;
@end



//第一层为数组的继承这个方法
@interface NdHJHttpListModel:NdHJHttpModel
+ (void)getListRequestActionStr:(NSString *)actionStr
                      paramDict:(id)paramDict
                  responseBlock:(ndresponseListHandler)responseDataBlock;

+ (void)postListRequestActionStr:(NSString *)actionStr
                       paramDict:(id)paramDict
                   responseBlock:(ndresponseListHandler)responseDataBlock;

+ (void)getListRequestActionStr:(NSString *)actionStr
                      paramDict:(id)paramDict
                  responseBlock:(ndresponseListHandler)responseDataBlock
                          error:(ndresponseHandler)errorDataBlock;

+ (void)postListRequestActionStr:(NSString *)actionStr
                       paramDict:(id)paramDict
                   responseBlock:(ndresponseListHandler)responseDataBlock
                           error:(ndresponseHandler)errorDataBlock;

@end

@interface NdHJHttpDicModel : NdHJHttpModel
@property (nonatomic, strong) NSDictionary *data;
@end

@interface NdHJHttpStrModel : NdHJHttpModel
@property (nonatomic, copy) NSString *data;
@end
NS_ASSUME_NONNULL_END
