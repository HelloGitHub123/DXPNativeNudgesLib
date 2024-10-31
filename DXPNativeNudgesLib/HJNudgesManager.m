//
//  HJNudgesManager.m
//  CLPApp
//
//  Created by 李标 on 2022/5/6.
//

#import "HJNudgesManager.h"
#import <sys/utsname.h>
#import "NdHJHttpRequest.h"
#import "Nudges.h"
#import "NdHJSocketRocketManager.h"
#import "NdHJIntroductManager.h"
#import "NodeModel.h"
#import "HJToolTipsManager.h"
#import "NdHJNudgesDBManager.h"
#import "HJSpotlightManager.h"
#import "HJPomoTagManager.h"
#import "HJHotSpotManager.h"
#import "HJAnnouncementManager.h"
#import "HJFloatingAtionManager.h"
#import "HJNPSManager.h"
#import "HJRateManager.h"
#import "HJFeedBackManager.h"
#import "CheckNudgeModel.h"
#import <DXPToolsLib/HJTool.h>
#import <DXPToolsLib/SNAlertMessage.h>
#import "NdIMDBManager.h"
#import <DXPFontManagerLib/FontManager.h>
#import "FrequencyModel.h"

static HJNudgesManager *manager = nil;

@interface HJNudgesManager ()<ToolTipsEventDelegate, SpotlightEventDelegate, PomoTagEventDelegate, HotSpotEventDelegate, AnnouncementEventDelegate, FloatingAtionEventDelegate, NPSEventDelegate, RateEventDelegate, FeedBackEventDelegate> {
	
}

@property (nonatomic, strong) NSMutableArray *nudgesShowList; // 单个页面要显示Nudges的队列
@property (nonatomic, strong) NSMutableArray *showList; // 要显示nudges list
@property (nonatomic, assign) BOOL isLock; // 请求锁
@property (nonatomic, assign) NSInteger nIndex; // 索引
@property (nonatomic, assign) BOOL isFindView; // 是否查找到对应的视图
@property (nonatomic, assign) BOOL isReq; // nudges list 是否请求。 防重复请求
@property (nonatomic, assign) BOOL sessionFlag; // 每次重新打开会话

@property (nonatomic, strong) NudgesModel *currentModel; //
@property (nonatomic, strong) NudgesBaseModel *currentBaseModel; //

/// 频次model
@property (nonatomic, strong) FrequencyModel *frequencyModel;
@end

@implementation HJNudgesManager

#pragma mark -- init
+ (instancetype)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[HJNudgesManager alloc] init];
	});
	return manager;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		
		[self initData];
		[self firstLaunchApp];
		[NdIMDBManager initDBSettings];
	}
	return self;
}

// 数据初始化
- (void)initData {
	self.sessionFlag = YES;
	self.domTreeDic = @{};
	self.configParametersModel = [[NudgesConfigParametersModel alloc] init];
	self.nudgesShowList = [[NSMutableArray alloc] init];
	self.showList = [[NSMutableArray alloc] init];
	self.isReq = false;
	self.isLock = NO;
	self.nIndex = 0;
	self.isReported = NO; // 默认不上报
}

// 判断App是否首次加载Nudges
- (void)firstLaunchApp {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"nudges_firstLaunch"]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"nudges_firstLaunch"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		NSLog(@"安装之后首次开启App");
		// 初始化 频次 数据库表
		if ([NdHJNudgesDBManager initFrequency:[self getCurrentTimestamp]]) {
			NSLog(@"频次表初始化成功");
		}
		// 获取当前App版本号并存入NSUserDefaults中
		NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:appVersion forKey:@"appVersion"];
		[userDefaults synchronize];
	} else {
		// 根据版本号判断是否更新后首次启动
		NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSString *localVersion = [userDefaults stringForKey:@"appVersion"];
		if ([appVersion isEqualToString:localVersion]) {
			NSLog(@"安装或升级之后并非首次开启App");
		} else {
			NSLog(@"升级之后首次开启App");
			// 初始化 频次 数据库表
			if ([NdHJNudgesDBManager initFrequency:[self getCurrentTimestamp]]) {
				NSLog(@"频次表初始化成功");
			}
			//将当前App版本号存入NSUserDefaults中
			[userDefaults setObject:appVersion forKey:@"appVersion"];
			[userDefaults synchronize];
		}
	}
}

#pragma mark -- 设备匹配相关
// 结束会话  断开websocket连接
- (void)endSessions {
	[[NdHJSocketRocketManager instance] closeSocket];
}

// 初始化websocket并连接
- (void)connectWebSocketByConfigCode:(NSString *)configCode  {
	if (isEmptyString_Nd(configCode)) {
		NSLog(@"configCode不能为空");
		return;
	}
	UIDevice *currentDevice = [UIDevice currentDevice];
	NSString *deviceId = [[currentDevice identifierForVendor] UUIDString];
	// 获取设备品牌
	NSString *brand = [self getCurrentDeviceModel];
	// 获取设备系统信息
	NSString *os = @"IOS";
	// 获取设备系统版本
	NSString *osVersion = [[UIDevice currentDevice] systemVersion];
	// 打开建立链接
	[[NdHJSocketRocketManager instance] openSocket:configCode wsSocketIP:self.configParametersModel.wsSocketIP deviceCode:deviceId brand:brand os:os osVersion:osVersion width:[NSString stringWithFormat:@"%ld",(long)kScreenWidth] height:[NSString stringWithFormat:@"%ld",(long)kScreenHeight]];
}

#pragma mark - 点击Capture按钮时候触发
- (void)captureClickAction {
	UIImage *img = [self currentWindowScreenShot];
	self.screenShotImg = img;
	// 获取DOM Tree
	NSDictionary *dict = @{};
	UIViewController *currentVC = [TKUtils topViewController];
	dict = [self digViewDomTreeForVC:currentVC subView:currentVC.view startTag:@""];
	NSLog(@"DomTree 数据：%@",dict);
	// 上报截屏和Dom Tree
	[self uploadCaptureInfoByScreenShotImg:self.screenShotImg domTree:dict permission:@"true"];
}

#pragma mark - 获取页面domTree (递归)
- (NSMutableDictionary *)digViewDomTreeForVC:(UIViewController *)viewController subView:(UIView *)view startTag:(NSString *)indexStr {
	// 初始化
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	NSMutableArray *childArr = [[NSMutableArray alloc] init];
	// tag
	[dict setObject:[NSString stringWithFormat:@"%ld",view.tag] forKey:@"tag"];
	// 非动态类标识
	NSString *accessibilityTag = [NSString stringWithFormat:@"Native_%@_%@",NSStringFromClass(view.class),indexStr];
	// findIndex
	[dict setObject:accessibilityTag forKey:@"findIndex"];
	// resId
	[dict setObject:accessibilityTag forKey:@"resId"];
	// view对应映射的frame
	NSString *frameStr = NSStringFromCGRect([self getAddress:view]);
	frameStr = [frameStr stringByReplacingOccurrencesOfString:@" " withString:@""];
	[dict setObject:frameStr forKey:@"frame"];
	// className
	[dict setObject:@"" forKey:@"className"];
	// pageName
	[dict setObject:[HJNudgesManager sharedInstance].currentPageName forKey:@"pageName"];
	
	// 如果子视图是tableviewCell
	if ([view isKindOfClass:[UITableViewCell class]]) {
		NSLog(@"cell的标识:%@",view.accessibilityIdentifier);
		[dict setObject:view.accessibilityIdentifier forKey:@"accessibilityIdentifier"];
		if (!isEmptyString_Nd(view.accessibilityIdentifier)) {
			view.accessibilityLabel = view.accessibilityIdentifier;
		}
		// 给tableviewcell的subsViews进行标签化
		NSMutableDictionary *cellDic = [self getTableViewCellSubsviewForTag:view.accessibilityIdentifier view:view startTag:@""];
		[childArr addObject:cellDic];
		
	} else {
		[dict setObject:accessibilityTag forKey:@"accessibilityIdentifier"];
		view.accessibilityLabel = accessibilityTag;
		// 遍历所有的子控件
		for (int i = 0; i< view.subviews.count; i++) {
			UIView *child = view.subviews[i];
			NSMutableDictionary *childDict = [self digViewDomTreeForVC:viewController subView:child startTag:[NSString stringWithFormat:@"%@%@%d",indexStr,isEmptyString_Nd(indexStr)?@"":@",",i]];
			[childArr addObject:childDict];
		}
	}
	
	if (childArr.count > 0) {
		[dict setObject:childArr forKey:@"childNodes"];
	}
	
	return dict;
}

/**
 *   eg: 给tableviewcell的 子view 进行打标签 (递归)
 *
 *   superAccessibility: cell 的 标识
 *   subView: tableviewCell
 *   indexStr: 索引
 */
- (NSMutableDictionary *)getTableViewCellSubsviewForTag:(NSString *)superAccessibility view:(UIView *)subView startTag:(NSString *)indexStr {
	
	NSMutableArray *childArr = [[NSMutableArray alloc] init];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	
	NSString *tagStr;
	if ([self isContainsViewType:subView]) {
		// frame
		NSString *frameStr = NSStringFromCGRect([self getAddress:subView]);
		frameStr = [frameStr stringByReplacingOccurrencesOfString:@" " withString:@""];
		[dict setObject:frameStr forKey:@"frame"];
		// className
		NSString *className = NSStringFromClass([subView class]);
		// 构建标识符
		tagStr = [NSString stringWithFormat:@"%@_%@",superAccessibility,indexStr];
		[dict setObject:tagStr forKey:@"accessibilityIdentifier"];
		// findIndex
		[dict setObject:tagStr forKey:@"findIndex"];
		// 打标签
		subView.accessibilityLabel = tagStr;
	}
	// 遍历所有的子控件
	for (int i = 0; i < subView.subviews.count; i++) {
		UIView *child = subView.subviews[i];
		NSMutableDictionary *dic = [self getTableViewCellSubsviewForTag:tagStr view:child startTag:[NSString stringWithFormat:@"%d",i]];
		[childArr addObject:dic];
	}
	[dict setObject:childArr forKey:@"childNodes"];
	
	return dict;
}

