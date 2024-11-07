//
//  HJRateManager.m
//  DITOApp
//
//  Created by 李标 on 2022/9/12.
//

#import "HJRateManager.h"
#import "NdHJNudgesDBManager.h"
#import "NdHJIntroductManager.h"
//#import "CMPopTipView.h"
#import "UIView+NdAddGradualLayer.h"
#import "UIImageView+ZFCache.h"
#import "ZFUtilities.h"
#import "ZFCustomControlView.h"
#import "HJNudgesManager.h"
#import "HJStar.h"
#import "HJThumbs.h"
#import "UIImage+SVGManager.h"
#import "WKTextView.h"
#import <DXPFontManagerLib/FontManager.h>
#import "NSString+ndDate.h"

#define Padding_Spacing 10
#define View_Spacing  10 // view 之间的间距
#define Bottom_Spacing 15
#define Button_height 43

static HJRateManager *manager = nil;

@interface HJRateManager ()<MonolayerViewDelegate> {
	double d_starScore; // 评分的值
	int thumbsScore;  // 点赞点踩的值
	NSString *showTimestamp;
}
//@property (nonatomic, strong) NSMutableArray *visiblePopTipViews;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) HJStar *qcStarView;
@property (nonatomic, strong) HJThumbs *thumbs;

@property (nonatomic, assign) NSInteger starNumbers;
@property (nonatomic, strong) WKTextView *textView;
@end


