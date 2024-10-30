//
//  UIView+NdAddGradualLayer.m
//  WYGColorChange
//
//  Created by agon on 2017/7/5.
//  Copyright © 2017年 agon. All rights reserved.
//

#import "UIView+NdAddGradualLayer.h"
#import "TKUtils.h"

@implementation UIView (NdAddGradualLayer)

-(void)addGradualLayerWithColors:(NSArray *)colors startPoint:(CGPoint)stratPoint endPoint:(CGPoint)endPoint{
    CAGradientLayer *_gradientLayer = [CAGradientLayer layer];

    _gradientLayer.startPoint = stratPoint;//第一个颜色开始渐变的位置
    _gradientLayer.endPoint = endPoint;//最后一个颜色结束的位置
    _gradientLayer.frame = self.bounds;//设置渐变图层的大小
    if (colors == nil) {
        //颜色为空时预置的颜色
        _gradientLayer.colors = @[UIColorFromRGB_Nd(0x660066),
                                  UIColorFromRGB_Nd(0x993399),
                                  ];
    }else {
        _gradientLayer.colors = colors;
    }
    
        [self.layer insertSublayer:_gradientLayer atIndex:0];
}

//绘制渐变色颜色的方法
- (CAGradientLayer *)setGradualChangingColorFromColor:(NSString *)fromHexColorStr toColor:(NSString *)toHexColorStr startPoint:(CGPoint)stratPoint endPoint:(CGPoint)endPoint{
    
    //    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    
    //  创建渐变色数组，需要转换为CGColor颜色 （因为这个按钮有三段变色，所以有三个元素）
    gradientLayer.colors = @[(__bridge id)[self colorWithHex:fromHexColorStr].CGColor,(__bridge id)[self colorWithHex:toHexColorStr].CGColor,
                             (__bridge id)[self colorWithHex:fromHexColorStr].CGColor];
    
    
    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0.01, 0.486);
    gradientLayer.endPoint = CGPointMake(0.92,0.514);
    
    //  设置颜色变化点，取值范围 0.0~1.0 （所以变化点有三个）
    gradientLayer.locations = @[@0,@1];
    
    return gradientLayer;
}

- (CAGradientLayer *)setGradualChangingColorFromColor:(NSString *)fromHexColorStr toColor:(NSString *)toHexColorStr startPoint:(CGPoint)stratPoint endPoint:(CGPoint)endPoint frame:(CGRect)frame {
    //    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = frame;
    
    //  创建渐变色数组，需要转换为CGColor颜色 （因为这个按钮有三段变色，所以有三个元素）
    gradientLayer.colors = @[(__bridge id)[self colorWithHex:fromHexColorStr].CGColor,(__bridge id)[self colorWithHex:toHexColorStr].CGColor,
                             (__bridge id)[self colorWithHex:fromHexColorStr].CGColor];
    
    
    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0.01, 0.486);
    gradientLayer.endPoint = CGPointMake(0.92,0.514);
    
    //  设置颜色变化点，取值范围 0.0~1.0 （所以变化点有三个）
    gradientLayer.locations = @[@0,@1];
    
    return gradientLayer;
}

//获取16进制颜色的方法
-(UIColor *)colorWithHex:(NSString *)hexColor {
    hexColor = [hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([hexColor length] < 6) {
        return nil;
    }
    if ([hexColor hasPrefix:@"#"]) {
        hexColor = [hexColor substringFromIndex:1];
    }
    NSRange range;
    range.length = 2;
    range.location = 0;
    NSString *rs = [hexColor substringWithRange:range];
    range.location = 2;
    NSString *gs = [hexColor substringWithRange:range];
    range.location = 4;
    NSString *bs = [hexColor substringWithRange:range];
    unsigned int r, g, b, a;
    [[NSScanner scannerWithString:rs] scanHexInt:&r];
    [[NSScanner scannerWithString:gs] scanHexInt:&g];
    [[NSScanner scannerWithString:bs] scanHexInt:&b];
    if ([hexColor length] == 8) {
        range.location = 4;
        NSString *as = [hexColor substringWithRange:range];
        [[NSScanner scannerWithString:as] scanHexInt:&a];
    } else {
        a = 255;
    }
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:((float)a / 255.0f)];
}

/**
  ** lineView:       需要绘制成虚线的view
  ** lineLength:     虚线的宽度
  ** lineSpacing:    虚线的间距
  ** lineColor:      虚线的颜色
*/
+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor {
    
      CAShapeLayer *shapeLayer = [CAShapeLayer layer];
      [shapeLayer setBounds:lineView.bounds];
      [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
      [shapeLayer setFillColor:[UIColor clearColor].CGColor];
      //  设置虚线颜色为blackColor
      [shapeLayer setStrokeColor:lineColor.CGColor];
      //  设置虚线宽度
      [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
      [shapeLayer setLineJoin:kCALineJoinRound];
      //  设置线宽，线间距
      [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
      //  设置路径
      CGMutablePathRef path = CGPathCreateMutable();
      CGPathMoveToPoint(path, NULL, 0, 0);
      CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
      [shapeLayer setPath:path];
      CGPathRelease(path);
      //  把绘制好的虚线添加上来
      [lineView.layer addSublayer:shapeLayer];
}

// 设置背景色圆半径方向渐变
- (void)drawRadialGradient:(CGContextRef)context path:(CGPathRef)path startColor:(CGColorRef)startColor endColor:(CGColorRef)endColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
     
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
     
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGRect pathRect = CGPathGetBoundingBox(path);
    CGPoint center = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMidY(pathRect));
    CGFloat radius = MAX(pathRect.size.width / 2.0, pathRect.size.height / 2.0) * sqrt(2);
     
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextEOClip(context);
     
    CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, 0);
     
    CGContextRestoreGState(context);
     
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