// websocket上报截屏和树形结构信息
- (void)uploadCaptureInfoByScreenShotImg:(UIImage *)screenShotImg domTree:(NSDictionary *)domTree permission:(NSString *)permission {
	if ([domTree allKeys] == 0 || !screenShotImg) {
		return;
	}
	// 截屏图片base64
	NSString *encodedImageString = [UIImagePNGRepresentation(screenShotImg) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
	NSString *imageStr = [NSString stringWithFormat:@"data:image/jpg;base64,%@",encodedImageString];
	// 调用websocket接口 /mccm/nudges/socket 上报
	NSDictionary *dic = @{
		@"screenShot":imageStr,
		@"domTree": domTree,
		@"permission": permission
	};
	NSString *strSend = [NSString dictionaryToJson:dic];
	if (isEmptyString_Nd(strSend)) {
		return;
	}
	[[NdHJSocketRocketManager instance] sendData:strSend];
}

#pragma mark -- 开启入口
- (void)start {
	// 请求全量nudges数据
	[self requestNudgesListWithModel:self.configParametersModel];
}

// 删除数据 如果不想每次启动都展示一遍所有nudges，可以屏蔽这个删除表数据操作
- (void)clearDBAndCacheData {
	[NdHJNudgesDBManager deleteTableAllDataForNudges];
	[self.nudgesShowList removeAllObjects];
}

#pragma mark -- 获取Nudges列表
- (void)requestNudgesListWithModel:(NudgesConfigParametersModel *)model {
	if (isEmptyString_Nd(model.baseUrl) || isEmptyString_Nd(model.accNbr)) {
		return;
	}
	UIDevice *currentDevice = [UIDevice currentDevice];
	NSString *deviceId = [[currentDevice identifierForVendor] UUIDString];
	// 调接口获取nudges 列表
	NdHJHttpRequest *request = [[NdHJHttpRequest alloc] init];
	request.httpMethod = NdHJHttpMethodPOST;
	NSString *reqUrl = [NSString stringWithFormat:@"%@nudges/contact",model.baseUrl];
	request.requestUrl = reqUrl;
	request.requestParams = @{
		@"identityType": [NSNumber numberWithInt:(int)(model.identityType)],
		@"identityId": [NSNumber numberWithLong:model.identityId],
		@"accNbr": model.accNbr,
		@"channelCode": isEmptyString_Nd(model.channelCode)?@"Nudges":model.channelCode,
		@"adviceCode": isEmptyString_Nd(model.adviceCode)?@"Nudges":model.adviceCode,
		@"deviceSystem": @"iOS",
		@"random":[TKUtils uuidString],
		@"appId": model.appId
	};
	
	__weak __typeof(&*self)weakSelf = self;
	[[NdHJHttpSessionManager sharedInstance] sendRequest:request complete:^(NdHJHttpReponse * _Nonnull response) {
		if (!response.serverError) {
			NSDictionary *resDic = response.responseObject;
			if (!weakSelf.isReq) { // 防重复请求
				weakSelf.isReq = YES;
				// 获取频次
				NSDictionary *frequencyDic = [resDic objectForKey:@"frequency"];
				if (!IsNilOrNull_Nd(frequencyDic)) {
					FrequencyModel *fModel = [[FrequencyModel alloc] initWithMsgDic:frequencyDic];
					self.frequencyModel = fModel;
				}
				
				NSArray *contactList = [resDic objectForKey:@"contactList"];
				// 判断是否满足条件
				if (IsArrEmpty_Nd(contactList) || ![self checkGlobalFrequency]) {
					return;
				}
				// 初始化 频次 数据库表
				if (!IsNilOrNull_Nd(frequencyDic) && [frequencyDic allKeys] == 0) {
					if ([NdHJNudgesDBManager initFrequency:[self getCurrentTimestamp]]) {
						NSLog(@"频次表初始化成功");
					}
				}
				// 筛选是否属于IOS的nudges
				for (int i = 0; i< contactList.count; i++) {
					NSDictionary *dic = [contactList objectAtIndex:i];
					NSString *pageName = [dic objectForKey:@"pageName"];
					//          if ([[pageName lowercaseString] containsString:@"viewcontroller"]) {
					//            [self.nudgesShowList addObject:dic];
					//          }
					if ([pageName isEqualToString:self.currentPageName]) {
						[self.nudgesShowList addObject:dic];
					}
				}
				if (IsArrEmpty_Nd(self.nudgesShowList)) {
					return;
				}
				// 如果本地数据库没有数据，则调用insertNudgesWithNudgesId 将数据插入到数据库表。
				// 否则 调用 updateNudgesWithNudgesId 更新本地数据库数据
				for (NSDictionary *dic in self.nudgesShowList) {
					NudgesModel *model = [[NudgesModel alloc] initWithMsgDic:dic];
					NSMutableArray *dbList = [NdHJNudgesDBManager selectNudgesDBWithNudgesId:model.nudgesId campaignId:model.campaignId];
					if (dbList.count > 0) {
						// 有则更新
						[NdHJNudgesDBManager updateNudgesWithNudgesId:model.nudgesId model:model];
					} else {
						// 如果没有，则插入数据库
						BOOL isSuccess = [NdHJNudgesDBManager insertNudgesWithNudgesId:model.nudgesId model:model];
						if (isSuccess) {
							NSLog(@"nudges插入数据库成功");
						}
					}
				}
				
				[[HJNudgesManager sharedInstance] queryNudgesWithPageName:@"viewController"];
			}
		}
	}];
}

// 判断全局频次条件(用于所有Nudges组件)
- (BOOL)checkGlobalFrequency {
	if (!self.frequencyModel) {
		return YES;
	}
	BOOL isRepeat = NO;
	BOOL isWeek = NO;
	BOOL isDay = NO;
	BOOL isHour = NO;
	// 本地数据库
	FrequencyModel *dbModel = [NdHJNudgesDBManager selectFrequencyData];
	if (!dbModel) {
		return NO;
	}
	
	// 频次的判断
	if (self.frequencyModel.repeatInterval == 0) {
		isRepeat = YES;
	} else if (self.frequencyModel.repeatInterval != 0 && ((dbModel.repeatInterval % (self.frequencyModel.repeatInterval + 1)) == 1)) {
		isRepeat = YES;
	}
	// session的判断 总session显示次数 不能 超过接口返回的次数
	//    if (dbModel.sessionTimes <= self.frequencyModel.sessionTimes) {
	//        isSession = YES;
	//    }
	NSString *lastTime = [NdHJNudgesDBManager selectFrequencyLastTime]; // 获取db时间戳
	NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:[lastTime longLongValue]/1000];
	NSDate *nowDate = [NSDate date]; // 当前时间
	
	// week的判断 一周展示几次
	if (self.frequencyModel.weekTimes == 0) {
		isWeek = YES;
	} else if ([self isSameWeek:date date2:nowDate]) {
		if (dbModel.weekTimes <= self.frequencyModel.weekTimes) {
			// 同一周 并且小于配置周次数频次
			isWeek = YES;
		} else {
			isWeek = NO;
		}
	} else {
		// 不同一周, 说明跨周了。
		[NdHJNudgesDBManager clearFrequencyWithWeekTimes]; // 清空week Times
		NSString *currentDateTamp = [self getCurrentTimestamp]; // 获取当前时间戳
		[NdHJNudgesDBManager updateFrequencyWithLastTime:currentDateTamp]; // 更新db表的lastTime为当前时间戳
		isWeek = YES;
	}
	
	// day的判断 一天展示几次
	if (self.frequencyModel.dayTimes == 0) {
		isDay = YES;
	} else if ([self isSameDay:date date2:nowDate]) {
		if (dbModel.dayTimes <= self.frequencyModel.dayTimes) {
			// 同一天 并且小于配置天次数频次
			isDay = YES;
		} else {
			isDay = NO;
		}
	} else {
		// 不是同一天
		[NdHJNudgesDBManager clearFrequencyWithDayTimes]; // 清空day Times
		NSString *currentDateTamp = [self getCurrentTimestamp]; // 获取当前时间戳
		[NdHJNudgesDBManager updateFrequencyWithLastTime:currentDateTamp]; // 更新db表的lastTime为当前时间戳
		isDay = YES;
	}
	
	// hour的判断 一小时展示几次
	if (self.frequencyModel.hourTimes == 0) {
		isHour = YES;
	} else if ([self isSameHour:date date2:nowDate]) {
		if (dbModel.hourTimes <= self.frequencyModel.hourTimes) {
			// 同一小时 并且小于配置小时次数频次
			isHour = YES;
		} else {
			isHour = NO;
		}
	} else {
		// 不是同一个小时
		[NdHJNudgesDBManager clearFrequencyWithHourTimes]; // 清空day Times
		NSString *currentDateTamp = [self getCurrentTimestamp]; // 获取当前时间戳
		[NdHJNudgesDBManager updateFrequencyWithLastTime:currentDateTamp]; // 更新db表的lastTime为当前时间戳
		isHour = YES;
	}
	
	[NdHJNudgesDBManager updateFrequencyWithRepeatInterval];
	if (isRepeat && isWeek && isDay && isHour) {
		// 记录频次 + 1
		if (self.sessionFlag) {
			//            [HJNudgesDBManager updateFrequencyWithSessionTimes];
			[NdHJNudgesDBManager updateFrequencyWithWeekTimes];
			[NdHJNudgesDBManager updateFrequencyWithDayTimes];
			[NdHJNudgesDBManager updateFrequencyWithHourTimes];
			self.sessionFlag = NO;
		}
		// 显示
		return YES;
	}
	return NO;
}

// Nudges显示后, 上报接口
- (void)nudgesContactRespByNudgesId:(NSInteger)nudgesId contactId:(NSString *)contactId {
	if (!self.isReported) {
		// 不进行上报
		return;
	}
	NdHJHttpRequest *request = [[NdHJHttpRequest alloc] init];
	request.httpMethod = NdHJHttpMethodPOST;
	NSString *reqUrl = [NSString stringWithFormat:@"%@nudges/contact/resp",self.configParametersModel.baseUrl];
	request.requestUrl = reqUrl;
	request.requestParams = @{
		@"nudgesId": @(nudgesId),
		@"contactId": contactId,
		@"identityType": [NSNumber numberWithInt:(int)self.configParametersModel.identityType],
		@"identityId": [NSNumber numberWithLong:self.configParametersModel.identityId],
		@"channelCode": @"Nudges",
		@"adviceCode": @"Nudges",
		@"deviceSystem": @"iOS",
		@"accNbr":isEmptyString_Nd(self.configParametersModel.accNbr) ? @"" : self.configParametersModel.accNbr,
		@"random":[TKUtils uuidString],
		@"deviceToken":[self getDeviceUUID],
		@"appId":self.configParametersModel.appId,
	};
	[[NdHJHttpSessionManager sharedInstance] sendRequest:request complete:^(NdHJHttpReponse * _Nonnull response) {
		if (!response.serverError) {
		} else {
		}
	}];
}

#pragma mark -- 调试预览nudges (Preview)
- (void)showPreviewNudges:(NSDictionary *)dic {
	// 清空数据库数据
	[NdHJNudgesDBManager deleteTableAllDataForNudges];
	// 查找对应预览的nudges
	[self removeAllPreviewNudge];
	// 解析构造
	NudgesModel *model = [[NudgesModel alloc] initWithMsgDic:dic];
	model.remainTimes = 1; // 预览默认给一次
	self.currentModel = model;
	
	NudgesBaseModel *baseModel = [[NudgesBaseModel alloc] initWithMsgModel:model];
	self.currentBaseModel = baseModel;
	
	if (baseModel.nudgesType == KNudgesType_NPS) {
		[self previewConstructsNudgesViewByFindView:nil isFindType:KNudgeFineType_Exist_Find];
	} else {
		// 检查是否存在当前页面
		[self checkNudgesViewExist:model isPreview:YES];
	}
}

