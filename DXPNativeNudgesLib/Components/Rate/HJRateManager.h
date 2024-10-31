//
//  HJRateManager.h
//  DITOApp
//
//  Created by 李标 on 2022/9/12.
//  Rate 点评 类型

#import <Foundation/Foundation.h>
#import "MonolayerView.h"
#import "NudgesBaseModel.h"
#import "NudgesModel.h"

@protocol RateEventDelegate <NSObject>

/// eg: 按钮点击事件
/// @param jumpType 跳转类型
/// @param url 跳转路由 or 路径
- (void)RateClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url isClose:(BOOL)isClose invokeAction:(NSString *)invokeAction buttonName:(NSString *)buttonName model:(NudgesBaseModel *)model;

/// eg:提交评分
- (void)RateSubmitByScore:(double)score thumb:(NSInteger)thumbsScore;


// nudges显示出来后回调代理
- (void)RateShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName;


@end


NS_ASSUME_NONNULL_BEGIN

@interface HJRateManager : NSObject

@property (nonatomic, assign) id<RateEventDelegate> delegate;

@property (nonatomic, strong) MonolayerView *monolayerView;

@property (nonatomic, strong) NudgesBaseModel *baseModel;

@property (nonatomic, strong) NudgesModel *nudgesModel;

+ (instancetype)sharedInstance;

// 删除预览的nudges
- (void)removePreviewNudges;
@end

NS_ASSUME_NONNULL_END
