//
//  NdHJAboveBackgroundView.h
//  MPTCLPMall
//
//  Created by Lee on 2021/12/2.
//  Copyright © 2021 OO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface NdHJAboveBackgroundView : NSObject
/**
 单例创建对象

 @return self
 */
+ (instancetype)shared;

/**
 截屏处理
 */
- (void)screenShot;
- (void)show;
- (void)hidden;
///获取当前界面截图
- (UIImage *)currentScreenShot;
@end

NS_ASSUME_NONNULL_END
