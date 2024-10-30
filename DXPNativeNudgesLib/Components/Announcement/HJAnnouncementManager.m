//
//  HJAnnouncementManager.m
//  DITOApp
//
//  Created by 李标 on 2022/8/9.
//  弹框

#import "HJAnnouncementManager.h"
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
#define View_Spacing  10 // view 之间的间距
#define Bottom_Spacing 15
#define Button_height 30

static HJAnnouncementManager *manager = nil;

@interface HJAnnouncementManager ()<CMPopTipViewDelegate, MonolayerViewDelegate> {
    
}
@property (nonatomic, strong) NSMutableArray *visiblePopTipViews;
@property (nonatomic, strong) UIImageView *containerView;
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFCustomControlView *controlView;
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UIView *backView;

@end

@implementation HJAnnouncementManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HJAnnouncementManager alloc] init];
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

- (void)ButtonClickAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    for (int i = 0; i< [_baseModel.buttonsModel.buttonList count]; i ++) {
        ButtonItem *item = [_baseModel.buttonsModel.buttonList objectAtIndex:i];
        if (item.itemTag == btn.tag) {
            if (KButtonsActionType_CloseNudges == item.action.type) {
                // 关闭Nudges
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
                
                [self stopCurrentPlayingView]; // 停止播放器
                [self removeNudges];
                [self removeMonolayer];
                [self stopTimer];
                [[HJNudgesManager sharedInstance] showNextNudges];
                
                

            } else if (KBorderStyle_LaunchURL == item.action.type) {
                // 内部跳转
                if (isEmptyString_Nd(item.action.url)) {
                    return;
                }
                if (_delegate && [_delegate conformsToProtocol:@protocol(AnnouncementEventDelegate)]) {
                  if (_delegate && [_delegate respondsToSelector:@selector(AnnouncementClickEventByType:Url:invokeAction:buttonName:model:)]) {
                    //                        [_delegate AnnouncementClickEventByType:item.action.urlJumpType Url:item.action.url];
                  
                    // 神策埋点
                    NSString *contactId = isEmptyString_Nd(_baseModel.contactId)?@"":_baseModel.contactId;
                    NSString *nudgesName = isEmptyString_Nd(_baseModel.nudgesName)?@"":_baseModel.nudgesName;
                    NSString *pageName = isEmptyString_Nd(_baseModel.pageName)?@"":_baseModel.pageName;
                    NSString *text = isEmptyString_Nd(item.text.content)?@"":item.text.content;
                    NSString *url = isEmptyString_Nd(item.action.url)?@"":item.action.url;
                    NSString *invokeAction = isEmptyString_Nd(item.action.invokeAction)?@"":item.action.invokeAction;
                    
                    [_delegate AnnouncementClickEventByType:item.action.urlJumpType Url:item.action.url invokeAction:invokeAction buttonName:text model:self.baseModel];
                    
                    // 埋点发送通知给RN
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeClick",@"body":@{@"nudgesId":@(_baseModel.nudgesId),@"nudgesName":nudgesName,@"contactId":_baseModel.contactId,@"campaignCode":@(_baseModel.campaignId),@"batchId":@"",@"source":@"1",@"pageName":pageName}}];
                  }
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
                [self stopCurrentPlayingView]; // 停止播放器
                [self removeNudges];
                [self removeMonolayer];
                [self stopTimer]; // 停止定时器
                
            } else if (KBorderStyle_InvokeAction == item.action.type) {
                // 调用方法
                if ([item.action.invokeAction isEqualToString:@"OPEN_APP_STORE"]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id6465894875"] options:@{} completionHandler:^(BOOL success) {
                    }];
                    // 调用方法 feedback
                    if (_delegate && [_delegate conformsToProtocol:@protocol(AnnouncementEventDelegate)]) {
                        if (_delegate && [_delegate respondsToSelector:@selector(AnnouncementSubmitByScore:)]) {
                            [_delegate AnnouncementSubmitByScore:0];
                        }
                    }
                    
                    // 关闭Nudges
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
                    
                    [self stopCurrentPlayingView]; // 停止播放器
                    [self removeNudges];
                    [self removeMonolayer];
                    [self stopTimer];
                }
            }
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
    [self MonolayerViewClickEventByTarget:self];
    // 上报评分
    if (_delegate && [_delegate conformsToProtocol:@protocol(AnnouncementEventDelegate)]) {
        if (_delegate && [_delegate respondsToSelector:@selector(AnnouncementSubmitByScore:)]) {
            [_delegate AnnouncementSubmitByScore:0];
        }
    }
}

