//
//  APNetworkController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/3/1.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "APNetworkController.h"
#import "ConnectApNetController.h"

#import <SystemConfiguration/CaptiveNetwork.h>

@interface APNetworkController () 

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) UILabel *wifiLabel;
@property (nonatomic, strong) UIButton *changeWifiButton;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UILabel *tipLabel;
@end

@implementation APNetworkController{
    NSString *ssid;
    NSString *password;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"7A7A7A"]];
    
    [self setNavItem];
    
    self.backgroundView = [self backgroundView];
    self.passwordTF = [self passwordTF];
    self.wifiLabel = [self wifiLabel];
    self.changeWifiButton = [self changeWifiButton];
    self.nextBtn = [self nextBtn];
    self.tipLabel = [self tipLabel];
    [self applicationWillEnterForeground];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getSSIDAndBSSID];
}

#pragma mark - private methods
- (void)applicationWillEnterForeground{
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]addObserverForName:UIApplicationWillEnterForegroundNotification  object:app queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self getSSIDAndBSSID];
    }];
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

- (void)getSSIDAndBSSID{
    NSDictionary *netInfo = [self fetchNetInfo];
    ssid = [netInfo objectForKey:@"SSID"];
    if (ssid == NULL) {
        [self showNoWifiAlertView];
        self.wifiLabel.text = [NSString stringWithFormat:@"Wi-Fi:"];
        [_passwordTF resignFirstResponder];
    }else{
        self.wifiLabel.text = [NSString stringWithFormat:@"Wi-Fi:%@",ssid];
        [_passwordTF becomeFirstResponder];
    }
}

- (void)showNoWifiAlertView{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
        
    };
    alert.rBlock = ^{
        //去Wi-Fi设置页面
        [self jump2Settings];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"当前手机没有连接Wi-Fi");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"去连接") forState:UIControlStateNormal];
    }];
    
}

- (void)jump2Settings{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

- (void)confirmSSIDAndPassword{
    if (ssid == NULL) {
        [self showNoWifiAlertView];
        return;
    }
    if ([self.passwordTF.text isEqualToString:@""]) {
        [self showNoPasswordAlert];
    }else{
        self->password = self.passwordTF.text;
        [self goConnectView];
    }
}

- (void)showNoPasswordAlert{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
        
    };
    alert.rBlock = ^{
        self->password = self.passwordTF.text;
        [self goConnectView];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"您输入的密码为空，请再次确认");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"继续") forState:UIControlStateNormal];
    }];
    
}

- (void)goConnectView{
    ConnectApNetController *connectVC = [[ConnectApNetController alloc] init];
    connectVC.ssid = ssid;
    connectVC.password = password;
    [self.navigationController pushViewController:connectVC animated:YES];
}

#pragma mark - setters and getters
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"AP模式");
    
}

- (UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_backgroundView];
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(320.f), 210.f));
            make.top.equalTo(self.view.mas_top).offset(80.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
        _backgroundView.layer.cornerRadius = 10.f;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = LocalString(@"输入家中Wi-Fi密码");
        titleLabel.font = [UIFont systemFontOfSize:17.f];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [_backgroundView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(120.f, 20.f));
            make.top.equalTo(self.backgroundView.mas_top).offset(20.f);
            make.centerX.equalTo(self.backgroundView.mas_centerX);
        }];
    }
    return _backgroundView;
}

- (UITextField *)passwordTF{
    if (!_passwordTF) {
        UIView *passwordView = [[UIView alloc] init];
        passwordView.backgroundColor = [UIColor colorWithHexString:@"F0F0F0"];
        [self.backgroundView addSubview:passwordView];
        [passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(260.f), 50.f));
            make.top.equalTo(self.backgroundView.mas_top).offset(60.f);
            make.centerX.equalTo(self.backgroundView.mas_centerX);
        }];
        passwordView.layer.cornerRadius = 10.f;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"img_wifipwd"];
        [passwordView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(14.f, 18.f));
            make.left.equalTo(passwordView.mas_left).offset(20.f);
            make.centerY.equalTo(passwordView.mas_centerY);
        }];
        
        _passwordTF = [[UITextField alloc] init];
        _passwordTF.textColor = [UIColor colorWithHexString:@"A1A1A1"];
        _passwordTF.placeholder = LocalString(@"请输入Wi-Fi密码");
        _passwordTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passwordTF.autocorrectionType = UITextAutocorrectionTypeNo;
        [passwordView addSubview:_passwordTF];
        [_passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(180.f), 20.f));
            make.centerY.equalTo(passwordView.mas_centerY);
            make.left.equalTo(imageView.mas_right).offset(15.f);
        }];
        
    }
    return _passwordTF;
}

- (UILabel *)wifiLabel{
    if (!_wifiLabel) {
        _wifiLabel = [[UILabel alloc] init];
        _wifiLabel.font = [UIFont systemFontOfSize:13.f];
        _wifiLabel.textColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0];
        _wifiLabel.text = @"Wi-Fi:CMCC-602";
        _wifiLabel.adjustsFontSizeToFitWidth = YES;
        [self.backgroundView addSubview:_wifiLabel];
        [_wifiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200.f, 30.f));
            make.left.equalTo(self.backgroundView.mas_left).offset(yAutoFit(30.f));
            make.top.equalTo(self.backgroundView.mas_top).offset(120.f);
        }];
    }
    return _wifiLabel;
}

- (UIButton *)changeWifiButton{
    if (!_changeWifiButton) {
        _changeWifiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeWifiButton setTitleColor:[UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_changeWifiButton setTitle:LocalString(@"更改网络") forState:UIControlStateNormal];
        [_changeWifiButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:13]];
        _changeWifiButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_changeWifiButton addTarget:self action:@selector(jump2Settings) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundView addSubview:_changeWifiButton];
        
        [_changeWifiButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80.f, 30.f));
            make.centerY.equalTo(self.wifiLabel.mas_centerY);
            make.right.equalTo(self.backgroundView.mas_right).offset(yAutoFit(-30.f));
        }];
        
    }
    return _changeWifiButton;
}

- (UIButton *)nextBtn{
    if (!_nextBtn) {
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self.backgroundView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1.f);
            make.top.equalTo(self.wifiLabel.mas_bottom).offset(10.f);
            make.left.equalTo(self.backgroundView.mas_left);
            make.right.equalTo(self.backgroundView.mas_right);
        }];
        
        self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_nextBtn setTitle:LocalString(@"确定") forState:UIControlStateNormal];
        [_nextBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:20]];
        [_nextBtn addTarget:self action:@selector(confirmSSIDAndPassword) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundView addSubview:_nextBtn];
        [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(320.f), 50.f));
            make.top.equalTo(lineView.mas_bottom);
            make.centerX.equalTo(self.backgroundView.mas_centerX);
        }];
    }
    return _nextBtn;
}

- (UILabel *)tipLabel{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = LocalString(@"仅支持2~4GWi-FI网络");
        _tipLabel.font = [UIFont systemFontOfSize:16.f];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_tipLabel];
        [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 20.f));
            make.top.equalTo(self.backgroundView.mas_bottom).offset(10.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _tipLabel;
}

@end
