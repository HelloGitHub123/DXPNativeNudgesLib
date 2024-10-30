//
//  NdHJInstructModel.m
//  MOC
//
//  Created by Lee on 2022/3/24.
//

#import "NdHJInstructModel.h"

@implementation NdHJInstructModel
+ (NSDictionary<NSString *,id> *)children {
    
    return @{
        @"children" : [NdHJInstructModel class]
    };
}
@end
