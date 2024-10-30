//
//  UIViewController+ndSwizzling.m
//  DITOApp
//
//  Created by 李标 on 2022/5/17.
//

#import "UIViewController+ndSwizzling.h"
#import "HJNudgesManager.h"

@implementation UIViewController (ndSwizzling)

+ (void)load {
    //我们只有在开发的时候才需要查看哪个viewController将出现
    //所以在release模式下就没必要进行方法的交换
#ifdef DEBUG

#pragma mark -- 原本的viewWillAppear方法
//    Method viewWillAppear = class_getInstanceMethod(self, @selector(viewWillAppear:));
//
//    //需要替换成 能够输出日志的viewWillAppear
//    Method logViewWillAppear = class_getInstanceMethod(self, @selector(logViewWillAppear:));
//
//    method_exchangeImplementations(viewWillAppear, logViewWillAppear);
    
#pragma mark -- viewDidLayoutSubviews
//    Method viewDidLayoutSubviews = class_getInstanceMethod(self, @selector(viewDidLayoutSubviews));
//    Method logLayoutSubviews = class_getInstanceMethod(self, @selector(logLayoutSubviews:));
//    //两方法进行交换
//    method_exchangeImplementations(viewDidLayoutSubviews, logLayoutSubviews);
    
#pragma mark -- viewWillLayoutSubviews
//    Method viewWillLayoutSubviews = class_getInstanceMethod(self, @selector(viewWillLayoutSubviews));
//    Method logViewWillLayoutSubviews = class_getInstanceMethod(self, @selector(logViewWillLayoutSubviews));
//    //两方法进行交换
//    method_exchangeImplementations(viewWillLayoutSubviews, logViewWillLayoutSubviews);

#pragma mark -- viewDidLoad
//    Method viewViewDidLoad = class_getInstanceMethod(self, @selector(viewDidLoad));
//
//    Method logViewViewDidLoad = class_getInstanceMethod(self, @selector(logViewViewDidLoad));
//
//    //两方法进行交换
//    method_exchangeImplementations(viewViewDidLoad, logViewViewDidLoad);
    
#endif
	
	
#pragma mark -- viewDidApper
	Method viewDidAppear = class_getInstanceMethod(self, @selector(viewDidAppear:));
	Method logViewDidAppear = class_getInstanceMethod(self, @selector(logViewDidAppear:));
	//两方法进行交换
	method_exchangeImplementations(viewDidAppear, logViewDidAppear);
	
	
}

- (void)logViewDidAppear:(BOOL)animated {
	UIViewController *VC = [TKUtils topViewController];
	NSString *className = NSStringFromClass([VC class]);
	NSLog(@"logViewDidAppear当前VC控制器className:%@",className);
	[[HJNudgesManager sharedInstance] queryNudgesWithPageName:className];
}

//- (void)logViewViewDidLoad {
//    UIViewController *VC = [self getCurrentVC];
//    NSString *className = NSStringFromClass([VC class]);
//    NSLog(@"logLayoutSubviews");
//    NSLog(@"当前VC控制器className:%@",className);
//    [[HJNudgesManager sharedInstance] selectNudgesDBWithPageName:className];
//    [self logViewViewDidLoad];
//}

//- (void)logLayoutSubviews:(BOOL)animated {
//    //    NSString *className = NSStringFromClass([self class]);
//    //    NSLog(@"当前VC控制器className:%@",className);
////    UIViewController *VC = [self getCurrentVC];
//    UIViewController *VC = [TKUtils topViewController];
//    NSString *className = NSStringFromClass([VC class]);
////    NSLog(@"logLayoutSubviews");
//    [[HJNudgesManager sharedInstance] queryNudgesWithPageName:className];
//    [self logLayoutSubviews:animated];
//}

//- (void)logViewWillAppear:(BOOL)animated {
//    NSString *className = NSStringFromClass([self class]);
//    // 查找对应页面的 nudges 列表
//    [[HJNudgesManager sharedInstance] createTimer:className];
//
//    //在这里，你可以进行过滤操作，指定哪些viewController需要打印，哪些不需要打印
//    //    if ([className hasPrefix:@"UI"] == NO) {
//    //        NSLog(@"%@ will appear",className);
//    //    }
//
//    //下面方法的调用，其实是调用viewWillAppear
//    [self logViewWillAppear:animated];
//}

//- (void)logViewWillLayoutSubviews {
//    NSString *className = NSStringFromClass([self class]);
////    NSLog(@"logViewWillLayoutSubviews");
//    [[HJNudgesManager sharedInstance] queryNudgesWithPageName:className];
////    NSDictionary *dic = [[HJNudgesManager sharedInstance] getWindowDomTree];
////    DebugLog(@"DomTree 数据：%@",dic);
//    [self logViewWillLayoutSubviews];
//}

//- (void)logviewDidLoad {
//    NSString *className = NSStringFromClass([self class]);
//    NSLog(@"logviewDidLoad");
//    NSLog(@"当前VC控制器className:%@",className);
//    [[HJNudgesManager sharedInstance] selectNudgesDBWithPageName:className];
////    NSDictionary *dic = [[HJNudgesManager sharedInstance] getWindowDomTree];
////    DebugLog(@"DomTree 数据：%@",dic);
//    [self logviewDidLoad];
//}

@end
