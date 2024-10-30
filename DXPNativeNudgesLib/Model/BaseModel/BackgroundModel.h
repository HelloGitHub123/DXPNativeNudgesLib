//
//  BackgroundModel.h
//  DITOApp
//
//  Created by 李标 on 2022/5/13.
//  背景

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface BackgroundModel : NdHJHttpModel

/// eg: 是否设置背景色 取值 true/false
@property (nonatomic, assign) BOOL enabled;
/// eg: 背景色类型 取值 1-Solid；2-Gradient；3-Image
@property (nonatomic, assign) KBackgroundType type;
/// eg: 背景色，使用取色器组件；16进制编码方式保存颜色
@property (nonatomic, copy) NSString *backgroundColor;
/// eg: 透明度，只有配置实色才可以选择透明度
@property (nonatomic, assign) NSInteger opacity;
/// eg: 渐变类型 1-Linear；2-Radial；3-Angular
@property (nonatomic, assign) KGradientType gradientType;
/// eg: 渐变色开始颜色
@property (nonatomic, copy) NSString *gradientStartColor;
/// eg: 渐变色结束颜色
@property (nonatomic, copy) NSString *gradientEndColor;
/// eg: 图片渲染类型，1-Fill, 2-Fit, 3-Stretch
@property (nonatomic, assign) KImageType imageType;
/// eg: 图片地址
@property (nonatomic, copy) NSString *imageUrl;
@end

NS_ASSUME_NONNULL_END
