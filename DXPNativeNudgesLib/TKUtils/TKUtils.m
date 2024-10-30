//
//  TKUtils.m
//  DITOApp
//
//  Created by 李标 on 2022/9/2.
//

#import "TKUtils.h"
#import <sys/utsname.h>
#import <DXPFontManagerLib/FontManager.h>

@implementation TKUtils

#pragma mark -- 获取字符串的高度
+ (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize string:(NSString *)string {
    NSDictionary *attrs = @{NSFontAttributeName:font};
    return [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

#pragma mark -- 根据16进制颜色值，获取 UIColor 对象
+ (UIColor *)GetColor:(NSString *)pColor alpha:(CGFloat) dAlpha {
    NSString* pStr = [[pColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([pStr length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([pStr hasPrefix:@"0X"])
        pStr = [pStr substringFromIndex:2];
    if ([pStr hasPrefix:@"#"])
        pStr = [pStr substringFromIndex:1];
    if ([pStr length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [pStr substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [pStr substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [pStr substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:dAlpha];
}

#pragma mark -- 根据字体的斜体、粗体、字体大小、字体。返回对应的UIFont对象
+ (UIFont *)setButtonFontWithSize:(CGFloat)fontSize familyName:(NSString *)familyName bold:(BOOL)bold itatic:(BOOL)italic weight:(UIFontWeight)weight {
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

#pragma mark -- 根据字体的斜体、粗体、字体大小、字体。返回对应的UIFont对象
+ (UIFont *)setTitleFontWithSize:(CGFloat)fontSize familyName:(NSString *)familyName bold:(BOOL)bold itatic:(BOOL)italic weight:(UIFontWeight)weight {
    //    UIFont *font = [UIFont systemFontOfSize:fontSize weight:weight];
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

#pragma mark -- 根据16进制颜色值，获取 RGB 色值
+ (NSString *)GetRGBColor:(NSString *)pColor alpha:(CGFloat) dAlpha {
    NSString* pStr = [[pColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([pStr length] < 6) {
        return @"";
    }
    
    // strip 0X if it appears
    if ([pStr hasPrefix:@"0X"])
        pStr = [pStr substringFromIndex:2];
    if ([pStr hasPrefix:@"#"])
        pStr = [pStr substringFromIndex:1];
    if ([pStr length] != 6)
        return @"";
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [pStr substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [pStr substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [pStr substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    NSString *rgb = [NSString stringWithFormat:@"%u,%u,%u",r,g,b];
    
    return rgb;
}

#pragma mark -- 比较两个时间字符串大小
+ (NSInteger)compareDate:(NSString*)aDate withDate:(NSString*)bDate {
    NSInteger aa = 0;
    NSDateFormatter *dateformater = [[NSDateFormatter alloc] init];
    [dateformater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dta = [[NSDate alloc] init];
    NSDate *dtb = [[NSDate alloc] init];
    
    dta = [dateformater dateFromString:aDate];
    dtb = [dateformater dateFromString:bDate];
    NSComparisonResult result = [dta compare:dtb];
    if (result==NSOrderedSame)
    {
        //相等
        aa = 0;
    }else if (result==NSOrderedAscending) {
        //bDate比aDate大
        aa = 1;
    }else if (result==NSOrderedDescending) {
        //bDate比aDate小
        aa = -1;
    }
    return aa;
}

#pragma mark -- 时间格式化
+ (NSString *)getFullDateStringWithDate:(NSDate *)date {
    return [self getDateStringWithDate:date formatterStr:@"yyyy-MM-dd HH:MM:SS"];
}

// 时间格式化
+ (NSString *)getDateStringWithDate:(NSDate *)date formatterStr:(NSString *)formatterStr {
    if (IsNilOrNull_Nd(formatterStr)) {
        return @"";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatterStr];
    NSString *dateStr = [formatter stringFromDate:date];
    return dateStr;
}

#pragma mark -- 获取毫秒级时间戳
+ (NSString *)timestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]* 1000];
    return timeSp;
}

#pragma mark -- 随机UUID
+ (NSString *)uuidString {
     CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
     CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
     NSString *uuid = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
     CFRelease(uuid_ref);
     CFRelease(uuid_string_ref);
     return [uuid lowercaseString];
}

#pragma mark -- 判断view是否在当前屏幕中
+ (BOOL)isDisplayedInScreen:(UIView *)view {
    if (view == nil) {
        return FALSE;
    }
    CGRect screenRect = [UIScreen mainScreen].bounds;
    //转换view对应window的Rect
    CGRect rect = [view convertRect:view.frame toView:[UIApplication sharedApplication].delegate.window];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
        return false;
    }
    //若view 隐藏
    if (view.hidden) {
        return false;
    }
    //若没有superView
    if (view.superview == nil) {
        return false;
    }
    //若size 为CGRectZero
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return false;
    }
    //获取 该view 与window 交叉的Rect
    CGRect intersectionRect = CGRectIntersection(rect, screenRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return false;
    }
    return true;
}

#pragma mark -- 获取当前栈顶控制器
+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[TKUtils keyWindow] rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

// 获取当前栈顶控制器
+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

#pragma mark -- 获取当前window
+ (UIWindow *)keyWindow {
    return [UIApplication sharedApplication].keyWindow;
}

#pragma mark -- Other
// 取设备型号
+ (NSString *)getCurrentDeviceModel {
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
    //新添加
    if([platform isEqualToString:@"iPhone13,1"])return@"iPhone 12 mini";
    if([platform isEqualToString:@"iPhone13,2"])return@"iPhone 12";
    if([platform isEqualToString:@"iPhone13,3"])return@"iPhone 12 Pro";
    if([platform isEqualToString:@"iPhone13,4"])return@"iPhone 12 Pro Max";
    if([platform isEqualToString:@"iPhone14,4"])return@"iPhone 13 mini";
    if([platform isEqualToString:@"iPhone14,5"])return@"iPhone 13";
    if([platform isEqualToString:@"iPhone14,2"])return@"iPhone 13 Pro";
    if([platform isEqualToString:@"iPhone14,3"])return@"iPhone 13 Pro Max";
    if([platform isEqualToString:@"iPhone14,6"])return@"iPhone SE 2022";
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

// 获取当前view所在视图的坐标和宽高
+ (CGRect)getAddress:(UIView *)view {
    CGRect rect=[view convertRect: view.bounds toView:[UIApplication sharedApplication].delegate.window];
    return rect;
}

// 获取设备device Id
+ (NSString *)getDeviceUUID {
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *deviceId = [[currentDevice identifierForVendor] UUIDString];
    if (isEmptyString_Nd(deviceId)) {
        return @"";
    }
    return deviceId;
}

// 获取当前时间戳
+ (NSString *)getCurrentTimestamp {
    //获取系统当前的时间戳 13位，毫秒级；10位，秒级
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSDecimalNumber *timeNumber = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", time]];
    NSDecimalNumber *baseNumber = [NSDecimalNumber decimalNumberWithString:@"1000"];
    NSDecimalNumber *result = [timeNumber decimalNumberByMultiplyingBy:baseNumber];
    return [NSString stringWithFormat:@"%ld", (long)[result integerValue]];
}

#pragma mark -- 判断是否是同一周
+ (BOOL)isSameWeek:(NSDate *)date1 date2:(NSDate *)date2 {
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
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

#pragma mark -- 判断是否同一小时
+ (BOOL)isSameHour:(NSDate*)date1 date2:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year] &&
    [comp1 hour] == [comp2 hour];
}

@end
