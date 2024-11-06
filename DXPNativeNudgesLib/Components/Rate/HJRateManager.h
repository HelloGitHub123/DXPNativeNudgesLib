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
- (void)RateClickEventByActionModel:(ActionModel *)actionModel isClose:(BOOL)isClose buttonName:(NSString *)buttonName score:(NSString *)score thumbResult:(NSString *)thumbResult comments:(NSString *)comments nudgeModel:(NudgesBaseModel *)model feedbackDuration:(NSInteger)feedbackDuration;

// nudges显示出来后回调代理
- (void)RateShowEventByNudgesModel:(NudgesBaseModel *)model batchId:(NSString *)batchId source:(NSString *)source;

/// eg:提交评分
- (void)RateSubmitByScore:(double)score thumb:(NSInteger)thumbsScore;

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
