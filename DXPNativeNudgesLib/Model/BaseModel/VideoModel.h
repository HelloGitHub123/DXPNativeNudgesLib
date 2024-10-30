//
//  VideoModel.h
//  DITOApp
//
//  Created by 李标 on 2022/8/5.
//

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface VideoModel : NdHJHttpModel

/// eg: 封面图片的url地址，如果没有配置，则为空
@property (nonatomic, copy) NSString *coverImageUrl;
/// eg: 视频文件的播放地址
@property (nonatomic, copy) NSString *videoUrl;
/// eg:宽度
@property (nonatomic, assign) NSInteger width;

@property (nonatomic, assign) BOOL paddingSpace;

@property (nonatomic, assign) BOOL allSides;
/// eg: 左
@property (nonatomic, assign) NSInteger paddingLeft;
/// eg: 上
@property (nonatomic, assign) NSInteger paddingTop;
/// eg: 右
@property (nonatomic, assign) NSInteger paddingRight;
/// eg: 下
@property (nonatomic, assign) NSInteger paddingBottom;

/// eg: 图片高度
@property (nonatomic, assign) CGFloat h_coverImage;
/// eg: 图片宽度
@property (nonatomic, assign) CGFloat w_coverImage;
@end

NS_ASSUME_NONNULL_END
