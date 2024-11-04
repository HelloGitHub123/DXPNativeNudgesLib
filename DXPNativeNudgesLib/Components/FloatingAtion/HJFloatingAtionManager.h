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

- (void)FloatingAtionClickEventByActionModel:(ActionModel *)actionModel isClose:(BOOL)isClose buttonName:(NSString *)buttonName nudgeModel:(NudgesBaseModel *)model;

// nudges显示出来后回调代理
- (void)FloatingAtionShowEventByNudgesModel:(NudgesBaseModel *)model batchId:(NSString *)batchId source:(NSString *)source;

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
