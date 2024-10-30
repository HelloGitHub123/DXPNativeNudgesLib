//
//  HJPomoTagManager.h
//  DITOApp
//
//  Created by 李标 on 2022/8/9.
//

#import <Foundation/Foundation.h>
#import "MonolayerView.h"
#import "NudgesBaseModel.h"
#import "NudgesModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol PomoTagEventDelegate <NSObject>

/// eg: 按钮点击事件
/// @param jumpType 跳转类型
/// @param url 跳转路由 or 路径
- (void)PomoTagClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url;
@end

@interface HJPomoTagManager : NSObject

@property (nonatomic, assign) id<PomoTagEventDelegate> delegate;

@property (nonatomic, strong) MonolayerView *monolayerView;

@property (nonatomic, strong) NudgesBaseModel *baseModel;

@property (nonatomic, strong) NudgesModel *nudgesModel;

@property (nonatomic, strong) UIView *findView;

+ (instancetype)sharedInstance;

/// eg: 移除蒙层
- (void)removeMonolayer;

// eg:开始显示nudges
- (void)startConstructsNudgesView;

// 删除预览的nudges
- (void)removePreviewNudges;

@end

NS_ASSUME_NONNULL_END
