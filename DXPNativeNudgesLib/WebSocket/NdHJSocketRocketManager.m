//
//  IMSocketRocketManager.m
//  IMDemo
//
//  Created by mac on 2020/6/5.
//  Copyright © 2020 mac. All rights reserved.
//

#import "NdHJSocketRocketManager.h"
#import "HJNudgesManager.h"
#import "NdHJHandelJson.h"
#import "NdCommonConstant.h"
#import "NSString+ND.h"
#import "NSString+ndDate.h"
#import "UIView+ndToast.h"
#import "NSString+ndJson.h"

#define kRconnectCount 8
#define kRconnectOverTime 5

@interface NdHJSocketRocketManager() <SRWebSocketDelegate> {
    NSInteger _reconnectCounter;
    NSString *_flowNo;
    NSString *_lastPingTime;
    NSString *_wsSocketURL; // ws的域名或者ip地址
    NSString *_deviceCode; // 设备唯一编码
	NSString *_brand;
	NSString *_os;
	NSString *_osVersion;
	NSString *_width;
	NSString *_height;
}

@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) NSTimer *pingTimer;   //心跳
@property (nonatomic, strong) NSTimer *reTimer;     //重连

@end

@implementation NdHJSocketRocketManager

+ (NdHJSocketRocketManager *)instance {
    static NdHJSocketRocketManager *Instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        Instance = [[NdHJSocketRocketManager alloc] init];
    });
    return Instance;
}

- (void)openSocket:(NSString *)flowNo wsSocketIP:(NSString *)ip deviceCode:(NSString *)deviceCode brand:(NSString *)brand os:(NSString *)os osVersion:(NSString *)osVersion width:(NSString *)width height:(NSString *)height {
    _flowNo = flowNo;
    _wsSocketURL = ip;
    _deviceCode = deviceCode;
	_brand = brand;
	_os = os;
	_osVersion = osVersion;
	_width = width;
	_height = height;
	
	NSLog(@"openSocket:flowNo -> %@", flowNo);
    [self p_registerReceiveMessageAPI:flowNo];
    [_socket open];
}

- (void)openSocket {
    [self p_registerReceiveMessageAPI:_flowNo];
    if (_socket) {
        [_socket open];
    }
}

- (void)openSocketTimer {
//    [self openSocket:_flowNo wsSocketIP:_wsSocketURL deviceCode:_deviceCode brand:_brand os:_os osVersion:_osVersion width:_width height:_height];
  [self openSocket:_flowNo wsSocketIP:_wsSocketURL deviceCode:_deviceCode brand:_brand os:_os osVersion:_osVersion width:_width height:_height];
}

- (void)closeSocket {
    [self closePingTimerSocket];
    [self closeRetimerSocket];
    
    [_socket close];
    _socket.delegate = nil;
    _socket = nil;
}

- (void)closePingTimerSocket {
    [self.pingTimer setFireDate:[NSDate distantFuture]];
    [self.pingTimer invalidate];
    self.pingTimer = nil;
}

- (void)closeRetimerSocket {
    [self.reTimer setFireDate:[NSDate distantFuture]];
    [self.reTimer invalidate];
    self.reTimer = nil;
}

- (void)p_registerReceiveMessageAPI:(NSString *)flowNo
{
    NSString *urlStr = [NSString stringWithFormat:@"%@nudges/socket?configCode=%@&deviceCode=%@&brand=%@&os=%@&osVersion=%@&width=%@&height=%@",_wsSocketURL,_flowNo, _deviceCode,_brand,_os,_osVersion,_width,_height];
//	NSString *urlStr = [NSString stringWithFormat:@"%@nudges/socket?configCode=%@&deviceCode=%@",_wsSocketURL,_flowNo, _deviceCode];
    //    NSString * urlStr = [NSString stringWithFormat:@"ws://10.45.98.90:8080/app/websocket/server?flowNo=1234129", flowNo, app_Version];
	NSLog(@"SRWebSocket  initWithURLRequest   urlStr -> %@", urlStr);
	NSString *encodedUrlString = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    _socket = [[SRWebSocket alloc]initWithURLRequest:
               [NSURLRequest requestWithURL:[NSURL URLWithString:encodedUrlString]]];
    _socket.delegate = self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self closeSocket];
}

