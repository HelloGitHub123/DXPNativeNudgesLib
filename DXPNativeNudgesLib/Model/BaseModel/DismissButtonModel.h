//
//  DismissButtonModel.h
//  DITOApp
//
//  Created by 李标 on 2022/5/13.
//  关闭按钮

#import <Foundation/Foundation.h>
#import "Nudges.h"
#import "ActionModel.h"

@class IconStyle;
@class BorderStyle;
NS_ASSUME_NONNULL_BEGIN

@interface DismissButtonModel : NdHJHttpModel

/// eg: 1-Filled Button; 2-Icon Button
@property (nonatomic, assign) KDismissButtonType type;
/// eg: 填充色
@property (nonatomic, copy) NSString *filledColor;
/// eg: 图标
@property (nonatomic, strong) IconStyle *iconStyle;
/// eg: 边框
@property (nonatomic, strong) BorderStyle *borderStyle;
/// eg:
@property (nonatomic, strong) ActionModel *action;
@end


@interface IconStyle : NdHJHttpModel

/// eg: 图标颜色
@property (nonatomic, copy) NSString *iconColor;
/// eg: 图标大小 8-16px
@property (nonatomic, assign) NSInteger iconSize;

@end



@interface BorderStyle : NdHJHttpModel

/// eg: 边框颜色
@property (nonatomic, copy) NSString *borderColor;
/// eg: 1-全边框一起配置，2-各边框单独配置
@property (nonatomic, assign) KRadiusConfigType radiusConfigType;
/// eg: 全边框配置时存储
@property (nonatomic, copy) NSString *all;
/// eg: 左上角
@property (nonatomic, assign) NSInteger topLeft;
/// eg: 右上角
@property (nonatomic, assign) NSInteger topRight;
/// eg: 右下角
@property (nonatomic, assign) NSInteger bottomRight;
/// eg: 右上角
@property (nonatomic, assign) NSInteger bottomLeft;
@end






NS_ASSUME_NONNULL_END
