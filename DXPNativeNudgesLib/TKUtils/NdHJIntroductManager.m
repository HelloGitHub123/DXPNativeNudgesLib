//
//  NdHJIntroductManager.m
//  MPTCLPMall
//
//  Created by Lee on 2022/3/27.
//  Copyright © 2022 OO. All rights reserved.
//

#import "NdHJIntroductManager.h"
#import "NdHJInstructPopView.h"
#import "NodeModel.h"
#import "NdHJModelToJson.h"
//#import "HJPackSectionHeaderView.h"

static NdHJIntroductManager *manager = nil;

@interface NdHJIntroductManager () {

}
@end

@implementation NdHJIntroductManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NdHJIntroductManager alloc] init];
    });
    return manager;
}

//- (void)showViewInWindowWithIdentifer:(NSString *)identifier {
//    UIView * view = [self getSubsViewWithIdentifier:identifier inView:kAppDelegate.window];
//    if (!view) {
//        return;
//    }
//    NdHJInstructPopView * popView = [[NdHJInstructPopView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
//    popView.contentStr = @"111222222222222";
//    [kAppDelegate.window addSubview:popView];
//    [popView.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        //        make.bottom.equalTo(view.mas_top).with.offset(-[_settingModel.pointY floatValue]);
//        //        make.leading.equalTo(view.mas_leading).with.offset([_settingModel.pointX floatValue]);
//        make.bottom.equalTo(@-20);
//        make.leading.equalTo(@20);
//    }];
//}

/// 遍历window上的view的层级 -- use
- (NSMutableDictionary *)digView:(UIView *)view inViewController:(UIViewController *)vc index:(NSString *)indexStr {
    // 1.初始化
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    NSMutableArray *childArr = [[NSMutableArray alloc] init];
   
//    if ([view isKindOfClass:[MJRefreshNormalHeader class]]) {
//        return dict;
//    }
    if ([view isKindOfClass:[UICollectionViewCell class]]) {
        NSLog(@"---class----indexStr-----:\n%@,%@",view.class,indexStr);
    }
    [dict setObject:[NSString stringWithFormat:@"%@_%@",view.class,indexStr] forKey:@"resId"];
    [dict setObject:[NSString stringWithFormat:@"%ld",view.tag] forKey:@"tag"];
    [dict setObject:NSStringFromCGRect([self getAddress:view]) forKey:@"frame"];
    if (vc) {
        [dict setObject:NSStringFromClass(vc.class) forKey:@"className"];
    } else {
        [dict setObject:@"" forKey:@"className"];
    }
    
    [dict setObject:NSStringFromClass(vc.class) forKey:@"pageName"]; // 修改从view.class 到 vc.class
    [dict setObject:indexStr forKey:@"findIndex"];
    
    // 修改findindex为元素标识
    view.isAccessibilityElement = YES;
    view.superview.isAccessibilityElement = YES;
    
//    NSString *accessibilityIdentifier = [NSString stringWithFormat:@"%@",view.accessibilityIdentifier];
//    NSLog(@"accessibilityIdentifier=====%@\n",accessibilityIdentifier);
//    if ([accessibilityIdentifier isKindOfClass:[NSString class]]) {
//        [dict setObject:accessibilityIdentifier forKey:@"accessibilityIdentifier"];
//    }
//	
//	NSString *accessibilityLabel = [NSString stringWithFormat:@"%@",view.accessibilityLabel];
//	if ([accessibilityLabel isKindOfClass:[NSString class]]) {
//		[dict setObject:accessibilityLabel forKey:@"accessibilityLabel"];
//	}
	
//	NSString *accessibility = [NSString stringWithFormat:@"RNView_%@",indexStr];
//	[dict setObject:accessibility forKey:@"accessibilityIdentifier"];
	
	
	
	
//	NSString *accessibilityTraits = [NSString stringWithFormat:@"%llu",view.accessibilityTraits];
//	NSLog(@"accessibilityTraits=====%@\n",accessibilityTraits);
//	if ([accessibilityTraits isKindOfClass:[NSString class]]) {
//		[dict setObject:accessibilityTraits forKey:@"accessibilityTraits"];
//	}
//	
//	CGRect accessibilityFrame = view.accessibilityFrame;
//	NSLog(@"accessibilityFrame x:%f,   y: %f ======\n",accessibilityFrame.origin.x, accessibilityFrame.origin.y);
//    
//	UIBezierPath *accessibilityPath = view.accessibilityPath;
//	if ([view isKindOfClass:[UIImageView class]]) {
//		NSString *value = view.accessibilityValue;
////		NSLog(@"accessibilityValue:======= %@",value);
//		// 获取 UIImageView 的 image
//		UIImage *image = ((UIImageView *)view).image;
//
//		// 获取图片名称
//		NSString *imageName = image.accessibilityIdentifier ?: image.accessibilityLabel ?: image.accessibilityHint;
//		NSLog(@"imageName:======= %@",imageName);
//	}
	
	
    // 3.判断是否要结束
    if (view.subviews.count == 0) {
        return dict;
    }
    
    NSMutableString * str = [NSMutableString string];
    [str appendString:indexStr];
    // 4.遍历所有的子控件
    for (int i =0; i<view.subviews.count; i++) {
        UIView *child = view.subviews[i];
        NSMutableDictionary *childDict = [self digView:child inViewController:vc index:[NSString stringWithFormat:@"%@%@%d",indexStr,isEmptyString_Nd(indexStr)?@"":@",",i]];
        [childArr addObject:childDict];
    }
    [dict setObject:childArr forKey:@"childNodes"];
    return dict;
}

