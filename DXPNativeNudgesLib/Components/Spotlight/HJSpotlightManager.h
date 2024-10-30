//
//  HJSpotlightManager.h
//  DITOApp
//
//  Created by 李标 on 2022/8/6.
//  Spotlight Nudges 样式 = 蒙层 + toolTips

#import <Foundation/Foundation.h>
#import "MonolayerView.h"
#import "NudgesModel.h"
#import "NudgesBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SpotlightEventDelegate <NSObject>

/// eg:按钮点击事件
/// @param jumpType 跳转类型
/// @param url 跳转路由 or 路径
- (void)SpotlightClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url invokeAction:(NSString *)invokeAction buttonName:(NSString *)buttonName model:(NudgesBaseModel *)model;

// nudges显示出来后回调代理
- (void)SpotlightShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName;
@end


@interface HJSpotlightManager : NSObject

@property (nonatomic, assign) id<SpotlightEventDelegate> delegate;

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
