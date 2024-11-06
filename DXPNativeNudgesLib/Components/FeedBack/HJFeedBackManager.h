//
//  HJFeedBackManager.h
//  DITOApp
//
//  Created by 李标 on 2022/9/18.
//

#import <Foundation/Foundation.h>
#import "MonolayerView.h"
#import "NudgesBaseModel.h"
#import "NudgesModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FeedBackEventDelegate <NSObject>

/// eg: 按钮点击事件
/// @param jumpType 跳转类型
/// @param url 跳转路由 or 路径
//- (void)FeedBackClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url isClose:(BOOL)isClose invokeAction:(NSString *)invokeAction buttonName:(NSString *)buttonName selectedOptionList:(NSMutableArray *)selectedOptionList model:(NudgesBaseModel *)model;


- (void)FeedBackClickEventByActionModel:(ActionModel *)actionModel isClose:(BOOL)isClose buttonName:(NSString *)buttonName optionList:(NSMutableArray *)optionList FeedBackText:(NSString *)FeedBackText nudgeModel:(NudgesBaseModel *)model comments:(NSString *)comments feedbackDuration:(NSInteger)feedbackDuration;

// nudges显示出来后回调代理
- (void)FeedBackShowEventByNudgesModel:(NudgesBaseModel *)model batchId:(NSString *)batchId source:(NSString *)source;


// nudges显示出来后回调代理
//- (void)FeedBackShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName;

@end


@interface HJFeedBackManager : NSObject

@property (nonatomic, assign) id<FeedBackEventDelegate> delegate;

@property (nonatomic, strong) MonolayerView *monolayerView;

@property (nonatomic, strong) NudgesBaseModel *baseModel;

@property (nonatomic, strong) NudgesModel *nudgesModel;

+ (instancetype)sharedInstance;

// 删除预览的nudges
- (void)removePreviewNudges;
@end

NS_ASSUME_NONNULL_END
