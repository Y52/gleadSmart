//
//  DeviceModel.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DeviceType) {
    DeviceCenterlControl = 0,
    DeviceThermostat = 1,
    DeviceValve = 2,
    DeviceWallhob = 3,
    DeviceNTCValve = 4,
    DevicePlugOutlet = 5,
    DeviceOneSwitch = 6,
    DeviceTwoSwitch = 7,
    DeviceThreeSwitch = 8,
    DeviceFourSwitch = 9,
    
};

@interface DeviceModel : NSObject

@property (nonatomic) NSUInteger tag;
///@brief 分享设备页面判断是否已经分享过
@property (nonatomic) BOOL isShared;

///@brief 设备基本信息
@property (strong, nonatomic) NSString *mac;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *ipAddress;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSString *roomUid;
@property (nonatomic, strong) NSString *roomName;
@property (strong, nonatomic) NSString *houseUid;
@property (strong, nonatomic) NSNumber *isOn;
@property (strong, nonatomic) NSNumber *isOnline;//判断在线离线

///@brief 设备列表，中央控制器拥有，包含温控器，水阀等
@property (nonatomic, strong) NSMutableArray *gatewayMountDeviceList;


///@breif 温控器拥有的属性
@property (strong, nonatomic) NSNumber *mode;//0为手动，1为自动
@property (strong, nonatomic) NSNumber *indoorTemp;
@property (strong, nonatomic) NSNumber *modeTemp;
@property (strong, nonatomic) NSNumber *compensate;
@property (strong, nonatomic) NSArray *weekProgram;

///@brief 无线阀门拥有的属性
@property (strong, nonatomic) NSMutableArray *nodeArray;
@property (nonatomic) BOOL isUnusual;//是否异常(开关状态)

///@brief 无线混水阀门拥有的属性
@property (nonatomic) BOOL isTemperatureAlarm;//是否温度报警

///@brief 分享设备特有的属性
@property (nonatomic) BOOL isShare;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *shareDeviceHouseMac;

///@brief 需要tcp连接的设备
@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (nonatomic) dispatch_semaphore_t sendSignal;//设备通信锁
@property (nonatomic) dispatch_queue_t queue;//设备通信线程

///@brief 设备socket发帧
- (void)sendData69With:(UInt8)controlCode mac:(NSString *)mac data:(NSArray *)data;

///@brief 获取设备状态
- (void)getRelayStatus;
@end

NS_ASSUME_NONNULL_END
