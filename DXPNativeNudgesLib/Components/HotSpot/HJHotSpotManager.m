//
//  HJHotSpotManager.m
//  DITOApp
//
//  Created by 李标 on 2022/8/9.
//

#import "HJHotSpotManager.h"
#import "NdHJNudgesDBManager.h"
#import "NdHJIntroductManager.h"
#import "CMPopTipView.h"
#import "UIView+NdAddGradualLayer.h"
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <ZFPlayer/ZFIJKPlayerManager.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import <ZFPlayer/UIView+ZFFrame.h>
#import <ZFPlayer/ZFPlayerConst.h>
#import "UIImageView+ZFCache.h"
#import "ZFUtilities.h"
#import "ZFCustomControlView.h"
#import "HJNudgesManager.h"
#import <DXPFontManagerLib/FontManager.h>

#define Padding_Spacing 10
#define View_Spacing  10
#define Button_height 30
#define Bottom_Spacing 15

static HJHotSpotManager *manager = nil;

@interface HJHotSpotManager ()<CMPopTipViewDelegate, MonolayerViewDelegate> {
    
}
//@property (nonatomic, strong) NSMutableArray *visiblePopTipViews;
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFCustomControlView *controlView;
@property (nonatomic, strong) UIView *beaConView;

@property (nonatomic, strong) CMPopTipView *popTipView;
@end

