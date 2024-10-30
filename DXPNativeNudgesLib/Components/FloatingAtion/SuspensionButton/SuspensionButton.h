//
//  SuspensionButton.h
//  DITOApp
//
//  Created by 李标 on 2022/8/10.
//  浮动按钮

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SuspensionButton : UIButton

@property(nonatomic, assign) BOOL MoveEnable;
@property(nonatomic, assign) BOOL MoveEnabled;
@property(nonatomic, assign) CGPoint beginpoint;

@end

NS_ASSUME_NONNULL_END
