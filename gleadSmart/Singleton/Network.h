//
//  Network.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

NS_ASSUME_NONNULL_BEGIN

@interface Network : NSObject <GCDAsyncSocketDelegate>

+ (instancetype)shareNetwork;

///@brief TCPSocket
@property (strong, nonatomic) GCDAsyncSocket *mySocket;
///@brief 连接上的设备
@property (strong, nonatomic, nullable) DeviceModel *connectedDevice;
///@brief 线程信号量使用
@property (nonatomic, strong) dispatch_semaphore_t sendSignal;

///@brief 接收数据
@property (nonatomic, strong) NSMutableArray *recivedData68;

///@brief Wi-Fi信息
@property (nonatomic, strong) NSString *ssid;
@property (nonatomic, strong) NSString *bssid;
@property (nonatomic, strong) NSString *apPwd;
@property (nonatomic, strong) NSString *ipAddr;





///@brief 连接
- (BOOL)connectToHost:(NSString*)host onPort:(uint16_t)port error:(NSError **)errPtr;

///@brief Frame69帧发送方法
- (void)onlineNodeInquire:(NSString *)mac;

@end

NS_ASSUME_NONNULL_END