// 查找对应预览的nudges，进行移除
- (void)removeAllPreviewNudge {
	[[HJHotSpotManager sharedInstance] removePreviewNudges];
	[[HJAnnouncementManager sharedInstance] removePreviewNudges];
	[[HJSpotlightManager sharedInstance] removePreviewNudges];
	[[HJPomoTagManager sharedInstance] removePreviewNudges];
	[[HJNPSManager sharedInstance] removePreviewNudges];
	[[HJRateManager sharedInstance] removePreviewNudges];
	[[HJFeedBackManager sharedInstance] removePreviewNudges];
	[[HJToolTipsManager sharedInstance] removePreviewNudges];
}

#pragma mark -- 预览nudges
- (void)previewConstructsNudgesViewByFindView:(UIView *)findView isFindType:(KNudgeFindType)type {
	
	[self removeAllPreviewNudge];
	
	if (self.currentBaseModel.nudgesType == KNudgesType_NPS) {
		[HJNPSManager sharedInstance].nudgesModel = self.currentModel;
		[HJNPSManager sharedInstance].baseModel = self.currentBaseModel;
		[HJNPSManager sharedInstance].delegate = self;
		return;
	}
	if (self.currentModel.nudgesType == KNudgesType_Forms) {
		[HJFeedBackManager sharedInstance].nudgesModel = self.currentModel;
		[HJFeedBackManager sharedInstance].baseModel = self.currentBaseModel;
		[HJFeedBackManager sharedInstance].delegate = self;
		return;
	}
	
	if (type == KNudgeFineType_Exist_Find) {
		// 类型匹配进行，显示
		switch (self.currentModel.nudgesType) {
			case KNudgesType_Hotspots: {
				[HJHotSpotManager sharedInstance].nudgesModel = self.currentModel;
				[HJHotSpotManager sharedInstance].baseModel = self.currentBaseModel;
				[HJHotSpotManager sharedInstance].delegate = self;
			}
				break;
			case KNudgesType_FunnelReminders: {
				[HJAnnouncementManager sharedInstance].nudgesModel = self.currentModel;
				[HJAnnouncementManager sharedInstance].baseModel = self.currentBaseModel;
				[HJAnnouncementManager sharedInstance].delegate = self;
			}
				break;
			case KNudgesType_SpotLight: {
				[HJSpotlightManager sharedInstance].nudgesModel = self.currentModel;
				[HJSpotlightManager sharedInstance].baseModel =  self.currentBaseModel;
				[HJSpotlightManager sharedInstance].findView = findView;
				[HJSpotlightManager sharedInstance].delegate = self;
				// 开始显示
				[[HJSpotlightManager sharedInstance] startConstructsNudgesView];
			}
				break;
			case KNudgesType_FOMOTags: {
				[HJPomoTagManager sharedInstance].nudgesModel = self.currentModel;
				[HJPomoTagManager sharedInstance].baseModel = self.currentBaseModel;
				[HJPomoTagManager sharedInstance].findView = findView;
				[HJPomoTagManager sharedInstance].delegate = self;
				// 开始显示
				[[HJPomoTagManager sharedInstance] startConstructsNudgesView];
			}
				break;
			case KNudgesType_FloatingActions: {
				[HJFloatingAtionManager sharedInstance].nudgesModel = self.currentModel;
				[HJFloatingAtionManager sharedInstance].baseModel = self.currentBaseModel;
				[HJFloatingAtionManager sharedInstance].delegate = self;
			}
				break;
			case KNudgesType_Rate: {
				[HJRateManager sharedInstance].nudgesModel = self.currentModel;
				[HJRateManager sharedInstance].baseModel = self.currentBaseModel;
				[HJRateManager sharedInstance].delegate = self;
			}
				break;
			case KNudgesType_Tooltips: {
				[HJToolTipsManager sharedInstance].nudgesModel = self.currentModel;
				[HJToolTipsManager sharedInstance].baseModel = self.currentBaseModel;
				[HJToolTipsManager sharedInstance].findView = findView;
				[HJToolTipsManager sharedInstance].delegate = self;
				// 开始显示
				[[HJToolTipsManager sharedInstance] startConstructsNudgesView];
			}
				break;
			default: {
				[HJToolTipsManager sharedInstance].nudgesModel = self.currentModel;
				[HJToolTipsManager sharedInstance].baseModel = self.currentBaseModel;
				[HJToolTipsManager sharedInstance].findView = findView;
				[HJToolTipsManager sharedInstance].delegate = self;
				// 开始显示
				[[HJToolTipsManager sharedInstance] startConstructsNudgesView];
			}
				break;
		}
	}
}


#pragma mark -- 查询对应页面上的nudges，并展示 (RunTime 会实时调用该方法)
- (void)queryNudgesWithPageName:(NSString *)pageName {
	if (isEmptyString_Nd(self.currentPageName)) {
		return;
	}
	self.isLock = NO;
	self.nIndex = 0;
	[self showNudgesViewWithPageName:self.currentPageName];
	
	//  if (isEmptyString_Nd(pageName)) {
	//    return;
	//  }
	//  // 1.判断当前界面pageName 有没有发生跳转，
	//  // 如果发生跳转，则重新从数据库拿下一个界面数据，并更新当前缓存数据。
	//  // 如果没有跳转，还是当前页面，则还从缓存中拿数据进行展示
	//  // 2. 判断当前界面nudge有没有，并且判断有没有展示。 用到索引nIndex，用来记录展示的nudges的index
	//  //   1>.当前界面有，但是没有显示出来 — 寻找下一个当前界面nudges
	//  //   2>.当前界面有，并且显示出来了   —  寻找下一个当前界面nudegs
	//  //   3>. 当前界面没有包含该元素     —  不寻找，并且删除当前数据。并寻找下一个当前界面nudegs
	//
	//  // 注:isReq 只有请求过contact/list 才可以进行查找
	//  //    isReq = YES; self.isLock= NO;
	//  if (self.isReq && !self.isLock) {
	//    self.isLock = YES; // 进行访问锁定
	//
	//    if (isEmptyString_Nd(self.currentPageName)) {
	//      self.currentPageName = pageName;
	//    }
	//    if ([pageName isEqualToString:self.currentPageName]) {
	//      [self showNudgesViewWithPageName:self.currentPageName];
	//    } else {
	//      // 界面发生变化 更新当前页面的变量
	//      self.isLock = NO;
	//      self.nIndex = 0;
	//      self.currentPageName = pageName;
	//      [self showNudgesViewWithPageName:self.currentPageName];
	//    }
	//  }
	
}

// nudges的显示逻辑
- (void)showNudgesViewWithPageName:(NSString *)pageName {
	// 界面没有发生跳转,从缓存中拿数据进行展示
	NSMutableArray *nudgesList = [NdHJNudgesDBManager selectNudgesDBWithPageName:pageName];
	if (IsArrEmpty_Nd(nudgesList)) {
		self.isLock = NO;
		return;
	} else {
		self.showList = nudgesList;
	}
	// 展示逻辑：判断当前界面nudge有没有，并且判断有没有展示。 可能用到索引，用来记录展示的nudges的index
	if (self.showList.count <= self.nIndex) {
		self.isLock = NO;
		self.nIndex = 0;
		self.isFindView = NO;
		return;
	}
	
	NudgesModel *nudgeModel = [self.showList objectAtIndex:self.nIndex];
	self.currentModel = nudgeModel;
	if (self.currentModel.nudgesType == KNudgesType_NPS || self.currentModel.nudgesType == KNudgesType_Forms) {
		[[HJNudgesManager sharedInstance] startConstructsNudgesViewByFindView:nil isFindType:KNudgeFineType_Exist_Find];
	} else {
		// 检查是否存在当前页面
		[self checkNudgesViewExist:nudgeModel isPreview:NO];
	}
}

#pragma mark -- 检查对应的view是否存在
- (void)checkNudgesViewExist:(NudgesModel *)nudgesModel isPreview:(BOOL)isPreview {
	if (!nudgesModel) {
		return;
	}
	NudgesBaseModel *baseModel = [[NudgesBaseModel alloc] initWithMsgModel:nudgesModel];
	NSString *accessibilityIdentifier = baseModel.appExtInfoModel.accessibilityIdentifier;
	if (!isEmptyString_Nd(accessibilityIdentifier)) {
		// 判断是RN的VC还是原生的VC
		if ([baseModel.pageName isEqualToString:self.currentPageName]) {
			UIViewController *currentVC = [TKUtils topViewController];
			[self searchRNViewWithAccessibility:accessibilityIdentifier viewController:currentVC subView:currentVC.view isPreview:isPreview];
		}
	}
}

#pragma mark -- 查找对应的view
- (void)searchRNViewWithAccessibility:(NSString *)accessibility viewController:(UIViewController *)viewController subView:(UIView *)subView isPreview:(BOOL)isPreview {
	
	NSLog(@"寻找accessibility标识:%@",accessibility);
	
	int type = [self checkViewTypeForAccessibility:accessibility];
	if (type == 1) {
		// tableview
		[self getViewTableViewForVC:viewController tableView:nil view:viewController.view startTag:@"" accessibility:accessibility block:^(UIView *rctView, UITableView *tableView) {
			NSLog(@"search tableview Log");
			UIView *view = rctView;
			BOOL isExist = NO;
			
			if (tableView) {
				// 判断rctView是cell 还是 cell的子view
				if ([rctView isKindOfClass:[UITableViewCell class]]) {
					// 获取当前屏幕上所有可见的cells
					NSArray *visibleCells = [tableView visibleCells];
					// 判断cell是否在visibleCells数组中
					BOOL isVisible = [visibleCells containsObject:(UITableViewCell *)rctView];
					if (isVisible) {
						// cell在屏幕上显示
						isExist = YES;
					} else {
						// cell不在屏幕上显示
						isExist = NO;
					}
				} else {
					// cell的子view
					NSArray *list = [accessibility componentsSeparatedByString:@"_"];
					if (!IsArrEmpty_Nd(list) && list.count > 3) {
						NSString *section = list[3];
						NSString *row = list[4];
						NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[row intValue] inSection:[section intValue]];
						// 获取对应的cell
						UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
						// 获取当前屏幕上所有可见的cells
						NSArray *visibleCells = [tableView visibleCells];
						// 判断cell是否在visibleCells数组中
						BOOL isVisible = [visibleCells containsObject:cell];
						if (isVisible) {
							// cell在屏幕上显示
							BOOL subviewVisible = [self isCellSubviewVisible:indexPath subview:rctView tableview:tableView];
							if (subviewVisible) {
								// 子视图在屏幕上显示
								isExist = YES;
								
							} else {
								// 子视图不在屏幕上显示
								isExist = NO;
							}
						} else {
							// cell不在屏幕上显示
							isExist = NO;
						}
					}
				}
			} else {
				isExist = [TKUtils isDisplayedInScreen:view];
			}
			
			KNudgeFindType isFindType = KNudgeFineType_NoExist_NoFind;
			if (isExist && view) {
				NSLog(@"当前界面有，查找到了");
				isFindType = KNudgeFineType_Exist_Find;
				
			} else  if (view && !isExist) {
				NSLog(@"当前界面有，但是没有查找到了");
				isFindType = KNudgeFineType_Exist_NoFind;
				
			} else if (!isExist && !view) {
				NSLog(@"当前界面既没有，也没有查找到");
				isFindType = KNudgeFineType_NoExist_NoFind;
			}
			
			if (isPreview) {
				// 预览
				[[HJNudgesManager sharedInstance] previewConstructsNudgesViewByFindView:view isFindType:isFindType];
			} else {
				// 非预览情况下
				[[HJNudgesManager sharedInstance] startConstructsNudgesViewByFindView:view isFindType:isFindType];
			}
		}];
		
	} else {
		[self getRNViewForVC:viewController subView:subView startTag:@"" accessibility:accessibility block:^(UIView *rctView) {
			NSLog(@"search View Log");
			// 判断当前view是否在屏幕中
			UIView *view = rctView;
			BOOL isExist = [TKUtils isDisplayedInScreen:view];
			KNudgeFindType isFindType = KNudgeFineType_NoExist_NoFind;
			if (isExist && view) {
				NSLog(@"当前界面有，查找到了");
				isFindType = KNudgeFineType_Exist_Find;
				
			} else  if (view && !isExist) {
				NSLog(@"当前界面有，但是没有查找到了");
				isFindType = KNudgeFineType_Exist_NoFind;
				
			} else if (!isExist && !view) {
				NSLog(@"当前界面既没有，也没有查找到");
				isFindType = KNudgeFineType_NoExist_NoFind;
			}
			
			if (isPreview) {
				// 预览
				[[HJNudgesManager sharedInstance] previewConstructsNudgesViewByFindView:view isFindType:isFindType];
			} else {
				// 非预览情况下
				[[HJNudgesManager sharedInstance] startConstructsNudgesViewByFindView:view isFindType:isFindType];
			}
		}];
	}
}

