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

- (void)FeedBackClickEventByActionModel:(ActionModel *)actionModel isClose:(BOOL)isClose buttonName:(NSString *)buttonName selectedOptionList:(NSMutableArray *)selectedOptionList FeedBackText:(NSString *)FeedBackText nudgeModel:(NudgesBaseModel *)model;

// nudges显示出来后回调代理
- (void)FeedBackShowEventByNudgesModel:(NudgesBaseModel *)model batchId:(NSString *)batchId source:(NSString *)source;

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