// 返回对应digView 转换成 model
- (NodeModel *)getWindowNode:(UIView *)view inViewController:(UIViewController *)vc index:(NSString *)indexStr {
    NodeModel *rootNode = [[NodeModel alloc] init];
    NSMutableArray *subsViewNodes = [[NSMutableArray alloc] init];
//    if ([view isKindOfClass:[MJRefreshNormalHeader class]]) {
//        return rootNode;
//    }
    if ([view isKindOfClass:[UICollectionViewCell class]]) {
        NSLog(@"---class----indexStr-----:\n%@,%@",view.class,indexStr);
    }
    rootNode.resId = [NSString stringWithFormat:@"%@_%@",view.class,indexStr];
    rootNode.tag = [NSString stringWithFormat:@"%ld",view.tag];
    rootNode.frame = NSStringFromCGRect([self getAddress:view]);
    if (vc) {
        rootNode.className = [NSString stringWithFormat:@"%@",vc.class];
    } else {
        rootNode.className = @"";
    }
    rootNode.pageName = [NSString stringWithFormat:@"%@",view.class];
    rootNode.findIndex = indexStr;
    
    rootNode.targetView = view;
    view.isAccessibilityElement = YES;
    view.superview.isAccessibilityElement = YES;
	
	
	
	
	NSString *accessibility = [NSString stringWithFormat:@"RNView_%@",indexStr];
	rootNode.strAccessibilityIdentifier = accessibility;
	
	
//    NSString * str1 = view.accessibilityIdentifier;
//    NSLog(@"accessibilityIdentifier=====%@\n",str1);
//    if ([str1 isKindOfClass:[NSString class]]) {
//        rootNode.strAccessibilityIdentifier = str1;
//        rootNode.superView = NSStringFromClass(view.superview.class);
//    }
//	
//	NSString *accessibilityLabel = [NSString stringWithFormat:@"%@",view.accessibilityLabel];
//	NSLog(@"accessibilityLabel=====%@\n",accessibilityLabel);
//	if ([accessibilityLabel isKindOfClass:[NSString class]]) {
//		rootNode.strAccessibilityLabel = accessibilityLabel;
//	}
    
    // 3.判断是否要结束
    if (view.subviews.count == 0) {
        return rootNode;
    }
    NSMutableString * str = [NSMutableString string];
    [str appendString:indexStr];
    // 4.遍历所有的子控件
    for (int i =0; i<view.subviews.count; i++){
        UIView *child = view.subviews[i];
        NodeModel *childNode = [self getWindowNode:child inViewController:vc index:[NSString stringWithFormat:@"%@%@%d",indexStr,isEmptyString_Nd(indexStr)?@"":@",",i]];
        [subsViewNodes addObject:childNode];
    }
    rootNode.childNodeList = subsViewNodes;
    return rootNode;
}

