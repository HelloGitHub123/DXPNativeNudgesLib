//
//  HJAnnouncementManager.h
//  DITOApp
//
//  Created by 李标 on 2022/8/9.
//  弹框

#import <Foundation/Foundation.h>
#import "MonolayerView.h"
#import "NudgesBaseModel.h"
#import "NudgesModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol AnnouncementEventDelegate <NSObject>

/// eg: 按钮点击事件
- (void)AnnouncementClickEventByActionModel:(ActionModel *)actionModel isClose:(BOOL)isClose buttonName:(NSString *)buttonName nudgeModel:(NudgesBaseModel *)model;

/// eg:提交评分
- (void)AnnouncementSubmitByScore:(NSInteger)score;

// nudges显示出来后回调代理
//- (void)AnnouncementShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName;


// nudges显示出来后回调代理
- (void)AnnouncementShowEventByNudgesModel:(NudgesBaseModel *)model batchId:(NSString *)batchId source:(NSString *)source;


@end

@interface HJAnnouncementManager : NSObject

@property (nonatomic, assign) id<AnnouncementEventDelegate> delegate;

@property (nonatomic, strong) MonolayerView *monolayerView;

@property (nonatomic, strong) NudgesBaseModel *baseModel;

@property (nonatomic, strong) NudgesModel *nudgesModel;

+ (instancetype)sharedInstance;

// 删除预览的nudges
- (void)removePreviewNudges;
@end

NS_ASSUME_NONNULL_END
