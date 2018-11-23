//
//  DeviceViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceViewController.h"
#import "EspViewController.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "TouchTableView.h"
#import "MJRefresh.h"
#import "DeviceTableViewCell.h"

#import <SystemConfiguration/CaptiveNetwork.h>

#import <sys/socket.h>
#import <netdb.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

#define HEIGHT_CELL 70.f
#define HEIGHT_HEADER 44.f
#define resendTimes 3

NSString *const CellIdentifier_device = @"CellID_device";

@interface DeviceViewController () <GCDAsyncUdpSocketDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) UITableView *devieceTable;

///@brief 当前设备
@property (nonatomic, strong) NSMutableArray *onlineDeviceArray;
///@brief 本地所有设备数组
@property (nonatomic, strong) NSMutableArray *deviceArray;

@end

@implementation DeviceViewController
{
    BOOL isConnect;
    int resendTime;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1]];

    self.navigationItem.title = LocalString(@"我的设备");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"ic_nav_more_black"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goEsp) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    _onlineDeviceArray = [NSMutableArray array];
    _devieceTable = [self devieceTable];
    _timer = [self timer];
    _lock = [self lock];
    
    if (!_deviceArray.count && !_onlineDeviceArray.count && ![NetWork shareNetWork].connectedDevice) {
        _devieceTable.hidden = YES;
    }else{
        _devieceTable.hidden = NO;
    }
    [self queryDevices];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    _timer = nil;
}

- (void)dealloc{
    if (_timer) {
        [_timer fire];
        _timer = nil;
    }
}

#pragma mark - lazy load
- (UITableView *)devieceTable{
    if (!_devieceTable) {
        _devieceTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.hidden = YES;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[DeviceTableViewCell class] forCellReuseIdentifier:CellIdentifier_device];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            //tableView.scrollEnabled = NO;
            if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
                [tableView setSeparatorInset:UIEdgeInsetsZero];
            }
            if ([tableView respondsToSelector:@selector(setLayoutMargins:)])  {
                [tableView setLayoutMargins:UIEdgeInsetsZero];
            }
            
            MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(sendSearchBroadcast)];
            // Set title
            [header setTitle:LocalString(@"下拉刷新") forState:MJRefreshStateIdle];
            [header setTitle:LocalString(@"松开刷新") forState:MJRefreshStatePulling];
            [header setTitle:LocalString(@"加载中") forState:MJRefreshStateRefreshing];
            
            // Set font
            header.stateLabel.font = [UIFont systemFontOfSize:15];
            header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
            
            // Set textColor
            header.stateLabel.textColor = [UIColor lightGrayColor];
            header.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
            tableView.mj_header = header;
            tableView;
        });
    }
    return _devieceTable;
}

