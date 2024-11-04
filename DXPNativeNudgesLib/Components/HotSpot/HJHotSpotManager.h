//
//  HJHotSpotManager.h
//  DITOApp
//
//  Created by 李标 on 2022/8/9.
//  Beacon

#import <Foundation/Foundation.h>
#import "MonolayerView.h"
#import "NudgesBaseModel.h"
#import "NudgesModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol HotSpotEventDelegate <NSObject>

/// eg: 按钮点击事件
- (void)HotSpotClickEventByActionModel:(ActionModel *)actionModel isClose:(BOOL)isClose buttonName:(NSString *)buttonName nudgeModel:(NudgesBaseModel *)model;

- (void)HotSpotShowEventByNudgesModel:(NudgesBaseModel *)model batchId:(NSString *)batchId source:(NSString *)source;
@end


@interface HJHotSpotManager : NSObject

@property (nonatomic, assign) id<HotSpotEventDelegate> delegate;

@property (nonatomic, strong) MonolayerView *monolayerView;

@property (nonatomic, strong) NudgesBaseModel *baseModel;

@property (nonatomic, strong) NudgesModel *nudgesModel;

@property (nonatomic, strong) UIView *findView;

+ (instancetype)sharedInstance;

// 删除预览的nudges
- (void)removePreviewNudges;

- (void)startConstructsNudgesView;

/// eg: 移除对应的ToolTips
- (void)removeNudges;

/// eg: 停止定时器
- (void)stopTimer;

@end

NS_ASSUME_NONNULL_END
