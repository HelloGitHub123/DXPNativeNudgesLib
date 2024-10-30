//
//  FrequencyModel.m
//  DITOApp
//
//  Created by 李标 on 2022/7/11.
//

#import "FrequencyModel.h"
#import "NdHJHandelJson.h"
#import "Nudges.h"

@implementation FrequencyModel

- (id)initWithMsgDic:(NSDictionary *)rDic {
    self = [super init];
    if (self) {
        self.repeatInterval = [[NSString ndStringWithoutNil:[rDic objectForKey:@"repeatInterval"]] integerValue];
        NSArray *arr = [rDic objectForKey:@"frequencyList"];
        if (!IsArrEmpty_Nd(arr)) {
//            NSMutableArray *list = [[NSMutableArray alloc] init];
//            for (NSDictionary *dic in arr) {
//                FrequencyItemModel *model = [[FrequencyItemModel alloc] init];
//                model.frequencyControl =  [NSString imStringWithoutNil:[dic objectForKey:@"frequencyControl"]];
//                model.times = [[NSString imStringWithoutNil:[dic objectForKey:@"times"]] integerValue];
//                [list addObject:model];
//            }
//            self.frequencyList = list;
            
            for (NSDictionary *dic in arr) {
                NSString *name = [dic objectForKey:@"frequencyControl"];
                if ([name isEqualToString:@"PERSESSION"]) {
                    NSInteger times = [[dic objectForKey:@"times"] integerValue];
                    self.sessionTimes = times;
                }
                if ([name isEqualToString:@"PERHOUR"]) {
                    NSInteger times = [[dic objectForKey:@"times"] integerValue];
                    self.hourTimes = times;
                }
                if ([name isEqualToString:@"PERDAY"]) {
                    NSInteger times = [[dic objectForKey:@"times"] integerValue];
                    self.dayTimes = times;
                }
                if ([name isEqualToString:@"PERWEEK"]) {
                    NSInteger times = [[dic objectForKey:@"times"] integerValue];
                    self.weekTimes = times;
                }
            }
        }
    }
    return self;
}

- (id)initWithResultSet:(FMResultSet *)rs {
    self = [super init];
    if (self) {
        self.repeatInterval = [[rs stringForColumn:@"repeatInterval"] integerValue];
        // session
        self.sessionTimes = [[rs stringForColumn:@"sessionTimes"] integerValue];
        // hour
        self.hourTimes = [[rs stringForColumn:@"hourTimes"] integerValue];
        // day
        self.dayTimes = [[rs stringForColumn:@"dayTimes"] integerValue];
        // hour
        self.weekTimes = [[rs stringForColumn:@"weekTimes"] integerValue];
    }
    return self;
}

@end
