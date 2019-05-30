//
//
//  DeviceConnectView.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/29.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//
//  Esptouch的源码在乐鑫官网可以找到

#import "DeviceConnectView.h"
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import "ESPAES.h"
#import "DeviceViewController.h"
#import <netdb.h>

@interface EspTouchDelegateImpl : NSObject<ESPTouchDelegate>

@end

@implementation EspTouchDelegateImpl

- (void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    NSLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //
    //    });
}

@end

@interface DeviceConnectView () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) NSCondition *condition;

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) EspTouchDelegateImpl *espTouchDelegate;
@property (atomic, strong) ESPTouchTask *esptouchTask;

@property (strong, nonatomic) NSTimer *udpTimer;;
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@end

@implementation DeviceConnectView{
    NSString *espDeviceIpAddr;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!_udpSocket) {
            dispatch_queue_t queue = dispatch_queue_create("udpQueue", DISPATCH_QUEUE_SERIAL);
            _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:queue];
        }
        if (!_udpTimer) {
            _udpTimer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(broadcast) userInfo:nil repeats:YES];
            [_udpTimer setFireDate:[NSDate distantFuture]];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"搜索并连接设备");
    
    self.condition = [[NSCondition alloc] init];
    self.espTouchDelegate = [[EspTouchDelegateImpl alloc] init];
    _spinner = [self spinner];
    _image =[self image];
    _cancelBtn = [self cancelBtn];
    [self startEsptouchConnect];
    
    [self sendSearchBroadcast];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(10);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.udpTimer setFireDate:[NSDate date]];
        });
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //去掉返回键的文字
    self.navigationController.navigationBar.topItem.title = @"";
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_udpTimer setFireDate:[NSDate distantFuture]];
    [_udpTimer invalidate];
    _udpTimer = nil;
    
}

- (void)didMoveToParentViewController:(UIViewController *)parent{
    [super didMoveToParentViewController:parent];
    if (!parent) {
        [self cancel];
    }
}

#pragma mark - start Esptouch
- (void)startEsptouchConnect
{
    [self.spinner startAnimating];
    
    NSLog(@"ESPViewController do confirm action...");
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSLog(@"ESPViewController do the execute work...");
        // execute the task
        NSArray *esptouchResultArray = [self executeForResults];
        // show the result to the user in UI Main Thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            
            ESPTouchResult *firstResult = [esptouchResultArray objectAtIndex:0];
            
            // check whether the task is cancelled and no results received
            if (!firstResult.isCancelled)
            {
                NSMutableString *mutableStr = [[NSMutableString alloc]init];
                NSUInteger count = 0;
                // max results to be displayed, if it is more than maxDisplayCount,
                // just show the count of redundant ones
                const int maxDisplayCount = 5;
                if ([firstResult isSuc])
                {
                    for (int i = 0; i < [esptouchResultArray count]; ++i)
                    {
                        ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                        [mutableStr appendString:[resultInArray description]];
                        [mutableStr appendString:@"\n"];
                        count++;
                        if (count >= maxDisplayCount){
                            break;
                        }
                    }
                    
                    if (count < [esptouchResultArray count]){
                        [mutableStr appendString:[NSString stringWithFormat:@"\nthere's %lu more result(s) without showing\n",(unsigned long)([esptouchResultArray count] - count)]];
                    }
                    NSLog(@"esp信息%@",mutableStr);
                    //                    for (UIViewController *controller in self.navigationController.viewControllers) {
                    //                        if ([controller isKindOfClass:[DeviceViewController class]]) {
                    //                            [self.navigationController popToViewController:controller animated:YES];
                    //                        }
                    //                    }
                    self->espDeviceIpAddr = [ESP_NetUtil descriptionInetAddr4ByData:firstResult.ipAddrData];
                    if (self->espDeviceIpAddr==nil) {
                        self->espDeviceIpAddr = [ESP_NetUtil descriptionInetAddr6ByData:firstResult.ipAddrData];
                    }
                }
                else
                {
                    //[self fail];
                }
            }
            
        });
    });
}

