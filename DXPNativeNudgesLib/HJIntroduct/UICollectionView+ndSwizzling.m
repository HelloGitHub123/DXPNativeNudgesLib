//
//  UICollectionView+ndSwizzling.m
//  MPTCLPMall
//
//  Created by Lee on 2022/3/28.
//  Copyright © 2022 OO. All rights reserved.
//

#import "UICollectionView+ndSwizzling.h"
#import "Nudges.h"

@implementation UICollectionView (ndSwizzling)

+ (void)load {
    // 通过class_getInstanceMethod()函数从当前对象中的method list获取method结构体，如果是类方法就使用class_getClassMethod()函数获取。
    Method fromMethod = class_getInstanceMethod([self class], @selector(reloadData));
    Method toMethod = class_getInstanceMethod([self class], @selector(swizzlingReloadData));
    /**
     *  我们在这里使用class_addMethod()函数对Method Swizzling做了一层验证，如果self没有实现被交换的方法，会导致失败。
     *  而且self没有交换的方法实现，但是父类有这个方法，这样就会调用父类的方法，结果就不是我们想要的结果了。
     *  所以我们在这里通过class_addMethod()的验证，如果self实现了这个方法，class_addMethod()函数将会返回NO，我们就可以对其进行交换了。
     */
    
#if TreeSwitch
    if (!class_addMethod([self class], @selector(swizzlingReloadData), method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
        method_exchangeImplementations(fromMethod, toMethod);
    }
#endif
}


// 我们自己实现的方法，也就是和self的viewDidLoad方法进行交换的方法。
- (void)swizzlingReloadData {
#if TreeSwitch
    NSLog(@"collectionView开始reload : %@", self.class);
    [self swizzlingReloadData];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"HJUploadWindowInfoNotificationKey" object:nil];

//    [[NSNotificationCenter defaultCenter] postNotificationName:@"HJFindViewNotificationKey" object:nil];
#endif
    
}
@end
