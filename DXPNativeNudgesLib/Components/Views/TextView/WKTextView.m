//
//  WKTextView.m
//  weirwood
//
//  Created by egs on 2017/4/11.
//  Copyright © 2017年 SDHS. All rights reserved.
//

#define singleHeight  22

#import "WKTextView.h"
#import "UIView+WKCategory.h"
#import "Nudges.h"

@interface WKTextView()<UITextViewDelegate>

@end

@implementation WKTextView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        UILabel *countLabel = [[UILabel alloc]init];
//        [self addSubview:countLabel];
//        countLabel.frame = CGRectMake(self.width - 60, self.height - 40, 60, 40);
//        countLabel.textAlignment = NSTextAlignmentCenter;
//        countLabel.textColor = [UIColor lightGrayColor];
//        countLabel.text = @"0/100";
//        self.countLabel = countLabel;
        ///设置边框
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4;
        self.layer.borderColor = UIColorFromRGB_Nd(0xF0F0F0).CGColor;
        self.layer.borderWidth = 1;
        
        self.delegate = self;
        //监听文字的改变的通知
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.placeholderLabel];
        [self addSubview:self.countLabel];
    }
    return self;
}

///移除通知监听
- (void)dealloc{
    UIView * view = [[UIView alloc]init];
    CGRect frame = view.frame;
    frame.origin.x = 100;
    view.frame = frame;
    //    self.frame.origin.x = 100;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.placeholderLabel.x = 8;
    self.placeholderLabel.y = 8;
    self.placeholderLabel.width = self.width - 2*self.placeholderLabel.x;
    ///根据占位文字myPlaceholder 算出占位Label的高度(宽度已定 高速自适应)
    CGSize maxSize = CGSizeMake(self.placeholderLabel.width, MAXFLOAT);
    self.placeholderLabel.height = [self.myPlaceholder boundingRectWithSize:maxSize options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.placeholderLabel.font} context:nil].size.height;
    if (self.isSigleLine) {
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(-3);
            make.trailing.equalTo(self.mas_trailing).offset(-10);
            make.height.equalTo(@22);
            make.width.greaterThanOrEqualTo(@30);
        }];
        self.height = singleHeight;
        self.textContainer.maximumNumberOfLines = 1;
        self.textContainer.lineBreakMode = NSLineBreakByTruncatingHead;
//        self.textContainerInset = UIEdgeInsetsZero;
//        self.textContainer.lineFragmentPadding = self.countLabel.width;
        CGFloat xMargin =12, yMargin = 10;
        // 使用textContainerInset设置top、left、right
        self.textContainerInset = UIEdgeInsetsMake(yMargin, 0, 0, self.countLabel.width);
        self.alwaysBounceVertical = YES;
    } else {
        [self.countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_bottom).offset(-18);
            make.trailing.equalTo(self.mas_trailing).offset(-10);
            make.height.equalTo(@18);
            make.width.greaterThanOrEqualTo(@30);
        }];
        
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self resignFirstResponder];
        return NO;
    }
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < self.maxNum) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = self.maxNum - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }
            else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                          
                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx++;
                                      }];
                
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            //既然是超出部分截取了，哪一定是最大限制了。
            self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld",(long)self.maxNum,(long)self.maxNum];
            
        }
        return NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    self.placeholderLabel.hidden = self.hasText;
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > self.maxNum)
    {
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        NSString *s = [nsTextContent substringToIndex:self.maxNum];
        
        [textView setText:s];
    }
    if (existTextNum > 100) {
        existTextNum = 100;
    }
    //不让显示负数
    self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld",MAX(0, existTextNum),(long)self.maxNum
                            ];
    
}



#pragma mark - setter

- (void)setMaxNum:(NSInteger)maxNum{
    _maxNum = maxNum;
    self.countLabel.text = [NSString stringWithFormat:@"0/%ld",(long)_maxNum];
}

// place holder 文本
- (void)setMyPlaceholder:(NSString *)myPlaceholder {
    _myPlaceholder = myPlaceholder;
    self.placeholderLabel.text = _myPlaceholder;
    ///重新计算占位label frame
    [self setNeedsLayout];
}

// place holder 文本颜色
- (void)setMyPlaceholderColor:(UIColor *)myPlaceholderColor{
    _myPlaceholderColor = myPlaceholderColor;
    self.countLabel.textColor = myPlaceholderColor;
    self.placeholderLabel.textColor = _myPlaceholderColor;
}

///从写TextView setFont方法 使占位labe、TextView、文字统计Label Font一致
- (void)setFont:(UIFont *)font {
    [super setFont:font];
    self.placeholderLabel.font = font;
    self.countLabel.font = font;
    ///重新计算占位label frame
    [self setNeedsLayout];
}

#pragma mark -- lazy load
- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
        _placeholderLabel.textAlignment = NSTextAlignmentLeft;
        _placeholderLabel.textColor = [UIColor lightGrayColor];
    }
    return _placeholderLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.text = [NSString stringWithFormat:@"0/200"];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.textColor = [UIColor lightGrayColor];
    }
    return _countLabel;
}

@end
