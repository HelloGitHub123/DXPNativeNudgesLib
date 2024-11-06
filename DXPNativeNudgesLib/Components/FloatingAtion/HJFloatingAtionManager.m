//
//  HJFloatingAtionManager.m
//  DITOApp
//
//  Created by 李标 on 2022/8/9.
//

#import "HJFloatingAtionManager.h"
#import "NdHJNudgesDBManager.h"
#import "NdHJIntroductManager.h"
#import "UIView+NdAddGradualLayer.h"
#import "UIImageView+ZFCache.h"
#import "ZFUtilities.h"
#import "HJNudgesManager.h"
#import "SuspensionButton.h" //悬浮按钮
#import <DXPFontManagerLib/FontManager.h>

#define View_Spacing  10
#define Button_height 43

static HJFloatingAtionManager *manager = nil;

@interface HJFloatingAtionManager () {
    
}
@property(nonatomic, strong) SuspensionButton *suspensionButton;
@end

@implementation HJFloatingAtionManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HJFloatingAtionManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setBaseModel:(NudgesBaseModel *)baseModel {
    _baseModel = baseModel;
    [self constructsNudgesViewData:baseModel];
}

- (void)setNudgesModel:(NudgesModel *)nudgesModel {
    _nudgesModel = nudgesModel;
}

