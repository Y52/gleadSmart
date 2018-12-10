//
//  Network.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "GCDAsyncUdpSocket.h"

NS_ASSUME_NONNULL_BEGIN

@interface Network : NSObject <GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>

+ (instancetype)shareNetwork;
///@brief 销毁单例
+ (void)destroyInstance;

///@brief TCPSocket
@property (strong, nonatomic) GCDAsyncSocket *mySocket;
///@brief 连接上的设备
@property (strong, nonatomic, nullable) DeviceModel *connectedDevice;
///@brief 线程信号量使用
@property (strong, nonatomic) dispatch_semaphore_t sendSignal;

///@brief Udp
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) NSTimer *udpTimer;;

///@brief 接收数据
@property (strong, nonatomic) NSMutableArray *recivedData69;

///@brief Wi-Fi信息
@property (strong, nonatomic) NSString *ssid;
@property (strong, nonatomic) NSString *bssid;
@property (strong, nonatomic) NSString *apPwd;
@property (strong, nonatomic) NSString *ipAddr;

///@brief Device Info
@property (strong, nonatomic) NSMutableArray *deviceArray;



///@brief 连接
- (BOOL)connectToHost:(NSString*)host onPort:(uint16_t)port error:(NSError **)errPtr;

///@brief Frame69帧发送方法
- (void)onlineNodeInquire:(NSString *)mac;
- (void)sendData69With:(UInt8)controlCode mac:(NSString *)mac data:(NSArray *)data;

///@brief OneNET回复数据处理
- (void)handleOneNET69Message:(NSString *)cmmdReply;

///@brief 判断设备类型
- (NSInteger)judgeDeviceTypeWith:(int)macByte2;
@end

NS_ASSUME_NONNULL_END
