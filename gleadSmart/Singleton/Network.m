//
//  Network.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "Network.h"

#import <netdb.h>

static Network *_network = nil;
static dispatch_once_t oneToken;


//用来判断手机与设备是否有信息交互的心跳，有交互后重新清零，心跳达到60就发送心跳帧
static int noUserInteractionHeartbeat = 0;

@implementation Network{
    UInt8 _frameCount;
    dispatch_queue_t _queue;//设备通信线程
    
    NSLock *_lock;//udp搜寻锁
    dispatch_semaphore_t _sendSignal;//设备通信锁
    
    NSMutableArray *_allMsg;//收到的帧处理沾包分帧后放入该数组
    
    dispatch_source_t _noUserInteractionHeartbeatTimer;//心跳时钟
    
    //测试用代码
    dispatch_source_t _testSendTimer;//测试时钟
}

+ (instancetype)shareNetwork{
    if (_network == nil) {
        _network = [[self alloc] init];
    }
    return _network;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    dispatch_once(&oneToken, ^{
        if (_network == nil) {
            _network = [super allocWithZone:zone];
        }
    });
    return _network;
}

- (instancetype)init{
    if (self = [super init]) {
        dispatch_queue_t queue = dispatch_queue_create("netQueue", DISPATCH_QUEUE_SERIAL);
        if (!_mySocket) {
            _mySocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
        }
        if (!_sendSignal) {
            _sendSignal = dispatch_semaphore_create(1);
        }
        if (!_recivedData69) {
            _recivedData69 = [[NSMutableArray alloc] init];
        }
        if (!_deviceArray) {
            _deviceArray = [[NSMutableArray alloc] init];
        }
        if (!_udpSocket) {
            dispatch_queue_t queue = dispatch_queue_create("udpQueue", DISPATCH_QUEUE_SERIAL);
            _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:queue];
        }
        if (!_udpTimer) {
            _udpTimer = [NSTimer scheduledTimerWithTimeInterval:6.f target:self selector:@selector(broadcast) userInfo:nil repeats:YES];
            [_udpTimer setFireDate:[NSDate distantFuture]];
        }
        if (!_noUserInteractionHeartbeatTimer) {
            //心跳时钟，每一秒加1
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _noUserInteractionHeartbeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            dispatch_source_set_timer(_noUserInteractionHeartbeatTimer, dispatch_walltime(NULL, 0), 1.f * NSEC_PER_SEC, 0);
            dispatch_source_set_event_handler(_noUserInteractionHeartbeatTimer, ^{
                noUserInteractionHeartbeat++;
                if (![[Database shareInstance].currentHouse.mac isKindOfClass:[NSNull class]] && noUserInteractionHeartbeat == 60 && [[Database shareInstance].currentHouse.mac isEqualToString:self.connectedDevice.mac]) {

                    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.f * NSEC_PER_SEC);
                    dispatch_semaphore_wait(self.sendSignal, time);
                    
                    noUserInteractionHeartbeat = 0;//心跳清零
                    
                    NSMutableArray *data69 = [[NSMutableArray alloc] init];
                    [data69 addObject:[NSNumber numberWithUnsignedInteger:0x69]];
                    [data69 addObject:[NSNumber numberWithUnsignedInteger:0xC0]];
                    [data69 addObject:[NSNumber numberWithUnsignedInteger:0x00]];
                    [data69 addObject:[NSNumber numberWithUnsignedChar:0x17]];
                    [self send:data69 withTag:100];//内网tcp发送
                }
            });
            dispatch_resume(_noUserInteractionHeartbeatTimer);
        }
        
        //测试用代码
        if (!_testSendTimer) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _testSendTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            dispatch_source_set_timer(_testSendTimer, dispatch_walltime(NULL, 0), 1.f * NSEC_PER_SEC, 0);
            dispatch_source_set_event_handler(_testSendTimer, ^{
                NSLog(@"aaaa");
                UInt8 controlCode = 0x00;
                NSArray *data = @[@0xFE,@0x01,@0x45,@0x00];//在网节点查询
                [[Network shareNetwork] sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data failuer:nil];
            });
            //dispatch_resume(_testSendTimer);
        }

        _allMsg = [[NSMutableArray alloc] init];
        _lock = [[NSLock alloc] init];
        _queue = dispatch_queue_create("com.thingcom.queue", DISPATCH_QUEUE_SERIAL);
        _frameCount = arc4random() % 255;//计数器随机，不能每次都是从0开始发，中央控制器那边不好处理
        [self sendSearchBroadcast];
        
        _testSendCount = 0;
        _testRecieveCount = 0;
        [self applicationWillEnterForeground];
    }
    return self;
}

+ (void)destroyInstance{
    _network = nil;
    oneToken = 0l;
}

#pragma mark - Udp Delegate And Connect
- (void)sendSearchBroadcast{
    
    [_udpSocket localPort];
    
    NSError *error;
    
    //设置广播
    [_udpSocket enableBroadcast:YES error:&error];
    
    //开启接收数据
    [_udpSocket beginReceiving:&error];
    if (error) {
        NSLog(@"开启接收数据:%@",error);
        return;
    }
    [self.udpTimer setFireDate:[NSDate date]];
}

- (void)broadcast{
    if (_connectedDevice) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.udpTimer setFireDate:[NSDate distantFuture]];
            sleep(60.f);
            [self.udpTimer setFireDate:[NSDate date]];
        });
    }
    NSString *host = @"255.255.255.255";
    NSTimeInterval timeout = 2000;
    NSString *request = @"whereareyou\r\n";
    NSData *data = [NSData dataWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    UInt16 port = 17888;
    
    [_udpSocket sendData:data toHost:host port:port withTimeout:timeout tag:200];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    [_lock lock];
    NSLog(@"UDP接收数据……………………………………………………");
    if (1) {
        /**
         *获取IP地址
         **/
        // Copy data to a "sockaddr_storage" structure.
        struct sockaddr_storage sa;
        socklen_t salen = sizeof(sa);
        [address getBytes:&sa length:salen];
        // Get host from socket address as C string:
        char host[NI_MAXHOST];
        getnameinfo((struct sockaddr *)&sa, salen, host, sizeof(host), NULL, 0, NI_NUMERICHOST);
        // Convert C string to NSString:
        NSString *ipAddress = [[NSString alloc] initWithBytes:host length:strlen(host) encoding:NSUTF8StringEncoding];
        NSLog(@"%@",ipAddress);
        
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",msg);
        NSString *mac = [msg substringWithRange:NSMakeRange(0, 8)];
        DeviceModel *device = [[DeviceModel alloc] init];
        device.mac = mac;
        
        /*
         *根据设备（网关、插座、开关）mac连接每个设备的tcp
         */
        for (DeviceModel *bindDevice in self.deviceArray) {
            NSUInteger type = [self judgeDeviceTypeWith:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]];
            if (type == DeviceCenterlControl) {
                //中央控制器退出循环
                break;
            }
            if ([bindDevice.mac isEqualToString:mac]) {
                /*
                 *初始化
                 */
                if (!bindDevice.socket) {
                    bindDevice.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
                }
                if (!bindDevice.queue) {
                    bindDevice.queue = dispatch_queue_create((char *)[bindDevice.mac UTF8String], DISPATCH_QUEUE_SERIAL);
                }
                if (!bindDevice.sendSignal) {
                    bindDevice.sendSignal = dispatch_semaphore_create(1);
                }
                
                if (![bindDevice.socket isDisconnected]) {
                    //已经连接了
                    [_lock unlock];
                    return;
                }
                
                NSError *error;
                if ([bindDevice.socket connectToHost:ipAddress onPort:16888 error:&error]) {
                    //连接操作
                    [_lock unlock];
                    
                    //查询插座状态
                    UInt8 controlCode = 0x01;
                    NSArray *data = @[@0xFC,@0x11,@0x00,@0x00];
                    [bindDevice sendData69With:controlCode mac:bindDevice.mac data:data];
                    
                    NSLog(@"%@连接成功",mac);
                    return;
                }else{
                    NSLog(@"bindError%@",error);
                }
            }
        }
        
        /*
         *分享设备列表
         *根据设备（网关、插座、开关）mac连接每个设备的tcp
         */
        for (DeviceModel *bindDevice in [Database shareInstance].shareDeviceArray) {
            NSUInteger type = [self judgeDeviceTypeWith:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]];
            if (type == DeviceCenterlControl) {
                //中央控制器退出循环
                break;
            }
            if ([bindDevice.mac isEqualToString:mac]) {
                /*
                 *初始化
                 */
                if (!bindDevice.socket) {
                    bindDevice.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
                }
                if (!bindDevice.queue) {
                    bindDevice.queue = dispatch_queue_create((char *)[bindDevice.mac UTF8String], DISPATCH_QUEUE_SERIAL);
                }
                if (!bindDevice.sendSignal) {
                    bindDevice.sendSignal = dispatch_semaphore_create(1);
                }
                
                if (![bindDevice.socket isDisconnected]) {
                    //已经连接了
                    [_lock unlock];
                    return;
                }
                
                NSError *error;
                if ([bindDevice.socket connectToHost:ipAddress onPort:16888 error:&error]) {
                    //连接操作
                    [_lock unlock];
                    
                    //查询插座状态
                    UInt8 controlCode = 0x01;
                    NSArray *data = @[@0xFC,@0x11,@0x00,@0x00];
                    [bindDevice sendData69With:controlCode mac:bindDevice.mac data:data];
                    
                    NSLog(@"%@连接成功",mac);
                    return;
                }else{
                    NSLog(@"bindError%@",error);
                }
            }
        }


        if (![self.mySocket isDisconnected]) {
            //如果已经连接了中央控制器，就不再重新连接了
            [_lock unlock];
            return;
        }
        
        if ([[Database shareInstance].currentHouse.mac isKindOfClass:[NSNull class]]) {
            [_lock unlock];
            return;
        }

        //只有绑定的网关才可以自动连接
        if (![[Database shareInstance].currentHouse.mac isEqualToString:mac]) {
            NSLog(@"该中央控制器不是当前家庭绑定的");
        }else{
            NSError *error;
            if ([self connectToHost:ipAddress onPort:16888 error:&error]) {
                self.connectedDevice = device;
            }
        }
    }
    [_lock unlock];
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    NSLog(@"断开连接1");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"发送的消息");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"已经连接");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"断开连接2");
    //设置广播
    [_udpSocket enableBroadcast:YES error:&error];
    
    //开启接收数据
    [_udpSocket beginReceiving:&error];
    if (error) {
        NSLog(@"开启接收数据:%@",error);
        return;
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"没有发送数据");
}

