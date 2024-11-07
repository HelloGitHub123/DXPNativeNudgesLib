//
//  UIScrollView+ndSwizzling.m
//  DITOApp
//
//  Created by 李标 on 2022/9/12.
//

#import "UIScrollView+ndSwizzling.h"
#import "HJNudgesManager.h"

@implementation UIScrollView (ndSwizzling)

+ (void)load {
    static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            SEL originalSelector = NSSelectorFromString(@"_scrollViewDidEndDeceleratingForDelegate");
            SEL swizzledSelector = @selector(jsbc_scrollViewDidEndDeceleratingForDelegate);

            [self exchangeMethod:originalSelector swizzledSelector:swizzledSelector];
            
            SEL originalSelector1 = NSSelectorFromString(@"_scrollViewDidEndDraggingForDelegateWithDeceleration:");
            SEL swizzledSelector1 = @selector(jsbc_scrollViewDidEndDraggingForDelegateWithDeceleration:);

            [self exchangeMethod:originalSelector1 swizzledSelector:swizzledSelector1];
            
        });
}

+ (void)exchangeMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Class class = [self class];

    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)jsbc_scrollViewDidEndDraggingForDelegateWithDeceleration:(BOOL)deceleration {
    [self jsbc_scrollViewDidEndDraggingForDelegateWithDeceleration:deceleration];
    if (!deceleration) {
        [self jsbcDidEndScroll];
        NSLog(@"DXPNugges Log:=== Stopped finger dragging %@",self);
        UIViewController *VC = [TKUtils topViewController];
        NSString *className = NSStringFromClass([VC class]);
        NSLog(@"DXPNugges Log:=== Current VC controller className:%@",className);
//        [[HJNudgesManager sharedInstance] selectNudgesDBWithPageName:className];
    }
}

- (void)jsbc_scrollViewDidEndDeceleratingForDelegate {
    [self jsbc_scrollViewDidEndDeceleratingForDelegate];
    [self jsbcDidEndScroll];
    NSLog(@"DXPNugges Log:=== Stopped inertial roll %@",self);
    UIViewController *VC = [TKUtils topViewController];
    NSString *className = NSStringFromClass([VC class]);
    NSLog(@"DXPNugges Log:=== Current VC controller className:%@",className);
//    [[HJNudgesManager sharedInstance] selectNudgesDBWithPageName:className];
	[[HJNudgesManager sharedInstance] queryNudgesWithPageName:className];
}

- (void)jsbcDidEndScroll {
    if ([self isKindOfClass:UITableView.class]) {
        UITableView *tableView = (UITableView *)self;
        [[tableView visibleCells] enumerateObjectsUsingBlock:^(__kindof UITableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *indexPath = [tableView indexPathForCell:obj];
            //通过indexPath获取当前可见区域cell坐标
            //TODO:在这里写自己的逻辑
         }];
    }
    else if ([self isKindOfClass:UICollectionView.class]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        [[collectionView visibleCells] enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *indexPath = [collectionView indexPathForCell:obj];
            //通过indexPath获取当前可见区域cell坐标
            //TODO:在这里写自己的逻辑
         }];
    }
}

@end
