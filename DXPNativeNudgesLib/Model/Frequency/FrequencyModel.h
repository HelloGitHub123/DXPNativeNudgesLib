//
//  FrequencyModel.h
//  DITOApp
//
//  Created by 李标 on 2022/7/11.
//  频次控制 model

#import <Foundation/Foundation.h>
#import <FMDB/FMResultSet.h>


//@class FrequencyItemModel;
NS_ASSUME_NONNULL_BEGIN

@interface FrequencyModel : NSObject

/// 重复间隔
@property (nonatomic, assign) NSInteger repeatInterval;
/// session times
@property (nonatomic, assign) NSInteger sessionTimes;
/// hour times
@property (nonatomic, assign) NSInteger hourTimes;
/// day times
@property (nonatomic, assign) NSInteger dayTimes;
/// week times
@property (nonatomic, assign) NSInteger weekTimes;

///  频次列表
//@property (nonatomic, strong) NSArray <FrequencyItemModel *>*frequencyList;

/// eg: 封装model
/// @param rDic 字典类型 原始数据源
- (id)initWithMsgDic:(NSDictionary *)rDic;
/// eg: 数据库结果集
- (id)initWithResultSet:(FMResultSet *)rs;
@end


//@interface FrequencyItemModel : NSObject
//
///// 频次类型：可能值 PERSESSION、PERWEEKPERDAY、PERHOUR、
//@property (nonatomic, copy) NSString *frequencyControl;
///// 一个周期内的展示次数
//@property (nonatomic, assign) NSInteger times;
//@end

NS_ASSUME_NONNULL_END
