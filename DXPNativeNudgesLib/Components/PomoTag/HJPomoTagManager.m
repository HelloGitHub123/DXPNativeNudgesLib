//
//  HJPomoTagManager.m
//  DITOApp
//
//  Created by 李标 on 2022/8/9.
//

#import "HJPomoTagManager.h"
#import "NdHJNudgesDBManager.h"
#import "NdHJIntroductManager.h"
#import "CMPopTipView.h"
#import "MonolayerModel.h"
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

#define View_Spacing  10
#define Button_height 43

#define kAppDelegate [UIApplication sharedApplication].delegate

static HJPomoTagManager *manager = nil;

@interface HJPomoTagManager ()<CMPopTipViewDelegate, MonolayerViewDelegate> {
    
}
@property (nonatomic, strong) NSMutableArray *visiblePopTipViews;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) CMPopTipView *popTipView;
@end

@implementation HJPomoTagManager

+ (instancetype)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[HJPomoTagManager alloc] init];
	});
	return manager;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		self.visiblePopTipViews = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)setBaseModel:(NudgesBaseModel *)baseModel {
	_baseModel = baseModel;
	//    [self constructsNudgesViewData:baseModel];
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
	[self MonolayerViewClickEventByTarget:self];
}

// 移除ToolTips
- (void)removeNudges {
	if ([self.visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
		[popTipView dismissAnimated:YES];
		[self.visiblePopTipViews removeObjectAtIndex:0];
		// 寻找下一个nudges
		[[HJNudgesManager sharedInstance] showNextNudges];
	}
}

// 删除预览的nudges
- (void)removePreviewNudges {
  if ([self.visiblePopTipViews count] > 0) {
    CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
    [popTipView dismissAnimated:YES];
    [self.visiblePopTipViews removeObjectAtIndex:0];
  }
}



#pragma mark -- 构造nudges数据
- (void)startConstructsNudgesView {
	if (self.baseModel && self.findView) {
		[self constructsNudgesViewData:self.baseModel view:self.findView];
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
	[self.monolayerView setAlphaRectParametersByRect:[self getAddress:view] SpotlightType:type radius:radius];
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
	
	CGFloat h_body = 0;
	
	UIView *customView = [[UIView alloc] init];
	// 宽度
	NSInteger nWidth = 200;
	if (baseModel.positionModel.width > 0) {
		nWidth = baseModel.positionModel.width;
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
		
		[bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
			make.leading.equalTo(customView.mas_leading);
			make.trailing.equalTo(customView.mas_trailing);
			make.top.equalTo(@5);
			make.height.equalTo(@(labelsize.height));
		}];
		
	} else {
		[bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
			make.leading.equalTo(customView.mas_leading);
			make.trailing.equalTo(customView.mas_trailing);
			make.top.equalTo(@0);
			make.height.equalTo(@0);
		}];
	}
	
	// 计算Nudges frame
	customView.frame = CGRectMake(0, 0, nWidth, 5+h_body+5);
#pragma mark -- 构造nudges view
	CMPopTipView *popTipView = [[CMPopTipView alloc] initWithCustomView:customView];
	popTipView.delegate = self;
	popTipView.pointerSize = 0; // 没有箭头展示
	popTipView.disableTapToDismiss = YES; // 点击Nudges是否关闭
	popTipView.dismissTapAnywhere = NO; // 点击任何空白处是否关闭
	popTipView.has3DStyle = NO;
	popTipView.hasShadow = NO;
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
		CGFloat radius = [baseModel.borderModel.all floatValue];
		if (radius > (customView.frame.size.height/2)) {
			// 如果设置的圆角大于等于配置的圆角值，则默认固定圆角为 Promo的(height/2)
			fCornerRadius = customView.frame.size.height/2;
		} else {
			fCornerRadius = [baseModel.borderModel.all floatValue];
		}
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
//    [popTipView presentPointingAtView:view inView:kAppDelegate.window animated:YES];
	[[TKUtils topViewController].tabBarController.view bringSubviewToFront:view];
	[popTipView presentPointingAtView:view inView:[TKUtils topViewController].view animated:NO];
	
	// 神策埋点
	NSString *contactId = isEmptyString_Nd(baseModel.contactId)?@"":baseModel.contactId;
	NSString *nudgesName = isEmptyString_Nd(baseModel.nudgesName)?@"":baseModel.nudgesName;
	NSString *pageName = isEmptyString_Nd(baseModel.pageName)?@"":baseModel.pageName;
	NSDictionary *dic = @{@"contact_id":contactId,@"nudges_name":nudgesName,@"nudges_id":@(baseModel.nudgesId),@"campaign_id":@(baseModel.campaignId),@"page_name":pageName};
//	[[SensorsManagement sharedInstance]trackWithName:@"NudgesShow" withProperties:dic];
	
	// 显示后上报接口
	[[HJNudgesManager sharedInstance] nudgesContactRespByNudgesId:baseModel.nudgesId contactId:baseModel.contactId];
  
  
  // 发送通知给RN
  [[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgesShowEvent",@"body":@{@"nudgesId":contactId,@"nudgesName":nudgesName,@"nudgesType":@(_baseModel.nudgesType),@"eventTypeId":@"onNudgesShow"}}];
  
  // 埋点发送通知给RN
  [[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeShow",@"body":@{@"nudgesId":@(_baseModel.nudgesId),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(_baseModel.campaignId),@"batchId":@"",@"source":@"1",@"pageName":pageName}}];
  
	
	[self.visiblePopTipViews addObject:popTipView];
	
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
			[self removeNudges]; // 移除nudges
			[self removeMonolayer]; // 移除蒙层
			[self stopTimer]; // 停止定时器
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
	[self removeNudges]; // 移除nudges
	[self removeMonolayer]; // 移除蒙层
	[self stopTimer]; // 停止定时器
	[[HJNudgesManager sharedInstance] showNextNudges]; // 展示下一个Nudges
}

#pragma mark - CMPopTipViewDelegate methods
// 点击Nudges的代理
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
	//    [self.visiblePopTipViews removeObject:popTipView];
}

#pragma mark - UIViewController methods
- (void)willAnimateRotationToInterfaceOrientation:(__unused UIInterfaceOrientation)toInterfaceOrientation duration:(__unused NSTimeInterval)duration {
	for (CMPopTipView *popTipView in self.visiblePopTipViews) {
		id targetObject = popTipView.targetObject;
		[popTipView dismissAnimated:NO];

		if ([targetObject isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)targetObject;
			[popTipView presentPointingAtView:button inView:kAppDelegate.window animated:NO];
		} else if ([targetObject isKindOfClass:[UIView class]]) {
			UIView *view = (UIView *)targetObject;
			[popTipView presentPointingAtView:view inView:kAppDelegate.window animated:YES];
		} else {
			UIBarButtonItem *barButtonItem = (UIBarButtonItem *)targetObject;
			[popTipView presentPointingAtBarButtonItem:barButtonItem animated:NO];
		}
	}
}

#pragma mark -- other
// 获取view相对于window的绝对地址
- (CGRect)getAddress:(UIView *)view {
	CGRect rect=[view convertRect: view.bounds toView:[TKUtils topViewController].view];
	return rect;
}

@end
