//
//  EspViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "EspViewController.h"
#import "DeviceConnectView.h"

#import <SystemConfiguration/CaptiveNetwork.h>

#define HEIGHT_TEXT_FIELD 44

@interface EspViewController ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UITextField *passwordTF;
@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation EspViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"7A7A7A"]];

    self.navigationItem.title = LocalString(@"添加设备");
    self.backgroundView = [self backgroundView];
    self.passwordTF = [self passwordTF];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setters and getters
- (UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_backgroundView];
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(320.f), 200.f));
            make.top.equalTo(self.view.mas_top).offset(80.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
        _backgroundView.layer.cornerRadius = 10.f;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = LocalString(@"输入家中Wi-Fi密码");
        titleLabel.font = [UIFont systemFontOfSize:17.f];
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
            make.top.equalTo(self.backgroundView.mas_bottom).offset(60.f);
            make.centerX.equalTo(self.backgroundView.mas_centerX);
        }];

        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"img_wifipwd"];
        [passwordView addSubview:imageView];
        [passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(18.f, 18.f));
            make.left.equalTo(passwordView.mas_left).offset(20.f);
            make.centerY.equalTo(passwordView.mas_centerY);
        }];
        
        _passwordTF = [[UITextField alloc] init];
        _passwordTF.textColor = [UIColor colorWithHexString:@"A1A1A1"];
        [passwordView addSubview:_passwordTF];
        [_passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(180.f), 20.f));
            make.centerY.equalTo(passwordView.mas_centerY);
            make.left.equalTo(imageView.mas_right);
        }];
        
    }
    return _passwordTF;
}

- (UIButton *)nextBtn{
    if (!_nextBtn) {
        self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn setTitle:LocalString(@"下一步") forState:UIControlStateNormal];
        [_nextBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_nextBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        [_nextBtn setButtonStyle1];
        //_nextBtn.enabled = NO;
        [_nextBtn addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nextBtn];
    }
    return _nextBtn;
}

@end