#pragma mark - Tcp Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功");
    //[self.udpTimer setFireDate:[NSDate distantFuture]];
    sleep(1.f);
    
    if ([self.connectedDevice.mac isEqualToString:[Database shareInstance].currentHouse.mac]) {
        //查询设备帧，一连上内网查一次
        UInt8 controlCode = 0x00;
        NSArray *data = @[@0xFE,@0x01,@0x45,@0x00];//在网节点查询
        [[Network shareNetwork] sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data failuer:nil];
        
        [_mySocket readDataWithTimeout:-1 tag:1];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"连接失败");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject showHudTipStr:LocalString(@"连接已断开")];
    });
    if (!_isDeviceVC) {
        [self.udpTimer setFireDate:[NSDate date]];
    }
    self.connectedDevice = nil;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"接收到消息%@",data);
    NSLog(@"socket成功收到帧, tag: %ld", tag);
    [self checkOutFrame:data];
    [_mySocket readDataWithTimeout:-1 tag:1];
    
    for (DeviceModel *device in self.deviceArray) {
        if (device.socket == sock) {
            
            [device.socket readDataWithTimeout:-1 tag:1];
            
            //以下操作保证收到上报帧或者回复帧后只有一个信号量，不会一次发出多条帧
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
            dispatch_semaphore_wait(device.sendSignal, time);
            dispatch_semaphore_signal(device.sendSignal);//收到信息增加信号量
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //NSLog(@"发送了一条帧");
    _frameCount++;
}

- (void)applicationWillEnterForeground{
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]addObserverForName:UIApplicationWillEnterForegroundNotification  object:app queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if (![self.mySocket isDisconnected]) {
            NSLog(@"网关主动断开");
            [self.mySocket disconnect];
        }
    }];
}

#pragma mark - AP配网组帧
/*
 *AP配网组帧
 */
- (void)APsendData69With:(UInt8)controlCode mac:(NSString *)mac data:(NSArray *)data{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_sync(self->_queue, ^{
            
            //线程锁需要放在最前面，放在后面锁不住
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
            dispatch_semaphore_wait(self.sendSignal, time);
            
            NSMutableArray *data69 = [[NSMutableArray alloc] init];
            [data69 addObject:[NSNumber numberWithUnsignedInteger:0x69]];
            [data69 addObject:[NSNumber numberWithUnsignedInteger:controlCode]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(0, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(4, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(6, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:self->_frameCount]];
            [data69 addObject:[NSNumber numberWithInteger:data.count]];
            [data69 addObjectsFromArray:data];
            [data69 addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:data69]]];
            [data69 addObject:[NSNumber numberWithUnsignedChar:0x17]];
            
            [self send:data69 withTag:100];//内网tcp发送
        });
    });
}

#pragma mark - Actions
//tcp connect
- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError *__autoreleasing *)errPtr{
    if (![_mySocket isDisconnected]) {
        NSLog(@"网关主动断开");
        [_mySocket disconnect];
    }
    return [_mySocket connectToHost:host onPort:port error:errPtr];
}

//帧的发送
- (void)send:(NSMutableArray *)msg withTag:(NSUInteger)tag
{
    if (![self.mySocket isDisconnected])
    {
        NSUInteger len = msg.count;
        UInt8 sendBuffer[len];
        for (int i = 0; i < len; i++)
        {
            sendBuffer[i] = [[msg objectAtIndex:i] unsignedCharValue];
        }
        
        NSData *sendData = [NSData dataWithBytes:sendBuffer length:len];
        NSLog(@"发送一条帧： %@",sendData);
        if (tag == 100) {
            [self.mySocket writeData:sendData withTimeout:-1 tag:1];
            [self.mySocket readDataWithTimeout:-1 tag:1];
        }
        
    }
    else
    {
        NSLog(@"Socket未连接");
    }
}

#pragma mark - 基本设备方法
/*
 *发送帧组成模版
 */
- (void)sendData69With:(UInt8)controlCode mac:(NSString *)mac data:(NSArray *)data failuer:(nullable void(^)(void))failure{
    if ([[Database shareInstance].currentHouse.mac isKindOfClass:[NSNull class]]) {
        NSLog(@"currentHouse.mac is null");
        //[NSObject showHudTipStr:@"当前家庭没有添加中央控制器"];
        [SVProgressHUD dismiss];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_sync(self->_queue, ^{
            
            //线程锁需要放在最前面，放在后面锁不住
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
            dispatch_semaphore_wait(self.sendSignal, time);

            noUserInteractionHeartbeat = 0;//心跳清零
            
            //测试用代码
            self.testSendCount++;

            NSMutableArray *data69 = [[NSMutableArray alloc] init];
            [data69 addObject:[NSNumber numberWithUnsignedInteger:0x69]];
            [data69 addObject:[NSNumber numberWithUnsignedInteger:controlCode]];
            if ([self judgeDeviceTypeWith:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]] == DeviceCenterlControl) {
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(0, 2)]]]];
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]]];
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(4, 2)]]]];
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(6, 2)]]]];
            }else{
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(6, 2)]]]];
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(4, 2)]]]];
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]]];
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(0, 2)]]]];

            }
            [data69 addObject:[NSNumber numberWithInt:self->_frameCount]];
            [data69 addObject:[NSNumber numberWithInteger:data.count]];
            [data69 addObjectsFromArray:data];
            [data69 addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:data69]]];
            [data69 addObject:[NSNumber numberWithUnsignedChar:0x17]];
            
            if ([[Database shareInstance].currentHouse.mac isKindOfClass:[NSNull class]]) {
                return;
            }
            
            if (![[Database shareInstance].currentHouse.mac isEqualToString:self.connectedDevice.mac]) {
                Database *db = [Database shareInstance];
                [self oneNETSendData:data69 apiKey:db.currentHouse.apiKey deviceId:db.currentHouse.deviceId failure:failure];//OneNet发送
            }else{
                [self send:data69 withTag:100];//内网tcp发送
            }
            
        });
    });
}

/*
 @param recivedData69 中央控制器返回的69帧
 *从网关获取设备列表并进行数据库等的操作
 */

