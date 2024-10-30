//
//  NodeModel.h
//  MPTCLPMall
//
//  Created by Lee on 2022/3/31.
//  Copyright © 2022 OO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface NodeModel : NSObject
@property (nonatomic, strong) NSString *pageName; // 页面名称
@property (nonatomic, strong) NSString *tag; // view tag
@property (nonatomic, strong) NSString *resId; // View ID
@property (nonatomic, strong) NSString *className; // 控件类型
@property (nonatomic, assign) NSString *frame; // 控件 显示范围 orgin(x,y)(width,height)
@property (nonatomic, strong) NSString *findIndex; // View 在 树形结构中索引
@property (nonatomic, strong) NSMutableArray *childNodeList;
@property (nonatomic, assign) BOOL isSelected;//判断是否选中

@property (nonatomic, copy) NSString *strAccessibilityIdentifier;
@property (nonatomic, strong) NSString *superView;
@property (nonatomic, strong) UIView *targetView;
@property (nonatomic, copy) NSString *strAccessibilityLabel;
@end

NS_ASSUME_NONNULL_END
