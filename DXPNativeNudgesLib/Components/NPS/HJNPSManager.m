//
//  HJNPSManager.m
//  DITOApp
//
//  Created by 李标 on 2022/9/11.
//

#import "HJNPSManager.h"
#import "NdHJNudgesDBManager.h"
#import "NdHJIntroductManager.h"
#import <YYCategories/YYCategories.h>
#import "UIView+NdAddGradualLayer.h"
#import "HJNudgesManager.h"
//#import "CMPopTipView.h"
#import "UIImageView+ZFCache.h"
#import "ZFUtilities.h"
#import "TKUtils.h"
#import "HJSliderView.h"
#import "WKTextView.h"
#import <DXPFontManagerLib/FontManager.h>
#import "NSString+ndDate.h"

#define Padding_Spacing 10
#define View_Spacing  10 // view 之间的间距
#define Bottom_Spacing 15
#define Button_height 43

static HJNPSManager *manager = nil;

@interface HJNPSManager ()<MonolayerViewDelegate, SliderViewEventDelegate> {
	NSString *showTimestamp;
}
//@property (nonatomic, strong) NSMutableArray *visiblePopTipViews;
@property (nonatomic, strong) dispatch_source_t timer;
//@property (nonatomic, strong) CMPopTipView *popTipView;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, copy) NSString *resultNumber; // 评分结果

@property (nonatomic, strong) WKTextView *textView;
@end

