//
//  NdHJHttpSessionManager.h
//  DITOApp
//
//  Created by leo on 2020/11/23.
//

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^NdHJHttpReponseBlock)(NdHJHttpReponse *response);
typedef void(^NdHttpSuccessBlock)(id Json, NSString *X);
typedef void(^NdHttpFailureBlock)(NSError *error, NSString *X);
typedef void(^NdHttpDownLoadProgressBlock)(CGFloat progress);
typedef void(^NdHttpUploadProgressBlock)(CGFloat progress);

@interface NdHJHttpSessionManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *requestTaskDict;



+ (instancetype)sharedInstance;


- (NSNumber *)sendRequest:(NdHJHttpRequest *)request complete:(NdHJHttpReponseBlock)complete;
- (NSNumber *)sendDownloadRequest:(NdHJHttpRequest *)request complete:(NdHJHttpReponseBlock)complete;
- (void)uploadImageWithPath:(NSString *)path
                     params:(NSDictionary *)params
                  thumbName:(NSString *)imagekey
                   fileName:(NSString *)fileName
                      image:(UIImage *)image
                    success:(NdHttpSuccessBlock)success
                    failure:(NdHttpFailureBlock)failure
                   progress:(NdHttpUploadProgressBlock)progress;

- (void)cancelRequestWithTaskId:(NSNumber *)taskId;

// 401弹框属性 多个异步请求只弹框一次
@property (nonatomic, assign) BOOL tokenExpireFlag;

@end

NS_ASSUME_NONNULL_END
