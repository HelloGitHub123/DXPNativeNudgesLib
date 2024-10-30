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
/// @param jumpType 跳转类型
/// @param url 跳转路由 or 路径
- (void)HotSpotClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url invokeAction:(NSString *)invokeAction buttonName:(NSString *)buttonName model:(NudgesBaseModel *)model;

// nudges显示出来后回调代理
- (void)HotSpotShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName;
@end


@interface HJHotSpotManager : NSObject

@property (nonatomic, assign) id<HotSpotEventDelegate> delegate;

@property (nonatomic, strong) MonolayerView *monolayerView;

@property (nonatomic, strong) NudgesBaseModel *baseModel;

@property (nonatomic, strong) NudgesModel *nudgesModel;

+ (instancetype)sharedInstance;

// 删除预览的nudges
- (void)removePreviewNudges;

@end

NS_ASSUME_NONNULL_END