@implementation HJNPSManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HJNPSManager alloc] init];
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
		BOOL isClose = NO;
		if (item.itemTag == btn.tag) {
			if (KButtonsActionType_CloseNudges == item.action.type) {
				isClose = YES;
			} else if (KBorderStyle_LaunchURL == item.action.type) {
				// 内部跳转
			} else if (KBorderStyle_InvokeAction == item.action.type) {
				// 调用方法 feedback
//                if (_delegate && [_delegate conformsToProtocol:@protocol(NPSEventDelegate)]) {
//                    if (_delegate && [_delegate respondsToSelector:@selector(NPSSubmitByScore:)]) {
//                        [_delegate NPSSubmitByScore:self.resultNumber];
//                    }
//                }
			}
			
			if (_baseModel.positionModel.position == KPosition_bottom) {
				if (self.backView) {
					[self.backView removeFromSuperview];
					self.backView = nil;
				}
			}
			
			// 关闭Nudges
			[self removeNudges];
			[self removeMonolayer];
			[self stopTimer];
			[[HJNudgesManager sharedInstance] showNextNudges];
			
			// 神策埋点
			NSString *contactId = isEmptyString_Nd(_baseModel.contactId)?@"":_baseModel.contactId;
			NSString *nudgesName = isEmptyString_Nd(_baseModel.nudgesName)?@"":_baseModel.nudgesName;
			NSString *pageName = isEmptyString_Nd(_baseModel.pageName)?@"":_baseModel.pageName;
			NSString *text = isEmptyString_Nd(item.text.content)?@"":item.text.content;
			NSString *url = isEmptyString_Nd(item.action.url)?@"":item.action.url;
			NSString *invokeAction = isEmptyString_Nd(item.action.invokeAction)?@"":item.action.invokeAction;
			NSString *comments = isEmptyString_Nd(self.textView.contentText)?@"":self.textView.contentText;
			
			if (_delegate && [_delegate conformsToProtocol:@protocol(NPSEventDelegate)]) {
				if (_delegate && [_delegate respondsToSelector:@selector(NPSClickEventByActionModel:isClose:buttonName:nudgeModel:score:optionList:thumbResult:comments:feedbackDuration:)]) {
					
					// 反馈时长
					NSString *feedBackTime = [NSString getCurrentTimestamp];
					NSInteger feedbackDuration = [feedBackTime integerValue] - [showTimestamp integerValue];
					
					[_delegate NPSClickEventByActionModel:item.action isClose:isClose buttonName:text nudgeModel:_baseModel score:self.resultNumber optionList:@[].mutableCopy thumbResult:@"" comments:comments feedbackDuration:feedbackDuration];
				}
			}
			
			// 埋点发送通知给RN
			[[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeClick",@"body":@{@"nudgesId":@(_baseModel.nudgesId),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(_baseModel.campaignId),@"batchId":@"0",@"jumpUrl":url,@"invokeAction":invokeAction,@"isClose":@(isClose),@"buttonName":text,@"source":@"1",@"pageName":pageName,@"score":self.resultNumber,@"comments":comments,@"optionList":@[].mutableCopy,@"thumbResult":@""}}];
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
//    [[HJNudgesManager sharedInstance] nudgesContactRespByNudgesId:_baseModel.nudgesId contactId:_baseModel.contactId];
  
  NSString *contactId = isEmptyString_Nd(_baseModel.contactId)?@"":_baseModel.contactId;
  NSString *nudgesName = isEmptyString_Nd(_baseModel.nudgesName)?@"":_baseModel.nudgesName;
  NSString *pageName = isEmptyString_Nd(_baseModel.pageName)?@"":_baseModel.pageName;
  
	showTimestamp = [NSString getCurrentTimestamp];
	
	[[HJNudgesManager sharedInstance].visiblePopTipViews addObject:self.customView];
	
	// 回调
	if (_delegate && [_delegate conformsToProtocol:@protocol(NPSEventDelegate)]) {
		if (_delegate && [_delegate respondsToSelector:@selector(NPSShowEventByNudgesModel:batchId:source:)]) {
			[_delegate NPSShowEventByNudgesModel:_baseModel batchId:@"0" source:@"1"];
		}
	}
	
	// 埋点发送通知给RN
	[[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeShow",@"body":@{@"nudgesId":@(_baseModel.nudgesId),@"nudgesType":@(_baseModel.nudgesType),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(_baseModel.campaignId),@"batchId":@"0",@"source":@"1",@"pageName":pageName}}];
}

#pragma mark -- SliderViewEventDelegate
- (void)SliderViewEventClickByResult:(NSInteger)reslut target:(id)target {
	self.resultNumber = [NSString stringWithFormat:@"%ld",(long)reslut];
   // self.resultNumber = reslut; // 缓存结果
//    NSLog(@"%ld",(long)self.resultNumber);
}

#pragma mark -- 构造nudges数据
- (void)constructsNudgesViewData:(NudgesBaseModel *)baseModel {
    // 定位要展示的view
//    UIView *view = [[NdHJIntroductManager sharedManager] getSubViewWithClassNameInViewController:baseModel.pageName viewClassName:@"UIView" index:0 inView:kAppDelegate.window findIndex:baseModel.findIndex];
    
//    // 获取window 的nodel
//    UIViewController *VC = [self getCurrentVC];
//    NodeModel *nodel = [[NdHJIntroductManager sharedManager] getWindowNode:[UIApplication sharedApplication].delegate.window inViewController:VC index:@""];
//    NSLog(@"nodel");
//
//    __block UIView *view = nil;
//    NSLog(@"baseModel.appExtInfoModel.accessibilityIdentifier:%@",baseModel.appExtInfoModel.accessibilityIdentifier);
//    [self getViewNodeModelByAccessibilityElement:baseModel.appExtInfoModel.accessibilityIdentifier targetView:nodel block:^(NodeModel *nodel) {
//        NSLog(@"halllo------%@",nodel.strAccessibilityIdentifier);
//        view = nodel.targetView;
//    }];
//
//    if (!view) {
//        return;
//    }
    
    
    // 根据返回的findIndex判断是否nudges target
//    __block UIView *view = nil;
//    if (!isEmptyString_Nd(baseModel.findIndex)) {
//        // 获取window 的nodel
////        UIViewController *VC = [self getCurrentVC];
//        UIViewController *VC = [TKUtils topViewController];
//        NodeModel *nodel = [[NdHJIntroductManager sharedManager] getWindowNode:[UIApplication sharedApplication].delegate.window inViewController:VC index:@""];
//        
//        __block BOOL isExist = NO;
//        NSLog(@"baseModel.appExtInfoModel.accessibilityIdentifier:%@",baseModel.appExtInfoModel.accessibilityIdentifier);
//        
//        NSString *identifier = baseModel.appExtInfoModel.accessibilityIdentifier;
//        NSString *stringWithoutSpace = [identifier stringByReplacingOccurrencesOfString:@" " withString:@""];
//        stringWithoutSpace = [stringWithoutSpace stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//        stringWithoutSpace = [stringWithoutSpace stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        
//        [self getViewNodeModelByAccessibilityElement:stringWithoutSpace targetView:nodel block:^(NodeModel *nodel) {
//            NSLog(@"halllo------%@",nodel.strAccessibilityIdentifier);
//            view = nodel.targetView;
//            // 判断当前view是否在屏幕中
//            isExist = [TKUtils isDisplayedInScreen:view];
//            if (isExist) {
//                // 在当前屏幕范围中
//            } else {
//                // 不在当前屏幕中 跳过展示下一个nudges
//                [[HJNudgesManager sharedInstance] showNextNudges];
//                return;
//            }
//        }];
//        
//        if (!view || !isExist) {
//            return;
//        }
//    }
    
	self.resultNumber = @"";
    
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
    
    // 遮罩 + 镂空
    self.monolayerView = [[MonolayerView alloc] init];
    self.monolayerView.monolayerViewType = KMonolayerViewType_full; // 全屏遮罩
    self.monolayerView.delegate = self;
    // 展示蒙层
//    if (baseModel.backdropModel.enabled) {
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
//    }
//    [kAppDelegate.window addSubview:self.monolayerView];
    [[TKUtils topViewController].view addSubview:self.monolayerView];

#pragma mark -- 自定义view
    int iViewCount = 0;
    CGFloat height_title = 0;
    CGFloat h_body = 0;
    CGFloat h_dissButton = 0;
    CGFloat h_NPS = 0;
    CGFloat h_textView = 0;
    
    UIView *customView = [[UIView alloc] init];
    // nudges宽度
    NSInteger nWidth = 200;
    if (baseModel.positionModel.width > 0) {
        nWidth = baseModel.positionModel.width;
    }
    if (_baseModel.positionModel.position == KPosition_bottom || _baseModel.positionModel.position == 0) {
        // 整屏宽度
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
    } else {
        [dissButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(customView.mas_top).offset(0);
            make.trailing.equalTo(customView.mas_trailing).offset(0);
            make.height.equalTo(@(0));
            make.width.equalTo(@(0));
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
            make.top.equalTo(dissButton.mas_bottom).offset(Padding_Spacing);
            make.height.equalTo(@(height_title));
        }];
        iViewCount = iViewCount + 1;
    } else {
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
            make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
            make.top.equalTo(dissButton.mas_bottom).offset(0);
            make.height.equalTo(@0);
        }];
    }
    
    UILabel *bodyLab = [[UILabel alloc] init];
    UIView *npsView = [[UIView alloc] init];
    WKTextView *textView = [[WKTextView alloc] init];
	self.textView = textView;
    if (baseModel.ownPropModel.enabled) { // 增加可输入区域
        // NPS Start
    #define H_numberView  20   // 刻度的高度 or 点击的刻度的高度
    #define H_SliderView  35   // 滑动块的高度
    #define H_TextInfo    20   // 说明文字的高度
        if ([baseModel.ownPropModel.npsType isEqualToString:@"S"] || isEmptyString_Nd(baseModel.ownPropModel.npsType)) {
            // Slider 默认
            npsView.backgroundColor = [UIColor whiteColor];
            npsView.userInteractionEnabled = YES;
            [customView addSubview:npsView];
            CGFloat h_nps = View_Spacing + H_numberView + 5 + H_SliderView + 5 + H_TextInfo;
            h_NPS = h_nps;
            [npsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading);
                make.trailing.equalTo(customView.mas_trailing);
                make.top.equalTo(titleLab.mas_bottom).offset(0);
                make.height.equalTo(@(h_nps)); // 95
            }];
            
            HJSliderView *sliderView = [[HJSliderView alloc] init];
            [npsView addSubview:sliderView];
            sliderView.delegate = self;
            sliderView.isClick = NO; // 不可以点击
            sliderView.ownPropModel = baseModel.ownPropModel;
            [sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(npsView.mas_leading);
                make.trailing.equalTo(npsView.mas_trailing);
                make.top.equalTo(npsView.mas_top).offset(10);
                make.height.equalTo(@(85));
            }];
        }
        if ([baseModel.ownPropModel.npsType isEqualToString:@"C"]) {
            // Click
            npsView.backgroundColor = [UIColor whiteColor];
            npsView.userInteractionEnabled = YES;
            [customView addSubview:npsView];
            CGFloat h_nps = View_Spacing + H_numberView + 5 + H_TextInfo;
            h_NPS = h_nps;
            [npsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading);
                make.trailing.equalTo(customView.mas_trailing);
                make.top.equalTo(titleLab.mas_bottom).offset(0);
                make.height.equalTo(@(h_nps));
            }];
            
            HJSliderView *sliderView = [[HJSliderView alloc] init];
            [npsView addSubview:sliderView];
            sliderView.delegate = self;
            [sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(npsView.mas_leading);
                make.trailing.equalTo(npsView.mas_trailing);
                make.top.equalTo(npsView.mas_top).offset(10);
                make.height.equalTo(@(45));
            }];
            sliderView.isClick = YES; // 不可以点击
            sliderView.ownPropModel = baseModel.ownPropModel;
        }
        // NPS End
        
        // body
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
                    make.top.equalTo(npsView.mas_bottom).offset(Padding_Spacing);
                    make.height.equalTo(@(labelsize.height));
                }];
            } else {
                [bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                    make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                    make.top.equalTo(npsView.mas_bottom).offset(View_Spacing);
                    make.height.equalTo(@(labelsize.height));
                }];
            }
            iViewCount = iViewCount + 1;
            
        } else {
            [bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading);
                make.trailing.equalTo(customView.mas_trailing);
                make.top.equalTo(npsView.mas_bottom).offset(0);
                make.height.equalTo(@0);
            }];
        }
        
        // 可输入textView
        [customView addSubview:textView];
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
            make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
            if ([baseModel.ownPropModel.input.style isEqualToString:@"S"]) {
                // 单行
                make.height.equalTo(@22);
            } else {
                // 多行
                make.height.equalTo(@48);
            }
            make.top.equalTo(bodyLab.mas_bottom).offset(12);
        }];
        // text View 高度
        if ([baseModel.ownPropModel.input.style isEqualToString:@"S"]) {
            h_textView = 22; // 单行
        } else {
            h_textView = 48; // 多行
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
        NSInteger fontSize = 14;
        if (baseModel.ownPropModel.hint.fontSize > 0) {
            fontSize = baseModel.bodyModel.fontSize;
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
        
        
    } else { // 没有携带可输入区域
        // body
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
        
        // NPS Start
    #define H_numberView  20   // 刻度的高度 or 点击的刻度的高度
    #define H_SliderView  35   // 滑动块的高度
    #define H_TextInfo    20   // 说明文字的高度
        if ([baseModel.ownPropModel.npsType isEqualToString:@"S"] || isEmptyString_Nd(baseModel.ownPropModel.npsType)) {
            // Slider 默认
            npsView.backgroundColor = [UIColor whiteColor];
            npsView.userInteractionEnabled = YES;
            [customView addSubview:npsView];
            CGFloat h_nps = View_Spacing + H_numberView + 5 + H_SliderView + 5 + H_TextInfo;
            h_NPS = h_nps;
            [npsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading);
                make.trailing.equalTo(customView.mas_trailing);
                make.top.equalTo(bodyLab.mas_bottom).offset(0);
                make.height.equalTo(@(h_nps)); // 95
            }];
            
            HJSliderView *sliderView = [[HJSliderView alloc] init];
            [npsView addSubview:sliderView];
            sliderView.delegate = self;
            sliderView.isClick = NO; // 不可以点击
            sliderView.ownPropModel = baseModel.ownPropModel;
            [sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(npsView.mas_leading);
                make.trailing.equalTo(npsView.mas_trailing);
                make.top.equalTo(npsView.mas_top).offset(10);
                make.height.equalTo(@(85));
            }];
        }
        if ([baseModel.ownPropModel.npsType isEqualToString:@"C"]) {
            // Click
            npsView.backgroundColor = [UIColor whiteColor];
            npsView.userInteractionEnabled = YES;
            [customView addSubview:npsView];
            CGFloat h_nps = View_Spacing + H_numberView + 5 + H_TextInfo;
            h_NPS = h_nps;
            [npsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading);
                make.trailing.equalTo(customView.mas_trailing);
                make.top.equalTo(bodyLab.mas_bottom).offset(0);
                make.height.equalTo(@(h_nps));
            }];
            
            HJSliderView *sliderView = [[HJSliderView alloc] init];
            [npsView addSubview:sliderView];
            sliderView.delegate = self;
            [sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(npsView.mas_leading);
                make.trailing.equalTo(npsView.mas_trailing);
                make.top.equalTo(npsView.mas_top).offset(10);
                make.height.equalTo(@(45));
            }];
            sliderView.isClick = YES; // 不可以点击
            sliderView.ownPropModel = baseModel.ownPropModel;
        }
        // NPS End
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
                                    // 可输入区域
                                    make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                                } else {
                                    // 无可输入textview
                                    make.top.equalTo(npsView.mas_bottom).offset(View_Spacing);
                                }
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        } else {
                            // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                                make.top.equalTo(npsView.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        }
                    } else if ([align isEqualToString:@"right"]) { // 右边
                        if (i == 0) {
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                                if (baseModel.ownPropModel.enabled) {
                                    // 可输入区域
                                    make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                                } else {
                                    // 无可输入textview
                                    make.top.equalTo(npsView.mas_bottom).offset(View_Spacing);
                                }
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        } else {
                            // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                                make.top.equalTo(npsView.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
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
                                    // 可输入区域
                                    make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                                } else {
                                    // 无可输入textview
                                    make.top.equalTo(npsView.mas_bottom).offset(View_Spacing);
                                }
                                make.height.mas_equalTo(Button_height);
                                make.width.mas_equalTo(titleSize.width);
                            }];
                        } else {
                            // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.centerX.mas_equalTo(customView.centerX);
                                make.top.equalTo(npsView.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
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
                                // 可输入区域
                                make.top.equalTo(textView.mas_bottom).offset(View_Spacing);
                            } else {
                                // 无可输入textview
                                make.top.equalTo(npsView.mas_bottom).offset(View_Spacing);
                            }
                            make.height.mas_equalTo(Button_height);
                        }];
                    } else {
                        // 当前只考虑一个按钮情况。所以下面多按钮的就先不加判断，判断图片在左还是在右。
                        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                            make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                            make.top.equalTo(npsView.mas_bottom).offset((Button_height*i + View_Spacing) + (i * View_Spacing));
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

    // 计算Nudges frame  标题高度 + 内容高度 + 按钮高度 + 间距高度
    CGFloat t_height = h_dissButton + height_title + h_body + h_NPS + h_textView + [baseModel.buttonsModel.buttonList count] * Button_height + iViewCount * View_Spacing + Bottom_Spacing;
    customView.frame = CGRectMake(0, 0, nWidth, t_height);
    self.customView = customView;
    [self showNudgesByWidth:nWidth height:t_height];
}

