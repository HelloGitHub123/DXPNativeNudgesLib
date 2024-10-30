//
//  AppExtInfoModel.h
//  DITOApp
//
//  Created by 李标 on 2022/7/5.
//

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppExtInfoModel : NdHJHttpModel

/// 父布局 类型
@property (nonatomic, copy) NSString *parentClassName;
/// 默认-1
@property (nonatomic, assign) NSInteger itemPosition;
/// 是否是复用View 一般是 RecycleView ListView 还有 GridView会存在这种问题
@property (nonatomic, assign) NSInteger isReuseView;
/// 复用View （ RecycleView ListView GridView）索引
@property (nonatomic, copy) NSString *reuseViewFindIndex;
/// 页面元素标识符
@property (nonatomic, copy) NSString *accessibilityIdentifier;

@property (nonatomic, copy) NSString *accessibilityLabel;
@end

NS_ASSUME_NONNULL_END
