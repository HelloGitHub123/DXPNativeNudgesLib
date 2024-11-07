//
//  NdIMDBManager.m
//  IMDemo
//
//  Created by mac on 2020/6/9.
//  Copyright © 2020 mac. All rights reserved.
//

#import "NdIMDBManager.h"
#import "NdFMDBMigrationManager.h"

static FMDatabaseQueue *dbQueue;

@implementation NdIMDBManager

+ (void)initCoreBizDBMigrationManagerSetting{
    NSBundle *CoreBizBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"NdCoreBizDBMigrationManager" ofType:@"bundle"]];
    
    NdFMDBMigrationManager *manager = [NdFMDBMigrationManager managerWithDatabaseAtPath:[[[self class]  userFilePath] stringByAppendingPathComponent:T_Nudges_DB_NAME]  migrationsBundle:CoreBizBundle];
    
    BOOL resultState = NO;
    NSError *error = nil;
    if (!manager.hasMigrationsTable){
        resultState = [manager createMigrationsTable:&error];
    }
    
    resultState = [manager migrateDatabaseToVersion:UINT64_MAX progress:nil error:&error];//迁移函数
}

#pragma mark - 业务相关的数据库
+ (FMDatabaseQueue *)getDBQueue{
    if (dbQueue) {
        return dbQueue;
    }
    
    @synchronized(self) {
        NSString *realPath = [[[self class]  userFilePath] stringByAppendingPathComponent:T_Nudges_DB_NAME];
        dbQueue = [FMDatabaseQueue databaseQueueWithPath:realPath];
    }
    return dbQueue;
}

+ (void)closeDB{
    if (dbQueue){
        [dbQueue close];
    }
}

#pragma mark - common
+ (void)initDBSettings{
    // 重新初始化数据库，（更换用户后数据库路径会改变，需要重新初始化数据库操作队列）
    [NdIMDBManager closeDB];
    [NdIMDBManager reInitDBQueue];
    [NdIMDBManager initCoreBizDBMigrationManagerSetting];
}

+ (void)reInitDBQueue{
    @synchronized(self) {
        NSString *realPath = [[[self class]  userFilePath] stringByAppendingPathComponent:T_Nudges_DB_NAME];
        dbQueue = [FMDatabaseQueue databaseQueueWithPath:realPath];
    }
}

#pragma mark  获取当前用户文件目录（如没有则创建）
+ (NSString *)userFilePath{
    // 初始化documents目录
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    // 设置用户保存的文件夹
    NSString *userPath = [documentPath stringByAppendingPathComponent:@"ucc"];
    // 创建文件管理器
    NSFileManager   *fileManager = [NSFileManager defaultManager];
    BOOL userPathExists = [fileManager fileExistsAtPath:userPath];
    
    NSLog(@"DXPNugges Log:=== Nudges database path:%@",userPath);
    if (!userPathExists) {
        [fileManager createDirectoryAtPath:userPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return userPath;
}

@end
