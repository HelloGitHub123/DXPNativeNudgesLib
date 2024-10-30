//
//  NdEnumConstant.h
//  UserNudges
//
//  Created by 李标 on 2022/12/3.
//

#ifndef NdEnumConstant_h
#define NdEnumConstant_h

// Nudges 类型
typedef NS_ENUM(NSInteger, KNudgesType) {
    KNudgesType_None               = 0,
    KNudgesType_GuidedWalkthrough  = 1,  //
    KNudgesType_Tooltips           = 2,  //
    KNudgesType_FunnelReminders    = 3,  //
    KNudgesType_FloatingActions    = 4,  //
    KNudgesType_Hotspots           = 5,  //
    KNudgesType_SpotLight          = 6,  //
    KNudgesType_NPS                = 7,  //
    KNudgesType_Rate               = 8,  //
    KNudgesType_Forms              = 9,  //
    KNudgesType_VideoNudges        = 10, //
    KNudgesType_FOMOTags           = 11, //
};

// 身份标识身份标识类型： 1、客户类型  2、订户类型。 默认订户类型
typedef NS_ENUM(NSInteger, KIdentityTypeType) {
	KIdentityTypeType_Customer       = 1, // 客户类型
	KIdentityTypeType_Subscriber     = 2, // 订户类型
};

// tooltips相对于target的定位
typedef NS_ENUM(NSInteger, KPosition) {
    KPosition_Auto   = 1,
    KPosition_Above  = 2,
    KPosition_Under  = 3,
    KPosition_Left   = 4,
    KPosition_Right  = 5,
    KPosition_Middle = 6,
    KPosition_bottom = 7,
};

// 背景\蒙层 背景色类型
typedef NS_ENUM(NSInteger, KBackgroundType) {
    KBackgroundType_Solid     = 1,
    KBackgroundType_Gradient  = 2,
    KBackgroundType_Image     = 3,
};

// 背景\蒙层 渐变类型
typedef NS_ENUM(NSInteger, KGradientType) {
    KGradientType_Linear    = 1,
    KGradientType_Radial    = 2,
    KGradientType_Angular   = 3,
};

// 图片\蒙层 渲染类型
typedef NS_ENUM(NSInteger, KImageType) {
    KImageType_Fill      = 1,
    KImageType_Fit       = 2,
    KImageType_Stretch   = 3,
};

// 边框类型
typedef NS_ENUM(NSInteger, KBorderStyle) {
    KBorderStyle_solid      = 1,
    KBorderStyle_dashed     = 2,
    KBorderStyle_dotted     = 3,
};

// 边框圆角类型
typedef NS_ENUM(NSInteger, KRadiusConfigType) {
    KRadiusConfigType_all       = 1, // 全边框一起配置
    KRadiusConfigType_other     = 2, // 各边框单独配置
};

// 按钮Action 类型
typedef NS_ENUM(NSInteger, KButtonsActionType) {
    KButtonsActionType_CloseNudges      = 1,
    KBorderStyle_LaunchURL              = 2,
    KBorderStyle_InvokeAction           = 3,
};

// 按钮URL跳转类型
typedef NS_ENUM(NSInteger, KButtonsUrlJumpType) {
    KButtonsUrlJumpType_Inner           = 1,
    KButtonsUrlJumpType_OuterBrower     = 2,
    KButtonsUrlJumpType_InnerWebview    = 3,
};

// 按钮填充类型
typedef NS_ENUM(NSInteger, KButtonsFillType) {
    KButtonsFillType_Outline          = 1,
    KButtonsFillType_Fill             = 2,
    KButtonsFillType_TextOnley        = 3,
    KButtonsFillType_Icon             = 4,
    KButtonsFillType_IconText         = 5,
};

// 关闭按钮 类型
typedef NS_ENUM(NSInteger, KDismissButtonType) {
    KDismissButtonType_FilledButton   = 1, //
    KDismissButtonType_IconButton     = 2, //
};

// 下沉来源
typedef NS_ENUM(NSInteger, KSourceType) {
    KSourceType_default       = 1, // 默认mccm 或者 dmc
    KSourceType_ceg           = 2, // ceg
};

// 自有属性 ownProp 类型
typedef NS_ENUM(NSInteger, KOwnPropType) {
    KOwnPropType_Round            = 1,
    KOwnPropType_Box              = 2,
    KOwnPropType_InnerHighlight   = 3,
    KOwnPropType_FilledHighlight  = 4,
};


// Button 布局类型 10: 按配置进行布局   11: 整行布局
typedef NS_ENUM(NSInteger, KButtonLayoutType) {
    KButtonLayoutType_Config    = 10, // 按配置进行布局
    KButtonLayoutType_Fixed     = 11, // 整行进行固定布局
};

// 图片位置，top文字上方/bottom文字下方/left文字左侧/right文字右侧
typedef NS_ENUM(NSInteger, KImagePositionType) {
    KImagePositionType_none      = 0,
    KImagePositionType_Top       = 1,
    KImagePositionType_Bottom    = 2,
    KImagePositionType_Left      = 3,
    KImagePositionType_Right     = 4,
};


// 评分类型：S - Star；H - Heart；T - Thumbs
typedef NS_ENUM(NSInteger, KRateType) {
    KRateType_Star       = 1, //
    KRateType_Heart      = 2, //
    KRateType_Thumbs     = 3, //
};

// 查找状态类型：1 - 存在于页面但没查找出来；  2 - 存在于当前页面并且查找出来； 3 - 不在当前页面也没查找出来
typedef NS_ENUM(NSInteger, KNudgeFindType) {
	KNudgeFineType_Exist_NoFind       = 1, //
	KNudgeFineType_Exist_Find         = 2, //
	KNudgeFineType_NoExist_NoFind     = 3, //
};

#endif /* NdEnumConstant_h */