- (void)inquireNode:(NSMutableArray *)recivedData69{
    Database *db = [Database shareInstance];
    NSMutableArray *localMountDeviceArray = [db queryCenterlControlMountDevice:db.currentHouse.houseUid];
    if (!self.connectedDevice) {
        self.connectedDevice = [[DeviceModel alloc] init];
    }
    if (!self.connectedDevice.gatewayMountDeviceList) {
        self.connectedDevice.gatewayMountDeviceList = [[NSMutableArray alloc] init];
    }
    [self.connectedDevice.gatewayMountDeviceList removeAllObjects];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObjectsFromArray:recivedData69];
    int count = [data[12] intValue];
    for (int i = 0; i < count; i++) {
        DeviceModel *device = [[DeviceModel alloc] init];
        device.mac = @"";
        device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[16 + i*4] intValue]]];
        device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[15 + i*4] intValue]]];
        device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[14 + i*4] intValue]]];
        device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[13 + i*4] intValue]]];
        device.type = [NSNumber numberWithInteger:[self judgeDeviceTypeWith:[data[15 + i*4] intValue]]];
        
        if ([device.type integerValue] == DeviceCenterlControl) {
            continue;
        }
        
        //将中央控制器查询到的设备和服务器设备对比
        BOOL isExisted = NO;//防止重复显示以及刷新时重新添加设备到服务器
        for (DeviceModel *existedDevice in self.connectedDevice.gatewayMountDeviceList) {
            NSLog(@"%@",existedDevice.mac);
            if ([existedDevice.mac isEqualToString:device.mac]) {
                //existedDevice.isOnline = @0;
                //existedDevice.isOn = @0;
                isExisted = YES;
            }
        }
        if (isExisted) {
            continue;
        }
        
        //判断设备是否本地存储过
        BOOL isLocal = NO;
        for (DeviceModel *localDevice in localMountDeviceArray) {
            if ([device.mac isEqualToString:localDevice.mac]) {
                localDevice.type = device.type;
                
                [self.connectedDevice.gatewayMountDeviceList addObject:localDevice];
                NSLog(@"%@",localDevice.mac);
                [localMountDeviceArray removeObject:localDevice];
                isLocal = YES;
                break;
            }
        }
        if (!isLocal) {
            /**
             ～～未保存过，需要上传到服务器，保存到本地～～
             *不需要保存，显示在所有设备里，用户添加到房间才保存*
             **/
            
            //初始命名
            if ([device.type integerValue] == 1) {
                device.name = [NSString stringWithFormat:@"%@%@",LocalString(@"温控器"),[device.mac substringWithRange:NSMakeRange(6, 2)]];
            }else if ([device.type integerValue] == 2){
                device.name = [NSString stringWithFormat:@"%@%@",LocalString(@"无线水阀"),[device.mac substringWithRange:NSMakeRange(6, 2)]];
            }
            __block typeof(self) blockSelf = self;
            [self addNewDeviceWith:device success:^{
                [blockSelf.connectedDevice.gatewayMountDeviceList addObject:device];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
            }];
        }
    }
    
    /*
     *将localDeviceArray剩余的device从服务器中删除，因为在网关中查找不到设备
     */
    for (DeviceModel *localDevice in localMountDeviceArray) {
        [self removeOldDeviceWith:localDevice success:^{
            //通知刷新设备
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
        } failure:^{
            
        }];
    }
    
    //通知刷新设备
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
    
    if (![[Database shareInstance].currentHouse.mac isEqualToString:self.connectedDevice.mac]) {
        //外网，OneNet查询监控点
        [self inquireDeviceInfoByOneNetdatastreams:self.connectedDevice.gatewayMountDeviceList apiKey:db.currentHouse.apiKey deviceId:db.currentHouse.deviceId];
    }else{
        //内网
        for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
            //每个设备发送状态查询帧
            UInt8 controlCode = 0x01;
            NSArray *data;
            switch ([self judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]]) {
                case 1:
                    data = @[@0xFE,@0x12,@0x01,@0x00];
                    break;
                    
                case 2:
                    data = @[@0xFE,@0x13,@0x01,@0x00];
                    break;
                    
                default:
                    break;
            }
            [self sendData69With:controlCode mac:device.mac data:data failuer:nil];
        }
    }
    
//    //分享设备onenet获取状态
//    for (DeviceModel *device in db.shareDeviceArray) {
//        [self inquireShareDeviceInfoByOneNetdatastream:device];
//    }
}

/*
 *批量查询数据流信息
 */
- (void)inquireDeviceInfoByOneNetdatastreams:(NSMutableArray *)deviceArray apiKey:(NSString *)apiKey deviceId:(NSString *)deviceId{
    Database *db = [Database shareInstance];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:apiKey forHTTPHeaderField:@"api-key"];
    
    NSString *url = [NSString stringWithFormat:@"http://api.heclouds.com/devices/%@/datastreams",deviceId];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSString *datastreams = @"";
    for (DeviceModel *device in deviceArray) {
        //每个设备发送状态查询帧
        switch ([self judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]]) {
            case DeviceThermostat:
                datastreams = [datastreams stringByAppendingString:@"11"];
                datastreams = [datastreams stringByAppendingString:device.mac];
                datastreams = [datastreams stringByAppendingString:@","];
                break;
                
            case DeviceValve:
            case DeviceNTCValve:
                datastreams = [datastreams stringByAppendingString:@"21"];
                datastreams = [datastreams stringByAppendingString:device.mac];
                datastreams = [datastreams stringByAppendingString:@","];
                break;
                
            case DevicePlugOutlet:
            case DeviceOneSwitch:
            case DeviceTwoSwitch:
            case DeviceThreeSwitch:
            case DeviceFourSwitch:
                datastreams = [datastreams stringByAppendingString:@"FC1100"];
                datastreams = [datastreams stringByAppendingString:device.mac];
                datastreams = [datastreams stringByAppendingString:@","];
                break;
                
            default:
                break;
        }
    }
    NSDictionary *parameters = @{@"datastream_ids":datastreams};
    NSLog(@"%@",parameters);
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            if ([[responseDic objectForKey:@"data"] isKindOfClass:[NSArray class]] && [[responseDic objectForKey:@"data"] count] > 0) {
                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *streamId = [obj objectForKey:@"id"];
                    NSNumber *value = [obj objectForKey:@"current_value"];
                    [self analysisResultValue:streamId value:value];
                }];
            }
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        
    }];
}

//解析从onenet获取的监控点信息
- (void)analysisResultValue:(NSString *)streamId value:(NSNumber *)value{
    NSString *index = [streamId substringWithRange:NSMakeRange(0, 2)];
    if ([index isEqualToString:@"FC"]) {
        [self analysisJienuo:streamId value:value];
    }else{
        //中央控制器下挂设备
    }
    
    NSString *mac = [streamId substringFromIndex:2];
    for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
        if ([device.mac isEqualToString:mac]) {
            switch ([index integerValue]) {
                case 11:
                {
                    device.isOnline = [NSNumber numberWithUnsignedInteger:[value unsignedIntegerValue] & 0x80];
                    device.isOn = [NSNumber numberWithUnsignedInteger:[value unsignedIntegerValue] & 0x01];
                }
                    break;
                    
                case 21:
                {
                    device.isOnline = [NSNumber numberWithUnsignedInteger:[value unsignedIntegerValue] & 0x80];
                    device.isOn = [NSNumber numberWithUnsignedInteger:[value unsignedIntegerValue] & 0x01];
                    device.isUnusual = [value unsignedIntegerValue] & 0x40;
                    device.isTemperatureAlarm = [value unsignedIntegerValue] & 0x20;
                }
                    break;
                    
                default:
                    break;
            }
            
            NSDictionary *userInfo = @{@"device":device,@"isShare":@0};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
        }
    }
}

- (void)analysisJienuo:(NSString *)streamId value:(NSNumber *)value{
    NSString *funcFrame = [streamId substringWithRange:NSMakeRange(4, 2)];
    NSString *mac = [streamId substringFromIndex:6];
    for (DeviceModel *device in self.deviceArray) {
        if ([device.mac isEqualToString:mac]) {
            switch ([funcFrame integerValue]) {
                case 00:
                {
                    device.isOnline = @1;
                    device.isOn = [NSNumber numberWithUnsignedInteger:[value unsignedIntegerValue] & 0xFF];
                }
                    break;
                    
                case 10:
                {
                    
                }
                    break;
                    
                default:
                    break;
            }
            
            NSDictionary *userInfo = @{@"device":device,@"isShare":@0};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
        }
    }
}

/*
 @param recivedData69 主动上报的帧
 *设备入网时主动上报的处理
 */
- (void)addNode:(NSMutableArray *)recivedData69{
    if (!_deviceArray) {
        _deviceArray = [[NSMutableArray alloc] init];
    }
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObjectsFromArray:self.recivedData69];
    
    DeviceModel *device = [[DeviceModel alloc] init];
    device.mac = @"";
    device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[12] intValue]]];
    device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[13] intValue]]];
    device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[14] intValue]]];
    device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[15] intValue]]];
    //device.type = [NSNumber numberWithInteger:[self judgeDeviceTypeWith:[data[13] intValue]]];
    
    /*
     ～未保存过，需要上传到服务器，保存到本地～
     *现在不保存到服务器，只加入所有设备房间中*
     */
    //[self addNewDeviceWith:device];
    
    device.name = device.mac;
    [self.deviceArray addObject:device];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
}


/*
 *上传新设备
 */
