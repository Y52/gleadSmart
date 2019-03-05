//
//  APProcessController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/3/5.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "APProcessController.h"
#import "GCDAsyncUdpSocket.h"

#import <netdb.h>//解析udp获取的IP地址

@interface APProcessController () <GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSLock *lock;

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
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    NSInteger length = self.ssid.length;
    NSMutableArray *ssidArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < length; i++) {
        int asciiCode = [self.ssid characterAtIndex:i];
        NSNumber *asciiSSID = [NSNumber numberWithInt:asciiCode];
        [ssidArray addObject:asciiSSID];
    }
    UInt8 controlCode = 0x00;
    NSMutableArray *data = [@[@0xFE,@0x03,@0x01,@0x01] mutableCopy];
    [data addObjectsFromArray:ssidArray];
    NSLog(@"%@",data);
    [[Network shareNetwork] APsendData69With:controlCode mac:mac data:data];
}

- (void)tcpSendPassword{
    NSInteger length = self.password.length;
    NSMutableArray *passwordArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < length; i++) {
        int asciiCode = [self.password characterAtIndex:i];
        NSNumber *asciiSSID = [NSNumber numberWithInt:asciiCode];
        [passwordArray addObject:asciiSSID];
    }

    UInt8 controlCode = 0x00;
    NSMutableArray *data = [@[@0xFE,@0x03,@0x02,@0x01] mutableCopy];
    [data addObjectsFromArray:passwordArray];
    NSLog(@"%@",data);
    [[Network shareNetwork] APsendData69With:controlCode mac:mac data:data];
}

#pragma mark - udp delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    [_lock lock];
    NSLog(@"UDP接收数据……………………………………………………");
    isFind = YES;//停止发送udp
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
        mac = [msg substringWithRange:NSMakeRange(0, 8)];
        
        resendTimes = 3;
        [self tcpActions:ipAddress];
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

-(NSLock *)lock{
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}


@end