// Native_tableView_HJTransferHistoryCell_5_UILabel_0,0,0,4,0,1
// view: ViewController.view
// accessibility：要查找到标识
- (void)getViewTableViewForVC:(UIViewController *)targetViewController tableView:(UITableView *)tableview view:(UIView *)subView startTag:(NSString *)indexStr accessibility:(NSString *)accessibility block:(void (^)(UIView *rctView, UITableView *tableView))block {
	// 判断是否是tableview
	if ([subView isKindOfClass:[UITableViewCell class]]) {
		// 如果是tableviewcell
		NSLog(@"cell accessibilityIdentifier:%@",subView.accessibilityIdentifier);
		if ([subView.accessibilityIdentifier isEqualToString:accessibility]) {
			block(subView,tableview);
		} else {
			// 递归查找子view
			[self searchTableViewCellSubsviewForTag:subView.accessibilityIdentifier tableview:tableview view:subView startTag:@"" accessibility:accessibility block:block];
		}
	} else {
		NSString *className = NSStringFromClass([subView class]);
		NSString *tagStr = [NSString stringWithFormat:@"Native_%@_%@",className,indexStr];
		if ([tagStr isEqualToString:accessibility] && block) {
			block(subView, tableview);
		}
	}
	
	if ([subView isKindOfClass:[UITableViewCell class]]) {
		
	} else {
		// 4.遍历所有的子控件
		for (int i =0; i<subView.subviews.count; i++) {
			UIView *child = subView.subviews[i];
			UITableView *table = tableview; // 获取到tableview
			if ([child isKindOfClass:[UITableView class]]) {
				table = (UITableView *)child;
			}
			[self getViewTableViewForVC:targetViewController tableView:table view:child startTag:[NSString stringWithFormat:@"%@%@%d",indexStr,isEmptyString_Nd(indexStr)?@"":@",",i] accessibility:accessibility block:block];
		}
	}
}

// 查找view
- (void)getRNViewForVC:(UIViewController *)rnViewController subView:(UIView *)subView startTag:(NSString *)indexStr accessibility:(NSString *)accessibility block:(void (^)(UIView *rctView))block {
	
	NSString *className = NSStringFromClass([subView class]);
	NSString *tagStr = [NSString stringWithFormat:@"Native_%@_%@",className,indexStr];
	if ([tagStr isEqualToString:accessibility] && block) {
		block(subView);
	}
	// 修改findindex为元素标识
	subView.isAccessibilityElement = YES;
	subView.superview.isAccessibilityElement = YES;
	
	NSMutableString * str = [NSMutableString string];
	[str appendString:indexStr];
	// 4.遍历所有的子控件
	for (int i =0; i<subView.subviews.count; i++) {
		UIView *child = subView.subviews[i];
		[self getRNViewForVC:rnViewController subView:child startTag:[NSString stringWithFormat:@"%@%@%d",indexStr,isEmptyString_Nd(indexStr)?@"":@",",i] accessibility:accessibility block:block];
	}
}

// 查找tableviewcell 的子view
- (void)searchTableViewCellSubsviewForTag:(NSString *)superAccessibility tableview:(UITableView *)tableview view:(UIView *)subView startTag:(NSString *)indexStr accessibility:(NSString *)accessibility block:(void (^)(UIView *rctView, UITableView *tableView))block {
	
	NSString *tagStr;
	if ([self isContainsViewType:subView]) {
		NSString *className = NSStringFromClass([subView class]);
		tagStr = [NSString stringWithFormat:@"%@_%@",superAccessibility,indexStr];
		if ([tagStr isEqualToString:accessibility] && block) {
			block(subView,tableview);
		}
	}
	// 遍历所有的子控件
	for (int i = 0; i<subView.subviews.count; i++) {
		UIView *child = subView.subviews[i];
		[self searchTableViewCellSubsviewForTag:tagStr tableview:tableview view:child startTag:[NSString stringWithFormat:@"%d",i] accessibility:accessibility block:block];
	}
}

// 通过判断accessibility得到对应的类型
- (int)checkViewTypeForAccessibility:(NSString *)accessibility {
	int type = 0;
	if (isEmptyString_Nd(accessibility)) {
		return 0;
	}
	// 切割
	NSArray *list = [accessibility componentsSeparatedByString:@"_"];
	if (!IsArrEmpty_Nd(list) && list.count > 0) {
		NSString *typeStr = list[1];
		if ([[typeStr lowercaseString] isEqualToString:@"tableview"]) {
			// 为tableview 类型
			return 1;
		}
	}
	return 0;
}

- (BOOL)isCellSubviewVisible:(NSIndexPath *)indexPath subview:(UIView *)subview tableview:(UITableView *)tableView {
	// 获取cell将要显示的区域
	CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
	// 将区域转换到tableView的坐标系
	CGRect onScreenRect = [tableView convertRect:cellRect toView:tableView];
	
	// 检查子视图的frame是否与tableView的可视区域相交
	CGRect subviewFrame = [subview convertRect:subview.bounds toView:tableView];
	BOOL isVisible = CGRectIntersectsRect(onScreenRect, subviewFrame);
	
	return isVisible;
}

#pragma mark -- 非预览情况
- (void)startConstructsNudgesViewByFindView:(UIView *)findView isFindType:(KNudgeFindType)type {
	if (type == KNudgeFineType_Exist_Find) {
		// 1.展示对应的nudges。
		// [self constructsNudgesViewData:baseModel view:view];
		// 2. 等这个nudge 移除后
		// 注意，要判断当前nudge是不是该页面最后一个nudeg
		// 设置 isLock = NO;
		// self.nIndex = 0
		// 调用 showNextNudges 方法进行下一个nudge 展示
		[self selectNudgesDBWithPageName:self.currentModel UIView:findView];
		return;
	} else if (type == KNudgeFineType_NoExist_NoFind) {
		// 1. 直接更新nudge的状态为展示过了
		// 注意，要判断当前nudge是不是该页面最后一个nudeg
		// 2. 设置 isLock = NO;
		// 3. self.nIndex = 0
		// 调用 showNextNudges 方法进行下一个nudge 展示
		if (self.currentModel) {
			[NdHJNudgesDBManager updateNudgesIsShowWithNudgesId:self.currentModel.nudgesId model:self.currentModel];
		}
		[self showNextNudges];
		return;
	} else if (type == KNudgeFineType_Exist_NoFind) {
		// 注意，要判断当前nudge是不是该页面最后一个nudeg
		// 1. 判断当前nudge 是不是该页面最后一个，
		// 如果是，则停止调用(不掉) showNextNudges 方法
		// 如果不是，则 self.nIndex = self.nIndex + 1; 跨过该nudges，进行下一个展示
		// 同时 设置 isLock = NO;
		// 2. 调用 showNextNudges 方法进行下一个nudge 展示
		if ([self.showList count] == 1) {
			// 最后一个
			self.isLock = NO;
			self.nIndex = 0;
			self.isFindView = NO;
		} else {
			// 不是最后一个
			self.isLock = NO;
			self.nIndex = self.nIndex + 1;
			self.isFindView = NO;
			UIViewController *VC = [TKUtils topViewController];
			NSString *className = NSStringFromClass([VC class]);
			[self queryNudgesWithPageName:className];
		}
		return;
	} else {
		// feed back
		if (self.currentModel.nudgesType == KNudgesType_NPS) {
			[self selectNudgesDBWithPageName:self.currentModel UIView:nil];
		}
		if (self.currentModel.nudgesType == KNudgesType_Rate) {
			[self selectNudgesDBWithPageName:self.currentModel UIView:nil];
		}
		if (self.currentModel.nudgesType == KNudgesType_Forms) {
			[self selectNudgesDBWithPageName:self.currentModel UIView:nil];
		}
		if (self.currentModel.nudgesType == KNudgesType_FunnelReminders) {
			[self selectNudgesDBWithPageName:self.currentModel UIView:nil];
		}
	}
}