- (void)addNewDeviceWith:(DeviceModel *)device success:(void(^)(void))success{
    Database *db = [Database shareInstance];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    if (!device.name) {
        device.name = device.mac;
    }
    NSDictionary *parameters;
    NSMutableArray *homeList = [db queryRoomsWith:db.currentHouse.houseUid];
    if (homeList.count <= 0) {
        [NSObject showHudTipStr:LocalString(@"当前家庭还没有添加房间，请尽快添加")];
        parameters = @{@"type":device.type,@"mac":device.mac,@"name":device.name,@"roomUid":db.currentHouse.houseUid,@"houseUid":db.currentHouse.houseUid};
    }else{
        RoomModel *room = homeList[0];//将新设备插入到家庭第一个房间
        parameters = @{@"type":device.type,@"mac":device.mac,@"name":device.name,@"roomUid":room.roomUid,@"houseUid":db.currentHouse.houseUid};
    }
    NSLog(@"%@",parameters);
    
    NSString *url = [NSString stringWithFormat:@"%@/api/device",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager POST:url parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"success:%@",daetr);
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  /*
                   *保存到本地
                   */
                  [db insertNewDevice:device];
                  if (success) {
                      success();
                  }
              }else{
                  
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              if (error.code == -1001) {
                  [NSObject showHudTipStr:LocalString(@"无法登录远程服务器，请检查网络状况")];
              }else{
                  [NSObject showHudTipStr:LocalString(@"服务器添加设备失败")];
              }
              
          }
     ];
}

/*
 *删除设备
 */
- (void)removeOldDeviceWith:(DeviceModel *)device success:(void(^)(void))success failure:(void(^)(void))failure{
    Database *db = [Database shareInstance];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"mac":device.mac,@"type":device.type,@"apiKey":db.currentHouse.apiKey};
    
    NSString *url = [NSString stringWithFormat:@"%@/api/device",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];//不加这句代码，delete方法会把字典以param形式加到url后面，而不是生成一个body，服务器会收不到信息
    
    [manager DELETE:url parameters:parameters
            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
                NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
                NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"success:%@",daetr);
                if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                    /*
                     *在本地删除
                     */
                    [db deleteDevice:device.mac];
                    NSLog(@"删除设备%@成功",device.mac);
                    if (success) {
                        success();
                    }
                }else{
                    if (failure) {
                        failure();
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"Error:%@",error);
                if (failure) {
                    failure();
                }
            }
     ];
}

/*
 *删除捷诺设备
 */
- (void)removeJienuoOldDeviceWith:(DeviceModel *)device success:(void(^)(void))success failure:(void(^)(void))failure{
    Database *db = [Database shareInstance];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"mac":device.mac,@"type":device.type,@"apiKey":device.apiKey};
    
    NSString *url = [NSString stringWithFormat:@"%@/api/device",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];//不加这句代码，delete方法会把字典以param形式加到url后面，而不是生成一个body，服务器会收不到信息
    
    [manager DELETE:url parameters:parameters
            success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
                NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
                NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"success:%@",daetr);
                if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                    /*
                     *在本地删除
                     */
                    [db deleteDevice:device.mac];
                    NSLog(@"删除设备%@成功",device.mac);
                    if (success) {
                        success();
                    }
                }else{
                    if (failure) {
                        failure();
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"Error:%@",error);
                if (failure) {
                    failure();
                }
            }
     ];
}


/*
 *判断设备类型
 */
- (DeviceType)judgeDeviceTypeWith:(int)macByte2{
    if (macByte2 >= 0x08 && macByte2 <= 0x0F) {
        return DeviceThermostat;
    }
    if (macByte2 >= 0x10 && macByte2 <= 0x17){
        return DeviceWallhob;
    }
    if (macByte2 >= 0x18 && macByte2 <= 0x1F) {
        return DeviceValve;
    }
    if (macByte2 >= 0x38 && macByte2 <= 0x3F) {
        return DevicePlugOutlet;
    }
    if (macByte2 >= 0x40 && macByte2 <= 0x47) {
        return DeviceNTCValve;
    }
    if (macByte2 >= 0x48 && macByte2 <= 0x4F) {
        return DeviceFourSwitch;
    }
    if (macByte2 >= 0x50 && macByte2 <= 0x57) {
        return DeviceThreeSwitch;
    }
    if (macByte2 >= 0x58 && macByte2 <= 0x5F) {
        return DeviceTwoSwitch;
    }
    if (macByte2 >= 0x60 && macByte2 <= 0x67) {
        return DeviceOneSwitch;
    }
    return DeviceCenterlControl;
}

#pragma mark - 分享设备方法
/*
 *分享设备发送帧
 */
- (void)sendData69With:(UInt8)controlCode shareDevice:(DeviceModel *)shareDevice data:(NSArray *)data failure:(nullable void(^)(void))failure{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_sync(self->_queue, ^{
            
            //线程锁需要放在最前面，放在后面锁不住
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC);
            dispatch_semaphore_wait(self.sendSignal, time);
            
            NSMutableArray *data69 = [[NSMutableArray alloc] init];
            [data69 addObject:[NSNumber numberWithUnsignedInteger:0x69]];
            [data69 addObject:[NSNumber numberWithUnsignedInteger:controlCode]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[shareDevice.mac substringWithRange:NSMakeRange(6, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[shareDevice.mac substringWithRange:NSMakeRange(4, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[shareDevice.mac substringWithRange:NSMakeRange(2, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[shareDevice.mac substringWithRange:NSMakeRange(0, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:self->_frameCount]];
            [data69 addObject:[NSNumber numberWithInteger:data.count]];
            [data69 addObjectsFromArray:data];
            [data69 addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:data69]]];
            [data69 addObject:[NSNumber numberWithUnsignedChar:0x17]];
            
            if (![shareDevice.shareDeviceHouseMac isEqualToString:self.connectedDevice.mac]) {
                [self oneNETSendData:data69 apiKey:shareDevice.apiKey deviceId:shareDevice.deviceId failure:failure];//OneNet发送
            }else{
                [self send:data69 withTag:100];//内网tcp发送
            }
            
        });
    });
}

/*
 *单独查询每个分享设备数据流信息
 */
- (void)inquireShareDeviceInfoByOneNetdatastream:(DeviceModel *)device{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:device.apiKey forHTTPHeaderField:@"api-key"];
    
    NSString *url = [NSString stringWithFormat:@"http://api.heclouds.com/devices/%@/datastreams",device.deviceId];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSString *datastreams = @"";
    switch ([self judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]]) {
        case DeviceThermostat:
            datastreams = [datastreams stringByAppendingString:@"11"];
            datastreams = [datastreams stringByAppendingString:device.mac];
            break;
            
        case DeviceValve:
        case DeviceNTCValve:
            datastreams = [datastreams stringByAppendingString:@"21"];
            datastreams = [datastreams stringByAppendingString:device.mac];
            break;
            
        case DevicePlugOutlet:
        case DeviceOneSwitch:
        case DeviceTwoSwitch:
        case DeviceThreeSwitch:
        case DeviceFourSwitch:
            datastreams = [datastreams stringByAppendingString:@"FC1100"];
            datastreams = [datastreams stringByAppendingString:device.mac];
            datastreams = [datastreams stringByAppendingString:@","];
            break;
            
        default:
            break;
    }
    NSDictionary *parameters = @{@"datastream_ids":datastreams};
    NSLog(@"%@",parameters);
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            if ([[responseDic objectForKey:@"data"] isKindOfClass:[NSArray class]] && [[responseDic objectForKey:@"data"] count] > 0) {
                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *streamId = [obj objectForKey:@"id"];
                    NSNumber *value = [obj objectForKey:@"current_value"];
                    [self analysisShareDeviceResultValue:streamId value:value];
                }];
            }
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        
    }];
}

//解析从onenet获取的分享设备监控点信息
- (void)analysisShareDeviceResultValue:(NSString *)streamId value:(NSNumber *)value{
    NSString *index = [streamId substringWithRange:NSMakeRange(0, 2)];
    
    if ([index isEqualToString:@"FC"]) {
        [self analysisShareDeviceJienuo:streamId value:value];
    }else{
        //中央控制器下挂设备
    }
    
    NSString *mac = [streamId substringFromIndex:2];
    for (DeviceModel *device in [Database shareInstance].shareDeviceArray) {
        if ([device.mac isEqualToString:mac]) {
            switch ([index integerValue]) {
                case 11:
                {
                    device.isOnline = [NSNumber numberWithUnsignedInteger:[value unsignedIntegerValue] & 0x80];
                    device.isOn = [NSNumber numberWithUnsignedInteger:[value unsignedIntegerValue] & 0x01];
                }
                    break;
                    
                case 21:
                {
                    device.isOnline = [NSNumber numberWithUnsignedInteger:[value unsignedIntegerValue] & 0x80];
                    device.isOn = [NSNumber numberWithUnsignedInteger:[value unsignedIntegerValue] & 0x01];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
}

- (void)analysisShareDeviceJienuo:(NSString *)streamId value:(NSNumber *)value{
    NSString *funcFrame = [streamId substringWithRange:NSMakeRange(4, 2)];
    NSString *mac = [streamId substringFromIndex:6];
    for (DeviceModel *device in [Database shareInstance].shareDeviceArray) {
        if ([device.mac isEqualToString:mac]) {
            switch ([funcFrame integerValue]) {
                case 00:
                {
                    device.isOnline = @1;
                    device.isOn = [NSNumber numberWithUnsignedInteger:[value unsignedIntegerValue] & 0xFF];
                }
                    break;
                    
                case 10:
                {
                    
                }
                    break;
                    
                default:
                    break;
            }
            
            NSDictionary *userInfo = @{@"device":device,@"isShare":@1};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
        }
    }
}

#pragma mark - OneNET Comminicate
- (void)oneNETSendData:(NSMutableArray *)msg apiKey:(NSString *)apiKey deviceId:(NSString *)deviceId failure:(void(^)(void))failure{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    
    [manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:apiKey forHTTPHeaderField:@"api-key"];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://api.heclouds.com/cmds?device_id=%@",deviceId];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSUInteger len = msg.count;
    NSMutableString *frame = [[NSMutableString alloc] init];
    for (int i = 0; i < len; i++)
    {
        [frame appendFormat:@"%@",[NSString stringWithFormat:@"%02lx",(unsigned long)[msg[i] unsignedIntegerValue]]];
    }
    NSDictionary *parameters = @{@"cmmd":frame};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSASCIIStringEncoding];
    NSLog(@"%@,%@,%@",jsonString,apiKey,deviceId);
    
    //AFNet会处理传入的parameters内容，添加=号，做以下处理就会原内容发送
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return jsonString;
    }];
    
    [manager POST:url parameters:jsonString progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            self->_frameCount++;//帧计数器增加
            NSDictionary *data =[responseDic objectForKey:@"data"];
            NSString *cmd_uuid = [data objectForKey:@"cmd_uuid"];
            [self getOneNETCommandStatus:cmd_uuid apiKey:apiKey resendTimes:20];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        if (failure) {
            failure();
        }
        [NSObject showHudTipStr:LocalString(@"网络异常")];
    }];
}

