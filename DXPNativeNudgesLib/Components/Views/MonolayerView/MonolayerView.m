//
//  MonolayerView.m
//  DITOApp
//
//  Created by 李标 on 2022/8/8.
//

#import "MonolayerView.h"
#import "TKUtils.h"

@interface MonolayerView ()

// 透明区域的Rect
@property (nonatomic, assign) CGRect alphaRect;
// 透明区域圆角
@property (nonatomic, assign) CGFloat cornerRadius;
// 样式
@property (nonatomic, assign) KOwnPropType spotlightType;
@end

@implementation MonolayerView

- (instancetype)init {
    self = [super init];
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickView:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
    
    // 默认全屏遮罩
    self.monolayerViewType = KMonolayerViewType_full;
    
    return self;
}

// 设置 镂空 view 的属性
- (void)setAlphaRectParametersByRect:(CGRect)alphaRect SpotlightType:(KOwnPropType)type radius:(CGFloat)cornerRadius {
    self.alphaRect = alphaRect;
    self.cornerRadius = cornerRadius;
    self.spotlightType = type;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return;
    }
    
    UIColor *backgroundColor = [TKUtils GetColor:self.bgroundColor alpha:1.0];
    [[backgroundColor colorWithAlphaComponent:self.backgroundAlpha] setFill];
    UIRectFill(rect);
    
    [[UIColor clearColor] setFill];
    
    if (self.monolayerViewType == KMonolayerViewType_Spotlight) {
        //设置透明部分位置和圆角
        CGRect alphaRect = self.alphaRect;
        CGFloat cornerRadius = self.cornerRadius;
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:alphaRect
                                                            cornerRadius:cornerRadius];
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor clearColor] CGColor]);
       
        CGContextAddPath(context, bezierPath.CGPath);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        CGContextFillPath(context);
    }
}

- (void)clickView:(UITapGestureRecognizer *)sender {
    if (self.isTouch) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(MonolayerViewClickEventByTarget:)]) {
            [self.delegate MonolayerViewClickEventByTarget:self];
        }
    }
}

@end
