//
//  IMSocketRocketManager.h
//  IMDemo
//
//  Created by mac on 2020/6/5.
//  Copyright © 2020 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>
NS_ASSUME_NONNULL_BEGIN

@interface NdHJSocketRocketManager : NSObject

/* instance socket */
+ (NdHJSocketRocketManager *)instance;

/* Connect socket*/
- (void)openSocket:(NSString *)flowNo wsSocketIP:(NSString *)ip deviceCode:(NSString *)deviceCode brand:(NSString *)brand os:(NSString *)os osVersion:(NSString *)osVersion width:(NSString *)width height:(NSString *)height;

/* Close socket*/
- (void)closeSocket;

- (void)sendData:(NSString *)data;
@end

NS_ASSUME_NONNULL_END
