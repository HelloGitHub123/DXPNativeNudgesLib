//
//  NdIMChatDBManager.m
//  IMDemo
//
//  Created by mac on 2020/6/9.
//  Copyright © 2020 mac. All rights reserved.
//

#import "NdHJNudgesDBManager.h"
#import "NdIMDBManager.h"
#import <FMDB/FMResultSet.h>

@implementation NdHJNudgesDBManager

// 删除表全部数据
+ (void)deleteTableAllDataForNudges {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];
    [dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from T_DB_Nudges"];
        if (!result) {
            HJLog(@"delete DB failed");
        }
     }];
}

// 插入Nudges 数据 原始数据源
+ (BOOL)insertNudgesWithNudgesId:(NSInteger)nudgesId model:(NudgesModel *)model {
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];
    __block BOOL result = NO;
    [dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"REPLACE INTO T_DB_Nudges(contactId ,campaignId, flowId, processId, campaignExpDate, nudgesId, nudgesName, remainTimes, channelCode, height, width, adviceCode, nudgesType, pageName, findIndex, ownProp ,position, appExtInfo, background, border, backdrop, dismiss, title, body, image, video, buttons, dismissButton, isShow) VALUES  (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?)" , model.contactId, @(model.campaignId), @(model.flowId), @(model.processId), model.campaignExpDate, @(nudgesId), model.nudgesName, @(model.remainTimes), model.channelCode, @(model.height), @(model.width), model.adviceCode, @(model.nudgesType), model.pageName, model.findIndex, model.ownProp, model.position, model.appExtInfo, model.background, model.border, model.backdrop, model.dismiss, model.title, model.body, model.image, model.video, model.buttons, model.dismissButton, @(0)];

        if (!result) {
            HJLog(@"insert DB failed");
        }
     }];
    return result;
}

// 更新对应的Nudges 数据
+ (void)updateNudgesWithNudgesId:(NSInteger)nudgesId model:(NudgesModel *)model {
   __block BOOL result = NO;
   FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];
   
   [dataQueue inDatabase:^(FMDatabase *db) {
       NSString *sql = [NSString stringWithFormat:@"UPDATE T_DB_Nudges SET contactId = '%@', campaignId = '%@', flowId = '%@', processId = '%@', campaignExpDate = '%@', nudgesName = '%@', remainTimes = '%@', channelCode = '%@', height = '%@', width = '%@', adviceCode = '%@', nudgesType = '%ld', pageName = '%@', findIndex = '%@', ownProp = '%@' ,position = '%@', appExtInfo = '%@', background = '%@', border = '%@', backdrop = '%@', dismiss = '%@', title = '%@', body = '%@', image = '%@', video = '%@', buttons = '%@', dismissButton = '%@'  WHERE nudgesId ='%@' ", model.contactId, @(model.campaignId), @(model.flowId), @(model.processId) ,model.campaignExpDate ,model.nudgesName, @(model.remainTimes), model.channelCode, @(model.height), @(model.width), model.adviceCode, model.nudgesType, model.pageName, model.findIndex, model.ownProp, model.position, model.appExtInfo, model.background, model.border, model.backdrop, model.dismiss, model.title, model.body, model.image, model.video, model.buttons, model.dismissButton, @(model.nudgesId)];

       result = [db executeUpdate:sql];
       if (!result) {
           HJLog(@"update DB failed");
       }
       
       //       FMResultSet *rs = [db executeQuery:sql];
//       while ([rs next]) {
//           result = YES;
//       }
//       [rs close];
   }];
}

// 查找对应的Nudges 数据
+ (NSMutableArray *)selectNudgesDBWithNudgesId:(NSInteger)nudgesId campaignId:(NSInteger)campaignId {
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM %@ where nudgesId ='%ld' and campaignId = '%ld' and isShow = 0 and remainTimes > 0", @"T_DB_Nudges",(long)nudgesId, (long)campaignId];

        FMResultSet *rs = [db executeQuery:findSql];

        while ([rs next]) {
            NudgesModel *model = [[NudgesModel alloc] initWithResultSet:rs];
            [resultArray addObject:model];
        }

        if (rs) {
            [rs close];
        }
     }];

    return resultArray;
}

// 根据对应的pagename查找对应的可展示的Nudges 数据
+ (NSMutableArray *)selectNudgesDBWithPageName:(NSString *)pageName {
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM T_DB_Nudges where pageName ='%@' and isShow = 0 and remainTimes > 0" ,pageName];

        FMResultSet *rs = [db executeQuery:findSql];

        while ([rs next]){
            NudgesModel *model = [[NudgesModel alloc] initWithResultSet:rs];
            [resultArray addObject:model];
        }

        if (rs) {
            [rs close];
        }
     }];

    return resultArray;
}

