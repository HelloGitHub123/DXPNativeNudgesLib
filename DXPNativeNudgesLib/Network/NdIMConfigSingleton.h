//
//  NdIMConfigSingleton.h
//  IMDemo
//
//  Created by mac on 2020/7/27.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NdIMConfigSingleton : NSObject

@property (nonatomic, copy) NSString *fileURLStr;
@property (nonatomic, copy) NSString *baseURLStr;
@property (nonatomic, copy) NSString *socketURLStr;
@property (nonatomic, copy) NSString *sysAccount;
@property (nonatomic, copy) NSString *secretKey;
@property (nonatomic, copy) NSString *sha1Key; // 加密key固定标识
@property (nonatomic, copy) NSString *langCode;
@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *custId;
@property (nonatomic, copy) NSString *accNbr;

@property (nonatomic, copy) NSString *dislikeMessageId;//最近被点踩消息的messageId
@property (nonatomic, assign) BOOL sessionS;//是否人工对话状态

+ (NdIMConfigSingleton *)sharedInstance;

@end

NS_ASSUME_NONNULL_END
