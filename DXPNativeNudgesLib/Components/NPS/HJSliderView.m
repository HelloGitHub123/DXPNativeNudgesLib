//
//  HJSliderView.m
//  DITOApp
//
//  Created by 李标 on 2022/9/11.
//

#import "HJSliderView.h"
#import <DXPFontManagerLib/FontManager.h>

@interface NumberView : UIButton

@end

@implementation NumberView


@end






@interface HJSliderView ()

@property (nonatomic, strong) UISlider *sliderView;
@property (nonatomic, assign) NSInteger selectIndex; // 选中的索引
@property (nonatomic, strong) NSMutableArray *numberList;
@property (nonatomic, strong) UILabel *leftLab;
@property (nonatomic, strong) UILabel *rightLab;
@property (nonatomic, assign) NSInteger resultNumber; // 评分结果
@end

@implementation HJSliderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.numberList = [[NSMutableArray alloc] init];
        self.selectIndex = 5;
        [self configView];
    }
    return self;
}

- (void)handleClick:(id)sender {
    NSLog(@"DXPNugges Log:=== handleClick");
    NumberView *selectNumberView = (NumberView *)sender;
    for (int i = 0; i< 11; i++) {
        NumberView *numberView = [self.numberList objectAtIndex:i];
        if (numberView.tag == selectNumberView.tag) {
            // 选中的view
            UIColor *selectionNpsColor = [UIColor colorWithHexString:self.ownPropModel.npsColor.selection];
            UIColor *selectionScaleColor = [UIColor colorWithHexString:self.ownPropModel.scaleColor.selection];
            [numberView setBackgroundColor:selectionNpsColor]; // 背景颜色
            [numberView setTitleColor:selectionScaleColor forState:UIControlStateNormal]; // 字体颜色
        } else {
            // 未选中的view
            UIColor *notSelection = [UIColor colorWithHexString:self.ownPropModel.npsColor.notSelection];
            UIColor *noSelectionScaleColor = [UIColor colorWithHexString:self.ownPropModel.scaleColor.notSelection];
            [numberView setBackgroundColor:notSelection]; // 背景颜色
            [numberView setTitleColor:noSelectionScaleColor forState:UIControlStateNormal]; // 字体颜色
        }
    }
    self.resultNumber = selectNumberView.tag;
    [self handleResult];
}

- (void)configView {
    
}

- (void)setIsClick:(BOOL)isClick {
    _isClick = isClick;
}

// 回调结果
- (void)handleResult {
    if (_delegate && [_delegate conformsToProtocol:@protocol(SliderViewEventDelegate)]) {
        if (_delegate && [_delegate respondsToSelector:@selector(SliderViewEventClickByResult:target:)]) {
            [_delegate SliderViewEventClickByResult:self.resultNumber target:self];
        }
    }
}

- (void)sliderValueChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    NSLog(@"DXPNugges Log:=== slider.value:%df",slider.value);
    for (int i = 0; i< 11; i++) {
        NumberView *numberView = [self.numberList objectAtIndex:i];
        if (i == (int)slider.value) {
            // 选中的view
            UIColor *selectionScaleColor = [UIColor colorWithHexString:_ownPropModel.scaleColor.selection];
            [numberView setTitleColor:selectionScaleColor forState:UIControlStateNormal]; // 字体颜色
        } else {
            // 未选中的view
            UIColor *noSelectionScaleColor = [UIColor colorWithHexString:_ownPropModel.scaleColor.notSelection];
            [numberView setTitleColor:noSelectionScaleColor forState:UIControlStateNormal]; // 字体颜色
        }
    }
    self.resultNumber = (int)slider.value;
    [self handleResult];
}