#pragma mark -- 刚调用接口返回。 数据库根据界面查找Nudges 轮询接口
- (void)selectNudgesDBWithPageName:(NudgesModel *)model UIView:(UIView *)findView {
	if (model.nudgesType == KNudgesType_Tooltips) {
		// 如果是toolTips
		NudgesBaseModel *baseModel = [[NudgesBaseModel alloc] initWithMsgModel:model];
		self.currentBaseModel = baseModel;
		// 数据库查找数据 (唯一性)
		NSMutableArray *nudgesList = [NdHJNudgesDBManager selectNudgesDBWithNudgesId:baseModel.nudgesId campaignId:baseModel.campaignId];
		if (IsArrEmpty_Nd(nudgesList)) {
			return;
		}
		NudgesModel *nudgesModel = nudgesList[0];
		if (isEmptyString_Nd(baseModel.findIndex) || nudgesModel.isShow ) {
			return;
		}
		[HJToolTipsManager sharedInstance].nudgesModel = model;
		[HJToolTipsManager sharedInstance].baseModel = baseModel;
		[HJToolTipsManager sharedInstance].findView = findView;
		[HJToolTipsManager sharedInstance].delegate = self;
		// 开始显示
		[[HJToolTipsManager sharedInstance] startConstructsNudgesView];
		
	} else if (model.nudgesType == KNudgesType_SpotLight) {
		// Spotlight 类型
		NudgesBaseModel *baseModel = [[NudgesBaseModel alloc] initWithMsgModel:model];
		// 数据库查找数据 (唯一性)
		NSMutableArray *nudgesList = [NdHJNudgesDBManager selectNudgesDBWithNudgesId:baseModel.nudgesId campaignId:baseModel.campaignId];
		if (IsArrEmpty_Nd(nudgesList)) {
			return;
		}
		NudgesModel *nudgesModel = nudgesList[0];
		if (isEmptyString_Nd(baseModel.findIndex) || nudgesModel.isShow) {
			return;
		}
		[HJSpotlightManager sharedInstance].nudgesModel = model;
		[HJSpotlightManager sharedInstance].baseModel = baseModel;
		[HJSpotlightManager sharedInstance].findView = findView;
		[HJSpotlightManager sharedInstance].delegate = self;
		// 开始显示
		[[HJSpotlightManager sharedInstance] startConstructsNudgesView];
		
	} else if (model.nudgesType == KNudgesType_FOMOTags) {
		// POMO Tag
		NudgesBaseModel *baseModel = [[NudgesBaseModel alloc] initWithMsgModel:model];
		// 数据库查找数据 (唯一性)
		NSMutableArray *nudgesList = [NdHJNudgesDBManager selectNudgesDBWithNudgesId:baseModel.nudgesId campaignId:baseModel.campaignId];
		if (IsArrEmpty_Nd(nudgesList)) {
			return;
		}
		NudgesModel *nudgesModel = nudgesList[0];
		if (isEmptyString_Nd(baseModel.findIndex) || nudgesModel.isShow ) {
			return;
		}
		[HJPomoTagManager sharedInstance].nudgesModel = model;
		[HJPomoTagManager sharedInstance].baseModel = baseModel;
		[HJPomoTagManager sharedInstance].findView = findView;
		[HJPomoTagManager sharedInstance].delegate = self;
		// 开始显示
		[[HJPomoTagManager sharedInstance] startConstructsNudgesView];
		
	} else if (model.nudgesType == KNudgesType_Hotspots) {
		// Hot spots
		NudgesBaseModel *baseModel = [[NudgesBaseModel alloc] initWithMsgModel:model];
		// 数据库查找数据 (唯一性)
		NSMutableArray *nudgesList = [NdHJNudgesDBManager selectNudgesDBWithNudgesId:baseModel.nudgesId campaignId:baseModel.campaignId];
		NudgesModel *nudgesModel = nudgesList[0];
		if (isEmptyString_Nd(baseModel.findIndex) || nudgesModel.isShow) {
			return;
		}
		[HJHotSpotManager sharedInstance].nudgesModel = model;
		[HJHotSpotManager sharedInstance].baseModel = baseModel;
		[HJHotSpotManager sharedInstance].delegate = self;
		
	} else if (model.nudgesType == KNudgesType_FunnelReminders) {
		// Announcement
		NudgesBaseModel *baseModel = [[NudgesBaseModel alloc] initWithMsgModel:model];
		// 数据库查找数据 (唯一性)
		NSMutableArray *nudgesList = [NdHJNudgesDBManager selectNudgesDBWithNudgesId:baseModel.nudgesId campaignId:baseModel.campaignId];
		NudgesModel *nudgesModel = nudgesList[0];
		//        if (isEmptyString_Nd(baseModel.findIndex) || nudgesModel.isShow) {
		//            return;
		//        }
		[HJAnnouncementManager sharedInstance].nudgesModel = model;
		[HJAnnouncementManager sharedInstance].baseModel = baseModel;
		[HJAnnouncementManager sharedInstance].delegate = self;
		
	} else if (model.nudgesType == KNudgesType_FloatingActions) {
		// Floating Ation
		NudgesBaseModel *baseModel = [[NudgesBaseModel alloc] initWithMsgModel:model];
		// 数据库查找数据 (唯一性)
		NSMutableArray *nudgesList = [NdHJNudgesDBManager selectNudgesDBWithNudgesId:baseModel.nudgesId campaignId:baseModel.campaignId];
		NudgesModel *nudgesModel = nudgesList[0];
		if (nudgesModel.isShow) {
			return;
		}
		[HJFloatingAtionManager sharedInstance].nudgesModel = model;
		[HJFloatingAtionManager sharedInstance].baseModel = baseModel;
		[HJFloatingAtionManager sharedInstance].delegate = self;
		
	} else if (model.nudgesType == KNudgesType_NPS) {
		
		NudgesBaseModel *baseModel = [[NudgesBaseModel alloc] initWithMsgModel:model];
		// 数据库查找数据 (唯一性)
		NSMutableArray *nudgesList = [NdHJNudgesDBManager selectNudgesDBWithNudgesId:baseModel.nudgesId campaignId:baseModel.campaignId];
		NudgesModel *nudgesModel = nudgesList[0];
		[HJNPSManager sharedInstance].nudgesModel = model;
		[HJNPSManager sharedInstance].baseModel = baseModel;
		[HJNPSManager sharedInstance].delegate = self;
		
	} else if (model.nudgesType == KNudgesType_Rate) {
		NudgesBaseModel *baseModel = [[NudgesBaseModel alloc] initWithMsgModel:model];
		// 数据库查找数据 (唯一性)
		NSMutableArray *nudgesList = [NdHJNudgesDBManager selectNudgesDBWithNudgesId:baseModel.nudgesId campaignId:baseModel.campaignId];
		NudgesModel *nudgesModel = nudgesList[0];
		[HJRateManager sharedInstance].nudgesModel = model;
		[HJRateManager sharedInstance].baseModel = baseModel;
		[HJRateManager sharedInstance].delegate = self;
		
	} else if (model.nudgesType == KNudgesType_Forms) {
		NudgesBaseModel *baseModel = [[NudgesBaseModel alloc] initWithMsgModel:model];
		// 数据库查找数据 (唯一性)
		NSMutableArray *nudgesList = [NdHJNudgesDBManager selectNudgesDBWithNudgesId:baseModel.nudgesId campaignId:baseModel.campaignId];
		NudgesModel *nudgesModel = nudgesList[0];
		//        if (isEmptyString_Nd(baseModel.findIndex) || nudgesModel.isShow) {
		//            return;
		//        }
		[HJFeedBackManager sharedInstance].nudgesModel = model;
		[HJFeedBackManager sharedInstance].baseModel = baseModel;
		[HJFeedBackManager sharedInstance].delegate = self;
	}
	else {
		// 其他类型
	}
}

#pragma mark -- 展示下一个Nudges view
- (void)showNextNudges {
	NSMutableArray *nudgesList = [NdHJNudgesDBManager selectNudgesDBWithPageName:self.currentPageName];
	if (IsArrEmpty_Nd(nudgesList)) {
		self.isLock = NO;
		self.nIndex = 0;
		self.isFindView = NO;
	} else {
		self.isLock = NO;
		self.nIndex = 0;
		self.isFindView = NO;
		UIViewController *VC = [TKUtils topViewController];
		NSString *className = NSStringFromClass([VC class]);
		[self queryNudgesWithPageName:className];
	}
}

#pragma mark -- ToolTipsEventDelegate
// 按钮点击事件
- (void)ToolTipsClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url isClose:(BOOL)isClose invokeAction:(nonnull NSString *)invokeAction buttonName:(nonnull NSString *)buttonName model:(nonnull NudgesBaseModel *)model {
	
	NSString *nudgesId = [NSString stringWithFormat:@"%ld",(long)model.nudgesId];
	NSString *nudgesName = isEmptyString_Nd(model.nudgesName)?@"":model.nudgesName;
	NSString *campaignCode = [NSString stringWithFormat:@"%ld",(long)model.campaignId];
	NSString *pageName = isEmptyString_Nd(self.currentPageName)?@"":self.currentPageName;
	
	NSDictionary *bodyDic = @{@"nudgesId":nudgesId,@"nudgesName":nudgesName,@"pageName":pageName,@"contactId":model.contactId ,@"nudgesType":@(model.nudgesType),@"batchId":@"",@"source":@"1",@"buttonName":buttonName,@"isClose":@(isClose),@"campaignCode":campaignCode,@"invokeAction":invokeAction,@"jumpUrl":url,@"schemeType":@(jumpType),@"eventTypeId":@"onNudgesButtonClick"};
	
	if (self.buttonClickEventBlock) {
		self.buttonClickEventBlock(@"ButtonClickEvent", bodyDic);
	}
}

// nudges显示出来后回调代理
- (void)ToolTipsShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName {
	
	if (self.nudgesShowEventBlock) {
		self.nudgesShowEventBlock(nudgesId, nudgesName, nudgesType, eventTypeId, contactId, campaignCode, batchId, source, pageName);
	}
}

#pragma mark -- SpotlightEventDelegate
// 按钮点击事件
- (void)SpotlightClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url isClose:(BOOL)isClose invokeAction:(nonnull NSString *)invokeAction buttonName:(nonnull NSString *)buttonName model:(nonnull NudgesBaseModel *)model{
	
	NSString *nudgesId = [NSString stringWithFormat:@"%ld",(long)model.nudgesId];
	NSString *nudgesName = isEmptyString_Nd(model.nudgesName)?@"":model.nudgesName;
	NSString *campaignCode = [NSString stringWithFormat:@"%ld",(long)model.campaignId];
	NSString *pageName = isEmptyString_Nd(self.currentPageName)?@"":self.currentPageName;
	
	NSDictionary *bodyDic = @{@"nudgesId":nudgesId,@"nudgesName":nudgesName,@"pageName":pageName,@"contactId":model.contactId ,@"nudgesType":@(model.nudgesType),@"batchId":@"",@"source":@"1",@"buttonName":buttonName,@"isClose":@(isClose),@"campaignCode":campaignCode,@"invokeAction":invokeAction,@"jumpUrl":url,@"schemeType":@(jumpType),@"eventTypeId":@"onNudgesButtonClick"};
	
	if (self.buttonClickEventBlock) {
		self.buttonClickEventBlock(@"ButtonClickEvent", bodyDic);
	}
}

// nudges显示出来后回调代理
- (void)SpotlightShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName {
	
	if (self.nudgesShowEventBlock) {
		self.nudgesShowEventBlock(nudgesId, nudgesName, nudgesType, eventTypeId, contactId, campaignCode, batchId, source, pageName);
	}
}

#pragma mark -- PomoTagEventDelegate
// 按钮点击事件
- (void)PomoTagClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url {
	//  if (_delegate && [_delegate conformsToProtocol:@protocol(PomoTagEventDelegate)]) {
	//    if (_delegate && [_delegate respondsToSelector:@selector(NudgesClickEventByType:jumpType:url:)]) {
	//      [_delegate NudgesClickEventByType:KNudgesType_FOMOTags jumpType:jumpType url:url];
	//    }
	//  }
}