@implementation HJHotSpotManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HJHotSpotManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
//        self.visiblePopTipViews = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)ButtonClickAction:(id)sender {
	UIButton *btn = (UIButton *)sender;
	for (int i = 0; i< [_baseModel.buttonsModel.buttonList count]; i ++) {
		ButtonItem *item = [_baseModel.buttonsModel.buttonList objectAtIndex:i];
		BOOL isClose = NO;// 是否关闭按钮
		if (item.itemTag == btn.tag) {
			if (KButtonsActionType_CloseNudges == item.action.type) {
				isClose = YES;
			} else if (KBorderStyle_LaunchURL == item.action.type) {
				isClose = NO;
			} else if (KBorderStyle_InvokeAction == item.action.type) {
				// 调用方法
				isClose = NO;
			}
			
			// 关闭Nudges
			[self removeBeaConView];
			[self stopCurrentPlayingView]; // 停止播放器
			[self removeNudges];
			[self removeMonolayer];
			[self stopTimer];
			[self.popTipView removeFromSuperview];
			self.popTipView = nil;
			[[HJNudgesManager sharedInstance] showNextNudges];
			
			// 神策埋点
			NSString *contactId = isEmptyString_Nd(_baseModel.contactId)?@"":_baseModel.contactId;
			NSString *nudgesName = isEmptyString_Nd(_baseModel.nudgesName)?@"":_baseModel.nudgesName;
			NSString *pageName = isEmptyString_Nd(_baseModel.pageName)?@"":_baseModel.pageName;
			NSString *text = isEmptyString_Nd(item.text.content)?@"":item.text.content;
			NSString *url = isEmptyString_Nd(item.action.url)?@"":item.action.url;
			NSString *invokeAction = isEmptyString_Nd(item.action.invokeAction)?@"":item.action.invokeAction;
				
			if (_delegate && [_delegate conformsToProtocol:@protocol(HotSpotEventDelegate)]) {
				if (_delegate && [_delegate respondsToSelector:@selector(HotSpotClickEventByActionModel:isClose:buttonName:nudgeModel:)]) {
					[_delegate HotSpotClickEventByActionModel:item.action isClose:isClose buttonName:text nudgeModel:_baseModel];
				}
			}
			
			// 埋点发送通知给RN
			[[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeClick",@"body":@{@"nudgesId":@(_baseModel.nudgesId),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(_baseModel.campaignId),@"batchId":@"0",@"jumpUrl":url,@"invokeAction":invokeAction,@"isClose":@(isClose),@"buttonName":text,@"source":@"1",@"pageName":pageName}}];
		}
	}
}

- (void)setBaseModel:(NudgesBaseModel *)baseModel {
    _baseModel = baseModel;
//    [self constructsNudgesViewData:baseModel];
}

- (void)setNudgesModel:(NudgesModel *)nudgesModel {
    _nudgesModel = nudgesModel;
}

#pragma mark -- 构造nudges数据
- (void)startConstructsNudgesView {
	if (self.baseModel && self.findView) {
		[self constructsNudgesViewData:self.baseModel view:self.findView];
	}
}

#pragma mark -- 方法
// 移除蒙层
- (void)removeMonolayer {
    if (self.monolayerView) {
        [self.monolayerView removeFromSuperview];
        self.monolayerView = nil;
    }
}

// 停止定时器
- (void)stopTimer {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

// dissMiss 按钮点击事件
- (void)dissMissButtonClick:(id)sender {
    NSLog(@"DXPNugges Log:=== dissMissButtonClick");
    [self MonolayerViewClickEventByTarget:self];
}

// 移除ToolTips
- (void)removeNudges {
    if ([[HJNudgesManager sharedInstance].visiblePopTipViews count] > 0) {
        CMPopTipView *popTipView = [[HJNudgesManager sharedInstance].visiblePopTipViews objectAtIndex:0];
        [popTipView dismissAnimated:YES];
        [[HJNudgesManager sharedInstance].visiblePopTipViews removeObjectAtIndex:0];
        [self stopCurrentPlayingView];
    }
}

// 删除预览的nudges
- (void)removePreviewNudges {
	// 关闭Nudges
	[self removeBeaConView];
	[self stopCurrentPlayingView]; // 停止播放器
	[self removeNudges];
	[self removeMonolayer];
	[self stopTimer];
	[self.popTipView removeFromSuperview];
	self.popTipView = nil;
}

// 停止播放，并且移除播放器
- (void)stopCurrentPlayingView {
    if (self.player) {
        [self.player stopCurrentPlayingView];
        self.player = nil;
        self.controlView = nil;
    }
}

- (void)removeBeaConView {
    if (self.beaConView) {
        [self.beaConView removeFromSuperview];
        self.beaConView = nil;
    }
}

#pragma mark -- 构造nudges数据
- (void)constructsNudgesViewData:(NudgesBaseModel *)baseModel view:(UIView *)view {
 
    // 展示时间判断
    NSString *dateNow = [TKUtils getFullDateStringWithDate:[NSDate date]];
    if (isEmptyString_Nd(dateNow) || isEmptyString_Nd(baseModel.campaignExpDate)) {
        // 时间是空的，调过时间判断，给予展示
    } else {
        if ([TKUtils compareDate:baseModel.campaignExpDate withDate:dateNow] == 1) {
            // 超过了 活动截止时间 不给展示
            return;
        }
    }
    
    // 创建 BeaCon
    CGRect rect = [self getAddress:view]; // 绝对地址
    CGFloat y_beaCon = rect.origin.y  + rect.size.height;
    self.beaConView = [[UIView alloc] init];
    self.beaConView.layer.cornerRadius = 15;
    [[UIApplication sharedApplication].delegate.window addSubview:self.beaConView];
    [self.beaConView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(rect.origin.x +  rect.size.width / 2 - 15));
        make.width.equalTo(@30);
        make.height.equalTo(@30);
        make.top.equalTo(@(y_beaCon));
    }];
    NSString *color = baseModel.ownPropModel.color;
    if (isEmptyString_Nd(color)) {
        color = @"4477EE";
    }

    NSInteger opacity = 100;
    if (baseModel.ownPropModel.opacity > 0) {
        opacity = baseModel.ownPropModel.opacity;
    }
    
    if (baseModel.ownPropModel.type == KOwnPropType_InnerHighlight) {
        self.beaConView.backgroundColor = [UIColor clearColor];//[HJUtils GetColor:@"FFFFFF" alpha:(baseModel.ownPropModel.opacity / 100.0)];
        self.beaConView.layer.borderColor = [UIColor colorWithHexString:color].CGColor;
        self.beaConView.layer.borderWidth = 1;
        self.beaConView.alpha = baseModel.ownPropModel.opacity / 100.0 ;
        // 中间的小圈
        UIView *midView = [[UIView alloc] init];
        [self.beaConView addSubview:midView];
        midView.backgroundColor = [UIColor colorWithHexString:color];
        midView.layer.cornerRadius = 10;
        [midView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.beaConView.mas_left).offset(5);
            make.right.equalTo(self.beaConView.mas_right).offset(-5);
            make.height.equalTo(@20);
            make.width.equalTo(@20);
            make.top.equalTo(self.beaConView.mas_top).offset(5);
        }];
    }
    if (baseModel.ownPropModel.type == KOwnPropType_FilledHighlight) {
        self.beaConView.backgroundColor = [TKUtils GetColor:color alpha:(baseModel.ownPropModel.opacity / 100.0)];
        self.beaConView.alpha = baseModel.ownPropModel.opacity / 100.0 ;
        // 中间的小圈
        UIView *midView = [[UIView alloc] init];
        [self.beaConView addSubview:midView];
        midView.backgroundColor = [UIColor colorWithHexString:color];
        midView.layer.cornerRadius = 10;
        [midView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.beaConView.mas_left).offset(5);
            make.right.equalTo(self.beaConView.mas_right).offset(-5);
            make.height.equalTo(@20);
            make.width.equalTo(@20);
            make.top.equalTo(self.beaConView.mas_top).offset(5);
        }];
    }

    
    // 遮罩 + 镂空
    self.monolayerView = [[MonolayerView alloc] init];
    self.monolayerView.monolayerViewType = KMonolayerViewType_Spotlight; // 遮罩 + 镂空
    self.monolayerView.delegate = self;
    // 设置属性
    NSInteger type = baseModel.ownPropModel.type;
    CGFloat radius = 10; // 矩形默认 10
    if (KOwnPropType_Round == type) {
        // 圆形
        radius = view.frame.size.height / 2;
    }
    [self.monolayerView setAlphaRectParametersByRect:[self getAddress:view] SpotlightType:KOwnPropType_Box radius:radius];
	
	
	// 构造给 nudges 指向的位置
	UIView *tConView = view;
//    CGRect frame = tConView.frame;
	CGRect frame = CGRectZero;
	frame.origin.y = view.origin.y + view.size.height;
