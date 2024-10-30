//
//  NudgesModel.h
//  DITOApp
//
//  Created by 李标 on 2022/5/16.
//  model 原始数据源

#import <Foundation/Foundation.h>
#import "Nudges.h"
#import <FMDB/FMResultSet.h>
//#import "FMResultSet.h"

NS_ASSUME_NONNULL_BEGIN

@interface NudgesModel : NSObject

/// 工单ID
@property (nonatomic, copy) NSString *contactId;
/// 活动ID
@property (nonatomic, assign) NSInteger campaignId;
/// 流程ID
@property (nonatomic, assign) NSInteger flowId;
/// 环节ID
@property (nonatomic, assign) NSUInteger processId;
/// 活动实效时间
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
@property (nonatomic, strong) NSString *ownProp;
/// 位置
@property (nonatomic, strong) NSString *position;
/// nudges元素定位需要的信息
@property (nonatomic, strong) NSString *appExtInfo;
/// 背景
@property (nonatomic, strong) NSString *background;
/// 边框
@property (nonatomic, strong) NSString *border;
/// 蒙层
@property (nonatomic, strong) NSString *backdrop;
/// 关闭方式
@property (nonatomic, strong) NSString *dismiss;
/// title
@property (nonatomic, strong) NSString *title;
/// body
@property (nonatomic, strong) NSString *body;
/// 图片
@property (nonatomic, strong) NSString *image;
/// 视频
@property (nonatomic, strong) NSString *video;
/// 按钮
@property (nonatomic, strong) NSString *buttons;
/// 关闭按钮
@property (nonatomic, strong) NSString *dismissButton;

#pragma mark -- 扩展字段
/// 是否已经显示过该nudges
@property (nonatomic, assign) NSInteger isShow;

- (id)initWithResultSet:(FMResultSet *)rs;

- (id)initWithMsgDic:(NSDictionary *)rDic;
@end

NS_ASSUME_NONNULL_END