#pragma mark -- MonolayerViewDelegate
// 蒙层事件
- (void)MonolayerViewClickEventByTarget:(id)target {
    if (_baseModel.positionModel.position == KPosition_bottom) {
        if (self.backView) {
            [self.backView removeFromSuperview];
            self.backView = nil;
        }
    }
    // 关闭当前nudges
    [self removeNudges]; // 移除nudges
    [self removeMonolayer]; // 移除蒙层
    [self stopTimer]; // 停止定时器
//    [self.popTipView removeFromSuperview];
//    self.popTipView = nil;
	
    [[HJNudgesManager sharedInstance] showNextNudges]; // 展示下一个Nudges
}

#pragma mark - CMPopTipViewDelegate methods
// 点击Nudges的代理
//- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
////    [self.visiblePopTipViews removeObject:popTipView];
//}

#pragma mark - UIViewController methods
//- (void)willAnimateRotationToInterfaceOrientation:(__unused UIInterfaceOrientation)toInterfaceOrientation duration:(__unused NSTimeInterval)duration {
//    for (CMPopTipView *popTipView in [HJNudgesManager sharedInstance].visiblePopTipViews) {
//        id targetObject = popTipView.targetObject;
//        [popTipView dismissAnimated:NO];
//
//        if ([targetObject isKindOfClass:[UIButton class]]) {
//            UIButton *button = (UIButton *)targetObject;
//            [popTipView presentPointingAtView:button inView:[UIApplication sharedApplication].delegate.window animated:NO];
//        } else if ([targetObject isKindOfClass:[UIView class]]) {
//            UIView *view = (UIView *)targetObject;
//            [popTipView presentPointingAtView:view inView:[UIApplication sharedApplication].delegate.window animated:YES];
//        } else {
//            UIBarButtonItem *barButtonItem = (UIBarButtonItem *)targetObject;
//            [popTipView presentPointingAtBarButtonItem:barButtonItem animated:NO];
//        }
//    }
//}

//画虚线
- (void)drawDashLine:(UIView *)lineView viewFrame:(CGRect)viewBounds viewHeight:(CGFloat)viewHeight viewWidth:(CGFloat)viewWidth lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor{
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:viewBounds];
    [shapeLayer setPosition:CGPointMake(viewWidth / 2, viewHeight)];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:viewHeight];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, viewWidth, 0);
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
    
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