- (void)getOneNETCommandStatus:(NSString *)cmd_uuid apiKey:(NSString *)apiKey resendTimes:(NSInteger)resendTimes{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:apiKey forHTTPHeaderField:@"api-key"];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://api.heclouds.com/cmds/%@",cmd_uuid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSDictionary *data =[responseDic objectForKey:@"data"];
            if ([[data objectForKey:@"status"] intValue] == 2 || [[data objectForKey:@"status"] intValue] == 1) {
                if (resendTimes > 0) {
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        sleep(0.5f);
                        NSInteger times = resendTimes - 1;
                        [self getOneNETCommandStatus:cmd_uuid apiKey:apiKey resendTimes:times];
                    });
                }else{
                    
                }
            }else if ([[data objectForKey:@"status"] intValue] == 4){
                [self getOneNETCommandRespond:cmd_uuid apiKey:apiKey];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        
    }];
}

- (void)getOneNETCommandRespond:(NSString *)cmd_uuid apiKey:(NSString *)apiKey{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:apiKey forHTTPHeaderField:@"api-key"];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://api.heclouds.com/cmds/%@/resp",cmd_uuid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSLog(@"%@",responseObject);
        if (responseObject == nil) {
            return ;
        }
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        NSString *cmmdReply = [responseDic objectForKey:@"cmmdReply"];
        [self handleOneNET69Message:cmmdReply];
        dispatch_semaphore_signal(self.sendSignal);//收到信息增加信号量
        
        //测试
        self.testRecieveCount++;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        
    }];
}

#pragma mark - OneNET 回复数据处理
- (void)handleOneNET69Message:(NSString *)cmmdReply{
    NSMutableArray *cmmdReplyData = [[NSMutableArray alloc] init];
    NSInteger length = cmmdReply.length;
    for (int i = 0; i < length; i = i + 2) {
        NSString *frameByte = [cmmdReply substringWithRange:NSMakeRange(i, 2)];
        [cmmdReplyData addObject:[NSNumber numberWithInt:[NSString stringScanToInt:frameByte]]];
    }
    [self handle68Message:cmmdReplyData];
}


#pragma mark - Frame69 接收处理
- (void)checkOutFrame:(NSData *)data{
    if (_allMsg && data) {
        [_allMsg removeAllObjects];
        
        //把读到的数据复制一份
        NSData *recvBuffer = [NSData dataWithData:data];
        NSUInteger recvLen = [recvBuffer length];
        //NSLog(@"%lu",(unsigned long)recvLen);
        UInt8 *recv = (UInt8 *)[recvBuffer bytes];
        if (recvLen > 1000) {
            return;
        }
        //把接收到的数据存放在recvData数组中
        NSMutableArray *recvData = [[NSMutableArray alloc] init];
        NSUInteger j = 0;
        while (j < recvLen) {
            [recvData addObject:[NSNumber numberWithUnsignedChar:recv[j]]];
            j++;
        }
        //每从recvData中取出正确的一帧就删除recvData中这段数据
        NSInteger i = 0;
        while (i < recvData.count) {
            //验证69帧的准确性
            //数据缓冲区中数据的长度
            NSUInteger recvDataLen = recvData.count;
            
            //数据不够一条完整的帧
            if (recvDataLen < 10) {
                return;
            }
            
            //1 帧头匹配
            if ([[recvData objectAtIndex:i] unsignedCharValue] == 0x69){
                //22,23位是数据域长度
                if ((i+7)>=recvLen) {
                    i++;
                    break;
                }
                int dataLen = [[recvData objectAtIndex:i+7] unsignedCharValue];
                
                NSInteger end = i + 7 + dataLen + 2;//帧尾0x17所在位置
                //2.帧尾匹配
                if ([recvData count] > end) {
                    if ([[recvData objectAtIndex:end] unsignedIntegerValue] == 0x17) {
                        //计算CS位 8＋数据域长度 ＝ 校验位前数据长度
                        UInt8 cs = 0x00;
                        for (int j = 0; j < 8 + dataLen; j++)
                        {
                            cs += [[recvData objectAtIndex:i+j] unsignedCharValue];
                        }
                        
                        //3.校验位匹配
                        if (cs == [[recvData objectAtIndex:end - 1] unsignedCharValue])
                        {
                            //存储这个帧命令
                            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:8+dataLen+2];
                            for (int k = 0; k < 8+dataLen+2; k++)
                            {
                                //每次删后，后面位自动前移
                                [array addObject:[recvData objectAtIndex:i]];
                                //NSLog(@"%@", array);
                                [recvData removeObjectAtIndex:i];
                            }
                            [_allMsg addObject:array];
                            continue;
                        }
                    }else{
                        NSLog(@"计算的字节长度不对");
                    }
                }
            }
            i++;
        }
        
    }
    [self distributeFrame];
}

- (void)distributeFrame{
    if (!_allMsg) {
        return;
    }
    //把每条数据分别处理
    for (int i = 0; i < _allMsg.count; i++) {
        //取出一帧
        NSMutableArray *data = [[NSMutableArray alloc] init];
        [data addObjectsFromArray:_allMsg[i]];
        //NSLog(@"沾包解出的帧%d：%@",i,data);
        
        [self handle68Message:data];
    }
}

