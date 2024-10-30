//
//  GZFRadioCheckBox.h
//  BlueMobiProject
//
//  Created by GengZhongFei on 14/11/28.
//  Copyright (c) 2014年 耿中飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+SVGManager.h"
/**
 *  单选控件， RadioCheckBox  -----> ARC
 */

/**
 *  block 方法
 *
 *  @param index    当前选中的index
 *  @param showText 显示的文字（UI 可看见）
 *  @param hideText 隐藏的文字（需求上有可能真正可见的字段，不定是需要的）
 *
 *
 */
typedef void (^RadioCheckBoxBlock)(NSUInteger index, NSString *showText, NSString *hideText);
typedef void (^RadioMultCheckBoxBlock)(NSMutableArray *hideMulitSelectArray);

// 代理方法
@class GZFRadioCheckBox;
@protocol GZFRadioCheckBoxDelegate <NSObject>

-(void)radioCheckBoxSelected:(GZFRadioCheckBox *) radioCheckBox index:(NSUInteger)index showText:(NSString *)showText hideText:(NSString *)hideText;
-(void)radioMultCheckBoxSelectedMulithideTextSelectArray:(NSMutableArray *)hideMulitSelectArray;

@end



@interface GZFRadioCheckBox : UIView

@property(nonatomic, strong) NSNumber* index; // 默认选中的位置（默认0）
@property(nonatomic, strong) NSArray *showTextArray; // 显示的数据，UI可见（必选）
@property(nonatomic, strong) NSArray *hideTextArray; // 隐藏的数据，根据需求可选,如果选择，请求保持和showTextArray数组个数保持一致,
@property(nonatomic, assign) BOOL isHorizontal; // YES 水平方向显示(默认)， NO 纵向
@property(nonatomic, assign) float spacing; // 每个item 的间距 默认 10.0

@property(nonatomic, strong) UIFont *showTextFont; // 显示字体的大小 默认 10
@property(nonatomic, strong) UIColor *showTextColor; // 显示字体的颜色 默认 black
@property(nonatomic, assign) BOOL isHasDecoration; // 是否有下划线

@property(nonatomic, strong) NSArray *selectImageArray; // 隐藏的数据，根据需求可选,如果选择，请求保持和showTextArray数组个数保持一致,
@property(nonatomic, strong) NSArray *unselectImageArray; // 隐藏的数据，根据需求可选,如果选择，请求保持和showTextArray数组个数保持一致,
@property(nonatomic, strong) NSMutableArray *hideMulitSelectArray; // 隐藏的数据，根据需求可选,如果选择，请求保持和showTextArray数组个数保持一致,
@property(nonatomic, assign) BOOL isMultSelect; // 是否多选默认单选




// 代理属性
@property (nonatomic,unsafe_unretained) id<GZFRadioCheckBoxDelegate> delegate;

//block
@property(nonatomic, copy) RadioCheckBoxBlock radioCheckBoxBlock;
@property(nonatomic, copy) RadioMultCheckBoxBlock multRadioCheckBoxBlock;

- (void) radioCheckBoxClick: (RadioCheckBoxBlock) block;
- (void) multCheckBoxClick: (RadioMultCheckBoxBlock) multbBlock;

@end
