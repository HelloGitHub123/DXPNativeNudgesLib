//
//  HJSliderView.h
//  DITOApp
//
//  Created by 李标 on 2022/9/11.
//

#import <UIKit/UIKit.h>
#import "OwnPropModel.h"

@protocol SliderViewEventDelegate <NSObject>
// 滑块 or 点击 后的评分结果
- (void)SliderViewEventClickByResult:(NSInteger)reslut target:(id)target;
@end

NS_ASSUME_NONNULL_BEGIN

@interface HJSliderView : UIView

@property (nonatomic, assign) id<SliderViewEventDelegate> delegate;
@property (nonatomic, strong) OwnPropModel *ownPropModel;
@property (nonatomic, assign) BOOL isClick; // 是否可以点击。 S:不可点击   C:可点击
@end

NS_ASSUME_NONNULL_END
