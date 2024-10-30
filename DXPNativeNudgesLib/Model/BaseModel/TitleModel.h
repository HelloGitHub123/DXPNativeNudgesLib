//
//  TitleModel.h
//  DITOApp
//
//  Created by 李标 on 2022/5/13.
//

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface TitleModel : NdHJHttpModel

/// eg: true/false
@property (nonatomic, assign) BOOL enable;
/// eg:  字体
@property (nonatomic, copy) NSString *fontFamily;
/// eg: 字体大小
@property (nonatomic, assign) NSInteger fontSize;
/// eg: 是否加粗 Y/N
@property (nonatomic, assign) BOOL isBold;
/// eg: 是否斜体 Y/N
@property (nonatomic, assign) BOOL isItalic;
/// eg: 是否下划线 Y/N
@property (nonatomic, assign) BOOL hasDecoration;
/// eg: 字体颜色
@property (nonatomic, copy) NSString *color;
/// eg: 字体对其方式  left;middle;right
@property (nonatomic, copy) NSString *textAlign;
/// eg: 标题内容
@property (nonatomic, copy) NSString *content;
@end

NS_ASSUME_NONNULL_END