//    frame.origin.x = ( rect.size.width / 2 ); //rect.origin.x ;
	frame.origin.x = view.origin.x +  view.size.width / 2 -15 ;
	frame.size.width = 30;
	frame.size.height = 30;
	tConView.frame = frame;
	
    // 展示蒙层
	if (!baseModel.backdropModel.enabled) {
		self.monolayerView.backgroundAlpha = 0;
		self.monolayerView.bgroundColor = @"0x000000";
	} else {
		if (baseModel.backdropModel.type == KBackgroundType_Image) {
			// 图片
		} else if (baseModel.backdropModel.type == KBackgroundType_Gradient) {
			// 渐变
			NSString *gradientStartColor = baseModel.backdropModel.gradientStartColor;
			NSString *gradientEndColor = baseModel.backdropModel.gradientEndColor;
			if (isEmptyString_Nd(gradientStartColor) || isEmptyString_Nd(gradientEndColor)) {
				return;
			}
			[self.monolayerView addGradualLayerWithColors:@[(__bridge id)[UIColor colorWithHexString:gradientStartColor].CGColor,(__bridge id)[UIColor colorWithHexString:gradientEndColor].CGColor] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
		} else {
			// 实色
			CGFloat alpha = 0.3;
			if (baseModel.backdropModel.opacity > 0) {
				alpha = baseModel.backdropModel.opacity / 100.0;
			}
			self.monolayerView.backgroundAlpha = alpha;
			
			if (isEmptyString_Nd(baseModel.backdropModel.backgroundColor)) {
				self.monolayerView.bgroundColor = @"0x000000";
			} else {
				self.monolayerView.bgroundColor = baseModel.backdropModel.backgroundColor;
			}
		}
	}

//    [kAppDelegate.window addSubview:self.monolayerView];
    [[TKUtils topViewController].view addSubview:self.monolayerView];
    
    
    if (isEmptyString_Nd(baseModel.imageModel.imageUrl)
        && isEmptyString_Nd(baseModel.titleModel.content)
        && isEmptyString_Nd(baseModel.bodyModel.content)
        && [baseModel.buttonsModel.buttonList count] == 0) {
        
        if (self.popTipView) {
            return;
        }
        CMPopTipView *popTipView = [[CMPopTipView alloc] initWithCustomView:[[UIView alloc]initWithFrame:CGRectZero]];
        self.popTipView = popTipView;
        // 弹出Nudges
        [popTipView presentPointingAtView:tConView inView:[UIApplication sharedApplication].delegate.window animated:YES];
        [[HJNudgesManager sharedInstance].visiblePopTipViews addObject:popTipView];
        
        return;
    }
    
    
#pragma mark -- 自定义view
    CGFloat height_title = 0;
    CGFloat h_body = 0;
    int iViewCount = 0;
    CGFloat height_image = 0; // 图片的高度
    CGFloat h_dissButton = 0;
    
    UIView *customView = [[UIView alloc] init];
    // 宽度
    NSInteger nWidth = 200;
    if (baseModel.positionModel.width > 0) {
        nWidth = baseModel.positionModel.width;
    }
    
    UIButton *dissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [customView addSubview:dissButton];
    if ([baseModel.dismiss containsString:@"A"]) {
        // 关闭按钮
        [dissButton addTarget:self action:@selector(dissMissButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        // 图标大小
        NSInteger iconSize = 16;
        if (baseModel.dismissButtonModel.iconStyle.iconSize > 0) {
            iconSize = baseModel.dismissButtonModel.iconStyle.iconSize;
        }
        [dissButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(customView.mas_top).offset(4);
            make.trailing.equalTo(customView.mas_trailing).offset(-14);
            make.height.equalTo(@(iconSize+10));
            make.width.equalTo(@(iconSize+10));
        }];
        dissButton.layer.cornerRadius = (iconSize+10)/2;
        [dissButton setTitle:@"X" forState:UIControlStateNormal];
        dissButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        dissButton.titleLabel.font = [FontManager setNormalFontSize:iconSize];
        // 标题颜色
        UIColor *color = [UIColor whiteColor];
        if (!isEmptyString_Nd([UIColor colorWithHexString:baseModel.dismissButtonModel.iconStyle.iconColor])) {
            color = [UIColor colorWithHexString:baseModel.dismissButtonModel.iconStyle.iconColor];
        }
        [dissButton setTitleColor:color forState:UIControlStateNormal];
        if (baseModel.dismissButtonModel.type == KDismissButtonType_FilledButton) {
            UIColor *color = [UIColor whiteColor];
            if (!isEmptyString_Nd(baseModel.dismissButtonModel.filledColor)) {
                color = [UIColor colorWithHexString:baseModel.dismissButtonModel.filledColor];
            }
            [dissButton setBackgroundColor:color];
        } else {
            [dissButton setBackgroundColor:[UIColor clearColor]] ;
        }
        h_dissButton = iconSize;
    } else {
        [dissButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(customView.mas_top).offset(0);
            make.trailing.equalTo(customView.mas_trailing).offset(0);
            make.height.equalTo(@(0));
            make.width.equalTo(@(0));
        }];
    }
    
    // 图片
    UIView *imgContentView = [[UIView alloc] init]; // 图片容器
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.contentMode = UIViewContentModeScaleAspectFit; // 按比例缩放并且填满view
    [customView addSubview:imgContentView];
    [imgContentView addSubview:imgView];
    __block CGFloat h_imageView = 0.f;
    if (!isEmptyString_Nd(baseModel.imageModel.imageUrl)) {
        [imgView sd_setImageWithURL:[NSURL URLWithString:baseModel.imageModel.imageUrl] placeholderImage:[UIImage imageNamed:@""] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        }];
        CGFloat h_image = baseModel.imageModel.h_image; // 实际宽高
        CGFloat w_image = baseModel.imageModel.w_image; // 实际宽高
        // 设置各参数
        CGFloat paddingTop = 10;
        CGFloat paddingBottom = 10;
        CGFloat paddingleft = 10;
        CGFloat paddingRight = 10;
        
        if (baseModel.imageModel.paddingSpace) {
            if (baseModel.imageModel.allAides) {
                paddingTop = baseModel.imageModel.paddingTop;
                paddingBottom = baseModel.imageModel.paddingTop;
                paddingleft = baseModel.imageModel.paddingTop;
                paddingRight = baseModel.imageModel.paddingTop;
            } else {
                paddingTop = baseModel.imageModel.paddingTop;
                paddingBottom = baseModel.imageModel.paddingBottom;
                paddingleft = baseModel.imageModel.paddingLeft;
                paddingRight = baseModel.imageModel.paddingRight;
            }
        }

        // 要显示的图片宽度
        CGFloat width_ShowImg = baseModel.imageModel.width; // 图片宽度
        if (baseModel.imageModel.autoWidth) {
            width_ShowImg = nWidth - Padding_Spacing * 2;
            // 等比例缩放
            h_imageView =  width_ShowImg * h_image / w_image;
            [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(h_imageView));
                make.width.equalTo(@(width_ShowImg));
                make.centerX.mas_equalTo(customView.centerX);
                make.top.equalTo(dissButton.mas_bottom).offset(paddingTop);
            }];
        } else {
            // 等比例缩放
            //            h_imageView = (w_image * width_ShowImg) / h_image;
            h_imageView = (width_ShowImg * h_image) / w_image;
            
            // 容器高度
            [imgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(h_imageView + paddingBottom + paddingTop));
                make.leading.equalTo(customView.mas_leading).offset(0);
                make.trailing.equalTo(customView.mas_trailing).offset(0);
                make.top.equalTo(dissButton.mas_bottom).offset(0);
            }];
            
            
            [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@(h_imageView));
                make.leading.equalTo(imgContentView.mas_leading).offset(paddingleft);
                make.trailing.equalTo(imgContentView.mas_trailing).offset(-paddingRight);
                make.top.equalTo(imgContentView.mas_top).offset(paddingTop);
                make.bottom.equalTo(imgContentView.mas_bottom).offset(-paddingBottom);
            }];
        }
