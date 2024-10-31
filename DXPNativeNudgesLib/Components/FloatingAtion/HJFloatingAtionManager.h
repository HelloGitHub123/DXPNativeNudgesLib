//
//  HJFloatingAtionManager.h
//  DITOApp
//
//  Created by 李标 on 2022/8/9.
//

#import <Foundation/Foundation.h>
#import "MonolayerView.h"
#import "NudgesBaseModel.h"
#import "NudgesModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FloatingAtionEventDelegate <NSObject>

/// eg: 按钮点击事件
/// @param jumpType 跳转类型
/// @param url 跳转路由 or 路径
- (void)FloatingAtionClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url isClose:(BOOL)isClose invokeAction:(NSString *)invokeAction buttonName:(NSString *)buttonName model:(NudgesBaseModel *)model;

// nudges显示出来后回调代理
- (void)FloatingAtionShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName;


@end

@interface HJFloatingAtionManager : NSObject

@property (nonatomic, assign) id<FloatingAtionEventDelegate> delegate;

@property (nonatomic, strong) MonolayerView *monolayerView;

@property (nonatomic, strong) NudgesBaseModel *baseModel;

@property (nonatomic, strong) NudgesModel *nudgesModel;

+ (instancetype)sharedInstance;

// 移除当前页面的浮现按钮
- (void)removeCurrentFloatingAtion;
@end

NS_ASSUME_NONNULL_END