/// 查找UIWindow上指定的view 的 node
- (NodeModel *)getSubViewNodeWithFindIndex:(NSString *)findIndex nodeModel:(NodeModel *)nodeModel startIndex:(int)startIndex {
    NSArray *arrlist = [findIndex componentsSeparatedByString:@","];
//    int index = [[arrlist objectAtIndex:startIndex] intValue];
//    NodeModel *model = (NodeModel *)[nodeModel.childNodeList objectAtIndex:index];
//    if (![model.findIndex isEqualToString:findIndex]) {
//        startIndex++;
//        [self getSubViewNodeWithFindIndex:findIndex nodeModel:model startIndex:startIndex];
//    }
//    return model;
    
    NodeModel *reNode = nodeModel;
    for (int i = 0; i< arrlist.count; i++) {
        int index = [[arrlist objectAtIndex:i] intValue];
        NodeModel *model = (NodeModel *)[reNode.childNodeList objectAtIndex:index];
        if ([model.findIndex isEqualToString:findIndex]) {
            reNode = model;
            break;
        } else {
            reNode = model;
        }
    }
    return reNode;
}

//- (NSMutableString *)findIndexInView:(UIView *)view {
//    NSMutableString *findIndex = [NSMutableString string];
////    [findIndex appendString:@"0"];
//    if (view.subviews.count == 0) {
//        return findIndex;
//    }
//
//    for (int i =0; i<view.subviews.count; i++) {
//        UIView *child = view.subviews[i];
//        [findIndex appendString:[NSString stringWithFormat:@",%d",i]];
//        findIndex = [self findIndexInView:child];
//    }
//    NSLog(@"----------view---------%@:%@",view.class,findIndex);
//    return findIndex;
//}


- (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        if ([window.rootViewController isKindOfClass:[UITabBarController class]]) {
            result = ((UITabBarController *)window.rootViewController).selectedViewController;
            result = [result.childViewControllers lastObject];
        } else {
        }
    }
    NSLog(@"非模态视图%@", result);
    return result;
}

// --------------------------------------------------------- 参考 -----------------------------------------------------------
// 指定view，展示对应的层级model  --- 未使用
- (NSDictionary *)getRootNodeForWindow:(UIView *)rootView inViewController:(UIViewController *)vc {
    NodeModel *rootNode = [[NodeModel alloc] init];
    NSMutableArray *subsViewNodes = [[NSMutableArray alloc] init];
    if ([rootView isKindOfClass:[UIWindow class]]) {
        // 说明是根节点
        rootNode.pageName = [NSString stringWithFormat:@"%@",vc.class];
        rootNode.className = [NSString stringWithFormat:@"%@",rootView.class];
        NSString *strFrame = [NSString stringWithFormat:@"%f,%f,%f,%f", rootView.frame.origin.x, rootView.frame.origin.y, rootView.frame.size.width, rootView.frame.size.height];
        rootNode.frame = strFrame;
        rootNode.findIndex = @"";
        if ([rootView.subviews count]>0) {
            for (int i = 0; i< [rootView.subviews count]; i++) {
                UIView *childview = [rootView.subviews objectAtIndex:i];
                NodeModel *node = [[NodeModel alloc] init];
                node.pageName = [NSString stringWithFormat:@"%@",vc.class];
                node.className = [NSString stringWithFormat:@"%@",childview.class];
                CGRect rect = [self getAddress:childview];
//                CGRect rect = rootView.frame;
                node.frame = [NSString stringWithFormat:@"%f,%f,%f,%f", rect.origin.x,rect.origin.y,rect.size.width,rect.size.height];
                if (isEmptyString_Nd(rootNode.findIndex)) {
                    node.findIndex = [NSString stringWithFormat:@"%d",i];
                } else {
                    node.findIndex = [NSString stringWithFormat:@"%@,%d",rootNode.findIndex,i];
                }
                [subsViewNodes addObject:node];
                if ([childview subviews].count > 0) {
                    // 递归子node
                    [self traverseChildView:childview nodeModel:node inViewController:vc];
                }
            }
        }
        rootNode.childNodeList = subsViewNodes;
    }
    
    NSDictionary *dic = [NdHJModelToJson getObjectData:rootNode];
    //    NSLog(@"层级json:%@",dic);
    return dic;
}