//        iViewCount = iViewCount + 1;
        height_image = h_imageView + paddingBottom + paddingTop;
        
    } else {
        [imgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@0);
            make.leading.equalTo(customView.mas_leading);
            make.trailing.equalTo(customView.mas_trailing);
            make.top.equalTo(dissButton.mas_bottom).offset(0);
        }];
    }
    
    
    
    // 标题
    UILabel *titleLab = [[UILabel alloc] init];
    [customView addSubview:titleLab];
    if (!isEmptyString_Nd(baseModel.titleModel.content)) {
        titleLab.numberOfLines = 0;
        titleLab.lineBreakMode = NSLineBreakByWordWrapping;
        titleLab.text = baseModel.titleModel.content;
        titleLab.textColor = isEmptyString_Nd(baseModel.titleModel.color)?[UIColor whiteColor]:[UIColor colorWithHexString:baseModel.titleModel.color];
        if ([baseModel.titleModel.textAlign isEqualToString:@"middle"]) {
            titleLab.textAlignment = NSTextAlignmentCenter;
        }  else if ([baseModel.titleModel.textAlign isEqualToString:@"right"]) {
            titleLab.textAlignment = NSTextAlignmentRight;
        } else {
            titleLab.textAlignment = NSTextAlignmentLeft;
        }
        BOOL isBold = NO;
        if (baseModel.titleModel.isBold) {
            isBold = YES;
        }
        BOOL isItatic = NO;
        if (baseModel.titleModel.isItalic) {
            isItatic = YES;
        }
        NSString *familyName = @""; // 默认字体
        if (!isEmptyString_Nd(baseModel.titleModel.fontFamily)) {
            familyName = baseModel.titleModel.fontFamily;
        }
        NSInteger fontSize = 14;
        if (baseModel.titleModel.fontSize > 0) {
            fontSize = baseModel.titleModel.fontSize;
        }
        titleLab.font = [TKUtils setTitleFontWithSize:fontSize familyName:familyName bold:isBold itatic:isItatic weight:0];
        // 下划线
        if (baseModel.titleModel.hasDecoration) {
            NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:baseModel.titleModel.content];
            NSRange contentRange = {0,[content length]};
            [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
            titleLab.attributedText = content;
        }
        // 计算标题高度
//        [titleLab sizeToFit];
//        CGSize labelsize =[titleLab sizeThatFits:CGSizeMake(nWidth, CGFLOAT_MAX)];
        CGSize titleSize = [TKUtils sizeWithFont:titleLab.font maxSize:CGSizeMake(nWidth-20, MAXFLOAT) string:baseModel.titleModel.content];
        height_title = titleSize.height;
        
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
            make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
            make.top.equalTo(imgContentView.mas_bottom).offset(Padding_Spacing);
            make.height.equalTo(@(height_title));
        }];
        iViewCount = iViewCount + 1;
        
    } else {
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
            make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
            make.top.equalTo(imgContentView.mas_bottom).offset(0);
            make.height.equalTo(@0);
        }];
    }
    
    
    // body
    UILabel *bodyLab = [[UILabel alloc] init];
    [customView addSubview:bodyLab];
    if (!isEmptyString_Nd(baseModel.bodyModel.content)) {
        bodyLab.numberOfLines = 0;
        bodyLab.lineBreakMode = NSLineBreakByWordWrapping;
        bodyLab.text = baseModel.bodyModel.content;
        bodyLab.textColor = isEmptyString_Nd(baseModel.bodyModel.color)?[UIColor whiteColor]:[UIColor colorWithHexString:baseModel.bodyModel.color];
        if ([baseModel.bodyModel.textAlign isEqualToString:@"left"]) {
            bodyLab.textAlignment = NSTextAlignmentLeft;
        } else if ([baseModel.bodyModel.textAlign isEqualToString:@"right"]) {
            bodyLab.textAlignment = NSTextAlignmentRight;
        } else {
            bodyLab.textAlignment = NSTextAlignmentCenter;
        }
        BOOL isBold = NO;
        if (baseModel.bodyModel.isBold) {
            isBold = YES;
        }
        BOOL isItatic = NO;
        if (baseModel.bodyModel.isItalic) {
            isItatic = YES;
        }
        NSString *familyName = @""; // 默认字体
        if (!isEmptyString_Nd(baseModel.bodyModel.fontFamily)) {
            familyName = baseModel.bodyModel.fontFamily;
        }
        NSInteger fontSize = 14;
        if (baseModel.bodyModel.fontSize > 0) {
            fontSize = baseModel.bodyModel.fontSize;
        }
        bodyLab.font = [TKUtils setTitleFontWithSize:fontSize familyName:familyName bold:isBold itatic:isItatic weight:0];
        // 下划线
        if (baseModel.titleModel.hasDecoration) {
            NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:baseModel.bodyModel.content];
            NSRange contentRange = {0,[content length]};
            [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
            bodyLab.attributedText = content;
        }
        // 计算标题高度
        [bodyLab sizeToFit];
        CGSize labelsize =[bodyLab sizeThatFits:CGSizeMake(nWidth, CGFLOAT_MAX)];
        h_body = labelsize.height;
        if (isEmptyString_Nd(baseModel.titleModel.content)) {
            [bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                make.top.equalTo(titleLab.mas_bottom).offset(Padding_Spacing);
                make.height.equalTo(@(labelsize.height));
            }];
        } else {
            [bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                make.top.equalTo(titleLab.mas_bottom).offset(View_Spacing);
                make.height.equalTo(@(labelsize.height));
            }];
        }
        iViewCount = iViewCount + 1;
        
    } else {
        [bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(customView.mas_leading);
            make.trailing.equalTo(customView.mas_trailing);
            make.top.equalTo(titleLab.mas_bottom).offset(0);
            make.height.equalTo(@0);
        }];
    }
    
    
    
    // 按钮
    if ([baseModel.buttonsModel.buttonList count] > 0)  {
        for (int i = 0; i< [baseModel.buttonsModel.buttonList count]; i++) {
            ButtonItem *item = [baseModel.buttonsModel.buttonList objectAtIndex:i];
            item.itemTag = i + 2000;
            HJText *text = item.text;
            if (!isEmptyString_Nd(text.content)) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
                btn.tag = i + 2000;
                [btn addTarget:self action:@selector(ButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
                [customView addSubview:btn];
                [btn setTitle:text.content forState:UIControlStateNormal];
                if (isEmptyString_Nd(text.color)) {
                    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                } else {
                    [btn setTitleColor:[UIColor colorWithHexString:text.color] forState:UIControlStateNormal];
                }
                // 计算按钮文本宽度 + 10
                CGSize titleSize = [text.content sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:btn.titleLabel.font.fontName size:text.fontSize]}];
                titleSize.width += 10;
                // 布局
                NSString *align = baseModel.buttonsModel.layout.align; // 布局位置
                NSString *type = baseModel.buttonsModel.layout.type; // 布局类型
                if (KButtonLayoutType_Config == [type intValue]) {
                    // 可配布局
                    if ([align isEqualToString:@"left"]) { // 左边
                        if (i == 0) {
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                                make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        } else {
                            // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                                make.top.equalTo(bodyLab.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        }
                    } else if ([align isEqualToString:@"right"]) { // 右边
                        if (i == 0) {
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                                make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        } else {
                            // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                                make.top.equalTo(bodyLab.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        }
                    } else {
                        // 默认 中间
                        if (i == 0) {
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.centerX.mas_equalTo(customView.centerX);
                                make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        } else {
                            // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.centerX.mas_equalTo(customView.centerX);
                                make.top.equalTo(bodyLab.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        }
                    }
                } else {
                    // 固定布局
                    if (i == 0) {
                        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                            make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                            make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
                            make.height.mas_equalTo(Button_height);
                        }];
                    } else {
                        // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                            make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                            make.top.equalTo(bodyLab.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                            make.height.mas_equalTo(Button_height);
                        }];
                    }
                }
                //                if ([text.textAlign isEqualToString:@"left"]) {
                //                    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                //                    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
                //                } else if ([text.textAlign isEqualToString:@"right"]) {
                //                    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                //                    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
                //                } else {
                //                    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                //                }
                BOOL isBold2 = NO;
                if (text.isBold) {
                    isBold2 = YES;
                }
                BOOL isItatic2 = NO;
                if (text.isItalic) {
                    isItatic2 = YES;
                }
                NSString *familyName2 = @""; // 默认字体
                if (!isEmptyString_Nd(text.fontFamily)) {
                    familyName2 = text.fontFamily;
                }
                NSInteger fontSize2 = 14;
                if (text.fontSize > 0) {
                    fontSize2 = text.fontSize;
                }
                UIFont *font = [TKUtils setButtonFontWithSize:fontSize2 familyName:familyName2 bold:isBold2 itatic:isItatic2 weight:0];
                btn.titleLabel.font  = font;
                // 下划线
                if (baseModel.titleModel.hasDecoration) {
                    NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:text.content];
                    NSRange contentRange = {0,[content length]};
                    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
                    btn.titleLabel.attributedText = content;
                }
                // 边框
                CGFloat borderWidth = 0.f;
                if (item.buttonStyle.borderWidth > 0) {
                    borderWidth = item.buttonStyle.borderWidth;
                }
                // 圆角
                CGFloat fCornerRadius = 0;
                if (!isEmptyString_Nd(item.buttonStyle.all)) {
                    fCornerRadius = [item.buttonStyle.all floatValue];
                }
                [btn.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
                
                if (item.buttonStyle.fillType == KButtonsFillType_Fill) {
                    NSString *color = @"FFFFFF"; // fill color 默认
                    if (!isEmptyString_Nd(item.buttonStyle.fillColor)) {
                        color = item.buttonStyle.fillColor;
                    }
                    UIColor *fillColor = [UIColor colorWithHexString:color];
                    [btn setBackgroundColor:fillColor]; // 背景
                    [btn.layer setBorderWidth:borderWidth]; // 设置边界的宽度
                    [btn.layer setCornerRadius:fCornerRadius]; // 设置圆角
                    // 边框颜色
                    if (!isEmptyString_Nd(item.buttonStyle.borderColor)) {
                        btn.layer.borderColor = [UIColor colorWithHexString:item.buttonStyle.borderColor].CGColor;
                    }
                } else if (item.buttonStyle.fillType == KButtonsFillType_Outline) {
                    [btn setBackgroundColor:[UIColor whiteColor]]; // 背景
                    [btn.layer setBorderWidth:borderWidth]; // 设置边界的宽度
                    [btn.layer setCornerRadius:fCornerRadius]; // 设置圆角
                    // 边框颜色
                    if (!isEmptyString_Nd(item.buttonStyle.borderColor)) {
                        btn.layer.borderColor = [UIColor colorWithHexString:item.buttonStyle.borderColor].CGColor;
                    }
                }
                else {
                    [btn setBackgroundColor:[UIColor clearColor]]; // 背景
                    [btn.layer setBorderWidth:0]; // 设置边界的宽度
                    [btn.layer setCornerRadius:0]; // 设置圆角
                }
                
                // 边框样式
                if (item.buttonStyle.borderStyle == KBorderStyle_dashed) {
                    // 虚线
//                    CAShapeLayer*border = [CAShapeLayer layer];
//                    border.strokeColor=[UIColor colorWithHexString:@"#D5D5D5"].CGColor;\
//                    border.fillColor= [UIColor redColor].CGColor;
//                    border.path= [UIBezierPath bezierPathWithRect:CGRectMake(0, 0 , titleSize.width + 10, Button_height)].CGPath;
//                    border.frame= CGRectMake(0, 0 , titleSize.width + 10, Button_height);
//                    //虚线的宽度
//                    border.lineWidth = 2.0f;
//                    //设置线条的样式
//                    border.lineCap = @"square";
//                    //设置虚线的间隔
//                    border.lineDashPattern=@[@5,@2];
//                    [btn.layer addSublayer:border];
                    
                    
//                    [self drawDashLine:btn viewFrame:CGRectMake(0, 0 , titleSize.width + 10, Button_height) viewHeight:Button_height viewWidth:titleSize.width + 10 lineLength:5 lineSpacing:2 lineColor:[UIColor redColor]];
                    
                } else if (item.buttonStyle.borderStyle == KBorderStyle_dotted) {
                    // 点状
                } else {
                    // 实线
                }
                
                iViewCount = iViewCount + 1;
            }
        }
    }
    
    // 计算Nudges frame
    customView.frame = CGRectMake(0, 0, nWidth, h_dissButton + height_title + h_body + height_image + [baseModel.buttonsModel.buttonList count] * Button_height + iViewCount * View_Spacing + Bottom_Spacing);