@implementation HJRateManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HJRateManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
	self = [super init];
	if (self) {
//		self.visiblePopTipViews = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)ButtonClickAction:(id)sender {
	UIButton *btn = (UIButton *)sender;
	for (int i = 0; i< [_baseModel.buttonsModel.buttonList count]; i ++) {
		ButtonItem *item = [_baseModel.buttonsModel.buttonList objectAtIndex:i];
		BOOL isClose = NO;
		if (item.itemTag == btn.tag) {
			if (KButtonsActionType_CloseNudges == item.action.type) {
				// 关闭Nudges
				isClose = YES;
			} else if (KBorderStyle_LaunchURL == item.action.type) {
				// 内部跳转
				
			} else if (KBorderStyle_InvokeAction == item.action.type) {
				// 调用方法
				//                if (_delegate && [_delegate conformsToProtocol:@protocol(RateEventDelegate)]) {
				//                  if (_delegate && [_delegate respondsToSelector:@selector(RateClickEventByType:Url:invokeAction:buttonName:model:)]) {
				//                        [_delegate RateSubmitByScore:d_starScore thumb:thumbsScore];
				//
				//                      NSString *nudgesName = isEmptyString_Nd(_baseModel.nudgesName)?@"":_baseModel.nudgesName;
				//                      NSString *pageName = isEmptyString_Nd(_baseModel.pageName)?@"":_baseModel.pageName;
				//                      NSString *thumbsScoreStr = [NSString stringWithFormat:@"%d",thumbsScore];
				//
				//                      // 选项是否被选中
				//                      NSMutableDictionary *optionDic = [NSMutableDictionary new];
				//                      NSInteger selectedIndex = d_starScore * starNumbers;
				//                      NSString *optionName = [NSString stringWithFormat:@"Option%ld",(long)(selectedIndex)];
				//
				//                      // 埋点发送通知给RN
				//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeFeedback",@"body":@{@"nudgesId":@(_baseModel.nudgesId),@"nudgesName":nudgesName,@"contactId":_baseModel.contactId,@"campaignCode":@(_baseModel.campaignId),@"score":@(d_starScore),@"thumbResult":thumbsScoreStr,@"source":@"1",@"pageName":pageName,@"batchId":@"",optionName:@(1)}}];
				//
				//                    }
				//                }
			}
			
			if (_baseModel.positionModel.position == KPosition_Middle) {
				if (self.customView) {
					[self.customView removeFromSuperview];
					self.customView = nil;
				}
			}
			if (_baseModel.positionModel.position == KPosition_bottom) {
				if (self.backView) {
					[self.backView removeFromSuperview];
					self.backView = nil;
				}
			}
			
			[self removeNudges];
			[self removeMonolayer];
			[self stopTimer];
			[[HJNudgesManager sharedInstance] showNextNudges];
			
			// 回调
			NSString *contactId = isEmptyString_Nd(_baseModel.contactId)?@"":_baseModel.contactId;
			NSString *nudgesName = isEmptyString_Nd(_baseModel.nudgesName)?@"":_baseModel.nudgesName;
			NSString *pageName = isEmptyString_Nd(_baseModel.pageName)?@"":_baseModel.pageName;
			NSString *text = isEmptyString_Nd(item.text.content)?@"":item.text.content;
			NSString *url = isEmptyString_Nd(item.action.url)?@"":item.action.url;
			NSString *invokeAction = isEmptyString_Nd(item.action.invokeAction)?@"":item.action.invokeAction;
			NSString *thumbsScoreStr;
			if (thumbsScore == 2) {
				// 点踩
				thumbsScoreStr = @"0";
			} else if (thumbsScore == 1) {
				// 点赞
				thumbsScoreStr = @"1";
			} else {
				thumbsScoreStr = @"";
			}
			NSInteger selectedIndex = d_starScore * self.starNumbers;
			NSString *comments = isEmptyString_Nd(self.textView.contentText)?@"":self.textView.contentText;
			
			if (_delegate && [_delegate conformsToProtocol:@protocol(RateEventDelegate)]) {
				if (_delegate && [_delegate respondsToSelector:@selector(RateClickEventByActionModel:isClose:buttonName:score:thumbResult:comments:nudgeModel:feedbackDuration:)]) {
					
					// 反馈时长
					NSString *feedBackTime = [NSString getCurrentTimestamp];
					NSInteger feedbackDuration = [feedBackTime integerValue] - [showTimestamp integerValue];
					
					[_delegate RateClickEventByActionModel:item.action isClose:isClose buttonName:text score:[NSString stringWithFormat:@"%ld",(long)selectedIndex] thumbResult:thumbsScoreStr comments:comments nudgeModel:_baseModel feedbackDuration:feedbackDuration];
				}
			}
			
			// 埋点发送通知给RN
			[[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeClick",@"body":@{@"nudgesId":@(_baseModel.nudgesId),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(_baseModel.campaignId),@"batchId":@"0",@"jumpUrl":url,@"invokeAction":invokeAction,@"isClose":@(isClose),@"buttonName":text,@"source":@"1",@"score":@(selectedIndex),@"thumbResult":thumbsScoreStr,@"comments":comments,@"pageName":pageName}}];
			
		}
	}
}

- (void)setBaseModel:(NudgesBaseModel *)baseModel {
    _baseModel = baseModel;
    [self constructsNudgesViewData:baseModel];
}

- (void)setNudgesModel:(NudgesModel *)nudgesModel {
    _nudgesModel = nudgesModel;
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
		UIView *popView = [[HJNudgesManager sharedInstance].visiblePopTipViews objectAtIndex:0];
		[popView removeFromSuperview];
		[popView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[obj removeFromSuperview];
		}];
		[[HJNudgesManager sharedInstance].visiblePopTipViews removeObjectAtIndex:0];
	}
}

// 删除预览的nudges
- (void)removePreviewNudges {
	[self removeNudges];
	[self removeMonolayer];
	[self stopTimer];
	
	if (_baseModel.positionModel.position == KPosition_Middle) {
		if (self.customView) {
			[self.customView removeFromSuperview];
			self.customView = nil;
		}
	}
	if (_baseModel.positionModel.position == KPosition_bottom) {
		if (self.backView) {
			[self.backView removeFromSuperview];
			self.backView = nil;
		}
	}
}

