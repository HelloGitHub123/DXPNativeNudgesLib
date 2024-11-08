//
//  HJToolTipsManager.m
//  DITOApp
//
//  Created by 李标 on 2022/5/16.
//

#import "HJToolTipsManager.h"
#import "NdHJNudgesDBManager.h"
#import "NdHJIntroductManager.h"
#import <YYCategories/YYCategories.h>
#import "UIView+NdAddGradualLayer.h"
#import "HJNudgesManager.h"
#import "CMPopTipView.h"
#import "MonolayerModel.h"
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <ZFPlayer/ZFIJKPlayerManager.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import <ZFPlayer/UIView+ZFFrame.h>
#import <ZFPlayer/ZFPlayerConst.h>
#import "UIImageView+ZFCache.h"
#import "ZFUtilities.h"
#import "ZFCustomControlView.h"
#import "TKUtils.h"
#import <DXPFontManagerLib/FontManager.h>

#define Padding_Spacing 10
#define View_Spacing  10 // view 之间的间距
#define Bottom_Spacing 15
#define Button_height 30

#define kAppDelegate [UIApplication sharedApplication].delegate

static HJToolTipsManager *manager = nil;

@interface HJToolTipsManager ()<CMPopTipViewDelegate, MonolayerViewDelegate> {
}

//@property (nonatomic, strong) NSMutableArray *visiblePopTipViews;
@property (nonatomic, strong) dispatch_source_t timer;
// 播放器
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) UIImageView *containerView;
@property (nonatomic, strong) ZFCustomControlView *controlView;

@property (nonatomic, strong) CMPopTipView *popTipView;

@property (nonatomic, strong) UIView *customView;
@end

@implementation HJToolTipsManager

+ (instancetype)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[HJToolTipsManager alloc] init];
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

