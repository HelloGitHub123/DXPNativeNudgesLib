//
//  NdIMDBManager.h
//  IMDemo
//
//  Created by mac on 2020/6/9.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "FMDatabaseQueue.h"
//#import "FMDatabase.h"
#import <FMDB/FMDatabaseQueue.h>
#import <FMDB/FMDatabase.h>


#define T_Nudges_DB_NAME          @"T_Nudges_DB.db"  //数据库名称

NS_ASSUME_NONNULL_BEGIN

@interface NdIMDBManager : NSObject

+ (FMDatabaseQueue *)getDBQueue;

+ (void)initDBSettings;

@end

NS_ASSUME_NONNULL_END
