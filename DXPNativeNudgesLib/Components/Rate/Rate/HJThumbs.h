//
//  HJThumbs.h
//  DITOApp
//
//  Created by 李标 on 2022/9/17.
//  点赞点踩

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HJThumbs : UIView

@property (nonatomic, copy) NSString *beforeSvgColor; // svg图未选中的颜色
//@property (nonatomic, copy) NSString *svgName; // svg 图片名称
@property (nonatomic, assign) CGFloat iconSize; // 图标大小
@property (nonatomic, assign) CGFloat viewWidth; // 视图宽度
@property (nonatomic, copy) NSString *thumbsUpColor; // 点赞颜色
@property (nonatomic, copy) NSString *thumbsDownColor; // 点踩颜色


@property(nonatomic,strong) void (^sendThumnsVal)(int res); // 点彩点赞的结果
@end

NS_ASSUME_NONNULL_END
