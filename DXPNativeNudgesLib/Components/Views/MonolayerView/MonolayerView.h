//
//  MonolayerView.h
//  DITOApp
//
//  Created by 李标 on 2022/8/8.
//  全局遮罩 view

#import <UIKit/UIKit.h>
#import "Nudges.h"

// 蒙层类型
typedef NS_ENUM(NSInteger, KMonolayerViewType) {
    KMonolayerViewType_full          = 1, // 全屏遮罩
    KMonolayerViewType_Spotlight     = 2, // 全屏遮罩 + 遮罩
};

NS_ASSUME_NONNULL_BEGIN

@protocol MonolayerViewDelegate <NSObject>

// 蒙层事件
- (void)MonolayerViewClickEventByTarget:(id)target;
@end

@interface MonolayerView : UIView

@property (nonatomic, assign) id<MonolayerViewDelegate> delegate;
/// eg: 蒙层背景透明度
@property (nonatomic, assign) CGFloat backgroundAlpha;
/// eg: 蒙层背景色
@property (nonatomic, copy) NSString *bgroundColor;
/// 点击蒙层是否响应 YES: 支持响应  NO: 不支持响应
@property (nonatomic, assign) BOOL isTouch;
/// 遮罩类型
@property (nonatomic, assign) KMonolayerViewType monolayerViewType;

/// eg: 设置 镂空 view 的属性
/// @param alphaRect  区域
/// @param type Spotlight 类型
/// @param cornerRadius  区域圆角
- (void)setAlphaRectParametersByRect:(CGRect)alphaRect SpotlightType:(KOwnPropType)type radius:(CGFloat)cornerRadius;

@end

NS_ASSUME_NONNULL_END
