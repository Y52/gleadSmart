//
//  ConnectApNetController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/3/5.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "ConnectApNetController.h"
#import "APProcessController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface ConnectApNetController ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIButton *connectButton;


@end

@implementation ConnectApNetController{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"7A7A7A"]];
    
    self.navigationItem.title = LocalString(@"AP模式");

    self.backgroundView = [self backgroundView];
    self.connectButton = [self connectButton];
    
    [self applicationWillEnterForeground];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - private methods
- (void)applicationWillEnterForeground{
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]addObserverForName:UIApplicationWillEnterForegroundNotification  object:app queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self confirmWifiName];
    }];
}

- (void)confirmWifiName{
    NSDictionary *netInfo = [self fetchNetInfo];
    NSString *ssid = [netInfo objectForKey:@"SSID"];
    if ([ssid hasPrefix:@"ESP"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self goAPProcess];
        });
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

- (void)jump2Settings{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)goAPProcess{
    APProcessController *vc =[[APProcessController alloc] init];
    vc.ssid = self.ssid;
    vc.password = self.password;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - setters and getters
- (UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_backgroundView];
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(320.f), ScreenHeight - getRectNavAndStatusHight - 100.f));
            make.top.equalTo(self.view.mas_top).offset(50.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
        _backgroundView.layer.cornerRadius = 10.f;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = LocalString(@"将手机Wi-Fi连接到设备热点");
        titleLabel.font = [UIFont boldSystemFontOfSize:25.f];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.numberOfLines = 0;
        [_backgroundView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(290.f), 50.f));
            make.top.equalTo(self.backgroundView.mas_top).offset(20.f);
            make.centerX.equalTo(self.backgroundView.mas_centerX);
        }];
        
        UITextView *textView = [[UITextView alloc] init];
        textView.backgroundColor = [UIColor clearColor];
        textView.text = LocalString(@"1.请将手机连接到如下热点: SmartLife-XXXX\n2.返回本应用，继续添加设备");
        textView.font = [UIFont systemFontOfSize:17.f];
        textView.textAlignment = NSTextAlignmentLeft;
        textView.textColor = [UIColor blackColor];
        textView.editable = NO;
        [_backgroundView addSubview:textView];
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(290.f), 350.f));
            make.top.equalTo(titleLabel.mas_bottom).offset(20.f);
            make.centerX.equalTo(self.backgroundView.mas_centerX);
        }];
    }
    return _backgroundView;
}

- (UIButton *)connectButton{
    if (!_connectButton) {
        _connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_connectButton setTitleColor:[UIColor colorWithHexString:@"639DF8"] forState:UIControlStateNormal];
        [_connectButton setTitle:LocalString(@"去连接") forState:UIControlStateNormal];
        [_connectButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:20]];
        [_connectButton addTarget:self action:@selector(jump2Settings) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundView addSubview:_connectButton];
        [_connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(280.f), 50.f));
            make.bottom.equalTo(self.backgroundView.mas_bottom).offset(-30.f);
            make.centerX.equalTo(self.backgroundView.mas_centerX);
        }];
        
        _connectButton.layer.borderColor = [UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0].CGColor;
        _connectButton.layer.borderWidth = 1.f;
        _connectButton.layer.cornerRadius = 25.f;
    }
    return _connectButton;
}


@end
