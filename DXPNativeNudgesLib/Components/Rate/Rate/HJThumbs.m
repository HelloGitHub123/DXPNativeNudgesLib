//
//  HJThumbs.m
//  DITOApp
//
//  Created by 李标 on 2022/9/17.
//

#import "HJThumbs.h"
#import "UIImage+SVGManager.h"
#import "Nudges.h"

@interface HJThumbs ()

@property (nonatomic, strong) UIImageView *thumbsUpImgview; // 点赞
@property (nonatomic, strong) UIImageView *thumbsDownImgview; // 点踩
@end



@implementation HJThumbs

- (instancetype)init {
    self = [super init];
    if (self) {
       
    }
    return self;
}

- (void)setViewWidth:(CGFloat)viewWidth {
    _viewWidth = viewWidth;
    [self initDataAndCreateUI];
}

- (void)setIconSize:(CGFloat)iconSize {
    _iconSize = iconSize;
}

// 初始化数据and创建视图
- (void)initDataAndCreateUI {
    // 2个icon区域的宽度
#define icon_space 20
    CGFloat w_iconview = self.iconSize * 2 + icon_space;
    
    [self addSubview:self.thumbsUpImgview];
    [self.thumbsUpImgview setUserInteractionEnabled:YES];
    self.thumbsUpImgview.frame = CGRectMake(_viewWidth/2 - w_iconview/2, 10, self.iconSize, self.iconSize);
    self.thumbsUpImgview.tag = 101;
    [self.thumbsUpImgview setImage:[UIImage svgImageNamed:@"thumbs-up" size:CGSizeMake(self.iconSize, self.iconSize) tintColor:isEmptyString_Nd(self.beforeSvgColor)?@"#333333":self.beforeSvgColor]];
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapRateView:)];
    tapGesture1.numberOfTapsRequired = 1;
    [self.thumbsUpImgview addGestureRecognizer:tapGesture1];
    
    [self addSubview:self.thumbsDownImgview];
    [self.thumbsDownImgview setUserInteractionEnabled:YES];
    self.thumbsDownImgview.frame = CGRectMake(_viewWidth/2 - w_iconview/2 + self.iconSize + 10, 10, self.iconSize, self.iconSize);
    self.thumbsDownImgview.tag = 102;
    [self.thumbsDownImgview setImage:[UIImage svgImageNamed:@"thumbs-down" size:CGSizeMake(self.iconSize, self.iconSize) tintColor:isEmptyString_Nd(self.beforeSvgColor)?@"#333333":self.beforeSvgColor]];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapRateView:)];
    tapGesture2.numberOfTapsRequired = 1;
    [self.thumbsDownImgview addGestureRecognizer:tapGesture2];
}

- (void)userTapRateView:(UIGestureRecognizer *)tap {
    NSInteger tag = tap.view.tag;
    if (tag == 101) {
        // 选中
        [self.thumbsUpImgview setImage:[UIImage svgImageNamed:@"thumbs-up" size:CGSizeMake(self.iconSize, self.iconSize) tintColor:isEmptyString_Nd(self.thumbsUpColor)?@"#e24a34":self.thumbsUpColor]];
        // 未选中颜色
        [self.thumbsDownImgview setImage:[UIImage svgImageNamed:@"thumbs-down" size:CGSizeMake(self.iconSize, self.iconSize) tintColor:isEmptyString_Nd(self.beforeSvgColor)?@"#e24a34":self.beforeSvgColor]];
    }
    if (tag == 102) {
        // 未选中颜色
        [self.thumbsUpImgview setImage:[UIImage svgImageNamed:@"thumbs-up" size:CGSizeMake(self.iconSize, self.iconSize) tintColor:isEmptyString_Nd(self.beforeSvgColor)?@"#e24a34":self.beforeSvgColor]];
        // 选中
        [self.thumbsDownImgview setImage:[UIImage svgImageNamed:@"thumbs-down" size:CGSizeMake(self.iconSize, self.iconSize) tintColor:isEmptyString_Nd(self.thumbsDownColor)?@"#e24a34":self.thumbsDownColor]];
    }
    
    if (self.sendThumnsVal) {
        self.sendThumnsVal((int)tag - 100);
    }
}

#pragma mark -- lazy load
- (UIImageView *)thumbsUpImgview {
    if (!_thumbsUpImgview) {
        _thumbsUpImgview = [[UIImageView alloc] init];
        _thumbsUpImgview.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _thumbsUpImgview;
}

- (UIImageView *)thumbsDownImgview {
    if (!_thumbsDownImgview) {
        _thumbsDownImgview = [[UIImageView alloc] init];
        _thumbsDownImgview.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _thumbsDownImgview;
}

@end
