//
//  PositionModel.h
//  DITOApp
//
//  Created by 李标 on 2022/5/13.
//

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface PositionModel : NdHJHttpModel

/// eg: tooltips相对于target的定位
/// 取值范围: 1-Auto, 2-Above, 3-Under, 4-Left, 5-Right  Funnel Reminders的位置，取值范围: 6-Middle, 7-Bottom
@property (nonatomic, assign) KPosition position;
/// eg: tooltip的宽度，范围在 30-200px
@property (nonatomic, assign) NSInteger width;
/// eg:tooltip相对于target对应方向的距离
@property (nonatomic, assign) NSInteger margin;

@end

NS_ASSUME_NONNULL_END