#pragma mark -- 构造nudges view
    CMPopTipView *popTipView = [[CMPopTipView alloc] initWithCustomView:customView];
    popTipView.delegate = self;
    popTipView.disableTapToDismiss = YES; // 点击Nudges是否关闭
    popTipView.dismissTapAnywhere = NO; // 点击任何空白处是否关闭
    popTipView.has3DStyle = YES;
    popTipView.hasShadow = YES;
    popTipView.animation = CMPopTipAnimationPop; // Nudges出现的动画
    popTipView.showFromCenter = NO; // 箭头是否指向元素view的中心位置
    // 方向位置
    if (baseModel.positionModel.position == KPosition_Above) {
        popTipView.preferredPointDirection = PointDirectionUp + 1;
    } else if (baseModel.positionModel.position == KPosition_Under) {
        popTipView.preferredPointDirection = PointDirectionDown - 1;
    } else {
        popTipView.preferredPointDirection = PointDirectionAny;
    }
    // margin
    if (baseModel.positionModel.position == KPosition_Above || baseModel.positionModel.position == KPosition_Auto) {
        if (baseModel.positionModel.margin > 0) {
            popTipView.topMargin = baseModel.positionModel.margin;
        } else {
            popTipView.topMargin = 10;
        }
    }
    
    // 背景色
    if (baseModel.backgroundModel.type == KBackgroundType_Gradient) {
        // 渐变类型
        if (baseModel.backgroundModel.gradientType == KGradientType_Linear) {
            // 线性
            popTipView.hasGradientBackground = YES;
        }
        if (baseModel.backgroundModel.gradientType == KGradientType_Radial) {
            // 圆半径方向渐变
        }
    } else if (baseModel.backgroundModel.type == KBackgroundType_Image) {
        // 背景图
        popTipView.hasGradientBackground = NO;
    } else {
        // 固定色 只有配置实色才有透明度
        popTipView.hasGradientBackground = NO;
        CGFloat alpha = 0.8;
        if (baseModel.backgroundModel.opacity > 0) {
            alpha = baseModel.backgroundModel.opacity / 100.0;
        }
        if (isEmptyString_Nd(baseModel.backgroundModel.backgroundColor)) {
            popTipView.backgroundColor = [TKUtils GetColor:@"0x000000" alpha:alpha];
        } else {
            popTipView.backgroundColor = [TKUtils GetColor:baseModel.backgroundModel.backgroundColor alpha:alpha];
        }
    }
    
    // 边框
    if (baseModel.borderModel.borderWidth > 0) {
        popTipView.borderWidth = baseModel.borderModel.borderWidth;
    } else {
        popTipView.borderWidth = 0;
    }
    
    if (baseModel.borderModel.borderStyle == KBorderStyle_dotted) {
        // 点状边框
        popTipView.isDotted = YES;
    } else if (baseModel.borderModel.borderStyle == KBorderStyle_dashed) {
        // 虚线边框
        popTipView.isDashed = YES;
    } else {
        // 实线边框
    }
    
    CGFloat fCornerRadius = 8.f;
    if (!isEmptyString_Nd(baseModel.borderModel.all)) {
        fCornerRadius = [baseModel.borderModel.all floatValue];
    }
    popTipView.cornerRadius = fCornerRadius;

    if (!isEmptyString_Nd(baseModel.borderModel.borderColor)) {
        popTipView.borderColor = [UIColor colorWithHexString:baseModel.borderModel.borderColor];
    }
    
    // 更新数据库nudges显示状态
    if (_nudgesModel) {
        [NdHJNudgesDBManager updateNudgesIsShowWithNudgesId:baseModel.nudgesId model:_nudgesModel];
    }

    // 弹出Nudges
