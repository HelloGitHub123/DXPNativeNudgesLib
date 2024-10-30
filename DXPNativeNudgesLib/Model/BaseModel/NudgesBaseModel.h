//
//  NudgesBaseModel.h
//  DITOApp
//
//  Created by 李标 on 2022/5/12.
//  基类Model

#import <Foundation/Foundation.h>
#import "Nudges.h"
#import "NudgesModel.h"
#import "PositionModel.h"
#import "BackgroundModel.h"
#import "BorderModel.h"
#import "BackdropModel.h"
#import "TitleModel.h"
#import "BodyModel.h"
#import "ImageModel.h"
#import "VideoModel.h"
#import "ButtonsModel.h"
#import "DismissButtonModel.h"
#import "AppExtInfoModel.h"
#import "OwnPropModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NudgesBaseModel : NdHJHttpModel

/// 工单ID
@property (nonatomic, copy) NSString *contactId;
/// 活动ID
@property (nonatomic, assign) NSInteger campaignId;
/// 流程ID
@property (nonatomic, assign) NSInteger flowId;
/// 环节ID
@property (nonatomic, assign) NSInteger processId;
/// 活动失效时间
@property (nonatomic, strong) NSString *campaignExpDate;
/// nudgesId，对应创意ID
@property (nonatomic, assign) NSInteger nudgesId;
/// nudges名称
@property (nonatomic, strong) NSString *nudgesName;
/// 剩余展示次数，默认为1
@property (nonatomic, assign) NSInteger remainTimes;
/// 接触渠道编码
@property (nonatomic, strong) NSString *channelCode;
/// 配置时的设备屏幕高度
@property (nonatomic, assign) CGFloat height;
/// 配置时的设备屏幕宽度
@property (nonatomic, assign) CGFloat width;
/// 运营位编码
@property (nonatomic, strong) NSString *adviceCode;
/// nudges类型
@property (nonatomic, assign) KNudgesType nudgesType;
/// 页面名称
@property (nonatomic, strong) NSString *pageName;
/// 元素路径
@property (nonatomic, strong) NSString *findIndex;
/// 自有属性
@property (nonatomic, strong) OwnPropModel *ownPropModel;
/// 位置
@property (nonatomic, strong) PositionModel *positionModel;
/// nudges元素定位需要的信息
@property (nonatomic, strong) AppExtInfoModel *appExtInfoModel;
/// 背景
@property (nonatomic, strong) BackgroundModel *backgroundModel;
/// 边框
@property (nonatomic, strong) BorderModel *borderModel;
/// 蒙层
@property (nonatomic, strong) BackdropModel *backdropModel;
///  关闭方式 值可能性 如下
///  A   Add close button
///  B  Close automatically in 5 seconds
///  C  Close when user clicks anywhere outside the nudges
@property (nonatomic, strong) NSString *dismiss;
/// 标题
@property (nonatomic, strong) TitleModel *titleModel;
/// 内容
@property (nonatomic, strong) BodyModel *bodyModel;
/// 图片
@property (nonatomic, strong) ImageModel *imageModel;
/// 视频
@property (nonatomic, strong) VideoModel *video;
/// 按钮
@property (nonatomic, strong) ButtonsModel *buttonsModel;
/// 关闭按钮
@property (nonatomic, strong) DismissButtonModel *dismissButtonModel;

#pragma mark -- 方法
/// eg: 封装model
/// @param rDic 字典类型 原始数据源
- (id)initWithMsgDic:(NSDictionary *)rDic;
/// eg: 封装model
/// @param model NudgesModel类型 原始数据源
- (id)initWithMsgModel:(NudgesModel *)model;

@end

NS_ASSUME_NONNULL_END
