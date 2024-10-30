//
//  NudgesModel.m
//  DITOApp
//
//  Created by 李标 on 2022/5/16.
//

#import "NudgesModel.h"
#import "NdHJHandelJson.h"

@implementation NudgesModel

- (id)initWithResultSet:(FMResultSet *)rs {
    self = [super init];
    if (self) {
        self.contactId =  [rs stringForColumn:@"contactId"];
        self.campaignId = [[rs stringForColumn:@"campaignId"] integerValue];
        self.flowId = [[rs stringForColumn:@"flowId"] integerValue];
        self.processId = [[rs stringForColumn:@"processId"] integerValue];
        self.campaignExpDate = [rs stringForColumn:@"campaignExpDate"];
        self.nudgesId = [[rs stringForColumn:@"nudgesId"] integerValue];
        self.nudgesName = [rs stringForColumn:@"nudgesName"];
        self.remainTimes = [[rs stringForColumn:@"remainTimes"] integerValue];
        self.channelCode = [rs stringForColumn:@"channelCode"];
        self.height = [[rs stringForColumn:@"height"] floatValue];
        self.width = [[rs stringForColumn:@"width"] floatValue];
        self.adviceCode = [rs stringForColumn:@"adviceCode"];
        self.nudgesType = [[rs stringForColumn:@"nudgesType"] integerValue];
        self.pageName = [rs stringForColumn:@"pageName"];
        self.findIndex = [rs stringForColumn:@"findIndex"];
        self.ownProp = [rs stringForColumn:@"ownProp"];
        self.position = [rs stringForColumn:@"position"];
        self.appExtInfo = [rs stringForColumn:@"appExtInfo"];
        self.background = [rs stringForColumn:@"background"];
        self.border = [rs stringForColumn:@"border"];
        self.backdrop = [rs stringForColumn:@"backdrop"];
        self.dismiss = [rs stringForColumn:@"dismiss"];
        self.title = [rs stringForColumn:@"title"];
        self.body = [rs stringForColumn:@"body"];
        self.image = [rs stringForColumn:@"image"];
        self.video = [rs stringForColumn:@"video"];
        self.buttons = [rs stringForColumn:@"buttons"];
        self.dismissButton = [rs stringForColumn:@"dismissButton"];
        self.isShow = [[rs stringForColumn:@"isShow"] integerValue];
    }
    return self;
}

- (id)initWithMsgDic:(NSDictionary *)rDic {
    self = [super init];
    if (self) {
        self.contactId = [NSString ndStringWithoutNil:[rDic objectForKey:@"contactId"]];
        self.campaignId = [[NSString ndStringWithoutNil:[rDic objectForKey:@"campaignId"]] integerValue];
        self.flowId = [[NSString ndStringWithoutNil:[rDic objectForKey:@"flowId"]] integerValue];
        self.processId = [[NSString ndStringWithoutNil:[rDic objectForKey:@"processId"]] integerValue];
        self.campaignExpDate = [NSString ndStringWithoutNil:[rDic objectForKey:@"campaignExpDate"]];
        self.remainTimes = [[NSString ndStringWithoutNil:[rDic objectForKey:@"remainTimes"]] integerValue];
        self.nudgesId = [[NSString ndStringWithoutNil:[rDic objectForKey:@"nudgesId"]] integerValue];
        self.nudgesName = [NSString ndStringWithoutNil:[rDic objectForKey:@"nudgesName"]];
        self.channelCode = [NSString ndStringWithoutNil:[rDic objectForKey:@"channelCode"]];
        self.height = [[NSString ndStringWithoutNil:[rDic objectForKey:@"height"]] floatValue];
        self.width = [[NSString ndStringWithoutNil:[rDic objectForKey:@"width"]] floatValue];
        self.adviceCode = [NSString ndStringWithoutNil:[rDic objectForKey:@"adviceCode"]];
        self.nudgesType = [[NSString ndStringWithoutNil:[rDic objectForKey:@"nudgesType"]] integerValue];
        self.pageName = [NSString ndStringWithoutNil:[rDic objectForKey:@"pageName"]];
        self.findIndex = [NSString ndStringWithoutNil:[rDic objectForKey:@"findIndex"]];
        self.ownProp = [NSString ndStringWithoutNil:[rDic objectForKey:@"ownProp"]];
        self.position = [NSString ndStringWithoutNil:[rDic objectForKey:@"position"]];
        self.appExtInfo = [NSString ndStringWithoutNil:[rDic objectForKey:@"appExtInfo"]];
        self.background = [NSString ndStringWithoutNil:[rDic objectForKey:@"background"]];
        self.border = [NSString ndStringWithoutNil:[rDic objectForKey:@"border"]];
        self.backdrop = [NSString ndStringWithoutNil:[rDic objectForKey:@"backdrop"]];
        self.dismiss = [NSString ndStringWithoutNil:[rDic objectForKey:@"dismiss"]];
        self.title = [NSString ndStringWithoutNil:[rDic objectForKey:@"title"]];
        self.body = [NSString ndStringWithoutNil:[rDic objectForKey:@"body"]];
        self.image = [NSString ndStringWithoutNil:[rDic objectForKey:@"image"]];
        self.video = [NSString ndStringWithoutNil:[rDic objectForKey:@"video"]];
        self.buttons = [NSString ndStringWithoutNil:[rDic objectForKey:@"buttons"]];
        self.dismissButton = [NSString ndStringWithoutNil:[rDic objectForKey:@"dismissButton"]];
        self.isShow = [[NSString ndStringWithoutNil:[rDic objectForKey:@"isShow"]] integerValue];
    }
    return self;
}
@end