#pragma mark -- 方法
- (void)suspensionButtonClick:(id)sender {
	ButtonsModel *buttonsModel = _baseModel.buttonsModel;
	NSArray<ButtonItem *> *buttonItemList = buttonsModel.buttonList;
	if (!IsArrEmpty_Nd(buttonItemList)) {
		ButtonItem *item = [buttonItemList objectAtIndex:0];
		BOOL isClose = NO;// 是否关闭按钮
		if (KButtonsActionType_CloseNudges == item.action.type) {
			// 关闭Nudges
			isClose = YES;
		} else if (KBorderStyle_LaunchURL == item.action.type) {
			// 内部跳转
		} else if (KBorderStyle_InvokeAction == item.action.type) {
			// 调用方法
		}
		
		[self removeNudges];
		[[HJNudgesManager sharedInstance] showNextNudges];
		
		// 回调
		NSString *contactId = isEmptyString_Nd(_baseModel.contactId)?@"":_baseModel.contactId;
		NSString *nudgesName = isEmptyString_Nd(_baseModel.nudgesName)?@"":_baseModel.nudgesName;
		NSString *pageName = isEmptyString_Nd(_baseModel.pageName)?@"":_baseModel.pageName;
		NSString *text = isEmptyString_Nd(item.text.content)?@"":item.text.content;
		NSString *url = isEmptyString_Nd(item.action.url)?@"":item.action.url;
		NSString *invokeAction = isEmptyString_Nd(item.action.invokeAction)?@"":item.action.invokeAction;
	
		if (_delegate && [_delegate conformsToProtocol:@protocol(FloatingAtionEventDelegate)]) {
			if (_delegate && [_delegate respondsToSelector:@selector(FloatingAtionClickEventByActionModel:isClose:buttonName:nudgeModel:)]) {
				[_delegate FloatingAtionClickEventByActionModel:item.action isClose:isClose buttonName:text nudgeModel:_baseModel];
			}
		}
		
		// 埋点发送通知给RN
		[[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeClick",@"body":@{@"nudgesId":@(_baseModel.nudgesId),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(_baseModel.campaignId),@"batchId":@"0",@"jumpUrl":url,@"invokeAction":invokeAction,@"isClose":@(isClose),@"buttonName":text,@"source":@"1",@"pageName":pageName}}];
	}
}

// 移除当前的页面的浮点按钮
- (void)removeCurrentFloatingAtion {
    if ([_baseModel.ownPropModel.displayOption isEqualToString:@"C"] || isEmptyString_Nd(_baseModel.ownPropModel.displayOption)) {
        [self removeNudges];
    }
}

- (void)removeNudges {
    if (self.suspensionButton) {
        [self.suspensionButton removeFromSuperview];
        self.suspensionButton = nil;
    }
}

#pragma mark -- 构造nudges数据
- (void)constructsNudgesViewData:(NudgesBaseModel *)baseModel {
    
    // 判断是否当前配置的页面
//    UIViewController *currentVC = [[NdHJIntroductManager sharedManager] getCurrentVC];
    UIViewController *currentVC = [TKUtils topViewController];
    NSString *vcString = NSStringFromClass([currentVC class]);
    if (![baseModel.pageName isEqualToString:vcString]) {
        return;
    }
    
    // 高度
    CGFloat viewHeight = 0;
    
    ButtonsModel *buttonsModel = baseModel.buttonsModel;
    NSArray<ButtonItem *> *buttonItemList = buttonsModel.buttonList;
    if (!IsArrEmpty_Nd(buttonItemList)) {
        ButtonItem *item = [buttonItemList objectAtIndex:0];
        ButtonStyle *style = item.buttonStyle;
        
        __block NSInteger x_position = 20;
        if (isEmptyString_Nd(buttonsModel.layout.align) || [buttonsModel.layout.align isEqualToString:@"left"]) {
            // 左边 默认
            x_position = 20;
        }
        
        // display option Float Action显示方式
        if ([baseModel.ownPropModel.displayOption isEqualToString:@"C"] || isEmptyString_Nd(baseModel.ownPropModel.displayOption)) {
            // 默认当前页面
//            UIViewController *currentVC = [[NdHJIntroductManager sharedManager] getCurrentVC];
            UIViewController *currentVC = [TKUtils topViewController];
            [currentVC.view addSubview:self.suspensionButton];
//            [kAppDelegate.window addSubview:self.suspensionButton];
        }
        if ([baseModel.ownPropModel.displayOption isEqualToString:@"A"]) {
            // 所有页面
            [[UIApplication sharedApplication].delegate.window addSubview:self.suspensionButton];
        }
        
        // 填充色
        NSString *bgroundColor = @"2D3040";
        if (!isEmptyString_Nd(style.fillColor)) {
            bgroundColor = style.fillColor;
        }
//        self.suspensionButton.backgroundColor = [TKUtils GetColor:bgroundColor alpha:1.0];
        self.suspensionButton.backgroundColor = [UIColor colorWithHexString:bgroundColor];
        
        // 类型
        if (style.fillType == KButtonsFillType_TextOnley) {
            // 单文本
          HJText *text = item.text;
          CGSize size = [text.content sizeWithAttributes:@{NSFontAttributeName:[FontManager setNormalFontSize:(text.fontSize == 0)?14:text.fontSize]}];
            CGFloat width = ceil(size.width); // 计算文本的宽度
            CGFloat height = ceil(size.height);
            [self.suspensionButton setTitle:isEmptyString_Nd(text.content)?@"":text.content forState:UIControlStateNormal];
            self.suspensionButton.titleLabel.font = [TKUtils setButtonFontWithSize:text.fontSize familyName:@"" bold:text.isBold itatic:text.isItalic weight:0];
            // 下划线
            if (text.hasDecoration) {
                NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:text.content];
                NSRange contentRange = {0,[content length]};
                [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
                self.suspensionButton.titleLabel.attributedText = content;
            }
            [self.suspensionButton setTitleColor:[TKUtils GetColor:text.color alpha:1.0]forState:UIControlStateNormal];
            // button 宽度
            NSInteger w_button = 12+width+12;
            NSInteger h_heigth = 12 +height+12;
            
            if ([buttonsModel.layout.align isEqualToString:@"middle"]) {
                // 中间
                x_position = kScreenWidth / 2 - w_button / 2;
            }
            if ([buttonsModel.layout.align isEqualToString:@"right"]) {
                // 右边
                x_position = kScreenWidth - w_button - 20;  // 屏幕宽度 - 按钮宽度 - 距离屏幕右边的距离
            }
            [self.suspensionButton setFrame:CGRectMake(x_position, kScreenHeight - TAB_BAR_HEIGHT_Nd - h_heigth, w_button, h_heigth)];
            
            viewHeight = h_heigth;
        }
        if (style.fillType == KButtonsFillType_Icon) {
            // 单icon
            //            [self.suspensionButton yy_setImageWithURL:[NSURL URLWithString:style.icon] forState:0 placeholder:[UIImage imageNamed:@""] options:0 completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            //            }];
            //            NSInteger w_imge = 8+image.size.width+8;
            //            NSInteger h_imge = 8+image.size.height+8;
            
            NSData *data;
            if ([style.icon containsString:@"https"] || [style.icon containsString:@"http"]) {
                data = [NSData dataWithContentsOfURL:[NSURL URLWithString:style.icon]];
            } else {
                NSString *baseStr = [style.icon substringFromIndex:22];
                data = [NSData dataWithBase64EncodedString:baseStr];
            }
            UIImage *image = [UIImage imageWithData:data];
//            NSInteger h_image = 8+image.size.height+8;
//            NSInteger w_image = 8+image.size.width+8;
            NSInteger h_image = 40;
            NSInteger w_image = 40;
            
            if ([buttonsModel.layout.align isEqualToString:@"middle"]) {
                // 中间
                x_position = kScreenWidth / 2 - w_image / 2;
            }
            if ([buttonsModel.layout.align isEqualToString:@"right"]) {
                // 右边
                x_position = kScreenWidth - w_image - 20;  // 屏幕宽度 - 按钮宽度 - 距离屏幕右边的距离
            }
            [self.suspensionButton setImage:image forState:UIControlStateNormal];
            [self.suspensionButton setFrame:CGRectMake(x_position, kScreenHeight - TAB_BAR_HEIGHT_Nd - h_image, w_image, h_image)];
            //                self.suspensionButton.layer.cornerRadius = (8+image.size.width+8)/2;
            
            viewHeight = h_image;
        }
        if (style.fillType == KButtonsFillType_IconText) {
            // 文本 + icon
            HJText *text = item.text;
            CGSize size = [text.content sizeWithAttributes:@{NSFontAttributeName:[FontManager setNormalFontSize:(text.fontSize == 0)?14:text.fontSize]}];
            CGFloat width = ceil(size.width); // 计算文本的宽度
            CGFloat height = ceil(size.height);
            
            CGFloat text_width = 5+width+5;
            CGFloat text_height = 5+height+5;
            
            [self.suspensionButton setTitle:isEmptyString_Nd(text.content)?@"":text.content forState:UIControlStateNormal];
            self.suspensionButton.titleLabel.font = [TKUtils setButtonFontWithSize:text.fontSize familyName:@"" bold:text.isBold itatic:text.isItalic weight:0];
            if (text.hasDecoration) {
                NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:text.content];
                NSRange contentRange = {0,[content length]};
                [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
                self.suspensionButton.titleLabel.attributedText = content;
            }
            [self.suspensionButton setTitleColor:[TKUtils GetColor:text.color alpha:1.0]forState:UIControlStateNormal];
            //            [self.suspensionButton yy_setImageWithURL:[NSURL URLWithString:style.icon] forState:0 placeholder:[UIImage imageNamed:@""] options:0 completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            //            }];
                        // 计算图片的高度 和 宽度
            //            CGSize imageSize = [UIImage getImageSizeWithURL:[NSURL URLWithString:style.icon]];

            
            NSData *data;
            if ([style.icon containsString:@"https"] || [style.icon containsString:@"http"]) {
                data = [NSData dataWithContentsOfURL:[NSURL URLWithString:style.icon]];
            } else {
                NSString *baseStr = [style.icon substringFromIndex:22];
                data = [NSData dataWithBase64EncodedString:baseStr];
            }
            UIImage *image = [UIImage imageWithData:data];
            //            NSInteger h_image = 8+image.size.height+8;
                        NSInteger w_image = 8+image.size.width+8;
            NSInteger h_image = 40;
//            NSInteger w_image = 40;
        
            if ([buttonsModel.layout.align isEqualToString:@"middle"]) {
                // 中间
                x_position = kScreenWidth / 2 - (text_width + w_image) / 2;
            }
            if ([buttonsModel.layout.align isEqualToString:@"right"]) {
                // 右边
                x_position = kScreenWidth - (text_width + w_image) - 20;  // 屏幕宽度 - 按钮宽度 - 距离屏幕右边的距离
            }
            
            [self.suspensionButton setImage:image forState:UIControlStateNormal];
            [self.suspensionButton setFrame:CGRectMake(x_position, kScreenHeight - TAB_BAR_HEIGHT_Nd - h_image, text_width + w_image, h_image)];
            //                self.suspensionButton.layer.cornerRadius = (8+image.size.width+8)/2;
//            [self.suspensionButton setTitleEdgeInsets:UIEdgeInsetsMake(8, -self.suspensionButton.imageView.bounds.size.width + 34, 8, 0)];
            [self.suspensionButton setTitleEdgeInsets:UIEdgeInsetsMake(8, 20, 8, 0)];
            [self.suspensionButton setImageEdgeInsets:UIEdgeInsetsMake(10, 5, 10, w_image + 8)];
            
            viewHeight = h_image;
        }

        
        // 圆角
        //        NSInteger iConer = 1;
        //        if (style.radiusConfigType == KRadiusConfigType_all) {
        // 全边框圆角
        NSInteger iConer = [style.all intValue];
        if (iConer == 0) {
            iConer = 1;
        }
        if (iConer > viewHeight/2) {
            iConer = viewHeight/2;
        }
        
        //        }
        self.suspensionButton.layer.cornerRadius = iConer;

        
        // 更新数据库nudges显示状态
        if (_nudgesModel) {
            [NdHJNudgesDBManager updateNudgesIsShowWithNudgesId:baseModel.nudgesId model:_nudgesModel];
        }
        
        // 显示后上报接口
//        [[HJNudgesManager sharedInstance] nudgesContactRespByNudgesId:baseModel.nudgesId contactId:baseModel.contactId];
      
      
      NSString *contactId = isEmptyString_Nd(_baseModel.contactId)?@"":_baseModel.contactId;
      NSString *nudgesName = isEmptyString_Nd(_baseModel.nudgesName)?@"":_baseModel.nudgesName;
      NSString *pageName = isEmptyString_Nd(_baseModel.pageName)?@"":_baseModel.pageName;
		
		
		// 显示回调
		if (_delegate && [_delegate conformsToProtocol:@protocol(FloatingAtionEventDelegate)]) {
			if (_delegate && [_delegate respondsToSelector:@selector(FloatingAtionShowEventByNudgesModel:batchId:source:)]) {
				[_delegate FloatingAtionShowEventByNudgesModel:baseModel batchId:@"0" source:@"1"];
			}
		}
		
		// 埋点发送通知给RN
		[[NSNotificationCenter defaultCenter] postNotificationName:@"start_event_notification" object:nil userInfo:@{@"eventName":@"NudgeShow",@"body":@{@"nudgesId":@(baseModel.nudgesId),@"nudgesType":@(baseModel.nudgesType),@"nudgesName":nudgesName,@"contactId":contactId,@"campaignCode":@(baseModel.campaignId),@"batchId":@"0",@"source":@"1",@"pageName":pageName}}];
    }
}

#pragma mark -- lazy load
- (SuspensionButton *)suspensionButton {
    if(_suspensionButton == nil) {
        _suspensionButton = [SuspensionButton buttonWithType:UIButtonTypeCustom];
        _suspensionButton.layer.masksToBounds = YES;
        _suspensionButton.MoveEnable = YES;
        [_suspensionButton addTarget:self action:@selector(suspensionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _suspensionButton;
}

@end
