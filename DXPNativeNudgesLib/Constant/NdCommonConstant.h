//
//  NdCommonConstant.h
//  UserNudges
//
//  Created by 李标 on 2022/12/3.
//

#ifndef NdCommonConstant_h
#define NdCommonConstant_h


#ifdef DEBUG
    #define HJLog(fmt, ...) NSLog((@"[文件名:%s]\n" "[函数名:%s]\n" "[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);

    #define NdDebugLog(s, ...)         NSLog(@"%s(%d): %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
    #define HJLog(...);
#endif


#define objectOrNull_Nd(obj)        ((obj) ? (obj) : [NSNull null])
#define isEmptyString_Nd(x)         (IsNilOrNull_Nd(x) || [x isEqual:@""] || [x isEqual:@"(null)"] || [x isEqual:@"null"] || [x isEqual:@"<null>"])
#define IsNilOrNull_Nd(_ref)        (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]))
#define IsArrEmpty_Nd(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref) count] == 0))

//颜色
#define UIColorFromRGB_Nd(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


// tabBar高度
#define TAB_BAR_HEIGHT_Nd       (iPhoneX ? (49.f+34.f) : 49.f)
//#define WS(weakSelf)    __weak __typeof(&*self)weakSelf = self

#endif /* NdCommonConstant_h */