- (void)handle68Message:(NSArray *)data
{
    if (![self frameIsRight:data])
    {
        //68帧数据错误
        return;
    }
    if (_recivedData69)
    {
        [_recivedData69 removeAllObjects];
        [_recivedData69 addObjectsFromArray:data];
    }
    
    switch ([_recivedData69[8] unsignedIntegerValue]) {
        case 0xFE:
        {
            //洁利达暖通项目
            [self gleadSmartFrameHandle];
        }
            break;
            
        case 0xFC:
        {
            //捷诺智能家居项目
            [self jienuoIOTFrameHandle];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)gleadSmartFrameHandle{
    //取出mac
    NSString *mac = @"";
    if ([_recivedData69[9] unsignedIntegerValue] == 0x01 || [_recivedData69[9] unsignedIntegerValue] == 0x02) {
        mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[2] intValue]]];
        mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[3] intValue]]];
        mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[4] intValue]]];
        mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[5] intValue]]];
    }else{
        mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[5] intValue]]];
        mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[4] intValue]]];
        mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[3] intValue]]];
        mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[2] intValue]]];
    }
    
    Database *db = [Database shareInstance];
    NSMutableArray *localMountDeviceArray = [db queryCenterlControlMountDevice:db.currentHouse.houseUid];

    //查询该设备是否已经添加到deviceArray
    BOOL isExisted = NO;//防止设备在localdevice中未添加到deviceArray，导致页面上UI不显示
    for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
        NSLog(@"%@",device.mac);
        if ([device.mac isEqualToString:mac]) {
            device.isOnline = @1;
            isExisted = YES;
        }
    }
    if (!isExisted) {
        //localdevice中的该设备添加到deviceArray
        for (DeviceModel *localDevice in localMountDeviceArray) {
            if ([mac isEqualToString:localDevice.mac]) {
                localDevice.isOnline = @1;
                
                [self.connectedDevice.gatewayMountDeviceList addObject:localDevice];
                NSLog(@"%@设备在localdevice中未添加到deviceArray，导致页面上UI不显示",localDevice.mac);
                break;
            }
        }
    }
    
    switch ([_recivedData69[9] unsignedIntegerValue]) {
        case 0x01:
        case 0x02:
        {
            /*
             *中央控制器
             */
            
            if ([_recivedData69[10] unsignedIntegerValue] == 0x45 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //在网节点查询
                NSLog(@"在网节点查询");
                [self inquireNode:_recivedData69];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x92 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                //在网节点删除
                NSLog(@"在网节点删除");
                self.isDeleted = YES;
                
                //获取家庭网关下所有下挂设备
                UInt8 controlCode = 0x00;
                NSArray *data = @[@0xFE,@0x01,@0x45,@0x00];//在网节点查询
                [[Network shareNetwork] sendData69With:controlCode mac:db.currentHouse.mac data:data failuer:nil];
                
                [NSObject showHudTipStr:LocalString(@"删除设备成功")];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x04 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //新增节点信息上报
                NSLog(@"新增节点信息上报");
                [self addNode:_recivedData69];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x05 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //恢复出厂设置
                NSLog(@"恢复出厂设置");
            }
        }
            break;
            
        case 0x03:
        {
            if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                NSLog(@"ap发送ssid成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"apSendSSIDSucc" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x02 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                NSLog(@"ap发送密码成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"apSendPasswordSucc" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                NSLog(@"获取路由器的RSSI值");
                NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
                
                NSNumber *RSSI = _recivedData69[12];
                [dataDic setObject:RSSI forKey:@"RSSI"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getRouterRSSIValue" object:nil userInfo:dataDic];
            }
        }
            break;
            
        case 0x12:
        {
            if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                NSLog(@"温控器状态");
                NSDictionary *userInfo;
                NSNumber *isOn;
                if ([_recivedData69[1] unsignedIntegerValue] == 0x01) {
                    //查询温控器状态
                    isOn = [NSNumber numberWithUnsignedInteger:[_recivedData69[12] unsignedIntegerValue]];
                }else if ([_recivedData69[1] unsignedIntegerValue] == 0x85){
                    //温控器状态主动上报
                    isOn = [NSNumber numberWithUnsignedInteger:[_recivedData69[16] unsignedIntegerValue]];
                }
                
                if (_recivedData69.count >= 18) {
                    UInt8 mode = [_recivedData69[13] unsignedIntegerValue];
                    UInt8 modetemp = [_recivedData69[14] unsignedIntegerValue];
                    UInt8 indoortemp = [_recivedData69[15] unsignedIntegerValue];
                    
                    if (modetemp & 0x80) {
                        modetemp = modetemp & 0x7F;
                        modetemp = -modetemp;
                    }else{
                        modetemp = modetemp & 0x7F;
                    }
                    NSNumber *modeTemp = [NSNumber numberWithFloat:modetemp/2.f];
                    
                    if (indoortemp & 0x80) {
                        indoortemp = indoortemp & 0x7F;
                        indoortemp = -indoortemp;
                    }else{
                        indoortemp = indoortemp & 0x7F;
                    }
                    NSNumber *indoorTemp = [NSNumber numberWithFloat:indoortemp/2.f];
                    
                    for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
                        if ([device.mac isEqualToString:mac]) {
                            NSLog(@"%@",device.mac);
                            device.isOn = isOn;
                            device.mode = [NSNumber numberWithUnsignedInteger:mode];
                            device.modeTemp = modeTemp;
                            device.indoorTemp = indoorTemp;
                            device.isOnline = @1;
                            userInfo = @{@"device":device,@"isShare":@0};
                        }
                    }
                    for (DeviceModel *device in db.shareDeviceArray) {
                        if ([device.mac isEqualToString:mac]) {
                            NSLog(@"%@",device.mac);
                            device.isOn = isOn;
                            device.mode = [NSNumber numberWithUnsignedInteger:mode];
                            device.modeTemp = modeTemp;
                            device.indoorTemp = indoorTemp;
                            device.isOnline = @1;
                            userInfo = @{@"device":device,@"isShare":@1};
                        }
                    }
                }
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThermostat" object:nil userInfo:nil];
                
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                //开关温控器
                NSLog(@"开关温控器");
                NSDictionary *userInfo;
                
                NSNumber *isOn = [NSNumber numberWithUnsignedInteger:[_recivedData69[12] unsignedIntegerValue]];
                if ([isOn integerValue]) {
                    NSLog(@"开关温控器%@",isOn);
                    
                    //打开温控器，通知温控器页面查询温度等
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"openThermostat" object:nil userInfo:nil];
                }
                
                if (_recivedData69.count >= 18) {
                    UInt8 mode = [_recivedData69[13] unsignedIntegerValue];
                    UInt8 modetemp = [_recivedData69[14] unsignedIntegerValue];
                    UInt8 indoortemp = [_recivedData69[15] unsignedIntegerValue];
                    
                    if (modetemp & 0x80) {
                        modetemp = modetemp & 0x7F;
                        modetemp = -modetemp;
                    }else{
                        modetemp = modetemp & 0x7F;
                    }
                    NSNumber *modeTemp = [NSNumber numberWithFloat:modetemp/2.f];
                    
                    if (indoortemp & 0x80) {
                        indoortemp = indoortemp & 0x7F;
                        indoortemp = -indoortemp;
                    }else{
                        indoortemp = indoortemp & 0x7F;
                    }
                    NSNumber *indoorTemp = [NSNumber numberWithFloat:indoortemp/2.f];
                    
                    for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
                        if ([device.mac isEqualToString:mac]) {
                            NSLog(@"%@",device.mac);
                            device.isOn = isOn;
                            device.mode = [NSNumber numberWithUnsignedInteger:mode];
                            device.modeTemp = modeTemp;
                            device.indoorTemp = indoorTemp;
                            device.isOnline = @1;
                            userInfo = @{@"device":device,@"isShare":@0};
                        }
                    }
                    for (DeviceModel *device in db.shareDeviceArray) {
                        if ([device.mac isEqualToString:mac]) {
                            NSLog(@"%@",device.mac);
                            device.isOn = isOn;
                            device.mode = [NSNumber numberWithUnsignedInteger:mode];
                            device.modeTemp = modeTemp;
                            device.indoorTemp = indoorTemp;
                            device.isOnline = @1;
                            userInfo = @{@"device":device,@"isShare":@1};
                        }
                    }
                }
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThermostat" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x03 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //查询温控器状态
                NSLog(@"查询温控器状态");
                UInt8 mode = [_recivedData69[12] unsignedIntegerValue];
                UInt8 modetemp = [_recivedData69[13] unsignedIntegerValue];
                UInt8 indoortemp = [_recivedData69[14] unsignedIntegerValue];
                
                if (modetemp & 0x80) {
                    modetemp = modetemp & 0x7F;
                    modetemp = -modetemp;
                }else{
                    modetemp = modetemp & 0x7F;
                }
                NSNumber *modeTemp = [NSNumber numberWithFloat:modetemp/2.f];
                
                if (indoortemp & 0x80) {
                    indoortemp = indoortemp & 0x7F;
                    indoortemp = -indoortemp;
                }else{
                    indoortemp = indoortemp & 0x7F;
                }
                NSNumber *indoorTemp = [NSNumber numberWithFloat:indoortemp/2.f];
                
                for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
                    if ([device.mac isEqualToString:mac]) {
                        device.mode = [NSNumber numberWithUnsignedInteger:mode];
                        device.modeTemp = modeTemp;
                        device.indoorTemp = indoorTemp;
                        device.isOnline = @1;
                    }
                }
                for (DeviceModel *device in db.shareDeviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.mode = [NSNumber numberWithUnsignedInteger:mode];
                        device.modeTemp = modeTemp;
                        device.indoorTemp = indoorTemp;
                        device.isOnline = @1;
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThermostat" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x03 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                NSLog(@"设置温控器模式温度");
                
                UInt8 modetemp = [_recivedData69[13] unsignedIntegerValue];
                
                if (modetemp & 0x80) {
                    modetemp = modetemp & 0x7F;
                    modetemp = -modetemp;
                }else{
                    modetemp = modetemp & 0x7F;
                }
                NSNumber *modeTemp = [NSNumber numberWithFloat:modetemp/2.f];
                NSDictionary *userInfo = @{@"modeTemp":modeTemp};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"postSetBackModeTemp" object:nil userInfo:userInfo];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x04 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                NSLog(@"1111");
                //查询周程序
                NSLog(@"查询周程序");
                NSMutableArray *weekProgram = [[NSMutableArray alloc] init];
                for (int i = 0; i < 24; i++) {
                    [weekProgram addObject:[NSNumber numberWithUnsignedInteger:[_recivedData69[12 + i] unsignedIntegerValue]]];
                }
                
                for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
                    if ([device.mac isEqualToString:mac]) {
                        device.weekProgram = weekProgram;
                    }
                }
                for (DeviceModel *device in db.shareDeviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.weekProgram = weekProgram;
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshWeekProgram" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x05 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                //切换模式
                NSLog(@"切换模式");
                UInt8 mode = [_recivedData69[12] unsignedIntegerValue];
                
                for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
                    if ([device.mac isEqualToString:mac]) {
                        device.mode = [NSNumber numberWithUnsignedInteger:mode];
                    }
                }
                for (DeviceModel *device in db.shareDeviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.mode = [NSNumber numberWithUnsignedInteger:mode];
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThermostat" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"switchThermostatMode" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x07 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //查询补偿
                NSLog(@"查询补偿");
                UInt8 temp = [_recivedData69[12] unsignedIntegerValue];
                if (temp * 0x80) {
                    temp = temp & 0x7F;
                }
                NSNumber *compensate = [NSNumber numberWithUnsignedInteger:temp];
                
                for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
                    if ([device.mac isEqualToString:mac]) {
                        device.compensate = compensate;
                    }
                }
                for (DeviceModel *device in db.shareDeviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.compensate = compensate;
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshCompensate" object:nil userInfo:nil];
            }
        }
            break;
            
        case 0x13:
        {
            if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                //控制水阀状态
                NSLog(@"控制水阀状态");
                NSDictionary *userInfo;
                for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
                    if ([device.mac isEqualToString:mac]) {
                        device.isOnline = @1;
                        device.isOn = [NSNumber numberWithUnsignedInteger:([_recivedData69[12] unsignedIntegerValue] & 0x01)];
                        device.isUnusual = [_recivedData69[12] unsignedIntegerValue] & 0x02;
                        device.isTemperatureAlarm = [_recivedData69[12] unsignedIntegerValue] & 0x04;
                        userInfo = @{@"device":device,@"isShare":@1};
                    }
                }
                for (DeviceModel *device in db.shareDeviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.isOnline = @1;
                        device.isOn = [NSNumber numberWithUnsignedInteger:([_recivedData69[12] unsignedIntegerValue] & 0x01)];
                        device.isUnusual = [_recivedData69[12] unsignedIntegerValue] & 0x02;
                        device.isTemperatureAlarm = [_recivedData69[12] unsignedIntegerValue] & 0x04;
                        userInfo = @{@"device":device,@"isShare":@1};
                    }
                }
                
                NSLog(@"水阀开关回复:%lu",(unsigned long)[_recivedData69[12] unsignedIntegerValue]);
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshValve" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //查询无线水阀状态
                NSDictionary *userInfo;
                NSLog(@"查询无线水阀状态");
                for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
                    if ([device.mac isEqualToString:mac]) {
                        device.isOnline = @1;
                        device.isOn = [NSNumber numberWithUnsignedInteger:([_recivedData69[12] unsignedIntegerValue] & 0x01)];
                        device.isUnusual = [_recivedData69[12] unsignedIntegerValue] & 0x02;
                        device.isTemperatureAlarm = [_recivedData69[12] unsignedIntegerValue] & 0x04;
                        userInfo = @{@"device":device,@"isShare":@0};
                    }
                }
                for (DeviceModel *device in db.shareDeviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.isOnline = @1;
                        device.isOn = [NSNumber numberWithUnsignedInteger:([_recivedData69[12] unsignedIntegerValue] & 0x01)];
                        device.isUnusual = [_recivedData69[12] unsignedIntegerValue] & 0x02;
                        device.isTemperatureAlarm = [_recivedData69[12] unsignedIntegerValue] & 0x04;
                        userInfo = @{@"device":device,@"isShare":@1};
                    }
                }
                
                //设备内容页面UI等刷新
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshValve" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x02 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //下挂漏水节点状态上报
                NSLog(@"下挂漏水节点状态上报");
                
                NSDictionary *userInfo = @{@"recivedData69":_recivedData69};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"valveHangingNodesReport" object:nil userInfo:userInfo];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x04 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //查询水阀下挂节点
                NSLog(@"获得水阀下挂节点");
                
                NSMutableArray *nodeArray = [[NSMutableArray alloc] init];
                NSInteger dataLenth = [_recivedData69[7] integerValue] - 4;
                for (int k = 0; k < dataLenth; k=k+5) {
                    NodeModel *node = [[NodeModel alloc] init];
                    
                    node.mac = @"";
                    node.mac = [node.mac stringByAppendingString:[NSString HexByInt:[_recivedData69[15 + k] intValue]]];
                    node.mac = [node.mac stringByAppendingString:[NSString HexByInt:[_recivedData69[14 + k] intValue]]];
                    node.mac = [node.mac stringByAppendingString:[NSString HexByInt:[_recivedData69[13 + k] intValue]]];
                    node.mac = [node.mac stringByAppendingString:[NSString HexByInt:[_recivedData69[12 + k] intValue]]];
                    UInt8 nodeInfo = [_recivedData69[16 + k] unsignedIntegerValue];
                    if (nodeInfo & 0b00000010) {
                        node.isLeak = YES;
                    }else{
                        node.isLeak = NO;
                    }
                    if (nodeInfo & 0b00000001){
                        node.isLowVoltage = YES;
                    }else{
                        node.isLowVoltage = NO;
                    }
                    
                    [nodeArray addObject:node];
                }
                
                for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
                    if ([device.mac isEqualToString:mac]) {
                        device.nodeArray = nodeArray;
                    }
                }
                for (DeviceModel *device in db.shareDeviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.nodeArray = nodeArray;
                    }
                }
                
                //设备内容页面UI等刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshValveHangingNodes" object:nil userInfo:nil];
                [SVProgressHUD dismiss];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x06 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //水阀恢复出厂设置
                NSLog(@"水阀恢复出厂设置");
                
                for (DeviceModel *device in self.connectedDevice.gatewayMountDeviceList) {
                    if ([device.mac isEqualToString:mac]) {
                        [device.nodeArray removeAllObjects];
                    }
                }
                for (DeviceModel *device in db.shareDeviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        [device.nodeArray removeAllObjects];
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"valveReset" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x07 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                //水阀删除某个节点
                NSLog(@"水阀删除某个节点");
                
                if ([_recivedData69[7] integerValue] == 4) {
                    NSLog(@"删除失败，设备为空");
                    [NSObject showHudTipStr:@"删除失败"];
                    return;
                }
                
                NodeModel *deletedNode = [[NodeModel alloc] init];
                deletedNode.mac = @"";
                deletedNode.mac = [deletedNode.mac stringByAppendingString:[NSString HexByInt:[_recivedData69[12] intValue]]];
                deletedNode.mac = [deletedNode.mac stringByAppendingString:[NSString HexByInt:[_recivedData69[13] intValue]]];
                deletedNode.mac = [deletedNode.mac stringByAppendingString:[NSString HexByInt:[_recivedData69[14] intValue]]];
                deletedNode.mac = [deletedNode.mac stringByAppendingString:[NSString HexByInt:[_recivedData69[15] intValue]]];
                
                if ([deletedNode.mac intValue] == 0) {
                    NSLog(@"删除失败，设备为空");
                    [NSObject showHudTipStr:@"删除失败"];
                    return;
                }
                
                [NSObject showHudTipStr:@"删除成功"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"valveDeleteHangingNode" object:nil userInfo:nil];//删除节点后直接水阀页面节点重新生成
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x08 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                
                NSLog(@"查询水阀阈值");
                NSNumber *getThreshold = [NSNumber numberWithInt:[_recivedData69[12] intValue]];
                NSNumber *temp = [NSNumber numberWithInt:[_recivedData69[13] intValue]];
                NSDictionary *userInfo = @{@"getThreshold":getThreshold,@"temp":temp};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getValveThreshold" object:nil userInfo:userInfo];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x08 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                
                NSLog(@"设置水阀阈值");
                NSNumber *setThreshold = [NSNumber numberWithInt:[_recivedData69[12] intValue]];
                NSDictionary *userInfo = @{@"setThreshold":setThreshold};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setValveThresholdSucc" object:nil userInfo:userInfo];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)jienuoIOTFrameHandle{
    //取出mac
    NSString *mac = @"";
    mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[2] intValue]]];
    mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[3] intValue]]];
    mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[4] intValue]]];
    mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[5] intValue]]];
    
    
    Database *db = [Database shareInstance];
    for (DeviceModel *device in self.deviceArray) {
        if ([device.mac isEqualToString:mac]) {
            //收到信息就上线
            device.isOnline = @1;
        }
    }
