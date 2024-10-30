//
//  NdHJHttpReponse.h
//  DITOApp
//
//  Created by leo on 2020/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NdHJHttpReponse : NSObject

@property (nonatomic, copy, readonly) NSNumber *requestId;

@property (nonatomic, copy, readonly) id responseObject;//NSData *responseData;

@property (nonatomic, assign) NSInteger statusCode;

@property (nonatomic, strong, readonly) NSError *serverError;

@property (nonatomic, strong, readonly) NSHTTPURLResponse *httpURLResponse;

@property (nonatomic, copy) NSData *responseData;

@property (nonatomic, strong) NSError *error;

- (instancetype)initWithRequestId:(NSNumber *)requestId
                     responseData:(NSData *)responseData
                  httpURLResponse:(NSHTTPURLResponse *)httpURLResponse
                            error:(NSError *)error statusCode:(NSInteger)statusCode;

@end

NS_ASSUME_NONNULL_END