// 移除ToolTips
- (void)removeNudges {
    if ([self.visiblePopTipViews count] > 0) {
        CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
        [popTipView dismissAnimated:YES];
        [self.visiblePopTipViews removeObjectAtIndex:0];
        [self stopCurrentPlayingView];
    }
}

// 删除预览的nudges
- (void)removePreviewNudges {
  [self removeNudges];
}

// 停止播放，并且移除播放器
- (void)stopCurrentPlayingView {
    if (self.player) {
        [self.player stopCurrentPlayingView];
        self.player = nil;
        self.controlView = nil;
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
  
  NSString *contactId = isEmptyString_Nd(_baseModel.contactId)?@"":_baseModel.contactId;
  NSString *nudgesName = isEmptyString_Nd(_baseModel.nudgesName)?@"":_baseModel.nudgesName;
  NSString *pageName = isEmptyString_Nd(_baseModel.pageName)?@"":_baseModel.pageName;
	
	
	// 回调
	if (_delegate && [_delegate conformsToProtocol:@protocol(AnnouncementEventDelegate)]) {
		if (_delegate && [_delegate respondsToSelector:@selector(AnnouncementShowEventByNudgesId:nudgesName:nudgesType:eventTypeId:contactId:campaignCode:batchId:source:pageName:)]) {
			[_delegate AnnouncementShowEventByNudgesId:_baseModel.nudgesId nudgesName:nudgesName nudgesType:_baseModel.nudgesType eventTypeId:@"" contactId:_baseModel.contactId campaignCode:_baseModel.campaignId batchId:@"" source:@"1" pageName:pageName];
		}
	}
	
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgesShowEvent",@"body":@{@"nudgesId":contactId,@"nudgesName":nudgesName,@"nudgesType":@(_baseModel.nudgesType),@"eventTypeId":@"onNudgesShow"}}];
  
  // 埋点发送通知给RN
  [[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeShow",@"body":@{@"nudgesId":@(_baseModel.nudgesId),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(_baseModel.campaignId),@"batchId":@"",@"source":@"1",@"pageName":pageName}}];
    
  // 显示后上报接口
  [[HJNudgesManager sharedInstance] nudgesContactRespByNudgesId:_baseModel.nudgesId contactId:_baseModel.contactId];
}

#pragma mark -- 构造nudges数据
- (void)constructsNudgesViewData:(NudgesBaseModel *)baseModel {
    // 定位要展示的view
//    UIView *view = [[NdHJIntroductManager sharedManager] getSubViewWithClassNameInViewController:baseModel.pageName viewClassName:@"UIView" index:0 inView:kAppDelegate.window findIndex:baseModel.findIndex];
//
//    if (!view) {
//        return;
//    }
    
    // 根据返回的findIndex判断是否nudges target
    __block UIView *view = nil;
    if (!isEmptyString_Nd(baseModel.findIndex)) {
        // 获取window 的nodel
//        UIViewController *VC = [self getCurrentVC];
        UIViewController *VC = [TKUtils topViewController];
        NodeModel *nodel = [[NdHJIntroductManager sharedManager] getWindowNode:[UIApplication sharedApplication].delegate.window inViewController:VC index:@""];
        
        __block BOOL isExist = NO;
        NSLog(@"baseModel.appExtInfoModel.accessibilityIdentifier:%@",baseModel.appExtInfoModel.accessibilityIdentifier);
        
        NSString *identifier = baseModel.appExtInfoModel.accessibilityIdentifier;
        NSString *stringWithoutSpace = [identifier stringByReplacingOccurrencesOfString:@" " withString:@""];
        stringWithoutSpace = [stringWithoutSpace stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        stringWithoutSpace = [stringWithoutSpace stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self getViewNodeModelByAccessibilityElement:stringWithoutSpace targetView:nodel block:^(NodeModel *nodel) {
            NSLog(@"halllo------%@",nodel.strAccessibilityIdentifier);
            view = nodel.targetView;
            // 判断当前view是否在屏幕中
            isExist = [TKUtils isDisplayedInScreen:view];
            if (isExist) {
                // 在当前屏幕范围中
            } else {
                // 不在当前屏幕中 跳过展示下一个nudges
                [[HJNudgesManager sharedInstance] showNextNudges];
                return;
            }
        }];
        
        if (!view || !isExist) {
            return;
        }
    }
    
    
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
    CGFloat height_image = 0; // 图片的高度
    CGFloat h_dissButton = 0;
    
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
    } else {
        [dissButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(customView.mas_top).offset(0);
            make.trailing.equalTo(customView.mas_trailing).offset(0);
            make.height.equalTo(@(0));
            make.width.equalTo(@(0));
        }];
    }
    
    // 判断图片相对文本的位置
    UIView *imgContentView = [[UIView alloc] init]; // 图片容器
    UILabel *titleLab = [[UILabel alloc] init]; // 标题
    UILabel *bodyLab = [[UILabel alloc] init]; // 文本
    KImagePositionType imagePosition = baseModel.imageModel.position;
    if (imagePosition == KImagePositionType_Top || imagePosition == KImagePositionType_none) {
        
        
        // 图片
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.contentMode = UIViewContentModeScaleToFill; // 按比例缩放并且填满view
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
                    make.top.equalTo(dissButton.mas_bottom).offset(paddingTop);
                }];
            } else {
                if (_baseModel.positionModel.position == KPosition_bottom || _baseModel.positionModel.position == 0) {
                    width_ShowImg = nWidth - Padding_Spacing * 2;
                }
                // 等比例缩放
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
//                    make.leading.equalTo(imgContentView.mas_leading).offset(paddingleft);
//                    make.trailing.equalTo(imgContentView.mas_trailing).offset(-paddingRight);
                    make.centerX.mas_equalTo(imgContentView.centerX);
                    make.width.equalTo(@(width_ShowImg));
                    make.top.equalTo(imgContentView.mas_top).offset(paddingTop);
                    make.bottom.equalTo(imgContentView.mas_bottom).offset(-paddingBottom);
                }];
            }
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
            height_title = labelsize.height;
            [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                make.top.equalTo(imgContentView.mas_bottom).offset(0);
                make.height.equalTo(@(labelsize.height));
            }];
            iViewCount = iViewCount + 1;

        } else {
            [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(customView.mas_leading).offset(0);
                make.trailing.equalTo(customView.mas_trailing).offset(0);
                make.top.equalTo(imgContentView.mas_bottom).offset(0);
                make.height.equalTo(@0);
            }];
        }
        
        
      
        


        
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
    }
    
    if (imagePosition == KImagePositionType_Bottom) {
        // 图片在文本下面
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
//            [titleLab sizeToFit];
//            CGSize labelsize =[titleLab sizeThatFits:CGSizeMake(nWidth, CGFLOAT_MAX)];
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
        
        // 图片
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.contentMode = UIViewContentModeScaleToFill; // 按比例缩放并且填满view
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
            
            // 图片在上下
            // 要显示的图片宽度
            CGFloat width_ShowImg = nWidth - Padding_Spacing * 2; // 图片宽度
            if (baseModel.imageModel.autoWidth) {
                // 等比例缩放
                h_imageView =  width_ShowImg * h_image / w_image;
                [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@(h_imageView));
                    make.width.equalTo(@(width_ShowImg));
                    make.centerX.mas_equalTo(customView.centerX);
                    make.top.equalTo(bodyLab.mas_bottom).offset(paddingTop);
                }];
            } else {
                if (_baseModel.positionModel.position == KPosition_bottom || _baseModel.positionModel.position == 0) {
                    width_ShowImg = nWidth - Padding_Spacing * 2;
                }
                // 等比例缩放
                h_imageView = (width_ShowImg * h_image) / w_image;
                // 容器高度
                [imgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@(h_imageView + paddingBottom + paddingTop));
                    make.leading.equalTo(customView.mas_leading).offset(0);
                    make.trailing.equalTo(customView.mas_trailing).offset(0);
                    make.top.equalTo(bodyLab.mas_bottom).offset(0);
                }];
                
                [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.height.equalTo(@(h_imageView));
                    make.leading.equalTo(imgContentView.mas_leading).offset(paddingleft);
                    make.trailing.equalTo(imgContentView.mas_trailing).offset(-paddingRight);
                    make.top.equalTo(imgContentView.mas_top).offset(paddingTop);
                    make.bottom.equalTo(imgContentView.mas_bottom).offset(-paddingBottom);
                }];
            }
            height_image = h_imageView + paddingBottom + paddingTop;
        } else {
            [imgContentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@0);
                make.leading.equalTo(customView.mas_leading);
                make.trailing.equalTo(customView.mas_trailing);
                make.top.equalTo(bodyLab.mas_bottom).offset(0);
            }];
        }
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
                            if (imagePosition == KImagePositionType_Top || imagePosition == KImagePositionType_none) {
                                // 图片在文本的上面
                                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                    make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                                    make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
                                    make.height.mas_equalTo(Button_height);
                                    make.width.mas_equalTo(titleSize.width);
                                }];
                            }
                            if (imagePosition == KImagePositionType_Bottom) {
                                // 图片在文本的下面
                                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                    make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                                    make.top.equalTo(imgContentView.mas_bottom).offset(View_Spacing);
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
                            if (imagePosition == KImagePositionType_Top || imagePosition == KImagePositionType_none) {
                                // 图片在文本上面
                                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                    make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                                    make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
                                    make.height.mas_equalTo(Button_height);
                                    make.width.mas_equalTo(titleSize.width);
                                }];
                            }
                            
                            if (imagePosition == KImagePositionType_Bottom) {
                                // 图片在文本下面
                                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                    make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                                    make.top.equalTo(imgContentView.mas_bottom).offset(View_Spacing);
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
                            if (imagePosition == KImagePositionType_Top || imagePosition == KImagePositionType_none) {
                                // 图片在文本上面
                                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                    make.centerX.mas_equalTo(customView.centerX);
                                    make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
                                    make.height.mas_equalTo(Button_height);
                                    make.width.mas_equalTo(titleSize.width);
                                }];
                            }
                            if (imagePosition == KImagePositionType_Bottom) {
                                // 图片在文本下面
                                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                    make.centerX.mas_equalTo(customView.centerX);
                                    make.top.equalTo(imgContentView.mas_bottom).offset(View_Spacing);
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
                        if (imagePosition == KImagePositionType_Top || imagePosition == KImagePositionType_none) {
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                                make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                                make.top.equalTo(bodyLab.mas_bottom).offset(View_Spacing);
                                make.height.mas_equalTo(Button_height);
                            }];
                        }
                        if (imagePosition == KImagePositionType_Bottom) {
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.leading.equalTo(customView.mas_leading).offset(Padding_Spacing);
                                make.trailing.equalTo(customView.mas_trailing).offset(-Padding_Spacing);
                                make.top.equalTo(imgContentView.mas_bottom).offset(View_Spacing);
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
    CGFloat t_height = h_dissButton + height_image + height_title + h_body + [baseModel.buttonsModel.buttonList count] * Button_height + iViewCount *Padding_Spacing + Bottom_Spacing + Padding_Spacing;
    customView.frame = CGRectMake(0, 0, nWidth, t_height);
    self.customView = customView;
    [self showNudgesByWidth:nWidth height:t_height];
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
    [self stopCurrentPlayingView]; // 停止播放器
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