#pragma mark - the example of how to use executeForResults
- (NSArray *) executeForResults
{
    [self.condition lock];
    int taskCount = 1;//具体用途待测试
    BOOL useAES = NO;
    if (useAES) {
        NSString *secretKey = @"1234567890123456"; // TODO modify your own key
        ESPAES *aes = [[ESPAES alloc] initWithKey:secretKey];
        self.esptouchTask = [[ESPTouchTask alloc]initWithApSsid:self.ssid andApBssid:self.bssid andApPwd:self.password andAES:aes];
    } else {
        self.esptouchTask = [[ESPTouchTask alloc]initWithApSsid:self.ssid andApBssid:self.bssid andApPwd:self.password];
        NSLog(@"%@",self.ssid);
        NSLog(@"%@",self.bssid);
        NSLog(@"%@",self.password);
    }
    
    // set delegate
    [self.esptouchTask setEsptouchDelegate:self.espTouchDelegate];
    [self.condition unlock];
    NSArray * esptouchResults = [self.esptouchTask executeForResults:taskCount];
    NSLog(@"ESPViewController executeForResult() result is: %@",esptouchResults);
    return esptouchResults;
}

#pragma mark - the example of how to cancel the executing task

- (void) cancel
{
    [self.condition lock];
    if (self.esptouchTask != nil)
    {
        [self.esptouchTask interrupt];
    }
    [self.condition unlock];
    [self.navigationController popViewControllerAnimated:YES];
    [NSObject showHudTipStr:LocalString(@"取消配置，你可以重新选择配置")];
}

#pragma mark - udp
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
    
}

- (void)broadcast{
    NSString *host = @"255.255.255.255";
    NSTimeInterval timeout = 2000;
    NSString *request = @"whereareyou\r\n";
    NSData *data = [NSData dataWithData:[request dataUsingEncoding:NSASCIIStringEncoding]];
    UInt16 port = 17888;
    
    [_udpSocket sendData:data toHost:host port:port withTimeout:timeout tag:200];
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
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
        
        NSLog(@"%@,%@",ipAddress,self->espDeviceIpAddr);
        if ([ipAddress isEqualToString:self->espDeviceIpAddr]) {
            DeviceModel *dModel = [[DeviceModel alloc] init];
            
            dModel.mac = mac;
            dModel.ipAddress = ipAddress;
            dModel.name = mac;
            dModel.type = [NSNumber numberWithInt:[[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]]];
            [self bindDevice:dModel success:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (dModel.type == DeviceCenterlControl) {
                        Network *net = [Network shareNetwork];
                        NSError *error;
                        if ([net connectToHost:ipAddress onPort:16888 error:&error]) {
                            net.connectedDevice = dModel;
                        }
                    }
                    [Network shareNetwork].isDeviceVC = NO;
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [NSObject showHudTipStr:LocalString(@"绑定设备成功")];
                });
            } failure:^{
                
            }];
            
            
        }
    }
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
    NSLog(@"断开连接");
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
    
    NSInteger type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]];
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
                  [NSObject showHudTipStr:LocalString(@"绑定该设备失败")];
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
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

- (UIImageView *)image{
    if (!_image) {
        _image = [[UIImageView alloc] init];
        _image.image = [UIImage imageNamed:@""];
        [self.view addSubview:_image];
        
        [_image mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(225.f), yAutoFit(150.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(yAutoFit(82.f));
        }];
        
        UILabel *tipLabel1 = [[UILabel alloc] init];
        tipLabel1.text = LocalString(@"请将手机尽量靠近路由器");
        tipLabel1.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel1.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        tipLabel1.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:tipLabel1];
        
        UILabel *tipLabel2 = [[UILabel alloc] init];
        tipLabel2.text = LocalString(@"连接过程中请不要操作设备");
        tipLabel2.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        tipLabel2.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        tipLabel2.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:tipLabel2];
        
        [tipLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 20.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.image.mas_bottom).offset(18.f);
        }];
        [tipLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 20.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(tipLabel1.mas_bottom).offset(8.f);
        }];
    }
    return _image;
}

- (UIButton *)cancelBtn{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitleColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1] forState:UIControlStateNormal];
        [_cancelBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [_cancelBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_cancelBtn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.8]];
        [_cancelBtn setButtonStyleWithColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1] Width:1.5 cornerRadius:18.f];
        [_cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cancelBtn];
        
        [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(92.f, 36.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).offset(-yAutoFit(40.f));
        }];
    }
    return _cancelBtn;
}

@end