- (NSTimer *)timer{
    if(!_timer){
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(broadcast) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

-(NSLock *)lock{
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

#pragma mark - udp
- (GCDAsyncUdpSocket *)udpSocket{
    if (!_udpSocket) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _udpSocket;
}

- (void)sendSearchBroadcast{
    resendTime = resendTimes;
    
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
    
    isConnect = NO;
    [_timer setFireDate:[NSDate date]];
}

- (void)broadcast{
    if (isConnect || resendTime == 0) {
        [_timer setFireDate:[NSDate distantFuture]];
        NSLog(@"发送三次udp请求或已经接收到数据");
        [self.devieceTable.mj_header endRefreshing];
        return;
    }else{
        resendTime--;
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
    [self.devieceTable.mj_header endRefreshing];
    isConnect = YES;//停止发送udp
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
        
        //避免重复显示同一个设备
        int isContain = 0;
        for (DeviceModel *device in _onlineDeviceArray) {
            if ([ipAddress isEqualToString:device.ipAddress]) {
                isContain = 1;
                break;
            }
        }
        if (!isContain) {
            DeviceModel *dModel = [[DeviceModel alloc] init];
            dModel.ipAddress = ipAddress;
            NSLog(@"strAddr = %@", ipAddress);
            
            NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",msg);
            dModel.sn = [msg substringWithRange:NSMakeRange(0, 8)];
            
            //判断本地是否已经存储过，如果有则将_deviceArray中的该设备删除，如果没有则存储该设备
            BOOL isStored = [[DataBase shareDataBase] queryDevice:[msg substringWithRange:NSMakeRange(0, 8)]];
            if (!isStored) {
                AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                
                //设置超时时间
                [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
                manager.requestSerializer.timeoutInterval = 6.f;
                [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

                [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
                [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
                NSNumber *deviceType;
                if ([ipAddress isEqualToString:[NetWork shareNetWork].ipAddr]) {
                    deviceType = [NetWork shareNetWork].deviceType;
                }else{
                    deviceType = @0;
                }
                dModel.deviceType = deviceType;
                NSDictionary *parameters = @{@"sn":[msg substringWithRange:NSMakeRange(0, 8)],@"name":[msg substringWithRange:NSMakeRange(0, 8)],@"userId":[DataBase shareDataBase].userId,@"deviceType":deviceType};
                [manager POST:@"http://139.196.90.97:8080/coffee/roaster" parameters:parameters progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
                          if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                              [NSObject showHudTipStr:LocalString(@"添加新设备到服务器成功")];

                              [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                                  BOOL result = [db executeUpdate:@"INSERT INTO device (sn,deviceName,deviceType) VALUES (?,?,?)",[msg substringWithRange:NSMakeRange(0, 8)],[msg substringWithRange:NSMakeRange(0, 8)],deviceType];
                                  if (result) {
                                      NSLog(@"插入新设备到device成功");
                                  }else{
                                      NSLog(@"插入新设备到device失败");
                                  }
                              }];
                          }else{
                              [NSObject showHudTipStr:LocalString(@"添加新设备到服务器失败")];
                          }
                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          NSLog(@"Error:%@",error);
                      }];
            }else{
                for (int i = 0; i < _deviceArray.count; i++) {
                    DeviceModel *device = _deviceArray[i];
                    if ([[msg substringWithRange:NSMakeRange(0, 8)] isEqualToString:device.sn]) {
                        dModel.deviceName = device.deviceName;
                        dModel.deviceType = device.deviceType;
                        [_deviceArray removeObjectAtIndex:i];
                        break;
                    }
                }
                if ([ipAddress isEqualToString:[NetWork shareNetWork].ipAddr]) {
                    NSNumber *deviceType = [NetWork shareNetWork].deviceType;
                    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                    
                    //设置超时时间
                    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
                    manager.requestSerializer.timeoutInterval = 6.f;
                    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

                    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
                    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
                    dModel.deviceType = deviceType;
                    NSDictionary *parameters = @{@"sn":[msg substringWithRange:NSMakeRange(0, 8)],@"name":dModel.deviceName,@"userId":[DataBase shareDataBase].userId,@"deviceType":deviceType};
                    [manager PUT:@"http://139.196.90.97:8080/coffee/roaster" parameters:parameters
                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
                              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                                  [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                                      BOOL result = [db executeUpdate:@"UPDATE device SET deviceType = ? WHERE sn = ?",deviceType,[msg substringWithRange:NSMakeRange(0, 8)]];
                                      if (result) {
                                          NSLog(@"更新咖啡机到device表成功");
                                      }else{
                                          NSLog(@"更新咖啡机到device表失败");
                                      }
                                  }];
                              }else{
                                  [NSObject showHudTipStr:LocalString(@"更新咖啡机到服务器失败")];
                              }
                          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                              NSLog(@"Error:%@",error);
                          }];
                }
            }
            
            [_onlineDeviceArray addObject:dModel];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_onlineDeviceArray.count) {
                    _devieceTable.hidden = YES;
                    _noDeviceView.hidden = NO;
                }else{
                    _devieceTable.hidden = NO;
                    _noDeviceView.hidden = YES;
                }
                
                [_devieceTable reloadData];
            });
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

#pragma mark - 获取网络信息
- (NSDictionary *)fetchNetInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    //    NSLog(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        //        NSLog(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

- (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}

#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [NetWork shareNetWork].connectedDevice?1:0;
            
        case 1:
            return _onlineDeviceArray.count;
            //return 1;
            
        case 2:
            return _deviceArray.count;
            
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_device];
        if (cell == nil) {
            cell = [[DeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_device];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = YES;
        DeviceModel *dModel = _onlineDeviceArray[indexPath.row];
        if (!dModel.deviceName) {
            cell.deviceName.text = dModel.sn;
        }else{
            cell.deviceName.text = dModel.deviceName;
        }
        
        return cell;
    }else if (indexPath.section == 0){
        DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_device];
        if (cell == nil) {
            cell = [[DeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_device];
        }
        cell.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = YES;

        NetWork *net = [NetWork shareNetWork];
        
        if (!net.connectedDevice.deviceName) {
            cell.deviceName.text = net.connectedDevice.sn;
        }else{
            cell.deviceName.text = net.connectedDevice.deviceName;
        }
        
        return cell;
    }else{
        DeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_device];
        if (cell == nil) {
            cell = [[DeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_device];
        }
        cell.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        cell.userInteractionEnabled = NO;
        DeviceModel *device = _deviceArray[indexPath.row];
        cell.deviceName.text = device.deviceName;
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NetWork *net = [NetWork shareNetWork];
    if (indexPath.section == 1) {
        
        NSError *error = nil;
        DeviceModel *dModel = _onlineDeviceArray[indexPath.row];
        [net connectToHost:dModel.ipAddress onPort:16888 error:&error];
        //[net connectToHost:@"172.16.1.104" onPort:16888 error:&error];

        if (error) {
            NSLog(@"tcp连接错误:%@",error);
        }else{
            [net setConnectedDevice:dModel];
            [_onlineDeviceArray removeObject:dModel];
            [tableView reloadData];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }else if (indexPath.section == 0){
        if (!net.mySocket.isDisconnected) {
            [net.mySocket disconnect];
            [net setConnectedDevice:nil];
            [_devieceTable reloadData];
        }else{
            [net setConnectedDevice:nil];
            [_devieceTable reloadData];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, HEIGHT_HEADER)];
    headerTitle.font = [UIFont systemFontOfSize:14.f];
    if (section == 0) {
        headerTitle.text = LocalString(@"已连接设备");
    }else if (section == 1){
        headerTitle.text = LocalString(@"在线设备");
    }else{
        headerTitle.text = LocalString(@"离线设备");
    }
    [headerView addSubview:headerTitle];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER;
}

#pragma mark - view action

- (void)goEsp{
    EspViewController *EspVC = [[EspViewController alloc] init];
    NSDictionary *netInfo = [self fetchNetInfo];
    EspVC.ssid = [netInfo objectForKey:@"SSID"];
    EspVC.bssid = [netInfo objectForKey:@"BSSID"];
    NSLog(@"%@",[netInfo objectForKey:@"SSID"]);
    EspVC.block = ^(ESPTouchResult *result) {
        
    };
    [self.navigationController pushViewController:EspVC animated:YES];
    
}

#pragma mark - Data Source
- (void)queryDevicesByApi{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    NSString *url = [NSString stringWithFormat:@"http://139.196.90.97:8080/coffee/roaster?userId=%@",[DataBase shareDataBase].userId];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSLog(@"%@",[DataBase shareDataBase].userId);
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[DataBase shareDataBase].userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[DataBase shareDataBase].token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        [responseDic[@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            DeviceModel *device = [[DeviceModel alloc] init];
            device.sn = [obj objectForKey:@"sn"];
            device.deviceName = [obj objectForKey:@"name"];
            device.deviceType = [obj objectForKey:@"deviceType"];
            BOOL isStored = [[DataBase shareDataBase] queryDevice:device.sn];
            if (!isStored) {
                [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                    BOOL result = [db executeUpdate:@"INSERT INTO device (sn,deviceName,deviceType) VALUES (?,?,?)",device.sn,device.deviceName,device.deviceType];
                    if (result) {
                        NSLog(@"插入服务器device成功");
                    }else{
                        NSLog(@"插入服务器device失败");
                    }
                }];
            }else{
                [[DataBase shareDataBase].queueDB inDatabase:^(FMDatabase * _Nonnull db) {
                    [db executeUpdate:@"UPDATE device SET deviceName = ?,deviceType = ? WHERE sn = ?",device.deviceName,device.deviceType,device.sn];
                }];
            }
        }];
        
        _deviceArray = [[DataBase shareDataBase] queryAllDevice];
        if (!_deviceArray.count && !_onlineDeviceArray.count && ![NetWork shareNetWork].connectedDevice) {
            _devieceTable.hidden = YES;
            _noDeviceView.hidden = NO;
        }else{
            _devieceTable.hidden = NO;
            _noDeviceView.hidden = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            _deviceArray = [[DataBase shareDataBase] queryAllDevice];
            [_devieceTable reloadData];
            [self sendSearchBroadcast];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"从服务器获取咖啡机信息失败"];
        });
    }];
}

- (void)queryDevices{
    _deviceArray = [[DataBase shareDataBase] queryAllDevice];
    if (_deviceArray.count == 0) {
        [self queryDevicesByApi];
    }else{
        _devieceTable.hidden = NO;
        _noDeviceView.hidden = YES;
        [self sendSearchBroadcast];
        if ([NetWork shareNetWork].connectedDevice) {
            for (DeviceModel *device in _deviceArray) {
                if ([device.sn isEqualToString:[NetWork shareNetWork].connectedDevice.sn]) {
                    [_deviceArray removeObject:device];
                    break;
                }
            }
        }
    }
}

@end
