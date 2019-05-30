//
//  APProcessController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/3/5.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "APProcessController.h"
#import "GCDAsyncUdpSocket.h"
#import "DeviceViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#import <netdb.h>//解析udp获取的IP地址

@interface APProcessController () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic) dispatch_source_t confirmWifiTimer;//确认Wi-Fi切换时钟
@property (nonatomic) dispatch_source_t getStatusTimer;//查询设备是否在线

@end

@implementation APProcessController{
    int resendTimes;//tcp连接次数
    BOOL isFind;
    NSString *mac;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"AP配网");

    self.spinner = [self spinner];
    self.timer = [self timer];
    self.udpSocket = [self udpSocket];
    self.lock = [self lock];
    
    [self sendSearchBroadcast];
    self.confirmWifiTimer = [self confirmWifiTimer];
    self.getStatusTimer = [self getStatusTimer];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apSendSSIDSucc) name:@"apSendSSIDSucc" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apSendPasswordSucc) name:@"apSendPasswordSucc" object:nil];
    

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"apSendSSIDSucc" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"apSendPasswordSucc" object:nil];

    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
    
    dispatch_source_cancel(_confirmWifiTimer);
    dispatch_source_cancel(_getStatusTimer);

    isSSIDSendSucc = NO;
    isPasswordSendSucc = NO;
    bindSucc = NO;
}

- (void)dealloc{
    if (_timer) {
        [_timer fire];
        _timer = nil;
    }
}

#pragma mark - private methods
- (void)sendSearchBroadcast{
    _udpSocket = [self udpSocket];
    
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
    
    isFind = NO;
    [_timer setFireDate:[NSDate date]];
}

- (void)broadcast{
    if (isFind) {
        [_timer setFireDate:[NSDate distantFuture]];
        NSLog(@"已经找到设备");
        return;
    }
    
    NSString *host = @"255.255.255.255";
    NSTimeInterval timeout = 2000;
    NSString *request = @"whereareyou\r\n";
    NSData *data = [NSData dataWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    UInt16 port = 17888;
    
    [_udpSocket sendData:data toHost:host port:port withTimeout:timeout tag:200];
}

- (void)tcpActions:(NSString *)ipAddress{
    
    Network *net = [Network shareNetwork];
    NSError *error = nil;
    if (![net connectToHost:ipAddress onPort:16888 error:&error] && resendTimes > 0) {
        NSLog(@"tcp连接错误:%@",error);
        [self tcpActions:ipAddress];
        resendTimes--;
    }else{
        resendTimes = 0;
        [self tcpSendSSID];
        [self tcpSendPassword];
    }
}

- (void)tcpSendSSID{
    NSString *ssid;
    NSMutableArray *ssidArray = [[NSMutableArray alloc] init];
    if ([self.ssid includeChinese]) {
        ssid = [self.ssid stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet uppercaseLetterCharacterSet]];
        NSMutableArray *array = [[ssid componentsSeparatedByString:@"%"] mutableCopy];
        NSLog(@"%@",ssid);
        [array removeObjectAtIndex:0];
        for (int i = 0; i < array.count; i++) {
            NSString *hexStr = array[i];
            int hex = [NSString stringScanToInt:hexStr];
            [ssidArray addObject:[NSNumber numberWithInt:hex]];
        }
    }else{
        ssid = self.ssid;
        NSInteger length = ssid.length;
        ssidArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < length; i++) {
            int asciiCode = [ssid characterAtIndex:i];
            NSNumber *asciiSSID = [NSNumber numberWithInt:asciiCode];
            [ssidArray addObject:asciiSSID];
        }
    }

    DeviceType type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]];
    if (type == DeviceCenterlControl) {
        UInt8 controlCode = 0x00;
        NSMutableArray *data = [@[@0xFE,@0x03,@0x01,@0x01] mutableCopy];
        [data addObjectsFromArray:ssidArray];
        NSLog(@"%@",data);
        [[Network shareNetwork] APsendData69With:controlCode mac:mac data:data];
    }else if (type >= DevicePlugOutlet && type <= DeviceFourSwitch){
        UInt8 controlCode = 0x00;
        NSMutableArray *data = [@[@0xFC,@0x11,@0x20,@0x01] mutableCopy];
        [data addObjectsFromArray:ssidArray];
        NSLog(@"%@",data);
        [[Network shareNetwork] APsendData69With:controlCode mac:mac data:data];
    }
}

