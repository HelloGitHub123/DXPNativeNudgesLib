//
//  UIView+NdAddGradualLayer.h
//  WYGColorChange
//
//  Created by agon on 2017/7/5.
//  Copyright © 2017年 agon. All rights reserved.
//

#import <UIKit/UIKit.h>

/// <#Description#>
@interface UIView (NdAddGradualLayer)

-(void)addGradualLayerWithColors:(NSArray *)colors startPoint:(CGPoint)stratPoint endPoint:(CGPoint)endPoint;

- (CAGradientLayer *)setGradualChangingColorFromColor:(NSString *)fromHexColorStr toColor:(NSString *)toHexColorStr startPoint:(CGPoint)stratPoint endPoint:(CGPoint)endPoint;

- (CAGradientLayer *)setGradualChangingColorFromColor:(NSString *)fromHexColorStr toColor:(NSString *)toHexColorStr startPoint:(CGPoint)stratPoint endPoint:(CGPoint)endPoint frame:(CGRect)frame;




/// 为视图增加虚线  （宽度默认为虚线的视图的长度）
/// @param lineView 增加虚线的视图
/// @param lineLength 虚线长度
/// @param lineSpacing 虚线间隔
/// @param lineColor 虚线颜色

+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;


// 设置背景色圆半径方向渐变
- (void)drawRadialGradient:(CGContextRef)context path:(CGPathRef)path startColor:(CGColorRef)startColor endColor:(CGColorRef)endColor;

@end
