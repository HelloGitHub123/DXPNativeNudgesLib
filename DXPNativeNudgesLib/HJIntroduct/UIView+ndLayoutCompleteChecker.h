//
//  UIView+ndLayoutCompleteChecker.h
//  MPTCLPMall
//
//  Created by Lee on 2022/3/29.
//  Copyright © 2022 OO. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^callback)();

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ndLayoutCompleteChecker)

- (void)startCheckingWithCompletionBlock:(callback)callback;

@end

NS_ASSUME_NONNULL_END
