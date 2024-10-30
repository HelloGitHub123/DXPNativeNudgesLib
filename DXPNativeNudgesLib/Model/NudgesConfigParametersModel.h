//
//  NudgesConfigParametersModel.h
//  DITOApp
//
//  Created by 李标 on 2023/5/27.
//  Nudges 配置参数 模型

#import <Foundation/Foundation.h>
#import "NdEnumConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface NudgesConfigParametersModel : NSObject

/// eg:  [必须]websocket IP或者域名 地址
/// 格式: (ws:// 或者 wss:// ) + (IP 或者 域名)
/// 注意: 地址后不要带 ‘/’
@property (nonatomic, copy) NSString *wsSocketIP;

/// eg: [必须] 数据接口地址
/// 格式: (http:// 或者 https:// ) + (IP 或者 域名)
/// 注意: 地址后不要带 ‘/’
@property (nonatomic, copy) NSString *baseUrl;

/// eg: [必须]身份标识身份标识类型： 1、客户类型  2、订户类型。 默认订户类型
@property (nonatomic, assign) KIdentityTypeType identityType;

/// eg: [必须]身份标识: identityType=1时，传客户标识； identityType=2时，传订户标识ID。
@property (nonatomic, assign) NSInteger identityId;

/// eg:[必须]目标对象号码
@property (nonatomic, copy) NSString *accNbr;

/// eg:接触渠道编码
@property (nonatomic, copy) NSString *channelCode;

/// eg:运营位编码
@property (nonatomic, copy) NSString *adviceCode;

/// eg: APP 标识Id
@property (nonatomic, copy) NSString *appId;

// header中国际化语言参数
@property (nonatomic, copy) NSString *locale;

// 
@property (nonatomic, copy) NSString *token;

@end

NS_ASSUME_NONNULL_END
