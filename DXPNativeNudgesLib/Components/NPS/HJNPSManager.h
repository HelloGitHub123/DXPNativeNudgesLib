//
//  HJNPSManager.h
//  DITOApp
//
//  Created by 李标 on 2022/9/11.
//  NPS 单例管理

#import <Foundation/Foundation.h>
#import "NudgesModel.h"
#import "NudgesBaseModel.h"
#import "MonolayerView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NPSEventDelegate <NSObject>

/// eg:按钮点击事件 score: 评分  thumbResult 点赞点踩
- (void)NPSClickEventByActionModel:(ActionModel *)actionModel isClose:(BOOL)isClose buttonName:(NSString *)buttonName nudgeModel:(NudgesBaseModel *)model score:(NSString *)score optionList:(NSMutableArray *)optionList thumbResult:(NSString *)thumbResult comments:(NSString *)comments feedbackDuration:(NSInteger)feedbackDuration;


/// eg:提交评分
- (void)NPSSubmitByScore:(NSInteger)score;

// nudges显示出来后回调代理
- (void)NPSShowEventByNudgesModel:(NudgesBaseModel *)model batchId:(NSString *)batchId source:(NSString *)source;

@end


@interface HJNPSManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NudgesBaseModel *baseModel;

@property (nonatomic, strong) NudgesModel *nudgesModel;

@property (nonatomic, assign) id<NPSEventDelegate> delegate;

@property (nonatomic, strong) MonolayerView *monolayerView;

/// eg: 移除对应的ToolTips
- (void)removeNudges;

// 删除预览的nudges
- (void)removePreviewNudges;

@end

NS_ASSUME_NONNULL_END
