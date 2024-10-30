//
//  UIImage+SVGManager.h
//  QCStarView
//
//  Created by 李标 on 2022/9/13.
//  Copyright © 2022 BYX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (SVGManager)

/**
 show svg image
 
 @param name svg name
 @param size image size
 @return svg image
 */
+ (UIImage *)svgImageNamed:(NSString *)name size:(CGSize)size;

/**
 show svg image
 
 @param name svg name
 @param size image size
 @param tintColor image color
 @return svg image
 */
+ (UIImage *)svgImageNamed:(NSString *)name size:(CGSize)size tintColor:(NSString *)tintColor;

@end


@interface UIColor (ColorChange)

// 颜色转换：iOS中（以#开头）十六进制的颜色转换为UIColor(RGB)
+ (UIColor *) colorWithHexString: (NSString *)color;

@end

NS_ASSUME_NONNULL_END
