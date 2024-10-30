//
//  ImageModel.h
//  DITOApp
//
//  Created by 李标 on 2022/5/13.
//  图片

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageModel : NdHJHttpModel

/// eg: 图片地址
@property (nonatomic, copy) NSString *imageUrl;
/// eg: rue/false，
/// auto-width 的最大宽度是前面录入的 tooltop的宽度减去 20px,比如前面 tooltip 是的宽度是 100px,那么图片最大的宽度就是80px, 行高根据图片等比放大的宽度自适应高度.
@property (nonatomic, assign) BOOL autoWidth;
/// eg: 图片设置的宽度
@property (nonatomic, assign) CGFloat width;
/// eg: 图片相对于文本的位置  top文字上方/bottom文字下方/left文字左侧/right文字右侧
@property (nonatomic, assign) KImagePositionType position;
/// eg: 透明度，按照百分比
@property (nonatomic, assign) CGFloat opacity;
/// eg: true/false
@property (nonatomic, assign) BOOL paddingSpace;
/// eg: true/false
@property (nonatomic, assign) BOOL allAides;
/// eg: 左
@property (nonatomic, assign) NSInteger paddingLeft;
/// eg: 上
@property (nonatomic, assign) NSInteger paddingTop;
/// eg: 右
@property (nonatomic, assign) NSInteger paddingRight;
/// eg: 下
@property (nonatomic, assign) NSInteger paddingBottom;

/// eg: 图片高度
@property (nonatomic, assign) CGFloat h_image;
/// eg: 图片宽度
@property (nonatomic, assign) CGFloat w_image;

@end

NS_ASSUME_NONNULL_END