#pragma mark -- HotSpotEventDelegate
// 按钮点击事件
- (void)HotSpotClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url isClose:(BOOL)isClose invokeAction:(nonnull NSString *)invokeAction buttonName:(nonnull NSString *)buttonName model:(nonnull NudgesBaseModel *)model {
	
	NSString *nudgesId = [NSString stringWithFormat:@"%ld",(long)model.nudgesId];
	NSString *nudgesName = isEmptyString_Nd(model.nudgesName)?@"":model.nudgesName;
	NSString *campaignCode = [NSString stringWithFormat:@"%ld",(long)model.campaignId];
	NSString *pageName = isEmptyString_Nd(self.currentPageName)?@"":self.currentPageName;
	
	NSDictionary *bodyDic = @{@"nudgesId":nudgesId,@"nudgesName":nudgesName,@"pageName":pageName,@"contactId":model.contactId ,@"nudgesType":@(model.nudgesType),@"batchId":@"",@"source":@"1",@"buttonName":buttonName,@"isClose":@(isClose),@"campaignCode":campaignCode,@"invokeAction":invokeAction,@"jumpUrl":url,@"schemeType":@(jumpType),@"eventTypeId":@"onNudgesButtonClick"};
	
	if (self.buttonClickEventBlock) {
		self.buttonClickEventBlock(@"ButtonClickEvent", bodyDic);
	}
}

// nudges显示出来后回调代理
- (void)HotSpotShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName {
	
	if (self.nudgesShowEventBlock) {
		self.nudgesShowEventBlock(nudgesId, nudgesName, nudgesType, eventTypeId, contactId, campaignCode, batchId, source, pageName);
	}
}

#pragma mark -- FloatingAtionEventDelegate
- (void)FloatingAtionClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url isClose:(BOOL)isClose invokeAction:(nonnull NSString *)invokeAction buttonName:(nonnull NSString *)buttonName model:(nonnull NudgesBaseModel *)model{
	
	NSString *nudgesId = [NSString stringWithFormat:@"%ld",(long)model.nudgesId];
	NSString *nudgesName = isEmptyString_Nd(model.nudgesName)?@"":model.nudgesName;
	NSString *campaignCode = [NSString stringWithFormat:@"%ld",(long)model.campaignId];
	NSString *pageName = isEmptyString_Nd(self.currentPageName)?@"":self.currentPageName;
	
	NSDictionary *bodyDic = @{@"nudgesId":nudgesId,@"nudgesName":nudgesName,@"pageName":pageName,@"contactId":model.contactId ,@"nudgesType":@(model.nudgesType),@"batchId":@"",@"source":@"1",@"buttonName":buttonName,@"isClose":@(isClose),@"campaignCode":campaignCode,@"invokeAction":invokeAction,@"jumpUrl":url,@"schemeType":@(jumpType),@"eventTypeId":@"onNudgesButtonClick"};
	
	if (self.buttonClickEventBlock) {
		self.buttonClickEventBlock(@"ButtonClickEvent", bodyDic);
	}
}

// nudges显示出来后回调代理
- (void)FloatingAtionShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName {
	
	if (self.nudgesShowEventBlock) {
		self.nudgesShowEventBlock(nudgesId, nudgesName, nudgesType, eventTypeId, contactId, campaignCode, batchId, source, pageName);
	}
}

#pragma mark -- NPSEventDelegate
- (void)NPSClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url isClose:(BOOL)isClose invokeAction:(nonnull NSString *)invokeAction buttonName:(nonnull NSString *)buttonName model:(nonnull NudgesBaseModel *)model{
	
	NSString *nudgesId = [NSString stringWithFormat:@"%ld",(long)model.nudgesId];
	NSString *nudgesName = isEmptyString_Nd(model.nudgesName)?@"":model.nudgesName;
	NSString *campaignCode = [NSString stringWithFormat:@"%ld",(long)model.campaignId];
	NSString *pageName = isEmptyString_Nd(self.currentPageName)?@"":self.currentPageName;
	
	NSDictionary *bodyDic = @{@"nudgesId":nudgesId,@"nudgesName":nudgesName,@"pageName":pageName,@"contactId":model.contactId ,@"nudgesType":@(model.nudgesType),@"batchId":@"",@"source":@"1",@"buttonName":buttonName,@"isClose":@(isClose),@"campaignCode":campaignCode,@"invokeAction":invokeAction,@"jumpUrl":url,@"schemeType":@(jumpType),@"eventTypeId":@"onNudgesButtonClick"};
	
	if (self.buttonClickEventBlock) {
		self.buttonClickEventBlock(@"ButtonClickEvent", bodyDic);
	}
}

// nudges显示出来后回调代理
- (void)NPSShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName {
	
	if (self.nudgesShowEventBlock) {
		self.nudgesShowEventBlock(nudgesId, nudgesName, nudgesType, eventTypeId, contactId, campaignCode, batchId, source, pageName);
	}
}

- (void)NPSSubmitByScore:(NSInteger)score {
	//  if (_delegate && [_delegate conformsToProtocol:@protocol(NudgesEventDelegate)]) {
	//    if (_delegate && [_delegate respondsToSelector:@selector(NudgesSubmitByScore:thumns:)]) {
	//      [_delegate NudgesSubmitByScore:score thumns:0];
	//    }
	//  }
}

#pragma mark -- FeedBackEventDelegate
- (void)FeedBackClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url isClose:(BOOL)isClose invokeAction:(nonnull NSString *)invokeAction buttonName:(nonnull NSString *)buttonName model:(nonnull NudgesBaseModel *)model {
	
	NSString *nudgesId = [NSString stringWithFormat:@"%ld",(long)model.nudgesId];
	NSString *nudgesName = isEmptyString_Nd(model.nudgesName)?@"":model.nudgesName;
	NSString *campaignCode = [NSString stringWithFormat:@"%ld",(long)model.campaignId];
	NSString *pageName = isEmptyString_Nd(self.currentPageName)?@"":self.currentPageName;
	
	NSDictionary *bodyDic = @{@"nudgesId":nudgesId,@"nudgesName":nudgesName,@"pageName":pageName,@"contactId":model.contactId ,@"nudgesType":@(model.nudgesType),@"batchId":@"",@"source":@"1",@"buttonName":buttonName,@"isClose":@(isClose),@"campaignCode":campaignCode,@"invokeAction":invokeAction,@"jumpUrl":url,@"schemeType":@(jumpType),@"eventTypeId":@"onNudgesButtonClick"};
	
	if (self.buttonClickEventBlock) {
		self.buttonClickEventBlock(@"ButtonClickEvent", bodyDic);
	}
}

// nudges显示出来后回调代理
- (void)FeedBackShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName {
	
	if (self.nudgesShowEventBlock) {
		self.nudgesShowEventBlock(nudgesId, nudgesName, nudgesType, eventTypeId, contactId, campaignCode, batchId, source, pageName);
	}
}

#pragma mark -- RateEventDelegate
- (void)RateClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url isClose:(BOOL)isClose invokeAction:(NSString *)invokeAction buttonName:(NSString *)buttonName model:(NudgesBaseModel *)model {
	
	NSString *nudgesId = [NSString stringWithFormat:@"%ld",(long)model.nudgesId];
	NSString *nudgesName = isEmptyString_Nd(model.nudgesName)?@"":model.nudgesName;
	NSString *campaignCode = [NSString stringWithFormat:@"%ld",(long)model.campaignId];
	NSString *pageName = isEmptyString_Nd(self.currentPageName)?@"":self.currentPageName;
	
	NSDictionary *bodyDic = @{@"nudgesId":nudgesId,@"nudgesName":nudgesName,@"pageName":pageName,@"contactId":model.contactId ,@"nudgesType":@(model.nudgesType),@"batchId":@"",@"source":@"1",@"buttonName":buttonName,@"isClose":@(isClose),@"campaignCode":campaignCode,@"invokeAction":invokeAction,@"jumpUrl":url,@"schemeType":@(jumpType),@"eventTypeId":@"onNudgesButtonClick"};
	
	if (self.buttonClickEventBlock) {
		self.buttonClickEventBlock(@"ButtonClickEvent", bodyDic);
	}
}

// nudges显示出来后回调代理
- (void)RateShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName {
	
	if (self.nudgesShowEventBlock) {
		self.nudgesShowEventBlock(nudgesId, nudgesName, nudgesType, eventTypeId, contactId, campaignCode, batchId, source, pageName);
	}
}


- (void)RateSubmitByScore:(double)score thumb:(NSInteger)thumbsScore {
	//  if (_delegate && [_delegate conformsToProtocol:@protocol(RateEventDelegate)]) {
	//    if (_delegate && [_delegate respondsToSelector:@selector(NudgesSubmitByScore:thumns:)]) {
	//      [_delegate NudgesSubmitByScore:score thumns:thumbsScore];
	//    }
	//  }
}

#pragma mark -- AnnouncementEventDelegate
- (void)AnnouncementSubmitByScore:(NSInteger)score {
	//  if (_delegate && [_delegate conformsToProtocol:@protocol(NudgesEventDelegate)]) {
	//    if (_delegate && [_delegate respondsToSelector:@selector(NudgesSubmitByScore:thumns:)]) {
	//      [_delegate NudgesSubmitByScore:score thumns:0];
	//    }
	//  }
}

- (void)AnnouncementClickEventByType:(KButtonsUrlJumpType)jumpType Url:(NSString *)url isClose:(BOOL)isClose invokeAction:(nonnull NSString *)invokeAction buttonName:(nonnull NSString *)buttonName model:(nonnull NudgesBaseModel *)model {
	
	NSString *nudgesId = [NSString stringWithFormat:@"%ld",(long)model.nudgesId];
	NSString *nudgesName = isEmptyString_Nd(model.nudgesName)?@"":model.nudgesName;
	NSString *campaignCode = [NSString stringWithFormat:@"%ld",(long)model.campaignId];
	NSString *pageName = isEmptyString_Nd(self.currentPageName)?@"":self.currentPageName;
	
	NSDictionary *bodyDic = @{@"nudgesId":nudgesId,@"nudgesName":nudgesName,@"pageName":pageName,@"contactId":model.contactId ,@"nudgesType":@(model.nudgesType),@"batchId":@"",@"source":@"1",@"buttonName":buttonName,@"isClose":@(isClose),@"campaignCode":campaignCode,@"invokeAction":invokeAction,@"jumpUrl":url,@"schemeType":@(jumpType),@"eventTypeId":@"onNudgesButtonClick"};
	
	if (self.buttonClickEventBlock) {
		self.buttonClickEventBlock(@"ButtonClickEvent", bodyDic);
	}
}

// nudges显示出来后回调代理
- (void)AnnouncementShowEventByNudgesId:(NSInteger)nudgesId nudgesName:(NSString *)nudgesName nudgesType:(KNudgesType)nudgesType eventTypeId:(NSString *)eventTypeId contactId:(NSString *)contactId campaignCode:(NSInteger)campaignCode batchId:(NSString *)batchId source:(NSString *)source pageName:(NSString *)pageName {
	
	if (self.nudgesShowEventBlock) {
		self.nudgesShowEventBlock(nudgesId, nudgesName, nudgesType, eventTypeId, contactId, campaignCode, batchId, source, pageName);
	}
}