- (void)tcpSendPassword{
    NSInteger length = self.password.length;
    NSMutableArray *passwordArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < length; i++) {
        int asciiCode = [self.password characterAtIndex:i];
        NSNumber *asciiSSID = [NSNumber numberWithInt:asciiCode];
        [passwordArray addObject:asciiSSID];
    }

    DeviceType type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]];
    if (type == DeviceCenterlControl) {
        UInt8 controlCode = 0x00;
        NSMutableArray *data = [@[@0xFE,@0x03,@0x02,@0x01] mutableCopy];
        [data addObjectsFromArray:passwordArray];
        NSLog(@"%@",data);
        [[Network shareNetwork] APsendData69With:controlCode mac:mac data:data];
    }else if (type >= DevicePlugOutlet && type <= DeviceFourSwitch){
        UInt8 controlCode = 0x00;
        NSMutableArray *data = [@[@0xFC,@0x11,@0x21,@0x01] mutableCopy];
        [data addObjectsFromArray:passwordArray];
        NSLog(@"%@",data);
        [[Network shareNetwork] APsendData69With:controlCode mac:mac data:data];
    }
}

static bool isSSIDSendSucc = NO;
static bool isPasswordSendSucc = NO;
- (void)apSendSSIDSucc{
    isSSIDSendSucc = YES;
    NSLog(@"isSSIDSendSucc");
}

- (void)apSendPasswordSucc{
    isPasswordSendSucc = YES;
    NSLog(@"isPasswordSendSucc");
}

static bool bindSucc = NO;
- (void)confirmWifiName{
    if (!(isSSIDSendSucc && isPasswordSendSucc)) {
        return;
    }
    NSDictionary *netInfo = [self fetchNetInfo];
    NSString *ssid = [netInfo objectForKey:@"SSID"];
    NSLog(@"%@",ssid);
    if(![ssid hasPrefix:@"ESP"]){
        ///热点搜到设备后直接绑定，查询api等待设备上线
        if (!bindSucc) {
            DeviceModel *dModel = [[DeviceModel alloc] init];
            dModel.mac = mac;
            dModel.name = mac;
            dModel.type = [NSNumber numberWithInt:[[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]]];
            
            
            [[AFNetworkReachabilityManager sharedManager] startMonitoring];
            [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                
                switch (status) {
                    case AFNetworkReachabilityStatusNotReachable:
                    {
                        NSLog(@"没有网络");
                        return;
                    }
                        break;
                        
                    default:
                    {
                        [self bindDevice:dModel success:^{
                            NSLog(@"绑定设备成功");
                            bindSucc = YES;
                        } failure:^{
                        }];
                    }
                        break;
                }
            }];
            
        }
    }
}

- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    //    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        //NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