- (void)traverseChildView:(UIView *)rootView nodeModel:(NodeModel *)node inViewController:(UIViewController *)vc {
    if (!rootView) {
        return;
    }
    
    NSMutableArray *subsViewNodes = [[NSMutableArray alloc] init];
    if ([rootView.subviews count]>0) {
        for (int i = 0; i< [rootView.subviews count]; i++) {
            UIView *childview = [rootView.subviews objectAtIndex:i];
            NodeModel *childNode = [[NodeModel alloc] init];
            if (isEmptyString_Nd(node.findIndex)) {
                childNode.findIndex = [NSString stringWithFormat:@"%d",i];
            } else {
                childNode.findIndex = [NSString stringWithFormat:@"%@,%d",node.findIndex,i];
            }
//            if ([childview isKindOfClass:[MJRefreshNormalHeader class]]) {
//                NSLog(@"---class----indexStr-----:\n%@%@",childview.class,childNode.findIndex);
//            }
            CGRect rect = [self getAddress:childview];
            childNode.frame = [NSString stringWithFormat:@"%f,%f,%f,%f", rect.origin.x,rect.origin.y,rect.size.width,rect.size.height];
            childNode.pageName = [NSString stringWithFormat:@"%@",vc.class];
            childNode.className = [NSString stringWithFormat:@"%@",childview.class];
            [subsViewNodes addObject:childNode];
            if ([childview.subviews count]>0) {
                [self traverseChildView:childview nodeModel:childNode inViewController:vc];
            }
        }
    }
    node.childNodeList = subsViewNodes;
}

// 获取view相对于window的绝对地址
- (CGRect)getAddress:(UIView *)view {
    CGRect rect=[view convertRect: view.bounds toView:[UIApplication sharedApplication].delegate.window];
    return rect;
}

/// 查找UIWindow上指定的view
- (UIView *)getSubViewWithClassNameInViewController:(NSString *)vcName viewClassName:(NSString *)className index:(int)index inView:(UIView *)inView findIndex:(NSString *)findIndex { // 1,0,0,0,0,0,0,0,0,0,0,4,9,0,1,0
    NSArray *arrlist = [findIndex componentsSeparatedByString:@","];
    Class class = NSClassFromString(vcName);
    if (![[self getCurrentVC] isKindOfClass:class])  return nil;
    //如果类型不一样，找不到的
            
    //判空处理
    if(!inView || !inView.subviews.count || !className || !className.length || [className isKindOfClass:NSNull.class]) return nil;
    //最终找到的view，找不到的话，就直接返回一个nil
//    UIView *foundView = nil;
//    for (int i = 0; i< [inView.subviews count]; i++) {
//        UIView *view = [inView.subviews objectAtIndex:i];
//        //如果view是当前要查找的view，就直接赋值并终止循环递归，最终返回
//        if([view isKindOfClass:NSClassFromString(className)] && index == arrlist.count-1&&i==[arrlist[index] intValue]) {
//            foundView = view;
//            CGRect rect = [self getAddress:view];
//            NSLog(@"绝对地址坐标:%f,%f,%f,%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
//            break;
//        }
//        //如果当前view不是要查找的view的话，就在递归查找当前view的subviews
//        foundView = [self getSubViewWithClassNameInViewController:vcName viewClassName:className index:index+1 inView:view findIndex:findIndex];
//        //如果找到了，则终止循环递归，最终返回
//        if (foundView) break;
//    }
//    return foundView;
    
    UIView *foundView = inView;
    for (int i = 0; i< arrlist.count; i++) {
        int index = [[arrlist objectAtIndex:i] intValue];
        if ([foundView.subviews count] <= index) {
            return nil;
        }
        NSLog(@"foundView.subviews:%@",foundView.subviews);
        UIView *view = [foundView.subviews objectAtIndex:index];
        if (i == arrlist.count-1) {
            foundView = view;
            break;
        } else {
            foundView = view;
        }
    }
    return foundView;
}