#pragma mark -- 上报数据
// score:反馈得分
// thumbResult:点赞点踩结果，1-点赞；0-点踩
// options:反馈选项，多个使用英文逗号分隔
// comments:反馈备注
// feedbackDuration:反馈时长（从Nudge展示到点击提交的市场）
- (void)nudgesFeedBackWithNudgesId:(NSInteger)nudgesId contactId:(NSString *)contactId score:(NSString *)score thumbResult:(NSString *)thumbResult options:(NSString *)options comments:(NSString *)comments feedbackDuration:(NSString *)feedbackDuration {
	
	NdHJHttpRequest *request = [[NdHJHttpRequest alloc] init];
	request.httpMethod = NdHJHttpMethodPOST;
	NSString *reqUrl = [NSString stringWithFormat:@"%@nudges/contact/feedback",self.configParametersModel.baseUrl];
	request.requestUrl = reqUrl;
	request.requestParams = @{
		@"nudgesId": @(nudgesId),
		@"contactId": contactId,
		@"identityType": [NSNumber numberWithInt:(int)self.configParametersModel.identityType],
		@"identityId": [NSNumber numberWithLong:self.configParametersModel.identityId],
		@"channelCode": @"Nudges",
		@"adviceCode": @"Nudges",
		@"deviceSystem": @"iOS",
		@"accNbr":isEmptyString_Nd(self.configParametersModel.accNbr) ? @"" : self.configParametersModel.accNbr,
		@"random":[TKUtils uuidString],
		@"deviceToken":[self getDeviceUUID],
		@"appId":self.configParametersModel.appId,
		@"score":score,
		@"thumbResult":thumbResult,
		@"options":options,
		@"comments":comments,
		@"feedbackDuration":feedbackDuration
	};
	[[NdHJHttpSessionManager sharedInstance] sendRequest:request complete:^(NdHJHttpReponse * _Nonnull response) {
		if (!response.serverError) {
		} else {
		}
	}];
}

#pragma mark -- 字体
/// SF-Pro-Display-HeavyItalic 斜体加粗
/// @param fontSize 字号
/// @param familyName 字体
/// @param bold 加粗
/// @param italic 斜体
/// @param weight 加粗量级
- (UIFont *)SFDisplayFontWithSize:(CGFloat)fontSize familyName:(NSString *)familyName bold:(BOOL)bold itatic:(BOOL)italic weight:(UIFontWeight)weight  {
	UIFont *font;
	if (isEmptyString_Nd(familyName)) {
		font = [FontManager setNormalFontSize:fontSize];
	} else {
		font = [UIFont fontWithName:familyName size:fontSize];
	}
	
	UIFontDescriptorSymbolicTraits symbolicTraits = 0;
	if (italic) {
		symbolicTraits |= UIFontDescriptorTraitItalic;
	}
	if (bold) {
		symbolicTraits |= UIFontDescriptorTraitBold;
	}
	UIFont *specialFont = [UIFont fontWithDescriptor:[[font fontDescriptor] fontDescriptorWithSymbolicTraits:symbolicTraits] size:font.pointSize];
	return specialFont;
}

#pragma mark -- 截屏
- (UIImage *)currentWindowScreenShot {
	CGSize imageSize = CGSizeZero;
	//屏幕朝向
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsPortrait(orientation))
		imageSize = [UIScreen mainScreen].bounds.size;
	else
		imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
	
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	//按理应取用户看见的那个window
	for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, window.center.x, window.center.y);
		CGContextConcatCTM(context, window.transform);
		CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
		if (orientation == UIInterfaceOrientationLandscapeLeft) {
			CGContextRotateCTM(context, M_PI_2);
			CGContextTranslateCTM(context, 0, -imageSize.width);
		} else if (orientation == UIInterfaceOrientationLandscapeRight) {
			CGContextRotateCTM(context, -M_PI_2);
			CGContextTranslateCTM(context, -imageSize.height, 0);
		} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
			CGContextRotateCTM(context, M_PI);
			CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
		}
		if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
			[window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
		} else {
			[window.layer renderInContext:context];
		}
		CGContextRestoreGState(context);
	}
	//截屏图片
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	//截屏图片t处理后
	//    UIImage *gaussianImage = [self coreGaussianBlurImage:image blurNumber:8];
	//    //生成控件
	//    UIImageView *bgImgv = [[UIImageView alloc] initWithImage:gaussianImage];
	//    bgImgv.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
	//    self.screenShotImageV = bgImgv;
	return image;
}

#pragma mark -- Other
// 取设备型号
- (NSString *)getCurrentDeviceModel {
	struct utsname systemInfo;
	uname(&systemInfo);
	
	NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
	if([platform isEqualToString:@"iPhone1,1"])return@"iPhone 2G";
	if([platform isEqualToString:@"iPhone1,2"])return@"iPhone 3G";
	if([platform isEqualToString:@"iPhone2,1"])return@"iPhone 3GS";
	if([platform isEqualToString:@"iPhone3,1"])return@"iPhone 4";
	if([platform isEqualToString:@"iPhone3,2"])return@"iPhone 4";
	if([platform isEqualToString:@"iPhone3,3"])return@"iPhone 4";
	if([platform isEqualToString:@"iPhone4,1"])return@"iPhone 4S";
	if([platform isEqualToString:@"iPhone5,1"])return@"iPhone 5";
	if([platform isEqualToString:@"iPhone5,2"])return@"iPhone 5";
	if([platform isEqualToString:@"iPhone5,3"])return@"iPhone 5c";
	if([platform isEqualToString:@"iPhone5,4"])return@"iPhone 5c";
	if([platform isEqualToString:@"iPhone6,1"])return@"iPhone 5s";
	if([platform isEqualToString:@"iPhone6,2"])return@"iPhone 5s";
	if([platform isEqualToString:@"iPhone7,1"])return@"iPhone 6 Plus";
	if([platform isEqualToString:@"iPhone7,2"])return@"iPhone 6";
	if([platform isEqualToString:@"iPhone8,1"])return@"iPhone 6s";
	if([platform isEqualToString:@"iPhone8,2"])return@"iPhone 6s Plus";
	if([platform isEqualToString:@"iPhone8,4"])return@"iPhone SE";
	if([platform isEqualToString:@"iPhone9,1"])return@"iPhone 7";
	if([platform isEqualToString:@"iPhone9,2"])return@"iPhone 7 Plus";
	if([platform isEqualToString:@"iPhone10,1"])return@"iPhone 8";
	if([platform isEqualToString:@"iPhone10,4"])return@"iPhone 8";
	if([platform isEqualToString:@"iPhone10,2"])return@"iPhone 8 Plus";
	if([platform isEqualToString:@"iPhone10,5"])return@"iPhone 8 Plus";
	if([platform isEqualToString:@"iPhone10,3"])return@"iPhone X";
	if([platform isEqualToString:@"iPhone10,6"])return@"iPhone X";
	if([platform isEqualToString:@"iPhone11,8"])return@"iPhone XR";
	if([platform isEqualToString:@"iPhone11,2"])return@"iPhone XS";
	if([platform isEqualToString:@"iPhone11,4"])return@"iPhone XS Max";
	if([platform isEqualToString:@"iPhone11,6"])return@"iPhone XS Max";
	if([platform isEqualToString:@"iPhone12,1"])return@"iPhone 11";
	if([platform isEqualToString:@"iPhone12,3"])return@"iPhone 11 Pro";
	if([platform isEqualToString:@"iPhone12,5"])return@"iPhone 11 Pro Max";
	if([platform isEqualToString:@"iPhone12,8"])return@"iPhone SE 2020";
	if([platform isEqualToString:@"iPhone13,1"])return@"iPhone 12 mini";
	if([platform isEqualToString:@"iPhone13,2"])return@"iPhone 12";
	if([platform isEqualToString:@"iPhone13,3"])return@"iPhone 12 Pro";
	if([platform isEqualToString:@"iPhone13,4"])return@"iPhone 12 Pro Max";
	if([platform isEqualToString:@"iPhone14,4"])return@"iPhone 13 mini";
	if([platform isEqualToString:@"iPhone14,5"])return@"iPhone 13";
	if([platform isEqualToString:@"iPhone14,2"])return@"iPhone 13 Pro";
	if([platform isEqualToString:@"iPhone14,3"])return@"iPhone 13 Pro Max";
	if([platform isEqualToString:@"iPhone14,6"])return@"iPhone SE 2022";
	//新添加
	if([platform isEqualToString:@"iPhone14,7"])return@"iPhone 14";
	if([platform isEqualToString:@"iPhone14,8"])return@"iPhone 14 Plus";
	if([platform isEqualToString:@"iPhone15,2"])return@"iPhone 14 Pro";
	if([platform isEqualToString:@"iPhone15,3"])return@"iPhone Pro Max";
	
	//结束
	if([platform isEqualToString:@"iPod1,1"])return@"iPod Touch 1G";
	if([platform isEqualToString:@"iPod2,1"])return@"iPod Touch 2G";
	if([platform isEqualToString:@"iPod3,1"])return@"iPod Touch 3G";
	if([platform isEqualToString:@"iPod4,1"])return@"iPod Touch 4G";
	if([platform isEqualToString:@"iPod5,1"])return@"iPod Touch 5G";
	if([platform isEqualToString:@"iPad1,1"])return@"iPad 1G";
	if([platform isEqualToString:@"iPad2,1"])return@"iPad 2";
	if([platform isEqualToString:@"iPad2,2"])return@"iPad 2";
	if([platform isEqualToString:@"iPad2,3"])return@"iPad 2";
	if([platform isEqualToString:@"iPad2,4"])return@"iPad 2";
	if([platform isEqualToString:@"iPad2,5"])return@"iPad Mini 1G";
	if([platform isEqualToString:@"iPad2,6"])return@"iPad Mini 1G";
	if([platform isEqualToString:@"iPad2,7"])return@"iPad Mini 1G";
	if([platform isEqualToString:@"iPad3,1"])return@"iPad 3";
	if([platform isEqualToString:@"iPad3,2"])return@"iPad 3";
	if([platform isEqualToString:@"iPad3,3"])return@"iPad 3";
	if([platform isEqualToString:@"iPad3,4"])return@"iPad 4";
	if([platform isEqualToString:@"iPad3,5"])return@"iPad 4";
	if([platform isEqualToString:@"iPad3,6"])return@"iPad 4";
	if([platform isEqualToString:@"iPad4,1"])return@"iPad Air";
	if([platform isEqualToString:@"iPad4,2"])return@"iPad Air";
	if([platform isEqualToString:@"iPad4,3"])return@"iPad Air";
	if([platform isEqualToString:@"iPad4,4"])return@"iPad Mini 2G";
	if([platform isEqualToString:@"iPad4,5"])return@"iPad Mini 2G";
	if([platform isEqualToString:@"iPad4,6"])return@"iPad Mini 2G";
	if([platform isEqualToString:@"iPad4,7"])return@"iPad Mini 3";
	if([platform isEqualToString:@"iPad4,8"])return@"iPad Mini 3";
	if([platform isEqualToString:@"iPad4,9"])return@"iPad Mini 3";
	if([platform isEqualToString:@"iPad5,1"])return@"iPad Mini 4";
	if([platform isEqualToString:@"iPad5,2"])return@"iPad Mini 4";
	if([platform isEqualToString:@"iPad5,3"])return@"iPad Air 2";
	if([platform isEqualToString:@"iPad5,4"])return@"iPad Air 2";
	if([platform isEqualToString:@"iPad6,3"])return@"iPad Pro 9.7";
	if([platform isEqualToString:@"iPad6,4"])return@"iPad Pro 9.7";
	if([platform isEqualToString:@"iPad6,7"])return@"iPad Pro 12.9";
	if([platform isEqualToString:@"iPad6,8"])return@"iPad Pro 12.9";
	if([platform isEqualToString:@"i386"])return@"iPhone Simulator";
	if([platform isEqualToString:@"x86_64"])return@"iPhone Simulator";
	return platform;
}