// 按钮事件
- (void)ButtonClickAction:(id)sender {
	UIButton *btn = (UIButton *)sender;
	for (int i = 0; i< [_baseModel.buttonsModel.buttonList count]; i ++) {
		ButtonItem *item = [_baseModel.buttonsModel.buttonList objectAtIndex:i];
		BOOL isClose = NO;// 是否关闭按钮
		if (item.itemTag == btn.tag) {
			if (KButtonsActionType_CloseNudges == item.action.type) {
				// 关闭Nudges
				isClose = YES;
			} else if (KBorderStyle_LaunchURL == item.action.type) {
				// URL跳转 内部webview or app 浏览器 or 内部浏览器
			} else if (KBorderStyle_InvokeAction == item.action.type) {
				// 提交 提交反馈 or 跳转app store
			}
			
			[self stopCurrentPlayingView]; // 停止播放器
			[self removeNudges];
			[self removeMonolayer];
			[self stopTimer]; // 停止定时器
			[[HJNudgesManager sharedInstance] showNextNudges];
			
			//  按钮点击事件 回调
			NSString *contactId = isEmptyString_Nd(_baseModel.contactId)?@"":_baseModel.contactId;
			NSString *nudgesName = isEmptyString_Nd(_baseModel.nudgesName)?@"":_baseModel.nudgesName;
			NSString *pageName = isEmptyString_Nd(_baseModel.pageName)?@"":_baseModel.pageName;
			NSString *text = isEmptyString_Nd(item.text.content)?@"":item.text.content;
			NSString *url = isEmptyString_Nd(item.action.url)?@"":item.action.url;
			NSString *invokeAction = isEmptyString_Nd(item.action.invokeAction)?@"":item.action.invokeAction;
			// 原生回调
			if (_delegate && [_delegate conformsToProtocol:@protocol(ToolTipsEventDelegate)]) {
				if (_delegate && [_delegate respondsToSelector:@selector(ToolTipsClickEventByActionModel:isClose:buttonName:nudgeModel:)]) {
					[_delegate ToolTipsClickEventByActionModel:item.action isClose:isClose buttonName:text nudgeModel:self.baseModel];
				}
			}
			// 埋点发送通知给RN
			[[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeClick",@"body":@{@"nudgesId":@(_baseModel.nudgesId),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(_baseModel.campaignId),@"batchId":@"0",@"jumpUrl":url,@"invokeAction":invokeAction,@"isClose":@(isClose),@"buttonName":text,@"source":@"1",@"pageName":pageName}}];
		}
	}
}

- (void)setBaseModel:(NudgesBaseModel *)baseModel {
	_baseModel = baseModel;
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
	if ([[HJNudgesManager sharedInstance].visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = [[HJNudgesManager sharedInstance].visiblePopTipViews objectAtIndex:0];
		[popTipView dismissAnimated:YES];
		[[HJNudgesManager sharedInstance].visiblePopTipViews removeObjectAtIndex:0];
		[self stopCurrentPlayingView];
		// 寻找下一个nudges
		
//		[[HJNudgesManager sharedInstance] showNextNudges];
	}
}

// 删除预览的nudges
- (void)removePreviewNudges {
	if ([[HJNudgesManager sharedInstance].visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = [[HJNudgesManager sharedInstance].visiblePopTipViews objectAtIndex:0];
		[popTipView dismissAnimated:YES];
		[[HJNudgesManager sharedInstance].visiblePopTipViews removeObjectAtIndex:0];
		[self stopCurrentPlayingView];
	}
	
	[self stopCurrentPlayingView]; // 停止播放器
	[self removeNudges];
	[self removeMonolayer];
	[self stopTimer]; // 停止定时器
}

// 停止播放，并且移除播放器
- (void)stopCurrentPlayingView {
	if (self.player) {
		[self.player stopCurrentPlayingView];
		self.player = nil;
		self.controlView = nil;
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
	self.monolayerView.monolayerViewType = KMonolayerViewType_Spotlight; // 全屏遮罩
	self.monolayerView.delegate = self;
	
	[self.monolayerView setAlphaRectParametersByRect:[self getAddress:view] SpotlightType:KOwnPropType_Box radius:2];
	
//	if (!baseModel.backdropModel.type) {
	if (!baseModel.backdropModel.enabled) {
		self.monolayerView.backgroundAlpha = 0;
		self.monolayerView.bgroundColor = @"0x000000";
	} else if (baseModel.backdropModel.type == KBackgroundType_Image) {
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
	
	[[TKUtils topViewController].view addSubview:self.monolayerView];
	
#pragma mark -- 自定义view
	int iViewCount = 0;
	CGFloat h_body = 0;
	CGFloat height_Video = 0; // 视频高度
	CGFloat height_image = 0; // 图片的高度
	CGFloat h_dissButton = 0;
	
	UIView *customView = [[UIView alloc] init];
	// nudges宽度
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
		h_dissButton = iconSize + 14;
	} else {
		[dissButton mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(customView.mas_top).offset(0);
			make.trailing.equalTo(customView.mas_trailing).offset(0);
			make.height.equalTo(@(0));
			make.width.equalTo(@(0));
		}];
	}
	
	// 视频
	[customView addSubview:self.containerView];
	if (!isEmptyString_Nd(baseModel.video.videoUrl) && [baseModel.video.videoUrl containsString:@"https://"]) {
		ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
		//        [playerManager pause];
		//        [playerManager shouldAutoPlay];
		playerManager.shouldAutoPlay = NO;
		
		/// 播放器相关
		self.player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:self.containerView];
		self.player.controlView = self.controlView; // 自定义view
		// 计算video宽高
		NSInteger videoWidth = nWidth;
		if (baseModel.video.width > 0) {
			videoWidth = baseModel.video.width;
		}
		// 设置各参数
		CGFloat paddingTop = 10;
		CGFloat paddingBottom = 0;
		CGFloat paddingleft = 0;
		CGFloat paddingRight = 0;
		if (baseModel.video.allSides) {
			paddingTop = baseModel.video.paddingTop;
			paddingBottom = baseModel.video.paddingTop;
			paddingleft = baseModel.video.paddingTop;
			paddingRight = baseModel.video.paddingTop;
		} else {
			paddingTop = baseModel.video.paddingTop;
			paddingBottom = baseModel.video.paddingBottom;
			paddingleft = baseModel.video.paddingLeft;
			paddingRight = baseModel.video.paddingRight;
		}
		CGFloat h_video = 200; // 默认高度
		if (!isEmptyString_Nd(baseModel.video.coverImageUrl)) {
			// 按照图片封面尺寸
			CGFloat h_image = baseModel.video.h_coverImage; // 图片真实宽高
			CGFloat w_image = baseModel.video.w_coverImage; // 图片真实宽高
			h_video = videoWidth * h_image / w_image; // 等比例缩放 计算出高度
		}
		height_Video = h_video;
		[self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(dissButton.mas_bottom).offset(paddingTop);
			make.leading.equalTo(customView.mas_leading).offset(paddingleft);
			make.trailing.equalTo(customView.mas_trailing).offset(-paddingRight);
			make.height.equalTo(@(h_video));
		}];
		// 封面图片URL
		NSString *coverImageUrl = isEmptyString_Nd(baseModel.video.coverImageUrl) ? @"" : baseModel.video.coverImageUrl;
		//        [_containerView setImageWithURLString:coverImageUrl placeholder:[ZFUtilities imageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] size:CGSizeMake(1, 1)]];
		/// 设置退到后台继续播放
		self.player.pauseWhenAppResignActive = YES;
		//        WS(self);
		//        self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
		//            ((AppDelegate*)[[UIApplication sharedApplication] delegate]).allowOrentitaionRotation = isFullScreen;
		//        };
		/// 播放完成
		__weak __typeof(&*self)weakSelf = self;
		self.player.playerDidToEnd = ^(id  _Nonnull asset) {
			[weakSelf.player.currentPlayerManager replay];
			[weakSelf.player playTheNext];
			if (!weakSelf.player.isLastAssetURL) {
				NSString *title = [NSString stringWithFormat:@"视频标题%zd",weakSelf.player.currentPlayIndex];
				[weakSelf.controlView showTitle:title coverURLString:coverImageUrl fullScreenMode:ZFFullScreenModeLandscape];
			} else {
				[weakSelf.player stop];
			}
		};
		playerManager.assetURL = [NSURL URLWithString:baseModel.video.videoUrl];
		[self.controlView showTitle:@"" coverURLString:coverImageUrl fullScreenMode:ZFFullScreenModeAutomatic];
		iViewCount = iViewCount + 1;
	} else {
		[self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(dissButton.mas_bottom).offset(0);
			make.leading.equalTo(customView.mas_leading);
			make.trailing.equalTo(customView.mas_trailing);
			make.height.equalTo(@0);
		}];
	}
	
	UIImageView *imgView = [[UIImageView alloc] init];
	UILabel *titleLab = [[UILabel alloc] init];
	__block CGFloat h_imageView = 0.f;
	KImagePositionType imagePosition = baseModel.imageModel.position;
	if (imagePosition == KImagePositionType_Left || imagePosition == KImagePositionType_Right) {
		// 图片
		// 判断图片相对文本的位置
		UIView *imgContentView = [[UIView alloc] init]; // 图片容器
		imgView.contentMode = UIViewContentModeScaleToFill; // 按比例缩放并且填满view
		[customView addSubview:imgContentView];
		[imgContentView addSubview:imgView];
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
			
			if (imagePosition ==  KImagePositionType_Right) { // 图片在文本的右边
				CGFloat width_ShowImg = (nWidth - Padding_Spacing * 2)/4;
				// 等比例缩放 得到图片的高度
				h_imageView =  width_ShowImg * h_image / w_image;
				[imgView mas_makeConstraints:^(MASConstraintMaker *make) {
					make.height.equalTo(@(h_imageView));
					make.width.equalTo(@(width_ShowImg));
					make.top.equalTo(self.containerView.mas_bottom).offset(Padding_Spacing);
					make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
				}];
				
			} else { // 默认 图片在文本的左边
				CGFloat width_ShowImg = (nWidth - Padding_Spacing * 2)/4;
				// 等比例缩放 得到图片的高度
				h_imageView =  width_ShowImg * h_image / w_image;
				[imgView mas_makeConstraints:^(MASConstraintMaker *make) {
					make.height.equalTo(@(h_imageView));
					make.width.equalTo(@(width_ShowImg));
					make.top.equalTo(self.containerView.mas_bottom).offset(Padding_Spacing);
					make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
				}];
			}
			
		} else {
			[imgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
				make.height.equalTo(@0);
				make.leading.equalTo(customView.mas_leading);
				make.trailing.equalTo(customView.mas_trailing);
				make.top.equalTo(self.containerView.mas_bottom).offset(0);
			}];
		}
		
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
			[titleLab sizeToFit];
			if (imagePosition == KImagePositionType_Right) {
				// 图片在文本的右边
				CGFloat width_ShowImg = (nWidth - Padding_Spacing * 2)/4; // 图片宽度
				CGSize labelsize =[titleLab sizeThatFits:CGSizeMake(nWidth - width_ShowImg - Padding_Spacing*2, CGFLOAT_MAX)];
				[titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
					make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
					make.trailing.equalTo(imgView.mas_leading).offset(-Padding_Spacing);
					make.top.equalTo(self.containerView.mas_bottom).offset(Padding_Spacing);
					make.height.equalTo(@(labelsize.height));
				}];
				
			} else {
				// 默认 图片在文本的左边
				CGFloat width_ShowImg = (nWidth - Padding_Spacing * 2)/4; // 图片宽度
				CGSize labelsize =[titleLab sizeThatFits:CGSizeMake(nWidth - width_ShowImg - Padding_Spacing*2 - 15, CGFLOAT_MAX)];
				[titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
					make.leading.equalTo(imgView.mas_trailing).offset(15); // 图片跟文本之间的间隔是15
					make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
					make.top.equalTo(self.containerView.mas_bottom).offset(Padding_Spacing);
					make.height.equalTo(@(labelsize.height));
				}];
			}
			
		} else {
			[titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
				make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
				make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
				make.top.equalTo(imgContentView.mas_bottom).offset(0);
				make.height.equalTo(@0);
			}];
		}
		
	} else {
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
			[titleLab sizeToFit];
			CGSize labelsize =[titleLab sizeThatFits:CGSizeMake(nWidth, CGFLOAT_MAX)];
			[titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
				make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
				make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
				make.top.equalTo(dissButton.mas_bottom).offset(Padding_Spacing);
				make.height.equalTo(@(labelsize.height));
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
		
		// 图片
		// 判断图片相对文本的位置
		UIView *imgContentView = [[UIView alloc] init]; // 图片容器
		imgView.contentMode = UIViewContentModeScaleToFill; // 按比例缩放并且填满view
		[customView addSubview:imgContentView];
		[imgContentView addSubview:imgView];
		
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
			
			// 图片在上下
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
					make.top.equalTo(titleLab.mas_bottom).offset(paddingTop);
				}];
			} else {
				// 等比例缩放
				h_imageView = (width_ShowImg * h_image) / w_image;
				// 容器高度
				[imgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
					make.height.equalTo(@(h_imageView + paddingBottom + paddingTop));
					make.leading.equalTo(customView.mas_leading).offset(0);
					make.trailing.equalTo(customView.mas_trailing).offset(0);
					make.top.equalTo(titleLab.mas_bottom).offset(0);
				}];
				
				
				[imgView mas_makeConstraints:^(MASConstraintMaker *make) {
					make.height.equalTo(@(h_imageView));
					make.leading.equalTo(imgContentView.mas_leading).offset(paddingleft);
					make.trailing.equalTo(imgContentView.mas_trailing).offset(-paddingRight);
					make.top.equalTo(imgContentView.mas_top).offset(paddingTop);
					make.bottom.equalTo(imgContentView.mas_bottom).offset(-paddingBottom);
				}];
			}
			//            iViewCount = iViewCount + 1;
			height_image = h_imageView + paddingBottom + paddingTop;
			
		} else {
			[imgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
				make.height.equalTo(@0);
				make.leading.equalTo(customView.mas_leading);
				make.trailing.equalTo(customView.mas_trailing);
				make.top.equalTo(titleLab.mas_bottom).offset(0);
			}];
		}
	}
	
	// body
	UILabel *bodyLab = [[UILabel alloc] init];
	[customView addSubview:bodyLab];
	if (!isEmptyString_Nd(baseModel.bodyModel.content)) {
		bodyLab.numberOfLines = 0;
		bodyLab.lineBreakMode = NSLineBreakByWordWrapping;
		bodyLab.text = baseModel.bodyModel.content;
		bodyLab.textColor = isEmptyString_Nd(baseModel.bodyModel.color)?[UIColor whiteColor]:[UIColor colorWithHexString:baseModel.bodyModel.color];
		if ([baseModel.bodyModel.textAlign isEqualToString:@"middle"]) {
			bodyLab.textAlignment = NSTextAlignmentCenter;
		} else if ([baseModel.bodyModel.textAlign isEqualToString:@"right"]) {
			bodyLab.textAlignment = NSTextAlignmentRight;
		} else {
			bodyLab.textAlignment = NSTextAlignmentLeft;
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
		if (imagePosition == KImagePositionType_Right) {
			// 图片在文本的右边
			CGFloat width_ShowImg = (nWidth - Padding_Spacing * 2)/4; // 图片宽度
			CGSize labelsize =[bodyLab sizeThatFits:CGSizeMake(nWidth - width_ShowImg - Padding_Spacing*4, CGFLOAT_MAX)];
			h_body = labelsize.height;
			[bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
				make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
				make.trailing.equalTo(imgView.mas_leading).offset(-Padding_Spacing);
				make.top.equalTo(titleLab.mas_bottom).offset(Padding_Spacing);
				make.height.equalTo(@(labelsize.height));
			}];
			
		} else if (imagePosition == KImagePositionType_Left) {
			// 图片在文本的左边
			CGFloat width_ShowImg = (nWidth - Padding_Spacing * 2)/4; // 图片宽度
			CGSize labelsize =[bodyLab sizeThatFits:CGSizeMake(nWidth - width_ShowImg - Padding_Spacing*2 - 15, CGFLOAT_MAX)];
			h_body = labelsize.height;
			[bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
				make.leading.equalTo(imgView.mas_trailing).offset(15); // 图片跟文本之间的间隔是15
				make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
				make.top.equalTo(titleLab.mas_bottom).offset(Padding_Spacing);
				make.height.equalTo(@(labelsize.height));
			}];
			
		} else {
			CGSize labelsize =[bodyLab sizeThatFits:CGSizeMake(nWidth, CGFLOAT_MAX)];
			h_body = labelsize.height;
			if (isEmptyString_Nd(baseModel.titleModel.content)) {
				[bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
					make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
					make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
					make.top.equalTo(imgView.mas_bottom).offset(Padding_Spacing);
					make.height.equalTo(@(labelsize.height));
				}];
			} else {
				[bodyLab mas_makeConstraints:^(MASConstraintMaker *make) {
					make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
					make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
					make.top.equalTo(imgView.mas_bottom).offset(View_Spacing);
					make.height.equalTo(@(labelsize.height));
				}];
			}
			iViewCount = iViewCount + 1;
		}
		
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
				titleSize.width += 20;
				// 布局
				NSString *align = baseModel.buttonsModel.layout.align; // 布局位置
				NSString *type = baseModel.buttonsModel.layout.type; // 布局类型
				if (KButtonLayoutType_Config == [type intValue]) {
					// 可配布局
					if ([align isEqualToString:@"left"]) { // 左边
						if (i == 0) {
							KImagePositionType position = baseModel.imageModel.position;
							if (position == KImagePositionType_Left || position == KImagePositionType_Right) {
								// 图片在左或者右边 要考虑文本的高度是否大于图片高度
								if ((titleLab.size.height + h_body) >= h_imageView) {
									[btn mas_makeConstraints:^(MASConstraintMaker *make) {
										make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
										make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
										make.height.mas_equalTo(Button_height);
										make.width.mas_equalTo(titleSize.width);
									}];
								} else {
									[btn mas_makeConstraints:^(MASConstraintMaker *make) {
										make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
										make.top.equalTo(imgView.mas_bottom).offset(View_Spacing);
										make.height.mas_equalTo(Button_height);
										make.width.mas_equalTo(titleSize.width);
									}];
								}
								
							} else {
								[btn mas_makeConstraints:^(MASConstraintMaker *make) {
									make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
									make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
									make.height.mas_equalTo(Button_height);
									make.width.mas_equalTo(titleSize.width);
								}];
							}
							
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
							KImagePositionType position = baseModel.imageModel.position;
							if (position == KImagePositionType_Left || position == KImagePositionType_Right) {
								// 图片在左或者右边 要考虑文本的高度是否大于图片高度
								if ((titleLab.size.height + h_body) >= h_imageView) {
									[btn mas_makeConstraints:^(MASConstraintMaker *make) {
										make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
										make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
										make.height.mas_equalTo(Button_height);
										make.width.mas_equalTo(titleSize.width);
									}];
								} else {
									[btn mas_makeConstraints:^(MASConstraintMaker *make) {
										make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
										make.top.equalTo(imgView.mas_bottom).offset(View_Spacing);
										make.height.mas_equalTo(Button_height);
										make.width.mas_equalTo(titleSize.width);
									}];
								}
								
							} else {
								[btn mas_makeConstraints:^(MASConstraintMaker *make) {
									make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
									make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
									make.height.mas_equalTo(Button_height);
									make.width.mas_equalTo(titleSize.width);
								}];
							}
							
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
							KImagePositionType position = baseModel.imageModel.position;
							if (position == KImagePositionType_Left || position == KImagePositionType_Right) {
								// 图片在左或者右边 要考虑文本的高度是否大于图片高度
								if ((titleLab.size.height + h_body) >= h_imageView) {
									[btn mas_makeConstraints:^(MASConstraintMaker *make) {
										make.centerX.mas_equalTo(customView.centerX);
										make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
										make.height.mas_equalTo(Button_height);
										make.width.mas_equalTo(titleSize.width);
									}];
								} else {
									[btn mas_makeConstraints:^(MASConstraintMaker *make) {
										make.centerX.mas_equalTo(customView.centerX);
										make.top.equalTo(imgView.mas_bottom).offset(View_Spacing);
										make.height.mas_equalTo(Button_height);
										make.width.mas_equalTo(titleSize.width);
									}];
								}
								
							} else {
								[btn mas_makeConstraints:^(MASConstraintMaker *make) {
									make.centerX.mas_equalTo(customView.centerX);
									make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
									make.height.mas_equalTo(Button_height);
									make.width.mas_equalTo(titleSize.width);
								}];
							}
							
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
						KImagePositionType position = baseModel.imageModel.position;
						if (position == KImagePositionType_Left || position == KImagePositionType_Right) {
							// 图片在左或者右边 要考虑文本的高度是否大于图片高度
							if ((titleLab.size.height + h_body) >= h_imageView) {
								[btn mas_makeConstraints:^(MASConstraintMaker *make) {
									make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
									make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
									make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
									make.height.mas_equalTo(Button_height);
								}];
							} else {
								[btn mas_makeConstraints:^(MASConstraintMaker *make) {
									make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
									make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
									make.top.equalTo(imgView.mas_bottom).offset(View_Spacing);
									make.height.mas_equalTo(Button_height);
								}];
							}
							
						} else {
							[btn mas_makeConstraints:^(MASConstraintMaker *make) {
								make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
								make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
								make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
								make.height.mas_equalTo(Button_height);
							}];
						}
						
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
				if (text.hasDecoration) {
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
	KImagePositionType position = baseModel.imageModel.position;
	if (position == KImagePositionType_Right) {
		// 图片在文本的右边
		if ((titleLab.size.height + h_body) >= h_imageView) {
			customView.frame = CGRectMake(0, 0, nWidth, h_dissButton + height_Video + titleLab.size.height + h_body + [baseModel.buttonsModel.buttonList count] * Button_height + 3 * View_Spacing);
		} else {
			customView.frame = CGRectMake(0, 0, nWidth,  h_dissButton + h_imageView + [baseModel.buttonsModel.buttonList count] * Button_height + 2 * View_Spacing);
		}
		
	} else if (position == KImagePositionType_Left) {
		// 图片在文本的左边
		if ((titleLab.size.height + h_body) >= h_imageView) {
			customView.frame = CGRectMake(0, 0, nWidth,  h_dissButton + height_Video + titleLab.size.height + h_body + [baseModel.buttonsModel.buttonList count] * Button_height + 3 * View_Spacing );
		} else {
			customView.frame = CGRectMake(0, 0, nWidth,  h_dissButton + h_imageView + [baseModel.buttonsModel.buttonList count] * Button_height + 2 * View_Spacing) ;
		}
		
	} else {
		// 图片在文本上下
		customView.frame = CGRectMake(0, 0, nWidth+Padding_Spacing*2,  h_dissButton + height_Video + titleLab.size.height + h_body + height_image + [baseModel.buttonsModel.buttonList count] * Button_height + iViewCount * View_Spacing + 10);
	}
	
#pragma mark -- 构造nudges view
	CMPopTipView *popTipView = [[CMPopTipView alloc] initWithCustomView:customView];
	popTipView.delegate = self;
	popTipView.disableTapToDismiss = YES; // 点击Nudges是否关闭
	popTipView.dismissTapAnywhere = NO; // 点击任何空白处是否关闭
	popTipView.has3DStyle = NO;
	popTipView.hasShadow = NO;
	popTipView.animation = CMPopTipAnimationPop; // Nudges出现的动画
	popTipView.showFromCenter = NO; // 箭头是否指向元素view的中心位置
	//    popTipView.backgroundColor = [UIColor redColor];
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
	
	// 展示蒙层
	//    MonolayerModel *mModel = [[MonolayerModel alloc] init];
	//    if (baseModel.backdropModel.type == KBackgroundType_Image) {
	//        // 图片
	//    } else if (baseModel.backdropModel.type == KBackgroundType_Gradient) {
	//        // 渐变
	//        NSString *gradientStartColor = baseModel.backdropModel.gradientStartColor;
	//        NSString *gradientEndColor = baseModel.backdropModel.gradientEndColor;
	//        if (isEmptyString_Nd(gradientStartColor) || isEmptyString_Nd(gradientEndColor)) {
	//            return;
	//        }
	//        [[MonolayerViewManager sharedInstance].monolayerView addGradualLayerWithColors:@[(__bridge id)[UIColor colorWithHexString:gradientStartColor].CGColor,(__bridge id)[UIColor colorWithHexString:gradientEndColor].CGColor] startPoint:CGPointMake(0, 0.5) endPoint:CGPointMake(1, 0.5)];
	//
	//    } else {
	//        // 实色
	//        CGFloat alpha = 0.3;
	//        if (baseModel.backdropModel.opacity > 0) {
	//            alpha = baseModel.backdropModel.opacity / 100.0;
	//        }
	//        if (isEmptyString_Nd(baseModel.backdropModel.backgroundColor)) {
	//            mModel.backgroundColor = [UIColor blackColor];
	//        } else {
	//            mModel.backgroundColor = [UIColor colorWithHexString:baseModel.backdropModel.backgroundColor];
	//        }
	//        mModel.alpha = alpha;
	//    }
	//
	//    [[MonolayerViewManager sharedInstance] showMonolayerViewWithModel:mModel];
	// 更新数据库nudges显示状态
	if (_nudgesModel) {
		[NdHJNudgesDBManager updateNudgesIsShowWithNudgesId:baseModel.nudgesId model:_nudgesModel];
	}
	// 弹出Nudges
	//    [popTipView presentPointingAtView:view inView:kAppDelegate.window animated:NO];
	
	[[TKUtils topViewController].tabBarController.view bringSubviewToFront:view];
	
	[popTipView presentPointingAtView:view inView:[TKUtils topViewController].view animated:NO];
	
	
	
	// 显示回调
	if (_delegate && [_delegate conformsToProtocol:@protocol(ToolTipsEventDelegate)]) {
		if (_delegate && [_delegate respondsToSelector:@selector(ToolTipsShowEventByNudgesModel:batchId:source:)]) {
			[_delegate ToolTipsShowEventByNudgesModel:baseModel batchId:@"0" source:@"1"];
		}
	}
	
	NSString *contactId = isEmptyString_Nd(baseModel.contactId)?@"":baseModel.contactId;
	NSString *nudgesName = isEmptyString_Nd(baseModel.nudgesName)?@"":baseModel.nudgesName;
	NSString *pageName = isEmptyString_Nd(baseModel.pageName)?@"":baseModel.pageName;
	// 埋点发送通知给RN
	[[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeShow",@"body":@{@"nudgesId":@(baseModel.nudgesId),@"nudgesType":@(baseModel.nudgesType),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(baseModel.campaignId),@"batchId":@"0",@"source":@"1",@"pageName":pageName}}];
	
	
	// 显示后上报接口
//	[[HJNudgesManager sharedInstance] nudgesContactRespByNudgesId:baseModel.nudgesId contactId:baseModel.contactId];
	
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
			[self stopCurrentPlayingView]; // 停止播放器
			[self removeNudges]; // 移除nudges
			[self removeMonolayer]; // 移除蒙层
			[self stopTimer]; // 停止定时器
			[self.popTipView removeFromSuperview];
			self.popTipView = nil;
			[[HJNudgesManager sharedInstance] showNextNudges];
		});
		dispatch_resume(self.timer);
	}
	
	self.popTipView = popTipView;
	
}

#pragma mark -- MonolayerViewDelegate
// 蒙层事件
- (void)MonolayerViewClickEventByTarget:(id)target {
	// 关闭当前nudges
	[self stopCurrentPlayingView]; // 停止播放器
	[self removeNudges]; // 移除nudges
	[self removeMonolayer]; // 移除蒙层
	[self stopTimer]; // 停止定时器
	[self.popTipView removeFromSuperview];
	self.popTipView = nil;
	// 展示下一个Nudges
	[[HJNudgesManager sharedInstance] showNextNudges];
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

#pragma mark -- lazy load
- (UIImageView *)containerView {
	if (!_containerView) {
		_containerView = [UIImageView new];
	}
	return _containerView;
}

- (ZFCustomControlView *)controlView {
	if (!_controlView) {
		_controlView = [ZFCustomControlView new];
	}
	return _controlView;
}

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

// 获取view相对于window的绝对地址
- (CGRect)getAddress:(UIView *)view {
	//    CGRect rect=[view convertRect: view.bounds toView:kAppDelegate.window];
	CGRect rect=[view convertRect: view.bounds toView:[TKUtils topViewController].view];
	return rect;
}

@end
