//
//  ActionModel.h
//  DITOApp
//
//  Created by 李标 on 2022/5/13.
//

#import <Foundation/Foundation.h>
#import "Nudges.h"

NS_ASSUME_NONNULL_BEGIN

@interface ActionModel : NdHJHttpModel

/// eg: 1-Close Nudges; 2-Launch URL; 3-Invoke Action
@property (nonatomic, assign) KButtonsActionType type;
///
@property (nonatomic, copy) NSString *url;
/// eg: 1-Inner; 2-Outer Brower; 3-Inner Webview
@property (nonatomic, assign) KButtonsUrlJumpType urlJumpType;

@property (nonatomic, copy) NSString *invokeAction;
@end

NS_ASSUME_NONNULL_END