// 更新对应的Nudges 数据
+ (void)updateNudgesIsShowWithNudgesId:(NSInteger)nudgesId model:(NudgesModel *)model {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];
    
    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"UPDATE T_DB_Nudges SET isShow = 1 WHERE nudgesId ='%ld' ", (long)model.nudgesId];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
    }];
}

#pragma mark -- 频次
// 删除频次表全部数据
+ (void)deleteTableAllDataForFrequency {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];
    [dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from T_DB_Frequency"];
        if (!result) {
            HJLog(@"delete DB failed");
        }
     }];
}

/// eg: 初始化频次数据表数据
+ (BOOL)initFrequency:(NSString *)currentTime {
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];
    __block BOOL result = NO;
    [dataQueue inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"REPLACE INTO T_DB_Frequency(repeatInterval , sessionTimes , hourTimes, dayTimes, weekTimes, lastTime) VALUES (?, ?, ?, ?, ?, ?)" , @(1), @(0), @(0), @(0), @(0), currentTime];

        if (!result) {
            HJLog(@"insert DB failed");
        }
     }];
    return result;
}

/// eg: 查询 Frequency 数据
+ (FrequencyModel *)selectFrequencyData {
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];
    __block NSMutableArray *resultArray = [[NSMutableArray alloc]init];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *findSql = [NSString stringWithFormat:@"SELECT * FROM T_DB_Frequency"];

        FMResultSet *rs = [db executeQuery:findSql];

        while ([rs next]) {
            FrequencyModel *model = [[FrequencyModel alloc] initWithResultSet:rs];
            [resultArray addObject:model];
        }

        if (rs) {
            [rs close];
        }
     }];
    
//    if (IsArrEmpty(resultArray)) {
//        return nil;
//    }

    return resultArray[0];
}

/// eg: 查询频次 时间
+ (NSString *)selectFrequencyLastTime {
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];
    __block NSString *lastTime = @"";

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *findSql = [NSString stringWithFormat:@"SELECT lastTime FROM T_DB_Frequency"];

        FMResultSet *rs = [db executeQuery:findSql];

        while ([rs next]) {
            lastTime = [rs stringForColumn:@"lastTime"];
        }

        if (rs) {
            [rs close];
        }
     }];

    return lastTime;
}

/// eg: 更新数据
//+ (void)updateFrequencyWithModel:(FrequencyModel *)model {
//    __block BOOL result = NO;
//    FMDatabaseQueue *dataQueue = [IMDBManager getDBQueue];
//
//    [dataQueue inDatabase:^(FMDatabase *db) {
//        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set repeatInterval = '%@', sessionTimes = '%@', hourTimes = '%@', dayTimes = '%@', weekTimes = '%@'", @(model.repeatInterval), @(model.sessionTimes), @(model.hourTimes), @(model.dayTimes), @(model.weekTimes)];
//
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
//    }];
//}

/// eg: 更新lastTime 时间
+ (void)updateFrequencyWithLastTime:(NSString *)currentTime {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set lastTime = '%@'", currentTime];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
    }];
}


/// eg: 更新repeatInterval数据 +1
+ (void)updateFrequencyWithRepeatInterval {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set repeatInterval = repeatInterval + 1"];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
    }];
}

/// eg: 重置repeatInterval为0
+ (void)clearFrequencyWithRepeatInterval {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set repeatInterval = 0"];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
    }];
}

/// eg: 更新session times数据 +1
+ (void)updateFrequencyWithSessionTimes {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set sessionTimes = sessionTimes + 1"];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
    }];
}

/// eg: 重置session timesl为0
+ (void)clearFrequencyWithSessionTimes {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set sessionTimes = 0"];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
    }];
}

/// eg: 更新day times数据 +1
+ (void)updateFrequencyWithDayTimes {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set dayTimes = dayTimes + 1"];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
    }];
}

/// eg: 重置day times为0
+ (void)clearFrequencyWithDayTimes {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set dayTimes = 0"];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
    }];
}

/// eg: 更新week times数据 +1
+ (void)updateFrequencyWithWeekTimes {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set weekTimes = weekTimes + 1"];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
    }];
}

/// eg: 重置week times为0
+ (void)clearFrequencyWithWeekTimes {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set weekTimes = 0"];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
    }];
}

/// eg: 更新hour times数据 +1
+ (void)updateFrequencyWithHourTimes {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set hourTimes = hourTimes + 1"];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
    }];
}

/// eg: 重置hour times为0
+ (void)clearFrequencyWithHourTimes {
    __block BOOL result = NO;
    FMDatabaseQueue *dataQueue = [NdIMDBManager getDBQueue];

    [dataQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update T_DB_Frequency set hourTimes = 0"];
        result = [db executeUpdate:sql];
        if (!result) {
            HJLog(@"update DB failed");
        }
//        FMResultSet *rs = [db executeQuery:sql];
//        while ([rs next]) {
//            result = YES;
//        }
//        [rs close];
    }];
}

@end
