//
//  NdHJInstructPopView.m
//  MOC
//
//  Created by Lee on 2022/3/24.
//

#import "NdHJInstructPopView.h"
#import "Nudges.h"

static NdHJInstructPopView *_instructPopView = nil;
static dispatch_once_t onceToken;

@interface NdHJInstructPopView (){
    CGRect MyFrame;
}


@property (nonatomic, strong) UILabel * contentLabel;

@property (nonatomic, strong) UIButton * sureBtn;

@end


@implementation NdHJInstructPopView
+ (NdHJInstructPopView *)instructPopView{
    dispatch_once(&onceToken, ^{
        _instructPopView = [[NdHJInstructPopView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-70, 200)];
    });
    return _instructPopView;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        MyFrame = frame;
        [self configView];
        
    }
    return self;
}

- (void)configView{
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.contentLabel];
    [self.bgView addSubview:self.sureBtn];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth-70);
        make.height.mas_equalTo(200);
    }];
    
    [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@16);
        make.trailing.equalTo(@-16);
        make.top.equalTo(@16);
    }];
    
    [_sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@16);
        make.trailing.equalTo(@-16);
        make.top.equalTo(self.contentLabel.mas_bottom).with.offset(15);
        make.height.equalTo(@44);
    }];
    
}

- (void)sureBtnAction:(UIButton *)sender{
    [self dismiss];
}

- (void)show {
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 1.0;
        
    } completion:nil];
}
 
- (void)dismiss {
   
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3f animations:^{
        weakSelf.alpha = 0.0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        
    }];
}

- (void)setContentStr:(NSString *)contentStr{
    _contentStr = contentStr;
    _contentLabel.text = contentStr;
    
}

#pragma mark -- lazy load
- (UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
//        _bgView.backgroundColor = UIColorFromRGB(0xffffff);
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.5f;
        _bgView.layer.masksToBounds = YES;
        _bgView.layer.cornerRadius = 12.f;
    }
    return _bgView;
}


- (UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureBtn setTitle:@"" forState:UIControlStateNormal];
        [_sureBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_sureBtn addTarget:self action:@selector(sureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _sureBtn;
}


@end
