//
//  MonolayerModel.h
//  DITOApp
//
//  Created by 李标 on 2022/5/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MonolayerModel : NSObject

/// 蒙版的颜色  默认黑色
@property (nonatomic, strong) UIColor *backgroundColor;
/// 蒙版的透明度 默认 0.4
@property (nonatomic, assign) CGFloat alpha;
@end

NS_ASSUME_NONNULL_END
