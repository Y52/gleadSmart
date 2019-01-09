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
    int _frameCount;
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
            _sendSignal = dispatch_semaphore_create(0);
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
                if (noUserInteractionHeartbeat == 60) {
                    UInt8 controlCode = 0x00;
                    NSArray *data = @[@0xFE,@0x01,@0x45,@0x00];//在网节点查询
                    [[Network shareNetwork] sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data];
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
                [[Network shareNetwork] sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data];
            });
            //dispatch_resume(_testSendTimer);
        }

        _allMsg = [[NSMutableArray alloc] init];
        _lock = [[NSLock alloc] init];
        _queue = dispatch_queue_create("com.thingcom.queue", DISPATCH_QUEUE_SERIAL);
        _frameCount = 0;
        [self sendSearchBroadcast];
        
        _testSendCount = 0;
        _testRecieveCount = 0;
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
        
        if (self.connectedDevice && [self.connectedDevice.mac isEqualToString:mac]) {
            //如果已经连接了这个设备，就不再重新连接了
            return;
        }
        
        if (![[Database shareInstance] queryDevice:mac]) {
            NSLog(@"as");
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
    NSLog(@"断开连接");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"发送的消息");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"已经连接");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"断开连接");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"没有发送数据");
}

#pragma mark - Tcp Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功");
    [self.udpTimer setFireDate:[NSDate distantFuture]];
    sleep(1.f);
    _frameCount = 0;
    
    //查询设备帧，一连上内网查一次
    UInt8 controlCode = 0x00;
    NSArray *data = @[@0xFE,@0x01,@0x45,@0x00];//在网节点查询
    [[Network shareNetwork] sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data];

    [_mySocket readDataWithTimeout:-1 tag:1];
    [_mySocket readDataWithTimeout:-1 tag:1];
    [_mySocket readDataWithTimeout:-1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"连接失败");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject showHudTipStr:LocalString(@"连接已断开")];
    });
    [self.udpTimer setFireDate:[NSDate date]];
    self.connectedDevice = nil;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"接收到消息%@",data);
    NSLog(@"socket成功收到帧, tag: %ld", tag);
    [self checkOutFrame:data];
    dispatch_semaphore_signal(self.sendSignal);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //NSLog(@"发送了一条帧");
    _frameCount++;
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

/*
 *发送帧组成模版
 */
- (void)sendData69With:(UInt8)controlCode mac:(NSString *)mac data:(NSArray *)data{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_sync(self->_queue, ^{
            
            //线程锁需要放在最前面，放在后面锁不住
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1.f * NSEC_PER_SEC);
            dispatch_semaphore_wait(self.sendSignal, time);

            noUserInteractionHeartbeat = 0;//心跳清零
            
            //测试用代码
            self.testSendCount++;

            NSMutableArray *data69 = [[NSMutableArray alloc] init];
            [data69 addObject:[NSNumber numberWithUnsignedInteger:0x69]];
            [data69 addObject:[NSNumber numberWithUnsignedInteger:controlCode]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(6, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(4, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(0, 2)]]]];
            [data69 addObject:[NSNumber numberWithInt:self->_frameCount]];
            [data69 addObject:[NSNumber numberWithInteger:data.count]];
            [data69 addObjectsFromArray:data];
            [data69 addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:data69]]];
            [data69 addObject:[NSNumber numberWithUnsignedChar:0x17]];
            
            if (![[Database shareInstance].currentHouse.mac isEqualToString:self.connectedDevice.mac]) {
                [self oneNETSendData:data69];//OneNet发送
            }else{
                [self send:data69 withTag:100];//内网tcp发送
            }
            
        });
    });
}

#pragma mark - OneNET API
- (void)oneNETSendData:(NSMutableArray *)msg{
    
    Database *db = [Database shareInstance];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    
    [manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.currentHouse.apiKey forHTTPHeaderField:@"api-key"];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://api.heclouds.com/cmds?device_id=%@",db.currentHouse.deviceId];
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
    NSLog(@"%@",jsonString);
    
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
            NSDictionary *data =[responseDic objectForKey:@"data"];
            NSString *cmd_uuid = [data objectForKey:@"cmd_uuid"];
            [self getOneNETCommandStatus:cmd_uuid resendTimes:5];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        
    }];
}

- (void)getOneNETCommandStatus:(NSString *)cmd_uuid resendTimes:(NSInteger)resendTimes{
    
    Database *db = [Database shareInstance];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.currentHouse.apiKey forHTTPHeaderField:@"api-key"];
    
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
                        sleep(3.f);
                        NSInteger times = resendTimes - 1;
                        [self getOneNETCommandStatus:cmd_uuid resendTimes:times];
                    });
                }else{
                    
                }
            }else if ([[data objectForKey:@"status"] intValue] == 4){
                [self getOneNETCommandRespond:cmd_uuid];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        
    }];
}

