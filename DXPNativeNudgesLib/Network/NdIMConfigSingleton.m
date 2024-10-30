//
//  NdIMConfigSingleton.m
//  IMDemo
//
//  Created by mac on 2020/7/27.
//  Copyright © 2020 mac. All rights reserved.
//

#import "NdIMConfigSingleton.h"

static NdIMConfigSingleton * _instance = nil;

@implementation NdIMConfigSingleton

+ (NdIMConfigSingleton *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NdIMConfigSingleton alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _fileURLStr = @"";
        _baseURLStr = @"";
        _socketURLStr = @"";
        _secretKey = @"";
        _sysAccount = @"";
        _langCode = @"";
        _userId = @"";
        _dislikeMessageId = @"";
        _sessionS = NO;
    }
    return self;
}


@end
