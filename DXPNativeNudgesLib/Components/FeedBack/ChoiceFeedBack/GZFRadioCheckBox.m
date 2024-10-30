//
//  GZFRadioCheckBox.m
//  BlueMobiProject
//
//  Created by GengZhongFei on 14/11/28.
//  Copyright (c) 2014年 朱 亮亮. All rights reserved.
//

#import "GZFRadioCheckBox.h"
#import <DXPFontManagerLib/FontManager.h>

// radio button 的宽高
#define kRadioButtonWidth 24
#define kRadioButtonHeight 24

@implementation GZFRadioCheckBox

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.index = nil;
        self.isHorizontal = YES;
        self.spacing = 10;
      self.showTextFont = [FontManager setNormalFontSize:10];
        self.showTextColor = [UIColor blackColor];
        self.hideMulitSelectArray = @[].mutableCopy;
    }
    return self;
}

- (void)setShowTextArray:(NSArray *)showTextArray {
    _showTextArray = showTextArray;
    [self initUI];
}

#pragma mark - 初始化UI
- (void) initUI {
    if (self.isHorizontal) { // 水平显示
        int showTextCount = [self.showTextArray count]; // 显示的个数
        for(int i = 0; i< showTextCount; i++) {
            //TODO: 间距是已button 为间距，没有已button和文字为整体做为间距，这里没做处理
            
            // 输入文字的宽度
            CGFloat showTextWidth  = [self getStringWidth:self.showTextArray[i] andFont:self.showTextFont];
            // Customize UIButton
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(i*(kRadioButtonWidth + self.spacing ), (self.frame.size.height-kRadioButtonHeight)/2,kRadioButtonWidth, kRadioButtonHeight);
            button.adjustsImageWhenHighlighted = NO;
            if (self.selectImageArray&&self.unselectImageArray) {
                [button setImage:[UIImage imageNamed:self.unselectImageArray[i]] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:self.selectImageArray[i]] forState:UIControlStateSelected];
            } else {
                if (self.isMultSelect) {
                    [button setImage:[UIImage imageNamed:@"icon_checkbox_normal"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"icon_checkbox_selected"] forState:UIControlStateSelected];
                } else {
                    [button setImage:[UIImage imageNamed:@"icon_raido_normal"] forState:UIControlStateNormal];
                    [button setImage:[UIImage imageNamed:@"icon_raido_selected"] forState:UIControlStateSelected];
                }
            }
            button.tag = i + 1;
            if (self.index&&self.index.intValue == i ) {
                button.selected = YES;
            }
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            // 显示的文字
            UILabel *showTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x +button.frame.size.width + 10, (self.frame.size.height-kRadioButtonHeight)/2, showTextWidth, kRadioButtonHeight)];
            showTextLabel.font = self.showTextFont;
            showTextLabel.textColor = self.showTextColor;
            showTextLabel.text = self.showTextArray[i];
            showTextLabel.backgroundColor = [UIColor clearColor];
            
            [self addSubview:showTextLabel];
            [self addSubview:button];
        }
    } else {
        // 纵向显示
        int showTextCount = [self.showTextArray count]; // 显示的个数
        for(int i = 0; i< showTextCount; i++) {
            // 输入文字的宽度
            CGFloat showTextWidth  = [self getStringWidth:self.showTextArray[i] andFont:self.showTextFont];
            // Customize UIButton
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, i*(kRadioButtonHeight + self.spacing),kRadioButtonWidth, kRadioButtonHeight);
            button.adjustsImageWhenHighlighted = NO;
            if (self.isMultSelect) {
                [button setImage:[UIImage imageNamed:@"icon_checkbox_normal"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"icon_checkbox_selected"] forState:UIControlStateSelected];
            } else {
                [button setImage:[UIImage imageNamed:@"icon_raido_normal"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"icon_raido_selected"] forState:UIControlStateSelected];
            }
            button.tag = i + 1;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            if (self.index&&self.index.intValue == i ) {
                button.selected = YES;
            }
            // 显示的文字
            UILabel *showTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width + 10, button.frame.origin.y, showTextWidth, kRadioButtonHeight)];
            showTextLabel.font = self.showTextFont;
            showTextLabel.textColor = self.showTextColor;
            showTextLabel.text = self.showTextArray[i];
            showTextLabel.backgroundColor = [UIColor clearColor];
            // 是否有下划线
            if (self.isHasDecoration) {
                NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:self.showTextArray[i]];
                NSRange contentRange = {0,[content length]};
                [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
                showTextLabel.attributedText = content;
            }
            [self addSubview:showTextLabel];
            [self addSubview:button];
        }
    }
}

#pragma mark - 点击事件
- (void)buttonClick:(UIButton *)btn {
    if (self.isMultSelect) {
        //多选
        btn.selected = !btn.isSelected;
        [self.hideMulitSelectArray removeAllObjects];
        for (UIButton *button in self.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
//                button.selected = NO;】
                if ( button.isSelected) {
                    [self.hideMulitSelectArray addObject:self.hideTextArray[button.tag - 1]];
                }
            }
        }
        if (self.hideTextArray && [self.hideTextArray count] > 0) {
            [self.delegate radioMultCheckBoxSelectedMulithideTextSelectArray:self.hideMulitSelectArray ];
        }
        if (self.multRadioCheckBoxBlock) {
            self.multRadioCheckBoxBlock(self.hideMulitSelectArray);
        }
        return;
    }
    
    //单选
    for (UIButton *button in self.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            button.selected = NO;
        }
    }
    
    btn.selected = YES;

    // 代理方法
    if (self.delegate && [self.delegate respondsToSelector:@selector(radioCheckBoxSelected:index:showText:hideText:)]) {
         // 隐藏的数组 必须和showTextArray 保持一致，否则会崩溃
        if (self.hideTextArray && [self.hideTextArray count] > 0) {
            [self.delegate radioCheckBoxSelected:self index:btn.tag -1 showText:self.showTextArray[btn.tag -1] hideText:self.hideTextArray[btn.tag - 1]];

        } else {
            [self.delegate radioCheckBoxSelected:self index:btn.tag -1 showText:self.showTextArray[btn.tag -1] hideText:@""];
        }
    }
    
    // block
    if (self.radioCheckBoxBlock) {
        // 隐藏的数组 必须和showTextArray 保持一致，否则会崩溃
        if (self.hideTextArray && [self.hideTextArray count] > 0) {
            self.radioCheckBoxBlock(btn.tag - 1, self.showTextArray[btn.tag -1], self.hideTextArray[btn.tag - 1]);
        } else {
            self.radioCheckBoxBlock(btn.tag - 1, self.showTextArray[btn.tag -1], @"");
        }
    }
}

#pragma mark - 方法
//获取字符的宽度，在水平排列时，需要获得
- (CGFloat) getStringWidth:(NSString *)aString andFont:(UIFont*) font {
    CGSize stringSize = [aString sizeWithFont:font]; // 规定字符字体获取字符串Size，再获取其宽度。
    CGFloat width = stringSize.width;
    return width;
}

#pragma mark - block 方法
- (void) radioCheckBoxClick:(RadioCheckBoxBlock)block {
    self.radioCheckBoxBlock = block;
}

- (void) multCheckBoxClick: (RadioMultCheckBoxBlock) multbBlock;
{
    self.multRadioCheckBoxBlock = multbBlock;
}

@end
