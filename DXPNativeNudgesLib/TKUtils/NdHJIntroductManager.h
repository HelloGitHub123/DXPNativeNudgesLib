//
//  NdHJIntroductManager.h
//  MPTCLPMall
//
//  Created by Lee on 2022/3/27.
//  Copyright © 2022 OO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NodeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NdHJIntroductManager : NSObject
@property (nonatomic, strong) UIView * findView;

@property (nonatomic, assign) long subsViewIndex;

+ (instancetype)sharedManager;

// 遍历获取window的层级
- (NSMutableDictionary *)digView:(UIView *)view inViewController:(UIViewController *)vc index:(NSString *)indexStr;

//- (void)showViewInWindowWithIdentifer:(NSString *)identifier;

//- (UIView *)getSubsViewWithIdentifier:(NSString *)identifier inView:(UIView *)view;

//- (void)allSubsviewIdentifier:(UIView *)view;

/// 指定view，展示对应的层级model  -- 未使用
- (NSDictionary *)getRootNodeForWindow:(UIView *)rootView inViewController:(UIViewController *)vc;

// 获取view相对于window的绝对地址
- (CGRect)getAddress:(UIView *)view;

/// 查找UIWindow上指定的view
- (UIView *) getSubViewWithClassNameInViewController:(NSString *)vcName viewClassName:(NSString *)className index:(int)index inView:(UIView *)inView findIndex:(NSString *)findIndex;

// 获取当前ViewController
- (UIViewController *)getCurrentVC;

// 返回对应digView 转换成 model
- (NodeModel *)getWindowNode:(UIView *)view inViewController:(UIViewController *)vc index:(NSString *)indexStr;

// 查找UIWindow上指定的view 的 node
- (NodeModel *)getSubViewNodeWithFindIndex:(NSString *)findIndex nodeModel:(NodeModel *)nodeModel startIndex:(int)startIndex;

// 测试用
- (NSString *)digView:(UIView *)view;

// 获取ViewController的层级 -- 测试阶段
- (NSDictionary *)digViewForViewController:(UIView *)view index:(NSString *)indexStr;
@end

NS_ASSUME_NONNULL_END
