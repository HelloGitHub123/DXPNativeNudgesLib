//
//  TKUtils.h
//  DITOApp
//
//  Created by 李标 on 2022/9/2.
//  Nudges 工具类

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface TKUtils : NSObject

// 获取字符串的高度
+ (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize string:(NSString *)string;
// 根据16进制颜色值，获取 UIColor 对象
+ (UIColor *)GetColor:(NSString *)pColor alpha:(CGFloat) dAlpha;
// 根据字体的斜体、粗体、字体大小、字体。返回对应的UIFont对象
+ (UIFont *)setButtonFontWithSize:(CGFloat)fontSize familyName:(NSString *)familyName bold:(BOOL)bold itatic:(BOOL)italic weight:(UIFontWeight)weight;
// 根据字体的斜体、粗体、字体大小、字体。返回对应的UIFont对象
+ (UIFont *)setTitleFontWithSize:(CGFloat)fontSize familyName:(NSString *)familyName bold:(BOOL)bold itatic:(BOOL)italic weight:(UIFontWeight)weight;
// 根据16进制颜色值，获取 RGB 色值
+ (NSString *)GetRGBColor:(NSString *)pColor alpha:(CGFloat) dAlpha;
// 比较两个时间字符串大小
+ (NSInteger)compareDate:(NSString*)aDate withDate:(NSString*)bDate;
// 时间格式化
+ (NSString *)getFullDateStringWithDate:(NSDate *)date;
// 获取毫秒级时间戳
+ (NSString *)timestamp;
// 随机UUID
+ (NSString *)uuidString;
// 判断view是否在当前屏幕中
+ (BOOL)isDisplayedInScreen:(UIView *)view;
// 获取当前栈顶控制器
+ (UIViewController *)topViewController;
// 获取当前window
+ (UIWindow *)keyWindow;
// 取设备型号
+ (NSString *)getCurrentDeviceModel;
// 获取当前view所在视图的坐标和宽高
+ (CGRect)getAddress:(UIView *)view;
// 获取设备device Id
+ (NSString *)getDeviceUUID;
// 获取当前时间戳
+ (NSString *)getCurrentTimestamp;
// 判断是否是同一周
+ (BOOL)isSameWeek:(NSDate *)date1 date2:(NSDate *)date2;
// 判断是否同一天
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;
// 判断是否同一小时
+ (BOOL)isSameHour:(NSDate*)date1 date2:(NSDate*)date2;
@end

NS_ASSUME_NONNULL_END