- (void)getOneNETCommandRespond:(NSString *)cmd_uuid{
    Database *db = [Database shareInstance];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.currentHouse.apiKey forHTTPHeaderField:@"api-key"];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://api.heclouds.com/cmds/%@/resp",cmd_uuid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        NSString *cmmdReply = [responseDic objectForKey:@"cmmdReply"];
        [[Network shareNetwork] handleOneNET69Message:cmmdReply];
        dispatch_semaphore_signal(self.sendSignal);//收到信息增加信号量
        
        //测试
        self.testRecieveCount++;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        
    }];
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
        NSLog(@"沾包解出的帧%d：%@",i,data);
        
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
    
    //取出mac
    NSString *mac = @"";
    mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[5] intValue]]];
    mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[4] intValue]]];
    mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[3] intValue]]];
    mac = [mac stringByAppendingString:[NSString HexByInt:[_recivedData69[2] intValue]]];

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
            
        case 0x12:
        {
            if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //查询温控器状态
                NSLog(@"查询温控器状态");
                for (DeviceModel *device in self.deviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.isOn = [NSNumber numberWithUnsignedInteger:[_recivedData69[12] unsignedIntegerValue]];
                        device.isOnline = @1;
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThermostat" object:nil userInfo:nil];

            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x01) {
                //开关温控器
                NSLog(@"开关温控器");
                
                for (DeviceModel *device in self.deviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.isOn = [NSNumber numberWithUnsignedInteger:[_recivedData69[12] unsignedIntegerValue]];
                        if ([device.isOn integerValue]) {
                            NSLog(@"%@",device.isOn);

                            [[NSNotificationCenter defaultCenter] postNotificationName:@"openThermostat" object:nil userInfo:nil];
                        }
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
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
                
                for (DeviceModel *device in self.deviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.mode = [NSNumber numberWithUnsignedInteger:mode];
                        device.modeTemp = modeTemp;
                        device.indoorTemp = indoorTemp;
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
                
                for (DeviceModel *device in self.deviceArray) {
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

                for (DeviceModel *device in self.deviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.mode = [NSNumber numberWithUnsignedInteger:mode];
                    }
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThermostat" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"switchThermostatMode" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x07 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //查询温控器状态
                NSLog(@"查询温控器状态");
                UInt8 temp = [_recivedData69[12] unsignedIntegerValue];
                if (temp * 0x80) {
                    temp = temp & 0x7F;
                }
                NSNumber *compensate = [NSNumber numberWithUnsignedInteger:temp];
                
                for (DeviceModel *device in self.deviceArray) {
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
                for (DeviceModel *device in self.deviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.isOn = [NSNumber numberWithUnsignedInteger:[_recivedData69[12] unsignedIntegerValue]];
                    }
                }

                NSLog(@"水阀开关回复:%lu",(unsigned long)[_recivedData69[12] unsignedIntegerValue]);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshValve" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x01 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //查询无线水阀状态
                NSLog(@"查询无线水阀状态");
                for (DeviceModel *device in self.deviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.isOn = [NSNumber numberWithUnsignedInteger:[_recivedData69[12] unsignedIntegerValue]];
                        device.isOnline = @1;
                    }
                }
                
                //设备内容页面UI等刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
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
                
                for (DeviceModel *device in self.deviceArray) {
                    if ([device.mac isEqualToString:mac]) {
                        device.nodeArray = nodeArray;
                    }
                }
                
                //设备内容页面UI等刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshValveHangingNodes" object:nil userInfo:nil];
            }
            if ([_recivedData69[10] unsignedIntegerValue] == 0x06 && [_recivedData69[11] unsignedIntegerValue] == 0x00) {
                //水阀恢复出厂设置
                NSLog(@"水阀恢复出厂设置");
                
                for (DeviceModel *device in self.deviceArray) {
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
                deletedNode.mac = [deletedNode.mac stringByAppendingString:[NSString HexByInt:[data[15] intValue]]];
                deletedNode.mac = [deletedNode.mac stringByAppendingString:[NSString HexByInt:[data[14] intValue]]];
                deletedNode.mac = [deletedNode.mac stringByAppendingString:[NSString HexByInt:[data[13] intValue]]];
                deletedNode.mac = [deletedNode.mac stringByAppendingString:[NSString HexByInt:[data[12] intValue]]];
                
                if ([deletedNode.mac intValue] == 0) {
                    NSLog(@"删除失败，设备为空");
                    [NSObject showHudTipStr:@"删除失败"];
                    return;
                }
                
                [NSObject showHudTipStr:@"删除成功"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"valveDeleteHangingNode" object:nil userInfo:nil];//删除节点后直接水阀页面节点重新生成
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


#pragma mark - Device management
/*
 *从网关获取设备列表并进行数据库等的操作
 */
- (void)inquireNode:(NSMutableArray *)recivedData69{
    Database *db = [Database shareInstance];
    if (!self.deviceArray) {
        self.deviceArray = [[NSMutableArray alloc] init];
    }
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
        [[Network shareNetwork] sendData69With:controlCode mac:device.mac data:data];
        
        //将中央控制器查询到的设备和服务器设备对比
        BOOL isExisted = NO;//防止重复显示以及刷新时重新添加设备到服务器
        for (DeviceModel *existedDevice in self.deviceArray) {
            if ([existedDevice.mac isEqualToString:device.mac]) {
                isExisted = YES;
            }
        }
        if (isExisted) {
            continue;
        }
        
        BOOL isLocal = NO;
        for (DeviceModel *localDevice in db.localDeviceArray) {
            if ([device.mac isEqualToString:localDevice.mac]) {
                localDevice.type = device.type;
                
                [self.deviceArray addObject:localDevice];
                
                [db.localDeviceArray removeObject:localDevice];
                isLocal = YES;
                break;
            }
        }
        if (!isLocal) {
            /*
             *未保存过，需要上传到服务器，保存到本地
             */
            [self addNewDeviceWith:device];
            
            if ([device.type integerValue] == 1) {
                device.name = [NSString stringWithFormat:@"%@%@",LocalString(@"温控器"),[device.mac substringWithRange:NSMakeRange(6, 2)]];
            }else if ([device.type integerValue] == 2){
                device.name = [NSString stringWithFormat:@"%@%@",LocalString(@"无线水阀"),[device.mac substringWithRange:NSMakeRange(6, 2)]];
            }
            
            [self.deviceArray addObject:device];
        }
    }
    /*
     *将localDeviceArray剩余的device从服务器中删除，因为在网关中查找不到设备
     */
    for (DeviceModel *localDevice in db.localDeviceArray) {
        //[self removeOldDeviceWith:localDevice];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
}

/*
 *设备入网时主动上报
 */
- (void)addNode:(NSMutableArray *)recivedData69{
    if (!_deviceArray) {
        _deviceArray = [[NSMutableArray alloc] init];
    }
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObjectsFromArray:self.recivedData69];
    
    DeviceModel *device = [[DeviceModel alloc] init];
    device.mac = @"";
    device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[15] intValue]]];
    device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[14] intValue]]];
    device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[13] intValue]]];
    device.mac = [device.mac stringByAppendingString:[NSString HexByInt:[data[12] intValue]]];
    device.type = [NSNumber numberWithInteger:[self judgeDeviceTypeWith:[data[14] intValue]]];
    
    /*
     *未保存过，需要上传到服务器，保存到本地
     */
    [self addNewDeviceWith:device];
    
    device.name = device.mac;
    [self.deviceArray addObject:device];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
}


