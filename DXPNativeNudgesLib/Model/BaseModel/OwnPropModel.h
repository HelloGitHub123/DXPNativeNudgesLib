//
//  OwnPropModel.h
//  DITOApp
//
//  Created by 李标 on 2022/8/8.
//

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@class LeftText;
@class NpsColor;
@class RightText;
@class ScaleColor;
@class Hint;
@class Input;
@class RateStyle;
@class Title;
@class TextProperties;

@interface OwnPropModel : NdHJHttpModel

/// eg: Spotlight样式，1-Round; 2-Box; Beacon样式，3-Inner Highlight; 4-Filled Highlight;
@property (nonatomic, assign) KOwnPropType type;
/// eg: Beacon颜色
@property (nonatomic, strong) NSString *color;
/// eg: Beacon透明度，入具体百分比数值
@property (nonatomic, assign) NSInteger opacity;
/// eg: Float Action显示方式；C - Current Page; A - All Pages
@property (nonatomic, copy) NSString *displayOption;
/// eg: 字体大小
@property (nonatomic, assign) NSInteger fontSize;
/// eg: nps 类型 S - Slider; C - Click
@property (nonatomic, copy) NSString *npsType;

@property (nonatomic, strong) LeftText *leftText;

@property (nonatomic, strong) NpsColor *npsColor;

@property (nonatomic, strong) RightText *rightText;

@property (nonatomic, strong) ScaleColor *scaleColor;
/// eg:是否增加可输出区域
@property (nonatomic, assign) BOOL enabled;
/// eg: 文字
@property (nonatomic, strong) Hint *hint;
/// eg: 输入框
@property (nonatomic, strong) Input *input;
/// eg: rate  评分类型：S - Star；H - Heart；T - Thumbs
@property (nonatomic, assign) KRateType rateType;
///
@property (nonatomic, strong) RateStyle *rateStyle;
///
@property (nonatomic, strong) Title *title;
/// eg: 选择类型， S - Single Select; M - Multi Select
@property (nonatomic, copy) NSString *selectType;
///
@property (nonatomic, strong) TextProperties *textProperties;


@end



@interface LeftText : NdHJHttpModel

@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *content;
@end

@interface NpsColor : NdHJHttpModel

@property (nonatomic, copy) NSString *notSelection; // 选中的颜色
@property (nonatomic, copy) NSString *selection; // 未选中的颜色
@end

@interface RightText : NdHJHttpModel

@property (nonatomic, copy) NSString *color;
@property (nonatomic, copy) NSString *content;
@end

@interface ScaleColor : NdHJHttpModel

@property (nonatomic, copy) NSString *notSelection; // 选中的颜色
@property (nonatomic, copy) NSString *selection; // 未选中的颜色
@end


@interface Hint : NdHJHttpModel

@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *fontSize;
@property (nonatomic, assign) BOOL isBold;
@property (nonatomic, assign) BOOL isItalic;
@property (nonatomic, assign) BOOL hasDecoration;
@property (nonatomic, copy) NSString *color;
@end

@interface Input : NdHJHttpModel

@property (nonatomic, copy) NSString *fontSize;
@property (nonatomic, copy) NSString *color;
@property (nonatomic, assign) BOOL isBold;
@property (nonatomic, assign) BOOL isItalic;
@property (nonatomic, assign) BOOL hasDecoration;
/// eg:  S - Single line单行输入; M-Mutiple line多行输入
@property (nonatomic, copy) NSString *style;
/// eg: 多行输入时，传值，默认为3
@property (nonatomic, assign) NSInteger rows;
@property (nonatomic, assign) NSInteger maxLength;
/// eg: 格式校验，内置，TEXT - Text随意输入，默认；NUM - Number数字
@property (nonatomic, copy) NSString *format;
@end


@interface RateStyle : NdHJHttpModel

/// eg: 选中的颜色，S/H会配置
@property (nonatomic, copy) NSString *activeColor;
/// eg: 未选中的颜色，三种都会配置
@property (nonatomic, copy) NSString *restColor;
/// eg: 图标大小
@property (nonatomic, assign) CGFloat iconSize;
/// eg: 点赞颜色，只有T会配置
@property (nonatomic, copy) NSString *thumbsUpColor;
/// eg: 点踩颜色，只有T会配置
@property (nonatomic, copy) NSString *thumbsDownColor;

@end


@interface Title : NdHJHttpModel

@property (nonatomic, copy) NSString *fontFamily;
@property (nonatomic, copy) NSString *color;
/// eg: 图标大小
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) BOOL isBold;
@property (nonatomic, assign) BOOL isItalic;
@property (nonatomic, assign) BOOL hasDecoration;
/// 问题描述
@property (nonatomic, copy) NSString *content;
@end



@interface TextProperties : NdHJHttpModel

@property (nonatomic, copy) NSString *fontFamily;
@property (nonatomic, copy) NSString *color;
/// eg: 图标大小
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) BOOL isBold;
@property (nonatomic, assign) BOOL isItalic;
@property (nonatomic, assign) BOOL hasDecoration;
@property (nonatomic, strong) NSMutableArray<NSString *> *options;
@end


NS_ASSUME_NONNULL_END
