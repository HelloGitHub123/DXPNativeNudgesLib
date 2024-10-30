//
//  UIImage+NdCategory.h
//  DITOApp
//
//  Created by leo on 2020/12/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (NdCategory)

/// 颜色转换为背景图片
/// @param color 颜色
+ (UIImage *)imageWithColor:(UIColor *)color;
- (NSData *)compressWithMaxLength:(NSUInteger)maxLength;
+ (UIImage *)triangleImageWithSize:(CGSize)size tintColor:(UIColor *)tintColor;

//从图片正中间拉伸
+(UIImage *)resizingMiddleStretchWithImage:(UIImage *)image;
//平铺
+(UIImage *)resizingModeTileWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
