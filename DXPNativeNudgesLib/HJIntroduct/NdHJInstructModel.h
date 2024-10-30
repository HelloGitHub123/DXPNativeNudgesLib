//
//  NdHJInstructModel.h
//  MOC
//
//  Created by Lee on 2022/3/24.
//

#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface NdHJInstructModel : NSObject

@property (nonatomic, strong) NSString *pageName; // 页面名称
@property (nonatomic, strong) NSString *tag; // view tag
@property (nonatomic, strong) NSString *resId; // View ID
@property (nonatomic, strong) NSString *className; // 控件类型
@property (nonatomic, assign) NSString *frame; // 控件 显示范围 orgin(x,y)(width,height)
@property (nonatomic, strong) NSString *findIndex; // View 在 树形结构中索引
@property (nonatomic, assign) BOOL isSelected;//判断是否选中

@property (nonatomic, strong) NSArray <NdHJInstructModel *>* children;


@end

NS_ASSUME_NONNULL_END
