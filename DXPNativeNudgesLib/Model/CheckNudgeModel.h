//
//  CheckNudgeModel.h
//  DITOApp
//
//  Created by 李标 on 2023/6/5.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NdEnumConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface CheckNudgeModel : NSObject

// 查找状态类型：1 - 存在于页面但没查找出来；  2 - 存在于当前页面并且查找出来； 3 - 不在当前页面也没查找出来
@property (nonatomic, assign) KNudgeFindType isFindType;
@property (nonatomic, strong) UIView *findView;  // 寻找到的view
@end

NS_ASSUME_NONNULL_END
