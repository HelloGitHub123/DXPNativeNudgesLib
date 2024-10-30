//
//  NdHJInstructPopView.h
//  MOC
//
//  Created by Lee on 2022/3/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NdHJInstructPopView : UIView

+ (NdHJInstructPopView *)instructPopView;

@property (nonatomic, strong) UIView * bgView;

- (id)initWithFrame:(CGRect)frame;

@property (nonatomic, copy) NSString * contentStr;
@end

NS_ASSUME_NONNULL_END
