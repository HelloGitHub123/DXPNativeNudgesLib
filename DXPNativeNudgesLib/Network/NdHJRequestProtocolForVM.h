//
//  NdHJRequestProtocolForVM.h
//  MPTCLPMall
//
//  Created by leo on 2020/9/16.
//  Copyright © 2020 OO. All rights reserved.
//

#ifndef NdHJRequestProtocolForVM_h
#define NdHJRequestProtocolForVM_h

@protocol NdHJVMRequestDelegate <NSObject>
@optional
// 请求成功
- (void)requestSuccess:(NSObject *)vm;
// 请求失败
- (void)requestFailure:(NSObject *)vm;

// 请求开始
- (void)requestStart:(NSObject *)vm;
/// 请求开始
/// @param vm vm
/// @param methodFlag 方法标识
- (void)requestStart:(NSObject *)vm method:(NSString *)methodFlag;
/// 请求成功
/// @param vm vm
/// @param methodFlag 方法标识
- (void)requestSuccess:(NSObject *)vm method:(NSString *)methodFlag;
/// 请求失败
/// @param vm vm
/// @param methodFlag 方法标识
- (void)requestFailure:(NSObject *)vm method:(NSString *)methodFlag;

@end
#endif /* NdHJRequestProtocolForVM_h */
