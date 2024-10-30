//
//  HJToolTipsManager.h
//  DITOApp
//
//  Created by 李标 on 2022/5/16.
//  ToolTips 单例管理

#import <Foundation/Foundation.h>
#import "NudgesModel.h"
#import "NudgesBaseModel.h"
#import "MonolayerView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ToolTipsEventDelegate <NSObject>

/// eg:按钮点击事件
/// @param jumpType 跳转类型
/// @param url 跳转路由 or 路径
- (void)ToolTipsClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url invokeAction:(NSString *)invokeAction buttonName:(NSString *)buttonName model:(NudgesBaseModel *)model;

// nudges显示出来后回调代理
- (void)ToolTipsShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName;

@end


@interface HJToolTipsManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NudgesBaseModel *baseModel;

@property (nonatomic, strong) NudgesModel *nudgesModel;

@property (nonatomic, assign) id<ToolTipsEventDelegate> delegate;

@property (nonatomic, strong) MonolayerView *monolayerView;

@property (nonatomic, strong) UIView *findView;

/// eg: 展示自定义ToolTips
/// @param baseModel 基类属性model
//- (void)showCustomToolTipsWithModel:(NudgesBaseModel *)baseModel nudgesModel:(NudgesModel *)model;

/// eg: 移除对应的ToolTips
- (void)removeNudges;

/// eg: 停止定时器
- (void)stopTimer;

// eg:开始显示nudges
- (void)startConstructsNudgesView;

// 删除预览的nudges
- (void)removePreviewNudges;

@end

NS_ASSUME_NONNULL_END
