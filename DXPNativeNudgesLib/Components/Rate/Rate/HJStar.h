//
//  QCStarView.h
//  QCStarView
//
//  Created by EricZhang on 2018/8/15.
//  Copyright © 2018年 BYX. All rights reserved.
//  评分

#import <UIKit/UIKit.h>

@interface HJStar : UIView

@property (nonatomic,assign) CGFloat scorePercent; //分数（0...1）
@property (nonatomic,assign) BOOL isAnimation; // 是否有动画
@property (nonatomic,assign) BOOL isCompleteStar; // 是否整星
@property (nonatomic,assign) BOOL isJsutDisplay; // 是否只是展示

@property (nonatomic, copy) NSString *beforeSvgColor; // svg图未选中的颜色
@property (nonatomic, copy) NSString *afterSvgColor; // svg图选中后的颜色
@property (nonatomic, copy) NSString *svgName; // svg 图片名称
@property (nonatomic, assign) CGFloat iconSize; // 图标大小
@property (nonatomic, assign) CGFloat viewWidth; // 视图宽度

//封装方法
- (instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars;
//block反向传星星score
@property(nonatomic,strong) void (^sendStarPercent)(double percent, NSInteger starNumbers);
@end