// 测试用
/**
 * 返回传入veiw的全部层级结构
 *
 * @param view 须要获取层级结构的view
 *
 * @return 字符串
 */
- (NSString *)digView:(UIView *)view {
    if ([view isKindOfClass:[UITableViewCell class]]) return @"";
    // 1.初始化
    NSMutableString *xml = [NSMutableString string];
    // 2.标签开头
    [xml appendFormat:@"<%@ frame=\"%@\"", view.class, NSStringFromCGRect(view.frame)];
    if (!CGPointEqualToPoint(view.bounds.origin, CGPointZero)) {
        [xml appendFormat:@" bounds=\"%@\"", NSStringFromCGRect(view.bounds)];
    }
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scroll = (UIScrollView *)view;
        if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, scroll.contentInset)) {
            [xml appendFormat:@" contentInset=\"%@\"", NSStringFromUIEdgeInsets(scroll.contentInset)];
        }
    }
    // 3.推断是否要结束
    if (view.subviews.count == 0) {
        [xml appendString:@" />"];
        return xml;
    } else {
        [xml appendString:@">"];
    }
    // 4.遍历全部的子控件
    for (UIView *child in view.subviews) {
        NSString *childXml = [self digView:child];
        [xml appendString:childXml];
    }
    // 5.标签结尾
    [xml appendFormat:@"</%@>", view.class];
    return xml;
}

// 获取ViewController的层级
- (NSDictionary *)digViewForViewController:(UIView *)view index:(NSString *)indexStr {
    // 初始化
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    if ([view isKindOfClass:[UITableViewCell class]]) {
//        return dict;
//    }
    NSMutableArray *childArr = [[NSMutableArray alloc] init];
    [dict setObject:[NSString stringWithFormat:@"%@_%@",view.class,indexStr] forKey:@"resId"];
    [dict setObject:[NSString stringWithFormat:@"%ld",view.tag] forKey:@"tag"];
    [dict setObject:NSStringFromCGRect([self getAddress:view]) forKey:@"frame"];
    if (!CGPointEqualToPoint(view.bounds.origin, CGPointZero)) {
        [dict setObject:NSStringFromCGRect(view.bounds) forKey:@"bounds"];
    }
    if ([view isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scroll = (UIScrollView *)view;
        if (!UIEdgeInsetsEqualToEdgeInsets(UIEdgeInsetsZero, scroll.contentInset)) {
            [dict setObject:NSStringFromUIEdgeInsets(scroll.contentInset) forKey:@"contentInset"];
        }
    }
    // 当前页面名称
    UIViewController *vc = [self getCurrentVC];
    [dict setObject:NSStringFromClass(vc.class) forKey:@"pageName"];
    [dict setObject:indexStr forKey:@"findIndex"];
    [dict setObject:NSStringFromClass(view.class) forKey:@"className"];
    
    // 3.推断是否要结束
    if (view.subviews.count == 0) {
        return dict;
    }
    // 4.遍历全部的子控件
    for (int i = 0; i< [view.subviews count]; i++) {
        UIView *child = view.subviews[i];
        NSDictionary *childDic = [self digViewForViewController:child index:[NSString stringWithFormat:@"%@%@%d",indexStr,isEmptyString_Nd(indexStr)?@"":@",",i]];
        [childArr addObject:childDic];
    }
    [dict setObject:childArr forKey:@"childNodes"];
    return dict;
}

@end