// 获取view相对于window的绝对地址
- (CGRect)getAddress:(UIView *)view {
	CGRect rect=[view convertRect: view.bounds toView:[UIApplication sharedApplication].delegate.window];
	return rect;
}

// 获取设备device Id
- (NSString *)getDeviceUUID {
	UIDevice *currentDevice = [UIDevice currentDevice];
	NSString *deviceId = [[currentDevice identifierForVendor] UUIDString];
	if (isEmptyString_Nd(deviceId)) {
		return @"";
	}
	return deviceId;
}

// 获取当前时间戳
- (NSString *)getCurrentTimestamp {
	//获取系统当前的时间戳 13位，毫秒级；10位，秒级
	NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
	NSTimeInterval time = [date timeIntervalSince1970];
	NSDecimalNumber *timeNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", time]];
	NSDecimalNumber *baseNumber = [NSDecimalNumber decimalNumberWithString:@"1000"];
	NSDecimalNumber *result = [timeNumber decimalNumberByMultiplyingBy:baseNumber];
	return [NSString stringWithFormat:@"%ld", (long)[result integerValue]];
}

#pragma mark -- 判断是否是同一周
- (BOOL)isSameWeek:(NSDate *)date1 date2:(NSDate *)date2 {
	// 日历对象
	NSCalendar *calendar = [NSCalendar currentCalendar];
	// 一周开始默认为星期天=1。
	calendar.firstWeekday = 1;
	
	unsigned unitFlag = NSCalendarUnitWeekOfYear | NSCalendarUnitYearForWeekOfYear;
	NSDateComponents *comp1 = [calendar components:unitFlag fromDate:date1];
	NSDateComponents *comp2 = [calendar components:unitFlag fromDate:date2];
	/// 年份和周数相同，即判断为同一周
	/// NSCalendarUnitYearForWeekOfYear已经帮转换不同年份的周所属了，比如2019.12.31是等于2020的。这里不使用year，使用用yearForWeekOfYear
	return (([comp1 yearForWeekOfYear] == [comp2 yearForWeekOfYear]) && ([comp1 weekOfYear] == [comp2 weekOfYear]));
}

#pragma mark -- 判断是否同一天
- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2 {
	NSCalendar* calendar = [NSCalendar currentCalendar];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
	NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
	
	return [comp1 day]   == [comp2 day] &&
	[comp1 month] == [comp2 month] &&
	[comp1 year]  == [comp2 year];
}

#pragma mark -- 判断是否同一小时
- (BOOL)isSameHour:(NSDate*)date1 date2:(NSDate*)date2 {
	NSCalendar* calendar = [NSCalendar currentCalendar];
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit;
	NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
	NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
	
	return [comp1 day]   == [comp2 day] &&
	[comp1 month] == [comp2 month] &&
	[comp1 year]  == [comp2 year] &&
	[comp1 hour] == [comp2 hour];
}

#pragma mark -- 配对Nudge(URL Scheme)
/**
 打开Nudges
 @param url   URL
 */
- (void)openNudgesUrl:(NSURL*)url {
	NSDictionary *dic = [self paramerWithURL:url];
	
	// 解析source
	NSString *sourceVal = [dic objectForKey:@"source"];
	[HJNudgesManager sharedInstance].sourceType = KSourceType_default;
	if (!isEmptyString_Nd(sourceVal)) {
		[HJNudgesManager sharedInstance].sourceType = KSourceType_ceg;
	}
	
	// 解析matchcode
	// nudges://match?matchcode={matchcode}
	// nudges://match?matchcode=${obj.matchcode}&source=ceg
	NSString *matchcodeVal = [dic objectForKey:@"matchcode"];
	NSLog(@"matchcode:%@",matchcodeVal);
	if (!isEmptyString_Nd(matchcodeVal)) {
		// 上报设备信息 设备绑定
		[[HJNudgesManager sharedInstance] uploadDeviceInfoWithMatchCode:matchcodeVal];
	}
	
	// 解析configcode
	// nudges://connect?configcode={configcode}
	// nudges://connect?configcode=${obj.configcode}&source=ceg
	NSString *configcodeVal = [dic objectForKey:@"configcode"];
	NSLog(@"configcode:%@",configcodeVal);
	if (!isEmptyString_Nd(configcodeVal)) {
		// 上报设备信息 设备绑定   /mccm/nudges/socket
		[[HJNudgesManager sharedInstance] connectWebSocketByConfigCode:configcodeVal];
	}
	
	if ([url.absoluteString containsString:@"source="]) {
		NSRange range = [url.absoluteString rangeOfString:@"source="];
		if (range.location == NSNotFound) {
		} else {
			NSUInteger startIndex = range.location + range.length;
			NSString *sourceCode = [url.absoluteString substringFromIndex:startIndex];
			NSLog(@"sourceCode:%@",sourceCode);
			[HJNudgesManager sharedInstance].sourceType = KSourceType_ceg;
		}
	}
	
	//    nudges://match?matchcode={matchcode}
	//    nudges://match?matchcode=${obj.matchcode}&source=ceg
	if ([url.absoluteString containsString:@"matchcode="]) {
		NSRange range = [url.absoluteString rangeOfString:@"matchcode="];
		if (range.location == NSNotFound) {
		} else {
			NSUInteger startIndex = range.location + range.length;
			NSString *matchcode = [url.absoluteString substringFromIndex:startIndex];
			NSLog(@"matchcode:%@",matchcode);
			// 上报设备信息 设备绑定
			[[HJNudgesManager sharedInstance] uploadDeviceInfoWithMatchCode:matchcode];
		}
	}
	
	//    nudges://connect?configcode={configcode}
	//    nudges://connect?configcode=${obj.configcode}&source=ceg
	if ([url.absoluteString containsString:@"configcode="]) {
		NSRange range = [url.absoluteString rangeOfString:@"configcode="];
		if (range.location == NSNotFound) {
		} else {
			NSUInteger startIndex = range.location + range.length;
			NSString *configCode = [url.absoluteString substringFromIndex:startIndex];
			NSLog(@"configCode:%@",configCode);
			// 上报设备信息 设备绑定   /mccm/nudges/socket
			[[HJNudgesManager sharedInstance] connectWebSocketByConfigCode:configCode];
		}
	}
}

// 上报设备信息
- (void)uploadDeviceInfoWithMatchCode:(NSString *)matchCode {
	// 获取设备device Id
	UIDevice *currentDevice = [UIDevice currentDevice];
	NSString *deviceId = [[currentDevice identifierForVendor] UUIDString];
	if (isEmptyString_Nd(matchCode) || isEmptyString_Nd(deviceId)) {
		NSLog(@"设备匹配码或者Device ID不能为空");
		return;
	}
	// 获取设备品牌
	NSString *brand = [self getCurrentDeviceModel];
	// 获取设备系统信息
	NSString *os = @"IOS";
	// 获取设备系统版本
	NSString *osVersion = [[UIDevice currentDevice] systemVersion];
	NSLog(@"\n  设备基本信息:\n  MatchCode:%@ \n  Device ID:%@ \n  Brand:%@ \n  OS:%@ \n  OsVersion:%@ ",matchCode,deviceId,brand,os,osVersion);
	
	// 调用上传接口 /mccm/nudges/device/match 进行匹配
	NdHJHttpRequest *request = [[NdHJHttpRequest alloc] init];
	request.httpMethod = NdHJHttpMethodPOST;
	NSString *reqUrl = [NSString stringWithFormat:@"%@nudges/device/match",self.configParametersModel.baseUrl];
	request.requestUrl = reqUrl;
	request.requestParams = @{
		@"matchCode": matchCode,
		@"deviceCode": deviceId,
		@"brand": isEmptyString_Nd(brand)?@"":brand,
		@"os": @"iOS",
		@"width": [NSString stringWithFormat:@"%ld",(long)kScreenWidth],
		@"height": [NSString stringWithFormat:@"%ld",(long)kScreenHeight],
	};
	[[NdHJHttpSessionManager sharedInstance] sendRequest:request complete:^(NdHJHttpReponse * _Nonnull response) {
		if (!response.serverError) {
			NSString *code = [response.responseObject objectForKey:@"code"];
			NSString *msg = @"";
			if ([code isEqualToString:@"MCCM-NUDGES-SUCC-000"]) {
				msg = @"Matching success";
			} else if ([code isEqualToString:@"MCCM-NUDGES-ERR-001"]) {
				msg = @"Pairing operation timeout";
			} else if ([code isEqualToString:@"MCCM-NUDGES-ERR-002"]) {
				msg = @"Pairing anomalies";
			} else {
				msg = [response.responseObject objectForKey:@"msg"];
			}
			[SNAlertMessage displayMessageInView:[TKUtils topViewController].view Message:msg];
		} else {
			[SNAlertMessage displayMessageInView:[TKUtils topViewController].view Message:@"Device binding exception"];
		}
	}];
}

- (NSDictionary *)paramerWithURL:(NSURL *) url {
	NSMutableDictionary *paramer = [[NSMutableDictionary alloc]init];
	//创建url组件类
	NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:url.absoluteString];
	//遍历所有参数，添加入字典
	[urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		[paramer setObject:obj.value forKey:obj.name];
	}];
	return paramer;
}

// 控件类型判断
- (BOOL)isContainsViewType:(UIView *)view {
	if ([view isKindOfClass:[UILabel class]]
		|| [view isKindOfClass:[UIImageView class]]
		|| [view isKindOfClass:[UILabel class]]
		|| [view isKindOfClass:[UIButton class]]
		|| [view isKindOfClass:[UITextField class]]
		|| [view isKindOfClass:[UITextView class]]
		|| [view isKindOfClass:[UISwitch class]]
		|| [view isKindOfClass:[UIBarButtonItem class]]
		|| [view isKindOfClass:[UISearchBar class]]
		|| [view isKindOfClass:[UIPageControl class]]
		|| [view isKindOfClass:[UISlider class]]
		|| [view isKindOfClass:[UIProgressView class]]
		|| [view isKindOfClass:[UIView class]]) {
		
		return YES;
	}
	return NO;
}

@end