//    [popTipView presentPointingAtView:tConView inView:kAppDelegate.window animated:YES];
    
    [[TKUtils topViewController].tabBarController.view bringSubviewToFront:view];
    [popTipView presentPointingAtView:view inView:[TKUtils topViewController].view animated:NO];
	
	
	// 显示回调
	if (_delegate && [_delegate conformsToProtocol:@protocol(HotSpotEventDelegate)]) {
		if (_delegate && [_delegate respondsToSelector:@selector(HotSpotShowEventByNudgesModel:batchId:source:)]) {
			[_delegate HotSpotShowEventByNudgesModel:baseModel batchId:@"0" source:@"1"];
		}
	}
	
	NSString *contactId = isEmptyString_Nd(baseModel.contactId)?@"":baseModel.contactId;
	NSString *nudgesName = isEmptyString_Nd(baseModel.nudgesName)?@"":baseModel.nudgesName;
	NSString *pageName = isEmptyString_Nd(baseModel.pageName)?@"":baseModel.pageName;
	// 埋点发送通知给RN
	[[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeShow",@"body":@{@"nudgesId":@(baseModel.nudgesId),@"nudgesType":@(baseModel.nudgesType),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(baseModel.campaignId),@"batchId":@"0",@"source":@"1",@"pageName":pageName}}];
	
    
    // 显示后上报接口
//    [[HJNudgesManager sharedInstance] nudgesContactRespByNudgesId:baseModel.nudgesId contactId:baseModel.contactId];
  
 
  
    [[HJNudgesManager sharedInstance].visiblePopTipViews addObject:popTipView];
    
    // dismissButton A,B,C
    if ([baseModel.dismiss containsString:@"C"] || isEmptyString_Nd(baseModel.dismiss)) {
        self.monolayerView.isTouch = YES;
    } else {
        self.monolayerView.isTouch = NO;
    }
    if ([baseModel.dismiss containsString:@"A"]) {
        // 关闭按钮
//        UIButton *dissButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [popTipView addSubview:dissButton];
//        [dissButton addTarget:self action:@selector(dissMissButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        dissButton.frame = CGRectMake(nWidth-20, -20, 30, 30);
//        [dissButton setBackgroundColor:[UIColor redColor]];
    }
    if ([baseModel.dismiss containsString:@"B"]) {
        // 起定时器 5秒后关闭
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(self.timer,
                                      dispatch_time(DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC),
                                      1.0 * NSEC_PER_SEC,
                                      0);
        dispatch_source_set_event_handler(self.timer, ^{
            // 关闭Nudges
            [self removeBeaConView];
            [self stopCurrentPlayingView]; // 停止播放器
            [self removeNudges]; // 移除nudges
            [self removeMonolayer]; // 移除蒙层
            [self stopTimer]; // 停止定时器
            [self.popTipView removeFromSuperview];
            self.popTipView = nil;
            [[HJNudgesManager sharedInstance] showNextNudges]; // 展示下一个Nudges
        });
        dispatch_resume(self.timer);
    }
    self.popTipView = popTipView;
}

#pragma mark -- MonolayerViewDelegate
// 蒙层事件
- (void)MonolayerViewClickEventByTarget:(id)target {
    // 关闭当前nudges
    [self removeBeaConView];
    [self stopCurrentPlayingView]; // 停止播放器
    [self removeNudges]; // 移除nudges
    [self removeMonolayer]; // 移除蒙层
    [self stopTimer]; // 停止定时器
    [self.popTipView removeFromSuperview];
    self.popTipView = nil;
    [[HJNudgesManager sharedInstance] showNextNudges]; // 展示下一个Nudges
}

#pragma mark - CMPopTipViewDelegate methods
// 点击Nudges的代理
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    //    [self.visiblePopTipViews removeObject:popTipView];
}

