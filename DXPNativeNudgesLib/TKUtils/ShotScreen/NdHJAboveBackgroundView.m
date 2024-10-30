//
//  NdHJAboveBackgroundView.m
//  MPTCLPMall
//
//  Created by Lee on 2021/12/2.
//  Copyright © 2021 OO. All rights reserved.
//

#import "NdHJAboveBackgroundView.h"

@interface NdHJAboveBackgroundView()
@property (nonatomic, strong) UIImageView *screenShotImageV;

@end



@implementation NdHJAboveBackgroundView
+ (instancetype)shared {
    
    static dispatch_once_t onceToken;
    static NdHJAboveBackgroundView *aboveView = nil;
    dispatch_once(&onceToken, ^{
       aboveView = [[self alloc] init];
    });
    return aboveView;
}

- (void)screenShot {
    CGSize imageSize = CGSizeZero;
    //屏幕朝向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //按理应取用户看见的那个window
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    //截屏图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //截屏图片t处理后
    UIImage *gaussianImage = [self coreGaussianBlurImage:image blurNumber:8];
    //生成控件
    UIImageView *bgImgv = [[UIImageView alloc] initWithImage:gaussianImage];
    bgImgv.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.screenShotImageV = bgImgv;
}


- (UIImage *)currentScreenShot {
    CGSize imageSize = CGSizeZero;
    //屏幕朝向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation))
        imageSize = [UIScreen mainScreen].bounds.size;
    else
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //按理应取用户看见的那个window
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    //截屏图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //截屏图片t处理后
//    UIImage *gaussianImage = [self coreGaussianBlurImage:image blurNumber:8];
//    //生成控件
//    UIImageView *bgImgv = [[UIImageView alloc] initWithImage:gaussianImage];
//    bgImgv.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
//    self.screenShotImageV = bgImgv;
    return image;
}

/**
 高斯模糊 处理

 @param image 要处理的image
 @param blur 模糊度
 @return 处理后的image
 */
- (UIImage *)coreGaussianBlurImage:(UIImage * _Nonnull)image  blurNumber:(CGFloat)blur{
    
    if (!image) {
        return nil;
    }
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:blur] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *blurImage = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return blurImage;
    
}
//显示window
- (void)show {
    
    [[UIApplication sharedApplication].delegate.window addSubview:self.screenShotImageV];
}
//隐藏window
- (void)hidden {
    
    [self.screenShotImageV removeFromSuperview];
}

@end