#pragma mark - sokect delegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    
	NSLog(@"websocket connected...");
    _reconnectCounter = 0;
    _lastPingTime = @"";
    //开始心跳
    self.pingTimer = [NSTimer timerWithTimeInterval:10 target:self selector:@selector(sendPing) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.pingTimer forMode:NSRunLoopCommonModes];
    [self.pingTimer setFireDate:[NSDate distantPast]];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(NSString *)string {
    NSLog(@"接受到字符串消息:%@",string);
    NSDictionary *resp = [NdHJHandelJson dictionaryWithJsonString:string];
    NSString *code = [resp objectForKey:@"code"];
    if ([code isEqualToString:@"MCCM-NUDGES-SUCC-000"]) {
        [[UIApplication sharedApplication].keyWindow makeToast:@"Device Binding Successful" duration:1.5f position:CSNdToastPositionCenter];
    } else if ([string isEqualToString:@"start capture"]) {
        // 点击capture
        [[HJNudgesManager sharedInstance] captureClickAction];
    } else if ([code isEqualToString:@"Please Break Connection"]) {
        [self closeSocket];
    } else {
        if (isEmptyString_Nd(code)) {
            // 预览
            NSDictionary *dic = [resp objectForKey:@"mccCreativeNudges"];
            if (dic) {
                [[HJNudgesManager sharedInstance] showPreviewNudges:dic];
            }
            // ceg预览
            NSDictionary *dicCeg = [resp objectForKey:@"cegCreativeNudges"];
            if (dicCeg) {
                [[HJNudgesManager sharedInstance] showPreviewNudges:dicCeg];
            }
            
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message  {
    if (![message JSONValue] && [message rangeOfString:@"pong"].location != NSNotFound) {
		NSLog(@"----------心跳,跳起来----------");
        _lastPingTime = [NSString getCurrentTimestamp];
        return;
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
	NSLog(@"连接失败，这里可以实现掉线自动重连，要注意以下几点");
	NSLog(@"1.判断当前网络环境，如果断网了就不要连了，等待网络到来，在发起重连");
	NSLog(@"2.判断调用层是否需要连接，例如用户都没在聊天界面，连接上去浪费流量");
	NSLog(@"3.连接次数限制，如果连接失败了，重试10次左右就可以了，不然就死循环了。或者每隔1，2，4，8，10，10秒重连...f(x) = f(x-1) * 2, (x=5)");
    [self closeSocket];
    [self socketReconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
	NSLog(@"断开连接，清空相关数据");
//    _socket.delegate = nil;
//    _socket = nil;
    [self closeSocket];
    [self socketReconnect];
}

- (void)socketReconnect {
    // 计数+1
    if (_reconnectCounter < kRconnectCount - 1) {
        _reconnectCounter ++;
        // 开启定时器
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kRconnectOverTime target:self selector:@selector(openSocket) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.reTimer = timer;
    } else{
		NSLog(@"Websocket Reconnected Outnumber ReconnectCount");
        if (self.reTimer) {
            [self closeRetimerSocket];
        }
        return;
    }
}

- (void)sendPing {
//    [_socket sendPing:nil];
    [_socket send:@"ping"];
    
    if (![NSString isNDBlankString:_lastPingTime]) {
        NSInteger seconde = [[NSString getCurrentTimestamp] integerValue] - [_lastPingTime integerValue] > 20;
        if (seconde/1000 > 20) {
            [self closeSocket];
            [self socketReconnect];
        }
    }
}

- (void)sendData:(NSString *)data {
	NSLog(@"发送socket数据:%@",data);

    __weak __typeof(&*self)weakSelf = self;
    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);

    dispatch_async(queue, ^{
        if (weakSelf.socket != nil) {
            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
            if (weakSelf.socket.readyState == SR_OPEN) {
                NSLog(@"Nudges Socket发送消息");
                NSError *err;
                [weakSelf.socket sendString:data error:&err];    // 发送数据
                NSLog(@"err:%@",err);
            } else if (weakSelf.socket.readyState == SR_CONNECTING) {
				NSLog(@"正在连接中，重连后其他方法会去自动同步数据");
                // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
                // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
                // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
                // 代码有点长，我就写个逻辑在这里好了
                [self socketReconnect];
            } else if (weakSelf.socket.readyState == SR_CLOSING || weakSelf.socket.readyState == SR_CLOSED) {
                // websocket 断开了，调用 reConnect 方法重连
				NSLog(@"重连");
                [self socketReconnect];
            }
        } else {
			NSLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
        }
    });
}

//#define WeakSelf(ws) __weak __typeof(&*self)weakSelf = self
//- (void)sendData:(id)data {
//    HJLog(@"发送socket数据:%@",data);
//
//    WeakSelf(ws);
//    dispatch_queue_t queue =  dispatch_queue_create("zy", NULL);
//
//    dispatch_async(queue, ^{
//        if (weakSelf.socket != nil) {
//            // 只有 SR_OPEN 开启状态才能调 send 方法啊，不然要崩
//            if (weakSelf.socket.readyState == SR_OPEN) {
//                [weakSelf.socket send:data];    // 发送数据
//            } else if (weakSelf.socket.readyState == SR_CONNECTING) {
//                HJLog(@"正在连接中，重连后其他方法会去自动同步数据");
//                // 每隔2秒检测一次 socket.readyState 状态，检测 10 次左右
//                // 只要有一次状态是 SR_OPEN 的就调用 [ws.socket send:data] 发送数据
//                // 如果 10 次都还是没连上的，那这个发送请求就丢失了，这种情况是服务器的问题了，小概率的
//                // 代码有点长，我就写个逻辑在这里好了
//                [self socketReconnect];
//            } else if (weakSelf.socket.readyState == SR_CLOSING || weakSelf.socket.readyState == SR_CLOSED) {
//                // websocket 断开了，调用 reConnect 方法重连
//                HJLog(@"重连");
//                [self socketReconnect];
//            }
//        } else {
//            HJLog(@"没网络，发送失败，一旦断网 socket 会被我设置 nil 的");
//        }
//    });
//}

@end