- (void)showNudgesByWidth:(CGFloat)nWidth height:(CGFloat)nHeight {
    // 背景颜色，目前只支持实色
    CGFloat alpha = 1.0;
    if (_baseModel.backgroundModel.opacity > 0) {
        alpha = _baseModel.backgroundModel.opacity / 100.0;
    }
    if (isEmptyString_Nd(_baseModel.backgroundModel.backgroundColor)) {
        self.customView.backgroundColor = [TKUtils GetColor:@"0xFFFFFF" alpha:alpha];
    } else {
        self.customView.backgroundColor = [TKUtils GetColor:_baseModel.backgroundModel.backgroundColor alpha:alpha];
    }
    
    // 设置frame 后弹出nudges
    if (_baseModel.positionModel.position == KPosition_Middle) {
        //中部
        self.customView.frame = CGRectMake(kScreenWidth/2 - nWidth/2, kScreenHeight/2 - nHeight/2, nWidth, nHeight);
        [[UIApplication sharedApplication].delegate.window addSubview:self.customView];
        // 设置边框
        if (_baseModel.borderModel.borderWidth > 0) {
            self.customView.layer.borderWidth = _baseModel.borderModel.borderWidth;
        } else {
            self.customView.layer.borderWidth = 1;
        }
        // 边框颜色
        if (isEmptyString_Nd(_baseModel.borderModel.borderColor)) {
           self.customView.layer.borderColor = [TKUtils GetColor:@"0xFFFFFF" alpha:alpha].CGColor;
        } else {
            self.customView.layer.borderColor = [TKUtils GetColor:_baseModel.borderModel.borderColor alpha:1.0].CGColor;
        }
        // 边框圆角
        if (_baseModel.borderModel.radiusConfigType == KRadiusConfigType_all) {
            self.customView.layer.cornerRadius = [_baseModel.borderModel.all intValue];
        }
        
    }
    if (_baseModel.positionModel.position == KPosition_bottom || _baseModel.positionModel.position == 0) {
        // 底部  默认
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - nHeight - 20, kScreenWidth, nHeight + 20)];
        backView.backgroundColor = [UIColor whiteColor];
        self.customView.frame = CGRectMake(kScreenWidth/2 - nWidth/2, 10, nWidth, nHeight);
        [backView addSubview:self.customView];
        [[UIApplication sharedApplication].delegate.window addSubview:backView];
        
        // 边框圆角
        if (_baseModel.borderModel.radiusConfigType == KRadiusConfigType_all) {
            self.customView.layer.cornerRadius = [_baseModel.borderModel.all intValue];
        }
        
        self.backView = backView;
    }
    
    // 更新数据库nudges显示状态
    if (_nudgesModel) {
        [NdHJNudgesDBManager updateNudgesIsShowWithNudgesId:_baseModel.nudgesId model:_nudgesModel];
    }
    // 显示后上报接口
