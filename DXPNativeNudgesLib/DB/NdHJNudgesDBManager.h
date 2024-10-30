//
//  NdIMChatDBManager.h
//  IMDemo
//
//  Created by mac on 2020/6/9.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NudgesBaseModel.h"
#import "NudgesModel.h"
#import "FrequencyModel.h"

@interface NdHJNudgesDBManager : NSObject

/// eg: 插入Nudges 数据
/// @param nudgesId 对应创意ID
/// @param model (NudgesModel)数据模型
/// @return 返回成功 \ 失败
+ (BOOL)insertNudgesWithNudgesId:(NSInteger)nudgesId model:(NudgesModel *)model;

/// eg:  查找对应的Nudges 数据
/// @param nudgesId 对应创意ID
/// @param campaignId 活动ID
/// @return Nudges 对象集合<NudgesModel *>
+ (NSMutableArray *)selectNudgesDBWithNudgesId:(NSInteger)nudgesId campaignId:(NSInteger)campaignId;

/// eg:根据对应的pagename查找对应可展示的Nudges 数据
/// @param pageName 页面名称
/// @return Nudges 对象集合<NudgesModel *>
+ (NSMutableArray *)selectNudgesDBWithPageName:(NSString *)pageName;

/// eg: 更新对应的Nudges 数据
/// @param nudgesId 对应创意ID
/// @param model (NudgesModel)数据模型
+ (void)updateNudgesWithNudgesId:(NSInteger)nudgesId model:(NudgesModel *)model;

/// eg: 更新对应的Nudges 数据
/// @param nudgesId 对应创意ID
//- (void)updateNudgesWithCampaignId:(NSInteger)nudgesId model:(NudgesModel *)model;


/// eg: 更新对应的Nudges 数据 --- 是否展示过
/// @param nudgesId 对应创意ID
/// @param model (NudgesModel)数据模型
+ (void)updateNudgesIsShowWithNudgesId:(NSInteger)nudgesId model:(NudgesModel *)model;

/// eg: 删除Nudges表全部数据
+ (void)deleteTableAllDataForNudges;

//---------------------------------------- Frequency 频次---------------------------------------------//
#pragma mark -- 频次
/// eg: 删除频次表全部数据
+ (void)deleteTableAllDataForFrequency;

/// eg: 初始化频次数据表数据
/// @param currentTime 当前时间
+ (BOOL)initFrequency:(NSString *)currentTime;

/// eg: 查询 Frequency 数据
+ (FrequencyModel *)selectFrequencyData;

/// eg: 查询频次 时间
+ (NSString *)selectFrequencyLastTime;

/// eg: 更新repeatInterval数据 + 1
+ (void)updateFrequencyWithRepeatInterval;

/// eg: 重置repeatInterval为0
//+ (void)clearFrequencyWithRepeatInterval;

/// eg: 更新session times数据 + 1
+ (void)updateFrequencyWithSessionTimes;

/// eg: 重置session timesl为0
//+ (void)clearFrequencyWithSessionTimes;

/// eg: 更新day times数据 + 1
+ (void)updateFrequencyWithDayTimes;

/// eg: 重置day times为0
+ (void)clearFrequencyWithDayTimes;

/// eg: 更新week times数据 + 1
+ (void)updateFrequencyWithWeekTimes;

/// eg: 重置week times为0
+ (void)clearFrequencyWithWeekTimes;

/// eg: 更新hour times数据 + 1
+ (void)updateFrequencyWithHourTimes;

/// eg: 重置hour times为0
+ (void)clearFrequencyWithHourTimes;

/// eg: 更新时间
/// @param currentTime 当前时间
+ (void)updateFrequencyWithLastTime:(NSString *)currentTime;
@end
