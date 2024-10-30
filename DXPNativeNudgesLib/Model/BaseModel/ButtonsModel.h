//
//  ButtonsModel.h
//  DITOApp
//
//  Created by 李标 on 2022/5/13.
//  按钮

#import <Foundation/Foundation.h>
#import "Nudges.h"
#import "ActionModel.h"

@class Layout;
@class ButtonItem;
@class HJText;
@class ButtonStyle;
NS_ASSUME_NONNULL_BEGIN

@interface ButtonsModel : NdHJHttpModel

/// eg: 布局
@property (nonatomic, strong) Layout *layout;
/// eg: 按钮 数组
@property (nonatomic, strong) NSArray<ButtonItem *> *buttonList;
@end




@interface Layout : NdHJHttpModel

/// eg: 10: 按配置进行布局   11: 整行布局
@property (nonatomic, copy) NSString *type;
/// eg: left;middle;right
@property (nonatomic, copy) NSString *align;
@end




@interface ButtonItem : NdHJHttpModel

@property (nonatomic, strong) HJText *text;

@property (nonatomic, strong) ActionModel *action;

@property (nonatomic, strong) ButtonStyle *buttonStyle;

// 扩展
@property (nonatomic, assign) NSInteger itemTag;
@end




@interface HJText : NdHJHttpModel

/// eg: 字体类型
@property (nonatomic, copy) NSString *fontFamily;
/// eg: 字体大小。取值 11-26
@property (nonatomic, assign) NSInteger fontSize;
/// eg: 是否加粗 Y/N
@property (nonatomic, assign) BOOL isBold;
/// eg: 是否斜体 Y/N
@property (nonatomic, assign) BOOL isItalic;
/// eg:  Y/N
@property (nonatomic, assign) BOOL hasDecoration;
/// eg:  字体颜色
@property (nonatomic, copy) NSString *color;
/// eg:  字体对其方式  left;middle;right
@property (nonatomic, copy) NSString *textAlign;
/// eg:  内容
@property (nonatomic, copy) NSString *content;
@end



@interface Action : NdHJHttpModel

/// eg: 1-Close Nudges; 2-Launch URL; 3-Invoke Action
@property (nonatomic, copy) NSString *type;
///
@property (nonatomic, copy) NSString *url;
/// eg: 1-Inner; 2-Outer Brower; 3-Inner Webview
@property (nonatomic, copy) NSString *urlJumpType;
@end



@interface ButtonStyle : NdHJHttpModel

/// eg: 1 - Outline; 2 - Fill; 3 - Text-Only; 4 - Icon; 5 - Icon + Text
@property (nonatomic, assign) KButtonsFillType fillType;
///
@property (nonatomic, copy) NSString *fillColor;
/// eg:边框宽度
@property (nonatomic, assign) NSInteger borderWidth;
/// eg: 边框类型 1-solid、2-dashed、3-dotted
@property (nonatomic, assign)  KBorderStyle borderStyle;
/// eg: 边框颜色，16进制HAX码保存
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
/// eg: 左下角
@property (nonatomic, assign) NSInteger bottomLeft;
/// eg:配置icon的地址
@property (nonatomic, copy) NSString *icon;
@end


NS_ASSUME_NONNULL_END