#pragma mark - UIViewController methods
- (void)willAnimateRotationToInterfaceOrientation:(__unused UIInterfaceOrientation)toInterfaceOrientation duration:(__unused NSTimeInterval)duration {
    for (CMPopTipView *popTipView in [HJNudgesManager sharedInstance].visiblePopTipViews) {
        id targetObject = popTipView.targetObject;
        [popTipView dismissAnimated:NO];

        if ([targetObject isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)targetObject;
            [popTipView presentPointingAtView:button inView:[UIApplication sharedApplication].delegate.window animated:NO];
        } else if ([targetObject isKindOfClass:[UIView class]]) {
            UIView *view = (UIView *)targetObject;
            [popTipView presentPointingAtView:view inView:[UIApplication sharedApplication].delegate.window animated:YES];
        } else {
            UIBarButtonItem *barButtonItem = (UIBarButtonItem *)targetObject;
            [popTipView presentPointingAtBarButtonItem:barButtonItem animated:NO];
        }
    }
}

#pragma mark -- lazy load
- (ZFCustomControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFCustomControlView new];
    }
    return _controlView;
}

#pragma mark -- other
// 获取view相对于window的绝对地址
- (CGRect)getAddress:(UIView *)view {
    CGRect rect=[view convertRect: view.bounds toView:[UIApplication sharedApplication].delegate.window];
    return rect;
}

