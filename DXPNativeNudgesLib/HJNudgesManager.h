//
//  HJNudgesManager.h
//  CLPApp
//
//  Created by 李标 on 2022/5/6.
//  Nudges 管理大单例

#import <Foundation/Foundation.h>
//#import "NudgesBaseModel.h"
//#import "NudgesModel.h"
#import "MonolayerModel.h"
#import "NudgesConfigParametersModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface HJNudgesManager : NSObject

/// eg: [必须]身份标识身份标识类型： 1、默认mccm dmc  2、ceg
@property (nonatomic, assign) KSourceType sourceType;

// eg:Nudges 配置参数 模型
@property (nonatomic, strong) NudgesConfigParametersModel *configParametersModel;

// nudges显示后是否进行上报
@property (nonatomic, assign) BOOL isReported;

// 记录当前页面名称
@property (nonatomic, copy) NSString *currentPageName;

// 页面domTree 数据
@property (nonatomic, strong) NSDictionary *domTreeDic;
// 屏幕截图
@property (nonatomic, strong) UIImage *screenShotImg;

/**
 * 按钮点击事件
 *  eventName: 事件名称
 *  bodyDic: 参数字典  包含：nudgesId, nudgesName, nudgesType, buttonName, invokeAction, url, schemeType, eventTypeId
 *
 */
@property (nonatomic, copy) void (^buttonClickEventBlock)(NSString *eventName, NSDictionary *bodyDic);

/**
 *  nudegs 展示事件 (兼容埋点事件)
 *   eventName: 事件名称
 *   nudgesId: nudgesId
 *   nudgesName: 名称
 *   nudgesType：类型
 *   eventTypeId: 事件ID
 *   contactId: 工单ID
 *   campaignCode:活动ID
 *   pageName: 页面名称
 */
@property (nonatomic, copy) void (^nudgesShowEventBlock)(NSInteger nudgesId, NSString *nudgesName, KNudgesType nudgesType, NSString *eventTypeId, NSString *contactId, NSInteger campaignCode, NSString *batchId, NSString *source, NSString *pageName);


+ (instancetype)sharedInstance;

/// eg: 连接websocket
/// @param configCode 连接码
- (void)connectWebSocketByConfigCode:(NSString *)configCode;

/// eg: 结束会话
- (void)endSessions;

/// eg:  截屏
/// @return 截屏 Image
- (UIImage *)currentWindowScreenShot;

/// eg: 上报设备信息 进行匹配
/// @param matchCode 匹配码
- (void)uploadDeviceInfoWithMatchCode:(NSString *)matchCode;

/// eg: 点击web配置capture 触发
- (void)captureClickAction;

/// eg: 点击Capture按钮时候触发 上传本地信息
/// @param screenShotImg (UIImage) 截屏图片
/// @param domTree 数据结构
/// @param permission 是否同意配对  Y: 同意(默认值)  N: 不同意
///
- (void)uploadCaptureInfoByScreenShotImg:(UIImage *)screenShotImg domTree:(NSDictionary *)domTree permission:(NSString *)permission;

/// eg: 数据库根据界面查找Nudges
/// @param pageName 页面名称
//- (void)selectNudgesDBWithPageName:(NSMutableArray *)nudgesList;
//- (void)selectNudgesDBWithPageName:(NudgesModel *)model;

/// eg:当发生页面重载或者新页面时候，调用
/// @param pageName 页面名称
- (void)queryNudgesWithPageName:(NSString *)pageName;

/// eg:展示下一个Nudges
- (void)showNextNudges;

/// eg: 启动nudges, 开始获取nudges 数据
- (void)start;

/// eg: nudges预览
- (void)showPreviewNudges:(NSDictionary *)dic;

/// eg: Nudges显示后, 上报接口
/// @param nudgesId 唯一id
/// @param contactId 唯一id
- (void)nudgesContactRespByNudgesId:(NSInteger)nudgesId contactId:(NSString *)contactId;

//- (void)createTimer:(NSString *)pageName;

// 上报数据
// score:反馈得分
// thumbResult:点赞点踩结果，1-点赞；0-点踩
// options:反馈选项，多个使用英文逗号分隔
// comments:反馈备注
// feedbackDuration:反馈时长（从Nudge展示到点击提交的市场）
- (void)nudgesFeedBackWithNudgesId:(NSInteger)nudgesId contactId:(NSString *)contactId score:(NSString *)score thumbResult:(NSString *)thumbResult options:(NSString *)options comments:(NSString *)comments feedbackDuration:(NSString *)feedbackDuration;

// 预览nudges
- (void)previewConstructsNudgesViewByFindView:(UIView *)findView isFindType:(KNudgeFindType)type;

// 查找nudges
- (void)startConstructsNudgesViewByFindView:(UIView *)findView isFindType:(KNudgeFindType)type;

/**
 打开Nudges
 @param url   URL
 */
- (void)openNudgesUrl:(NSURL*)url;

@end

NS_ASSUME_NONNULL_END