//    if ([_recivedData69[1] unsignedIntegerValue] == 0x81 ) {
//        //NSLog(@"屏蔽内网上报");
//        return;
//    }
    switch ([_recivedData69[9] unsignedIntegerValue]) {
        case 0x11:
        {
            if ([_recivedData69[10] unsignedIntegerValue] == 0x20 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                NSLog(@"ap发送ssid成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"apSendSSIDSucc" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x21 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                NSLog(@"ap发送密码成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"apSendPasswordSucc" object:nil userInfo:nil];
            }

            //智能插座
             NSInteger type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]];
            switch (type) {
                case DevicePlugOutlet: //智能插座
                {
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x00 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        //NSLog(@"查询wifi智能插座的开关状态");
                        
                    }
                    if (([_recivedData69[10] unsignedIntegerValue] == 0x00 && [_recivedData69[11] unsignedIntegerValue] == 0x00) || ([_recivedData69[10] unsignedIntegerValue] == 0x00 && [_recivedData69[11] unsignedIntegerValue] == 0x01)) {
                        NSLog(@"查询或设置wifi智能插座的开关状态,或主动上报");
                        NSDictionary *userInfo;
                        
                        NSNumber *isOn = [NSNumber numberWithUnsignedInteger:[_recivedData69[12] unsignedIntegerValue]];
                        
                        for (DeviceModel *device in self.deviceArray) {
                            if ([device.mac isEqualToString:mac]) {
                                NSLog(@"%@",device.mac);
                                device.isOn = isOn;
                                device.isOnline = @1;
                                userInfo = @{@"device":device,@"isShare":@0};
                            }
                        }
                        for (DeviceModel *device in db.shareDeviceArray) {
                            if ([device.mac isEqualToString:mac]) {
                                NSLog(@"%@",device.mac);
                                device.isOn = isOn;
                                device.isOnline = @1;
                                userInfo = @{@"device":device,@"isShare":@1};
                            }
                        }
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPlugOutletUI" object:nil userInfo:userInfo];
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能插座当前日期时间");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                        //在网节点查询
                        NSLog(@"设置wifi智能插座当前日期时间");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x02 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能插座的闹钟");
                        NSDictionary *userInfo = @{@"frame":_recivedData69,@"mac":mac};
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getClockList" object:nil userInfo:userInfo];
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x02 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                        NSLog(@"设置wifi智能插座的闹钟");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"plugoutSetClock" object:nil userInfo:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"plugoutDeleteClock" object:nil userInfo:nil];
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x03 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能插座的闹钟项列表");
                        NSDictionary *userInfo = @{@"frame":_recivedData69,@"mac":mac};
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getClockList" object:nil userInfo:userInfo];
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x04 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能插座的延时开关");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x04 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                        NSLog(@"设置wifi智能插座的延时开关");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"plugoutSetDelay" object:nil userInfo:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"plugoutDeleteDelayClock" object:nil userInfo:nil];
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x05 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能插座的延时开关列表");
                        NSDictionary *userInfo = @{@"frame":_recivedData69,@"mac":mac};
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getdelayclockList" object:nil userInfo:userInfo];
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x10 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能插座的电量（电压，电流，功率）");
                        
                        NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
                        
                        NSNumber *voltage1 = _recivedData69[12];
                        NSNumber *voltage2 = _recivedData69[13];
                        NSNumber *current1 = _recivedData69[14];
                        NSNumber *current2 = _recivedData69[15];
                        NSNumber *power1 = _recivedData69[16];
                        NSNumber *power2 = _recivedData69[17];
                        NSNumber *todayEnergyUsed1 = _recivedData69[18];
                        NSNumber *todayEnergyUsed2 = _recivedData69[19];
                        NSNumber *todayEnergyUsed3 = _recivedData69[20];
                        NSNumber *todayEnergyUsed4 = _recivedData69[21];
                        NSString *voltage = [[NSString alloc] initWithFormat:@"%.1f",([voltage1 intValue]*256 + [voltage2 intValue]) * 0.1];
                        NSString *current = [[NSString alloc] initWithFormat:@"%d",[current1 intValue]*256 + [current2 intValue]];
                        NSString *power = [[NSString alloc] initWithFormat:@"%d",[power1 intValue]*256 + [power2 intValue]];
                        NSString *todayEnergyUsed = [[NSString alloc] initWithFormat:@"%.3f",([todayEnergyUsed1 intValue]*65536 + [todayEnergyUsed2 intValue]*4096 +[todayEnergyUsed3 intValue]*256 +[todayEnergyUsed4 intValue]) *0.001];
                        [dataDic setObject:voltage forKey:@"Voltage"];
                        [dataDic setObject:current forKey:@"Current"];
                        [dataDic setObject:power forKey:@"Power"];
                        [dataDic setObject:todayEnergyUsed forKey:@"todayEnergyUsed"];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getElectricityValue" object:nil userInfo:dataDic];

                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x11 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能插座的电压");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x12 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能插座的电流");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x13 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能插座的功率");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x20 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                        NSLog(@"设置wifi的SSID");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x21 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                        NSLog(@"设置wifi的密码");
                    }
                }
                    break;
        
                default: //智能开关
                {
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x00 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能开关的状态");
                        NSDictionary *userInfo;
                        
                        NSNumber *isOn = [NSNumber numberWithUnsignedInteger:[_recivedData69[12] unsignedIntegerValue]];
                        
                        for (DeviceModel *device in self.deviceArray) {
                            if ([device.mac isEqualToString:mac]) {
                                NSLog(@"%@",device.mac);
                                device.isOn = isOn;
                                device.isOnline = @1;
                                userInfo = @{@"device":device,@"isShare":@0};
                            }
                        }
                        for (DeviceModel *device in db.shareDeviceArray) {
                            if ([device.mac isEqualToString:mac]) {
                                NSLog(@"%@",device.mac);
                                device.isOn = isOn;
                                device.isOnline = @1;
                                userInfo = @{@"device":device,@"isShare":@1};
                            }
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMulSwitchUI" object:nil userInfo:nil];
                        
                    }
                    if (([_recivedData69[10] unsignedIntegerValue] == 0x00 && [_recivedData69[11] unsignedIntegerValue] == 0x00) || ([_recivedData69[10] unsignedIntegerValue] == 0x00 && [_recivedData69[11] unsignedIntegerValue] == 0x01)) {
                        NSLog(@"查询或设置wifi智能开关的状态");
                        NSDictionary *userInfo;
                        
                        NSNumber *isOn = [NSNumber numberWithUnsignedInteger:[_recivedData69[12] unsignedIntegerValue]];
                        
                        for (DeviceModel *device in self.deviceArray) {
                            if ([device.mac isEqualToString:mac]) {
                                NSLog(@"%@",device.mac);
                                device.isOn = isOn;
                                device.isOnline = @1;
                                userInfo = @{@"device":device,@"isShare":@0};
                            }
                        }
                        for (DeviceModel *device in db.shareDeviceArray) {
                            if ([device.mac isEqualToString:mac]) {
                                NSLog(@"%@",device.mac);
                                device.isOn = isOn;
                                device.isOnline = @1;
                                userInfo = @{@"device":device,@"isShare":@1};
                            }
                        }
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMulSwitchUI" object:nil userInfo:nil];
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能开关当前日期时间");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                        //在网节点查询
                        NSLog(@"设置wifi智能开关当前日期时间");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x02 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能开关的闹钟");
                        NSDictionary *userInfo = @{@"frame":_recivedData69,@"mac":mac};
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getSwitchClockList" object:nil userInfo:userInfo];
                        
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x02 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                        NSLog(@"设置wifi智能开关的闹钟");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"switchSetClock" object:nil userInfo:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"switchDeleteClock" object:nil userInfo:nil];
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x03 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能开关的闹钟项列表");
                        NSDictionary *userInfo = @{@"frame":_recivedData69,@"mac":mac};
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getClockList" object:nil userInfo:userInfo];
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x04 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能开关的延时");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x04 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                        NSLog(@"设置wifi智能开关的延时");
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"plugoutSetDelay" object:nil userInfo:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"plugoutDeleteDelayClock" object:nil userInfo:nil];
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x05 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能开关的延时开关列表");
                        NSDictionary *userInfo = @{@"frame":_recivedData69,@"mac":mac};
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"getdelayclockList" object:nil userInfo:userInfo];
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x10 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能开关的电量（电压，电流，功率）");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x11 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能开关的电压");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x12 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能开关的电流");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x13 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                        NSLog(@"查询wifi智能开关的功率");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x20 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                        NSLog(@"设置wifi的SSID");
                    }
                    if ([_recivedData69[10] unsignedIntegerValue] == 0x21 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                        NSLog(@"设置wifi的密码");
                    }
                }
                    break;
            }
            
        }
            break;
            
        default:
            break;
    }
}

-(BOOL)frameIsRight:(NSArray *)data
{
    NSUInteger count = data.count;
    UInt8 front = [data[0] unsignedCharValue];
    UInt8 end1 = [data[count-1] unsignedCharValue];
    
    //判断帧头帧尾
    if (front != 0x69 || end1 != 0x17)
    {
        NSLog(@"帧头帧尾错误");
        return NO;
    }
    //判断cs位
    UInt8 csTemp = 0x00;
    for (int i = 0; i < count - 2; i++)
    {
        csTemp += [data[i] unsignedCharValue];
    }
    if (csTemp != [data[count-2] unsignedCharValue])
    {
        NSLog(@"校验错误");
        return NO;
    }
    return YES;
}

@end