// 查找指定node下的view 节点
- (void)getViewNodeModelByAccessibilityElement:(NSString *)AccessibilityElement  targetView:(NodeModel *)nodel block:(void (^)(NodeModel *nodel))block {
    // 去除accessibilityIdentifier中的空字符串，因为服务器返回是没有空字符串的
    NSString *stringWithoutSpace = [nodel.strAccessibilityIdentifier stringByReplacingOccurrencesOfString:@" " withString:@""];
    stringWithoutSpace = [stringWithoutSpace stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    stringWithoutSpace = [stringWithoutSpace stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([stringWithoutSpace isEqualToString:AccessibilityElement]) {
        !block?:block(nodel);
    }
    for (NSInteger i = 0 ; i<[nodel.childNodeList count]; i++) {
        NodeModel *childNodel = [nodel.childNodeList objectAtIndex:i];
        [self getViewNodeModelByAccessibilityElement:AccessibilityElement targetView:childNodel block:block];
    }
}

//- (UIViewController *)getCurrentVC {
//    UIViewController *result = nil;
//
//    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
//    if (window.windowLevel != UIWindowLevelNormal) {
//        NSArray *windows = [[UIApplication sharedApplication] windows];
//        for(UIWindow * tmpWin in windows) {
//            if (tmpWin.windowLevel == UIWindowLevelNormal) {
//                window = tmpWin;
//                break;
//            }
//        }
//    }
//
//    UIView *frontView = [[window subviews] objectAtIndex:0];
//    id nextResponder = [frontView nextResponder];
//
//    if ([nextResponder isKindOfClass:[UIViewController class]]) {
//        result = nextResponder;
//    } else {
//        if ([window.rootViewController isKindOfClass:[UITabBarController class]]) {
//            result = ((UITabBarController *)window.rootViewController).selectedViewController;
//            result = [result.childViewControllers lastObject];
//        }else{
//        }
//    }
//
//    NSLog(@"非模态视图%@", result);
//    return result;
//}

@end