/*
 *从onenet获取设备列表并进行数据库等的操作
 */


/*
 *上传新设备
 */
- (void)addNewDeviceWith:(DeviceModel *)device{
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
    NSDictionary *parameters = @{@"type":device.type,@"mac":device.mac,@"name":device.name,@"roomUid":@"5bfcb08be4b0c54526650eec"};

    [manager POST:@"http://gleadsmart.thingcom.cn/api/device" parameters:parameters progress:nil
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
              }else{
                  
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              [NSObject showHudTipStr:LocalString(@"无法登录远程服务器，请检查网络状况")];

          }
     ];
}

/*
 *删除设备
 */
- (void)removeOldDeviceWith:(DeviceModel *)device{
    Database *db = [Database shareInstance];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];

    NSLog(@"%@",db.user.userId);
    NSDictionary *parameters = @{@"userId":db.user.userId,@"mac":device.mac};
    
    [manager DELETE:@"http://gleadsmart.thingcom.cn/api/device" parameters:parameters
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
              }else{
                  
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              [NSObject showHudTipStr:LocalString(@"无法登录远程服务器，请检查网络状况")];
              
          }
     ];
}

/*
 *判断设备类型
 *设备种类；0表示中央控制器，1表示温控器，2表示无线水阀，3表示壁挂炉调节器
 */
- (NSInteger)judgeDeviceTypeWith:(int)macByte2{
    if (macByte2 >= 0x08 && macByte2 <= 0x0F) {
        return 1;
    }
    if (macByte2 >= 0x10 && macByte2 <= 0x17){
        return 3;
    }
    if (macByte2 >= 0x18 && macByte2 <= 0x1F) {
        return 2;
    }
    return 0;
}

@end