#pragma mark - udp delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    [_lock lock];
    NSLog(@"UDP接收数据……………………………………………………");
    isFind = YES;//停止发送udp
    if (isSSIDSendSucc && isPasswordSendSucc) {
        /**
         *发送完账号密码后在Wi-Fi里查询udp
         **/
//        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",msg);
//        NSString *newMac = [msg substringWithRange:NSMakeRange(0, 8)];
//        if ([newMac isEqualToString:mac]) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                for (UIViewController *controller in self.navigationController.viewControllers) {
//                    if ([controller isKindOfClass:[DeviceViewController class]]) {
//                        [self.navigationController popToViewController:controller animated:YES];
//                    }
//                }
//                [NSObject showHudTipStr:LocalString(@"连接成功，请进行设备的选择")];
//            });
//        }
    }else{
        /**
         *热点连接时获得udp地址
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
        mac = [msg substringWithRange:NSMakeRange(0, 8)];
        
        self->resendTimes = 3;
        [self tcpActions:ipAddress];
    }
    [_lock unlock];
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error{
    NSLog(@"未连接");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"发送的消息");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{
    NSLog(@"已经连接");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"断开连接,%@",error);
    if (isPasswordSendSucc && isSSIDSendSucc) {
        isFind = NO;
        [self sendSearchBroadcast];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"没有发送数据");
}

#pragma mark - private methods
- (void)bindDevice:(DeviceModel *)device success:(void(^)(void))success failure:(void(^)(void))failur{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[Database shareInstance].token] forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:[Database shareInstance].user.userId forHTTPHeaderField:@"userId"];
    
    Database *db = [Database shareInstance];
    
    NSInteger type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]];
    NSNumber *postType;
    if (type == DevicePlugOutlet) {
        postType = @4;
    }else if (type >= DeviceOneSwitch && type <= DeviceFourSwitch){
        postType = @3;
    }else if (type == DeviceCenterlControl){
        postType = @0;
    }
    
    NSDictionary *parameters;
    NSMutableArray *homeList = [db queryRoomsWith:db.currentHouse.houseUid];
    if (homeList.count <= 0) {
        [NSObject showHudTipStr:LocalString(@"当前家庭还没有添加房间，请尽快添加")];
        parameters = @{@"type":postType,@"mac":device.mac,@"name":device.name,@"roomUid":db.currentHouse.houseUid,@"houseUid":db.currentHouse.houseUid};
    }else{
        RoomModel *room = homeList[0];//将新设备插入到家庭第一个房间
        parameters = @{@"mac":device.mac,@"name":device.name,@"type":postType,@"houseUid":db.currentHouse.houseUid,@"roomUid":room.roomUid};
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
                  [NSObject showHudTipStr:LocalString(@"绑定该设备成功")];
                  [[Database shareInstance].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                      BOOL result = [db executeUpdate:@"REPLACE INTO device (mac,name,type,houseUid) VALUES (?,?,?,?)",device.mac,device.name,device.type,[Database shareInstance].currentHouse.houseUid];
                      if (result) {
                          NSLog(@"插入设备到device成功");
                      }else{
                          NSLog(@"插入设备到device失败");
                      }
                  }];
                  if (success) {
                      success();
                  }
              }else{
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
          }];
}

//查询配网绑定的设备是否在线，在线就判断绑定成功并退出页面
- (void)getStatus{
    if (!bindSucc) {
        return;
    }
    Database *db = [Database shareInstance];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/device/state?mac=%@",httpIpAddress,mac];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSLog(@"%@",url);
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSDictionary *data = [responseDic objectForKey:@"data"];
            NSNumber *state = [data objectForKey:@"state"];
            if ([state integerValue]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [NSObject showHudTipStr:LocalString(@"配网成功")];
                });
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

#pragma mark - setters and getters
- (UIActivityIndicatorView *)spinner{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] init];
        [_spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_spinner setHidesWhenStopped:NO];
        //[_spinner setColor:[UIColor blueColor]];
        [self.view addSubview:_spinner];
        [_spinner mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(15.f, 15.f));
            make.top.equalTo(self.view.mas_top).offset(yAutoFit(337.f));
            make.left.equalTo(self.view.mas_left).offset(yAutoFit(128.5f));
        }];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.text = LocalString(@"正在搜索设备...");
        tipLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [self.view addSubview:tipLabel];
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), 20.f));
            make.centerY.equalTo(self.spinner.mas_centerY);
            make.left.equalTo(self.spinner.mas_right).offset(8.f);
        }];
    }
    return _spinner;
}

- (GCDAsyncUdpSocket *)udpSocket{
    if (!_udpSocket) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _udpSocket;
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(broadcast) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

- (dispatch_source_t)confirmWifiTimer{
    if (!_confirmWifiTimer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _confirmWifiTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_confirmWifiTimer, dispatch_walltime(NULL, 0), 1.f * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_confirmWifiTimer, ^{
            [self confirmWifiName];
        });
        dispatch_resume(_confirmWifiTimer);
    }
    return _confirmWifiTimer;
}

- (dispatch_source_t)getStatusTimer{
    if (!_getStatusTimer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _getStatusTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_getStatusTimer, dispatch_walltime(NULL, 0), 5.f * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_getStatusTimer, ^{
            [self getStatus];
        });
        dispatch_resume(_getStatusTimer);
    }
    return _getStatusTimer;
}

-(NSLock *)lock{
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}


@end