//	[[HJNudgesManager sharedInstance] nudgesContactRespByNudgesId:_baseModel.nudgesId contactId:_baseModel.contactId];
  
  NSString *contactId = isEmptyString_Nd(_baseModel.contactId)?@"":_baseModel.contactId;
  NSString *nudgesName = isEmptyString_Nd(_baseModel.nudgesName)?@"":_baseModel.nudgesName;
  NSString *pageName = isEmptyString_Nd(_baseModel.pageName)?@"":_baseModel.pageName;
	
	showTimestamp = [NSString getCurrentTimestamp];
	
	// 显示回调
	if (_delegate && [_delegate conformsToProtocol:@protocol(RateEventDelegate)]) {
		if (_delegate && [_delegate respondsToSelector:@selector(RateShowEventByNudgesModel:batchId:source:)]) {
			[_delegate RateShowEventByNudgesModel:_baseModel batchId:@"0" source:@"1"];
		}
	}
	
	// 埋点发送通知给RN
	[[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeShow",@"body":@{@"nudgesId":@(_baseModel.nudgesId),@"nudgesType":@(_baseModel.nudgesType),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(_baseModel.campaignId),@"batchId":@"0",@"source":@"1",@"pageName":pageName}}];
    
}

#pragma mark -- 构造nudges数据
- (void)constructsNudgesViewData:(NudgesBaseModel *)baseModel {
	d_starScore = 0;
	thumbsScore = 0;
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
    
    // 遮罩
    self.monolayerView = [[MonolayerView alloc] init];
    self.monolayerView.monolayerViewType = KMonolayerViewType_full; // 全屏遮罩
    self.monolayerView.delegate = self;
    // 展示蒙层
  if (!baseModel.backdropModel.enabled) {
    self.monolayerView.backgroundAlpha = 0.f;
    self.monolayerView.backgroundColor = [UIColor clearColor];
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

//    }
//    [kAppDelegate.window addSubview:self.monolayerView];
    [[TKUtils topViewController].view addSubview:self.monolayerView];
    
#pragma mark -- 自定义view
    int iViewCount = 0;
    CGFloat h_body = 0;
    CGFloat height_title = 0; // 标题高度
    CGFloat height_image = 0; // 图片的高度
    CGFloat h_dissButton = 0;
    CGFloat h_qcStarView = 0;
    CGFloat h_textView = 0;
    
    
    UIView *customView = [[UIView alloc] init];
    // 宽度
    NSInteger nWidth = 200;
    if (baseModel.positionModel.width > 0) {
        nWidth = baseModel.positionModel.width;
    }
    if (_baseModel.positionModel.position == KPosition_bottom || _baseModel.positionModel.position == 0) {
        nWidth = kScreenWidth;
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
        
        iViewCount = iViewCount + 1;
        
    } else {
        [dissButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(customView.mas_top).offset(0);
            make.trailing.equalTo(customView.mas_trailing).offset(0);
            make.height.equalTo(@(0));
            make.width.equalTo(@(0));
        }];
    }
    
    UILabel *titleLab = [[UILabel alloc] init]; // 标题
    UILabel *bodyLab = [[UILabel alloc] init]; // 文本
    // 标题
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
        CGSize titleSize = [TKUtils sizeWithFont:titleLab.font maxSize:CGSizeMake(nWidth-20, MAXFLOAT) string:baseModel.titleModel.content];
        height_title = titleSize.height;
        
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
            make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
            make.top.equalTo(dissButton.mas_bottom).offset(Padding_Spacing);
            make.height.equalTo(@(height_title));
        }];
        iViewCount = iViewCount + 1;

    } else {
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(customView.mas_leading).offset(0);
            make.trailing.equalTo(customView.mas_trailing).offset(0);
            make.top.equalTo(dissButton.mas_bottom).offset(0);
            make.height.equalTo(@0);
        }];
    }
    
    WKTextView *textView = [[WKTextView alloc] init];
	self.textView = textView;
    if (baseModel.ownPropModel.enabled) { // 增加可输入区域
        // 打分图标
        if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
            // 评分
            if (self.qcStarView) {
                [self.qcStarView removeFromSuperview];
                self.qcStarView = nil;
            }
            [customView addSubview:self.qcStarView];
            CGFloat iconSize = baseModel.ownPropModel.rateStyle.iconSize == 0 ? 15: baseModel.ownPropModel.rateStyle.iconSize;
            self.qcStarView.iconSize = iconSize; // 图标大小
            if (baseModel.ownPropModel.rateType == KRateType_Star) {
                self.qcStarView.afterSvgColor = baseModel.ownPropModel.rateStyle.activeColor;
                self.qcStarView.svgName = @"icon_star";
            }
            if (baseModel.ownPropModel.rateType == KRateType_Heart) {
                self.qcStarView.afterSvgColor = baseModel.ownPropModel.rateStyle.activeColor;
                self.qcStarView.svgName = @"heart-fill";
            }
            
            self.qcStarView.beforeSvgColor = baseModel.ownPropModel.rateStyle.restColor;
            h_qcStarView = 10 + iconSize + 10;
            self.qcStarView.viewWidth = nWidth;
            [_qcStarView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading).offset(10);
                make.trailing.equalTo(customView.mas_trailing).offset(-10);
                make.height.equalTo(@(h_qcStarView));
                make.top.equalTo(titleLab.mas_bottom).offset(10);
            }];
            self.qcStarView.scorePercent = 0.0;
            self.qcStarView.isCompleteStar = YES; //NO的话可以展示半星
            self.qcStarView.isAnimation = YES;
            //是否仅仅是展示,默认为NO，可选
            //self.qcStarView.isJsutDisplay = YES;
			__weak __typeof(&*self)weakSelf = self;
			self.qcStarView.sendStarPercent= ^(double data,  NSInteger starNumbers) {
				NSLog(@"DXPNugges Log:=== %f",data);
				
				d_starScore = data;
				weakSelf.starNumbers = starNumbers;
            };
        }
        // 点赞点彩
        if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
            if (self.thumbs) {
                [self.thumbs removeFromSuperview];
                self.thumbs = nil;
            }
            [customView addSubview:self.thumbs];
            CGFloat iconSize = baseModel.ownPropModel.rateStyle.iconSize == 0 ? 15: baseModel.ownPropModel.rateStyle.iconSize;
            self.thumbs.iconSize = iconSize; // 图标大小
            self.thumbs.beforeSvgColor = baseModel.ownPropModel.rateStyle.restColor;
            self.thumbs.thumbsUpColor = baseModel.ownPropModel.rateStyle.thumbsUpColor;
            self.thumbs.thumbsDownColor = baseModel.ownPropModel.rateStyle.thumbsDownColor;
            h_qcStarView = 10 + iconSize + 10;
            self.thumbs.viewWidth = nWidth;
            [_thumbs mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading).offset(10);
                make.trailing.equalTo(customView.mas_trailing).offset(-10);
                make.height.equalTo(@(h_qcStarView));
                make.top.equalTo(titleLab.mas_bottom).offset(10);
            }];
            self.thumbs.sendThumnsVal= ^(int res) {
                if (res == 1) {
                    NSLog(@"DXPNugges Log:=== kudos:%d",res);
                }
                if (res == 2) {
                    NSLog(@"DXPNugges Log:=== point and click:%d",res);
                }
                thumbsScore = res;
            };
        }
        iViewCount = iViewCount + 1;
        
        // body
        [customView addSubview:bodyLab];
        if (!isEmptyString_Nd(baseModel.bodyModel.content)) {
            bodyLab.numberOfLines = 0;
            bodyLab.lineBreakMode = NSLineBreakByCharWrapping;
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
            if (baseModel.bodyModel.hasDecoration) {
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
                    if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
                        make.top.equalTo(_qcStarView.mas_bottom).offset(Padding_Spacing);
                    }
                    if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
                        make.top.equalTo(_thumbs.mas_bottom).offset(Padding_Spacing);
                    }
                    make.height.equalTo(@(labelsize.height));
                }];
            } else {
                [bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                    make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                    if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
                        make.top.equalTo(_qcStarView.mas_bottom).offset(View_Spacing);
                    }
                    if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
                        make.top.equalTo(_thumbs.mas_bottom).offset(View_Spacing);
                    }
                    make.height.equalTo(@(labelsize.height));
                }];
            }
            iViewCount = iViewCount + 1;
            
        } else {
            [bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading);
                make.trailing.equalTo(customView.mas_trailing);
                if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
                    make.top.equalTo(_qcStarView.mas_bottom).offset(0);
                }
                if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
                    make.top.equalTo(_thumbs.mas_bottom).offset(0);
                }
                
                make.height.equalTo(@0);
            }];
        }
        
        // 可输入textView
        [customView addSubview:textView];
        NSInteger fontSize = 14;
        if (baseModel.ownPropModel.hint.fontSize > 0) {
            fontSize = baseModel.bodyModel.fontSize;
        }
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
            make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
            if ([baseModel.ownPropModel.input.style isEqualToString:@"S"]) {
                // 单行
                make.height.equalTo(@(fontSize));
            } else {
                // 多行 默认为3行
                make.height.equalTo(@(10+fontSize * 3));
            }
            make.top.equalTo(bodyLab.mas_bottom).offset(12);
        }];
        // text View 高度
        if ([baseModel.ownPropModel.input.style isEqualToString:@"S"]) {
            h_textView = fontSize; // 单行
        } else {
            h_textView = 10+fontSize * 3; // 多行
        }
        // placeholder
        textView.myPlaceholder = isEmptyString_Nd(baseModel.ownPropModel.hint.content)?@"":baseModel.ownPropModel.hint.content;
        BOOL isBold = NO;
        if (baseModel.ownPropModel.hint.isBold) {
            isBold = YES;
        }
        BOOL isItatic = NO;
        if (baseModel.ownPropModel.hint.isItalic) {
            isItatic = YES;
        }
        
        textView.placeholderLabel.font = [TKUtils setTitleFontWithSize:fontSize familyName:@"" bold:isBold itatic:isItatic weight:0];
        // 下划线
        if (baseModel.ownPropModel.hint.hasDecoration) {
            NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:baseModel.bodyModel.content];
            NSRange contentRange = {0,[content length]};
            [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
            textView.placeholderLabel.attributedText = content;
        }
        NSString *color = @"#333333";
        if (!isEmptyString_Nd(baseModel.ownPropModel.hint.color)) {
            color = baseModel.ownPropModel.hint.color;
        }
        textView.myPlaceholderColor = [UIColor colorWithHexString:color];
        // text
        textView.maxNum = baseModel.ownPropModel.input.maxLength == 0 ? 50: baseModel.ownPropModel.input.maxLength;
        BOOL t_isBold = NO;
        if (baseModel.ownPropModel.input.isBold) {
            t_isBold = YES;
        }
        BOOL t_isItatic = NO;
        if (baseModel.ownPropModel.input.isItalic) {
            t_isItatic = YES;
        }
        NSInteger t_fontSize = 14;
        if (baseModel.ownPropModel.input.fontSize > 0) {
            t_fontSize = baseModel.bodyModel.fontSize;
        }
        textView.font = [TKUtils setTitleFontWithSize:t_fontSize familyName:@"" bold:t_isBold itatic:t_isItatic weight:0];
        // 下划线
        if (baseModel.ownPropModel.input.hasDecoration) {
            NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:baseModel.bodyModel.content];
            NSRange contentRange = {0,[content length]};
            [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
            textView.attributedText = content;
        }
        textView.maxNum = baseModel.ownPropModel.input.maxLength == 0 ? 200: baseModel.ownPropModel.input.maxLength;
        
        iViewCount = iViewCount + 1;
        
        
    } else { // 没有可输入区域
        // body
        [customView addSubview:bodyLab];
        if (!isEmptyString_Nd(baseModel.bodyModel.content)) {
            bodyLab.numberOfLines = 0;
            bodyLab.lineBreakMode = NSLineBreakByCharWrapping;
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
            if (baseModel.bodyModel.hasDecoration) {
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
        
        // 打分图标
        if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
            // 评分
            if (self.qcStarView) {
                [self.qcStarView removeFromSuperview];
                self.qcStarView = nil;
            }
            [customView addSubview:self.qcStarView];
            CGFloat iconSize = baseModel.ownPropModel.rateStyle.iconSize == 0 ? 15: baseModel.ownPropModel.rateStyle.iconSize;
            self.qcStarView.iconSize = iconSize; // 图标大小
            if (baseModel.ownPropModel.rateType == KRateType_Star) {
                self.qcStarView.afterSvgColor = baseModel.ownPropModel.rateStyle.activeColor;
                self.qcStarView.svgName = @"icon_star";
            }
            if (baseModel.ownPropModel.rateType == KRateType_Heart) {
                self.qcStarView.afterSvgColor = baseModel.ownPropModel.rateStyle.activeColor;
                self.qcStarView.svgName = @"heart-fill";
            }
            
            self.qcStarView.beforeSvgColor = baseModel.ownPropModel.rateStyle.restColor;
            h_qcStarView = 10 + iconSize + 10;
            self.qcStarView.viewWidth = nWidth;
            [_qcStarView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading).offset(10);
                make.trailing.equalTo(customView.mas_trailing).offset(-10);
                make.height.equalTo(@(h_qcStarView));
                make.top.equalTo(bodyLab.mas_bottom).offset(10);
            }];
            self.qcStarView.scorePercent = 0.0;
            self.qcStarView.isCompleteStar = YES; //NO的话可以展示半星
            self.qcStarView.isAnimation = YES;
            //是否仅仅是展示,默认为NO，可选
            //self.qcStarView.isJsutDisplay = YES;
			__weak __typeof(&*self)weakSelf = self;
			self.qcStarView.sendStarPercent= ^(double data, NSInteger starNumbers) {
				NSLog(@"DXPNugges Log:=== %f",data);
				d_starScore = data;
				weakSelf.starNumbers = starNumbers;
            };
        }
        // 点赞点彩
        if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
            if (self.thumbs) {
                [self.thumbs removeFromSuperview];
                self.thumbs = nil;
            }
            [customView addSubview:self.thumbs];
            CGFloat iconSize = baseModel.ownPropModel.rateStyle.iconSize == 0 ? 15: baseModel.ownPropModel.rateStyle.iconSize;
            self.thumbs.iconSize = iconSize; // 图标大小
            self.thumbs.beforeSvgColor = baseModel.ownPropModel.rateStyle.restColor;
            self.thumbs.thumbsUpColor = baseModel.ownPropModel.rateStyle.thumbsUpColor;
            self.thumbs.thumbsDownColor = baseModel.ownPropModel.rateStyle.thumbsDownColor;
            h_qcStarView = 10 + iconSize + 10;
            self.thumbs.viewWidth = nWidth;
            [_thumbs mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading).offset(10);
                make.trailing.equalTo(customView.mas_trailing).offset(-10);
                make.height.equalTo(@(h_qcStarView));
                make.top.equalTo(bodyLab.mas_bottom).offset(10);
            }];
            self.thumbs.sendThumnsVal= ^(int res) {
                if (res == 1) {
                    NSLog(@"DXPNugges Log:=== kudos:%d",res);
                }
                if (res == 2) {
                    NSLog(@"DXPNugges Log:=== point and click:%d",res);
                }
                thumbsScore = res;
            };
        }
        iViewCount = iViewCount + 1;
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
                                if (baseModel.ownPropModel.enabled) {
                                    // 有可输入区域
                                    make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                                } else {
                                    if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
                                        make.top.equalTo(_qcStarView.mas_bottom).offset(View_Spacing);
                                    }
                                    if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
                                        make.top.equalTo(_thumbs.mas_bottom).offset(View_Spacing);
                                    }
                                }
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                            
                        } else {
                            // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                                
                                if (baseModel.ownPropModel.enabled) {
                                    // 有可输入区域
                                    make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                                } else {
                                    if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
                                        make.top.equalTo(_qcStarView.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                    }
                                    if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
                                        make.top.equalTo(_thumbs.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                    }
                                }
                                
                                
                                
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        }
                    } else if ([align isEqualToString:@"right"]) { // 右边
                        if (i == 0) {
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                                
                                if (baseModel.ownPropModel.enabled) {
                                    make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                                } else {
                                    if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
                                        make.top.equalTo(_qcStarView.mas_bottom).offset(View_Spacing);
                                    }
                                    if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
                                        make.top.equalTo(_thumbs.mas_bottom).offset(View_Spacing);
                                    }
                                }
                                
                                
                                
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                            
                        } else {
                            // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                                
                                if (baseModel.ownPropModel.enabled) {
                                    make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                                } else {
                                    if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
                                        make.top.equalTo(_qcStarView.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                    }
                                    if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
                                        make.top.equalTo(_thumbs.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                    }
                                }
                                
                                
                                
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        }
                    } else {
                        // 默认 中间
                        if (i == 0) {
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.centerX.mas_equalTo(customView.centerX);
                                
                                
                                if (baseModel.ownPropModel.enabled) {
                                    make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                                } else {
                                    if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
                                        make.top.equalTo(_qcStarView.mas_bottom).offset(View_Spacing);
                                    }
                                    if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
                                        make.top.equalTo(_thumbs.mas_bottom).offset(View_Spacing);
                                    }
                                }
                                
                                
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                            
                        } else {
                            // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.centerX.mas_equalTo(customView.centerX);
                                
                                if (baseModel.ownPropModel.enabled) {
                                    make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                                } else {
                                    if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
                                        make.top.equalTo(_qcStarView.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                    }
                                    if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
                                        make.top.equalTo(_thumbs.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                    }
                                }
                                
                                
                               
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
                            
                            if (baseModel.ownPropModel.enabled) {
                                make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                            } else {
                                if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
                                    make.top.equalTo(_qcStarView.mas_bottom).offset(View_Spacing);
                                }
                                if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
                                    make.top.equalTo(_thumbs.mas_bottom).offset(View_Spacing);
                                }
                            }
                            
                            
                            
                            make.height.mas_equalTo(Button_height);
                        }];
                        
                    } else {
                        // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                            make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                            
                            if (baseModel.ownPropModel.enabled) {
                                make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                            } else {
                                if (baseModel.ownPropModel.rateType == KRateType_Heart || baseModel.ownPropModel.rateType == KRateType_Star) {
                                    make.top.equalTo(_qcStarView.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                }
                                if (baseModel.ownPropModel.rateType == KRateType_Thumbs) {
                                    make.top.equalTo(_thumbs.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                }
                            }
                            
                            
                            make.height.mas_equalTo(Button_height);
                        }];
                    }
                }

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
                NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:text.content];
                NSRange contentRange = {0,[content length]};
                [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
                btn.titleLabel.attributedText = content;
                // 边框
                CGFloat borderWidth = 0.f;
                if (item.buttonStyle.borderWidth > 0) {
                    borderWidth = item.buttonStyle.borderWidth;
                }
                // 圆角
                CGFloat fCornerRadius = 0;
                if (!isEmptyString_Nd(item.buttonStyle.all)) {
                    fCornerRadius = [item.buttonStyle.all floatValue];
                    if (fCornerRadius > Button_height/2) {
                        fCornerRadius = Button_height/2;
                    }
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

    // 计算Nudges frame   视频高度 + 标题高度 + 内容高度 + 图片高度 + 按钮高度 + 间距高度
    // 图片在文本上下
    CGFloat t_height = h_dissButton  + height_title + h_body + h_qcStarView + h_textView + [baseModel.buttonsModel.buttonList count] * Button_height + iViewCount *Padding_Spacing + Bottom_Spacing;
    customView.frame = CGRectMake(0, 0, nWidth, t_height);
    self.customView = customView;
    [self showNudgesByWidth:nWidth height:t_height];
	[[HJNudgesManager sharedInstance].visiblePopTipViews addObject:self.customView];
}

#pragma mark -- MonolayerViewDelegate
// 蒙层事件
- (void)MonolayerViewClickEventByTarget:(id)target {
    // 关闭当前nudges
    if (_baseModel.positionModel.position == KPosition_Middle) {
        if (self.customView) {
            [self.customView removeFromSuperview];
            self.customView = nil;
        }
    }
    if (_baseModel.positionModel.position == KPosition_bottom) {
        if (self.backView) {
            [self.backView removeFromSuperview];
            self.backView = nil;
        }
    }
    [self removeNudges]; // 移除nudges
    [self removeMonolayer]; // 移除蒙层
    [self stopTimer]; // 停止定时器
    [[HJNudgesManager sharedInstance] showNextNudges]; // 展示下一个Nudges
}

#pragma mark - CMPopTipViewDelegate methods
// 点击Nudges的代理
//- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
//	//    [self.visiblePopTipViews removeObject:popTipView];
//}

#pragma mark - UIViewController methods
//- (void)willAnimateRotationToInterfaceOrientation:(__unused UIInterfaceOrientation)toInterfaceOrientation duration:(__unused NSTimeInterval)duration {
//	for (CMPopTipView *popTipView in [HJNudgesManager sharedInstance].visiblePopTipViews) {
//		id targetObject = popTipView.targetObject;
//		[popTipView dismissAnimated:NO];
//		
//		if ([targetObject isKindOfClass:[UIButton class]]) {
//			UIButton *button = (UIButton *)targetObject;
//			[popTipView presentPointingAtView:button inView:[UIApplication sharedApplication].delegate.window animated:NO];
//		} else if ([targetObject isKindOfClass:[UIView class]]) {
//			UIView *view = (UIView *)targetObject;
//			[popTipView presentPointingAtView:view inView:[UIApplication sharedApplication].delegate.window animated:YES];
//		} else {
//			UIBarButtonItem *barButtonItem = (UIBarButtonItem *)targetObject;
//			[popTipView presentPointingAtBarButtonItem:barButtonItem animated:NO];
//		}
//	}
//}

#pragma mark -- lazy load
- (HJStar *)qcStarView {
    if (!_qcStarView) {
        _qcStarView = [[HJStar alloc] init];
    }
    return _qcStarView;
}

- (HJThumbs *)thumbs{
    if (!_thumbs) {
        _thumbs = [[HJThumbs alloc] init];
    }
    return _thumbs;
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