- (void)setOwnPropModel:(OwnPropModel *)ownPropModel {
    CGFloat single_width = (kScreenWidth - 2*12)/11;
    _ownPropModel = ownPropModel;
    for (int i = 0; i< 11; i++) {
        NumberView *numberView = [NumberView buttonWithType:UIButtonTypeCustom];
        [self.numberList addObject:numberView];
        numberView.tag = i;
        NSString *strTitle = [NSString stringWithFormat:@"%d",i];
        [numberView setTitle:strTitle forState:UIControlStateNormal];
        [self addSubview:numberView];
        [numberView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(0);
            if (i == 0) {
                make.leading.equalTo(self.mas_leading).offset([@(i*single_width+2) floatValue]);
            } else {
                make.leading.equalTo(self.mas_leading).offset([@(i*single_width+2*i) floatValue]);
            }
            make.width.equalTo(@(single_width));
            make.height.equalTo(@(20));
        }];
        
        if ([_ownPropModel.npsType isEqualToString:@"S"]) {
            [numberView setBackgroundColor:[UIColor clearColor]]; // 背景颜色
            if (i == self.selectIndex) {
                UIColor *selectionScaleColor = [UIColor colorWithHexString:_ownPropModel.scaleColor.selection];
                [numberView setTitleColor:selectionScaleColor forState:UIControlStateNormal]; // 字体颜色
            } else {
                UIColor *noSelectionScaleColor = [UIColor colorWithHexString:_ownPropModel.scaleColor.notSelection];
                [numberView setTitleColor:noSelectionScaleColor forState:UIControlStateNormal]; // 字体颜色
            }
        }
        
        
        if ([self.ownPropModel.npsType isEqualToString:@"C"]) {
            [numberView addTarget:self action:@selector(handleClick:) forControlEvents:UIControlEventTouchUpInside];
            if (i == self.selectIndex) {
                // 选中的按钮
                UIColor *selectionNpsColor = [UIColor colorWithHexString:_ownPropModel.npsColor.selection];
                UIColor *selectionScaleColor = [UIColor colorWithHexString:_ownPropModel.scaleColor.selection];
                [numberView setBackgroundColor:selectionNpsColor]; // 背景颜色
                [numberView setTitleColor:selectionScaleColor forState:UIControlStateNormal]; // 字体颜色
            } else {
                // 未选中的
                UIColor *notSelection = [UIColor colorWithHexString:_ownPropModel.npsColor.notSelection];
                UIColor *noSelectionScaleColor = [UIColor colorWithHexString:_ownPropModel.scaleColor.notSelection];
                [numberView setBackgroundColor:notSelection]; // 背景颜色
                [numberView setTitleColor:noSelectionScaleColor forState:UIControlStateNormal]; // 字体颜色
            }
        }
    }
    
    if ([_ownPropModel.npsType isEqualToString:@"S"]) {
        // 滑动Slider
        [self addSubview:self.sliderView];
        [_sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(20+5);
            make.leading.equalTo(self.mas_leading).offset(10);
            make.trailing.equalTo(self.mas_trailing).offset(-10);
            make.height.equalTo(@(35));
        }];
        // 设置滑条的颜色
        UIColor *selectionNpsColor = [UIColor colorWithHexString:_ownPropModel.npsColor.selection];
        UIColor *notSelection = [UIColor colorWithHexString:_ownPropModel.npsColor.notSelection];
        _sliderView.minimumTrackTintColor = selectionNpsColor;
        _sliderView.maximumTrackTintColor = notSelection;
    }
    // 左边
    [self addSubview:self.leftLab];
    self.leftLab.text = isEmptyString_Nd(self.ownPropModel.leftText.content)?@"":self.ownPropModel.leftText.content;
    NSString *L_textColor = @"#ABACB2";
    if (!isEmptyString_Nd(self.ownPropModel.leftText.color)) {
        L_textColor = self.ownPropModel.leftText.color;
    }
    self.leftLab.textColor = [UIColor colorWithHexString:L_textColor];
    self.leftLab.font = [FontManager setNormalFontSize:(self.ownPropModel.fontSize == 0 ? 12:self.ownPropModel.fontSize)];
    [_leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(10);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@50);
        if ([_ownPropModel.npsType isEqualToString:@"C"]) {
            make.bottom.equalTo(self.mas_bottom).offset(-5);
        } else {
            make.bottom.equalTo(self.mas_bottom).offset(-10);
        }
    }];
    // 右边
    [self addSubview:self.rightLab];
    self.rightLab.text = isEmptyString_Nd(self.ownPropModel.rightText.content)?@"":self.ownPropModel.rightText.content;
    NSString *R_textColor = @"#ABACB2";
    if (!isEmptyString_Nd(self.ownPropModel.rightText.color)) {
        R_textColor = self.ownPropModel.rightText.color;
    }
    self.rightLab.textColor = [UIColor colorWithHexString:R_textColor];
    self.rightLab.font = [FontManager setNormalFontSize:(self.ownPropModel.fontSize == 0 ?12:self.ownPropModel.fontSize)];
    [_rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing).offset(-10);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@50);
        if ([_ownPropModel.npsType isEqualToString:@"C"]) {
            make.bottom.equalTo(self.mas_bottom).offset(-5);
        } else {
            make.bottom.equalTo(self.mas_bottom).offset(-10);
        }
    }];
}

- (UISlider *)sliderView {
    if (!_sliderView) {
        _sliderView = [[UISlider alloc] initWithFrame:CGRectMake(0, 45, kScreenWidth, 35)];
        _sliderView.userInteractionEnabled = YES;
        _sliderView.continuous = YES;
        _sliderView.maximumValue = 10;
        _sliderView.minimumValue = 0;
        _sliderView.value = 5;
        _sliderView.backgroundColor = [UIColor whiteColor];
        [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _sliderView;
}

- (UILabel *)leftLab {
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        _leftLab.textAlignment = NSTextAlignmentLeft;
    }
    return _leftLab;
}

- (UILabel *)rightLab {
    if (!_rightLab) {
        _rightLab = [[UILabel alloc] init];
        _rightLab.textAlignment = NSTextAlignmentRight;
    }
    return _rightLab;
}

@end
