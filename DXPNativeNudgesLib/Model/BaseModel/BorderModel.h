//
//  BorderModel.h
//  DITOApp
//
//  Created by 李标 on 2022/5/13.
//  边框

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface BorderModel : NdHJHttpModel

/// eg: 是否开启配置，true/false
@property (nonatomic, assign) BOOL enabled;
/// eg: 边框宽度
@property (nonatomic, assign) NSInteger borderWidth;
/// eg: 边边框类型，1-solid、2-dashed、3-dotted
@property (nonatomic, assign) KBorderStyle borderStyle;
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
/// eg: 右上角
@property (nonatomic, assign) NSInteger bottomLeft;
@end

NS_ASSUME_NONNULL_END
