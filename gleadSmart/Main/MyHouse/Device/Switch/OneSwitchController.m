//
//  OneSwitchController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/24.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "OneSwitchController.h"
#import "DeviceSettingController.h"
#import "MulSwitchTimingSetingController.h"

#define buttonGap ((ScreenWidth - 51*4)/5)

@interface OneSwitchController ()

@property (nonatomic, strong) UIView *mulSwitchView_1;
@property (nonatomic, strong) UIView *mulSwitchCloth_1;

@property (strong, nonatomic) UIButton *openAllButton_1;
@property (strong, nonatomic) UIButton *timeButton_1;
@property (strong, nonatomic) UIButton *delayButton;
@property (strong, nonatomic) UIButton *closeAllButton_1;

@end

@implementation OneSwitchController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0].CGColor;
    [self setNavItem];
    
    self.mulSwitchView_1 = [self mulSwitchView_1];
    self.mulSwitchCloth_1 = [self mulSwitchCloth_1];
    self.openAllButton_1 = [self openAllButton_1];
    self.timeButton_1 = [self timeButton_1];
    //self.delayButton = [self delayButton];不要了
    self.closeAllButton_1 = [self closeAllButton_1];
    
    [self setBackgroundColor_1];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMulSwitchUI:) name:@"refreshMulSwitchUI" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshMulSwitchUI" object:nil];
}

#pragma mark - private methods

- (void)goSetting_1{
    DeviceSettingController *VC = [[DeviceSettingController alloc] init];
    VC.device = self.device;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)mulSwitchAllOpen_1{
    
}

- (void)mulSwitchClock_1{
    
    MulSwitchTimingSetingController *SetingVC = [[MulSwitchTimingSetingController alloc] init];
    SetingVC.device = self.device;
    [self.navigationController pushViewController:SetingVC animated:YES];
}

- (void)mulSwitchAllClose_1{
    
}

- (void)switchClickOne:(UIButton *)sender{
    if (sender.tag == yUnselect) {
        sender.tag = ySelect;
        [sender setImage:[UIImage imageNamed:@"img_switch3_on"] forState:UIControlStateNormal];
    }else{
        sender.tag = yUnselect;
        [sender setImage:[UIImage imageNamed:@"img_switch3_off"] forState:UIControlStateNormal];
    }
}

#pragma mark - setters & getters
- (void)setBackgroundColor_1{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[(id)[UIColor colorWithHexString:@"62A5EE"].CGColor,(id)[UIColor colorWithHexString:@"1665BB"].CGColor];
    gradient.startPoint = CGPointMake(0.5, 0);
    gradient.endPoint = CGPointMake(0.5, 1);
    //    gradient.locations = @[@(0.5f), @(1.0f)];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)setNavItem{
    self.navigationItem.title = LocalString(@"开关");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"thermostatMoer"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goSetting_1) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UIView *)mulSwitchView_1{
    if (!_mulSwitchView_1) {
        _mulSwitchView_1 = [[UIView alloc] init];
        _mulSwitchView_1.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_mulSwitchView_1];
        [_mulSwitchView_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(290.f), 280.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(100.f);
        }];
        
        _mulSwitchView_1.layer.shadowColor = [UIColor colorWithRed:10/255.0 green:56/255.0 blue:106/255.0 alpha:0.49].CGColor;
        _mulSwitchView_1.layer.shadowOffset = CGSizeMake(0,9);
        _mulSwitchView_1.layer.shadowOpacity = 1;
        _mulSwitchView_1.layer.shadowRadius = 12;
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_switchback_back"]];
        image.frame = CGRectMake(0, 0, yAutoFit(290.f), 280.f);
        image.contentMode = UIViewContentModeScaleAspectFit;
        [_mulSwitchView_1 addSubview:image];
    }
    return _mulSwitchView_1;
}

- (UIView *)mulSwitchCloth_1{
    if (!_mulSwitchCloth_1) {
        _mulSwitchCloth_1 = [[UIView alloc] init];
        [_mulSwitchView_1 addSubview:_mulSwitchCloth_1];
        [_mulSwitchCloth_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(200.f), 190.f));
            make.centerX.equalTo(self.mulSwitchView_1.mas_centerX);
            make.centerY.equalTo(self.mulSwitchView_1.mas_centerY);
        }];
        
        UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        switchButton.frame = CGRectMake(0, 0, yAutoFit(200.f), 190.f);
        switchButton.tag = yUnselect;
        [switchButton setImage:[UIImage imageNamed:@"img_switch3_off"] forState:UIControlStateNormal];
        [switchButton.imageView setClipsToBounds:YES];
        switchButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [switchButton addTarget:self action:@selector(switchClickOne:) forControlEvents:UIControlEventTouchUpInside];
        [self.mulSwitchCloth_1 addSubview:switchButton];
    }
    return _mulSwitchCloth_1;
}

- (UIButton *)openAllButton_1{
    if (!_openAllButton_1) {
        _openAllButton_1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openAllButton_1 setImage:[UIImage imageNamed:@"img_switch_allopen"] forState:UIControlStateNormal];
        [_openAllButton_1 addTarget:self action:@selector(mulSwitchAllOpen_1) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_openAllButton_1];
        [_openAllButton_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 51));
            make.right.equalTo(self.timeButton_1.mas_left).offset(-40.f);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(80.f + ySafeArea_Bottom)));
        }];
        
        UILabel *openAllLabel = [[UILabel alloc] init];
        openAllLabel.text = LocalString(@"全部开");
        openAllLabel.textColor = [UIColor whiteColor];
        openAllLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Regular" size: 14];
        openAllLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:openAllLabel];
        [openAllLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 15));
            make.centerX.equalTo(self.openAllButton_1.mas_centerX);
            make.top.equalTo(self.openAllButton_1.mas_bottom);
        }];
    }
    return _openAllButton_1;
}

- (UIButton *)timeButton_1{
    if (!_timeButton_1) {
        _timeButton_1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeButton_1 setImage:[UIImage imageNamed:@"img_switch_clock"] forState:UIControlStateNormal];
        [_timeButton_1 addTarget:self action:@selector(mulSwitchClock_1) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_timeButton_1];
        [_timeButton_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 51));
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(80.f + ySafeArea_Bottom)));
        }];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = LocalString(@"定时");
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Regular" size: 14];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 15));
            make.centerX.equalTo(self.timeButton_1.mas_centerX);
            make.top.equalTo(self.timeButton_1.mas_bottom);
        }];
    }
    return _timeButton_1;
}

- (UIButton *)delayButton{
    if (!_delayButton) {
        _delayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delayButton setImage:[UIImage imageNamed:@"img_switch_delay"] forState:UIControlStateNormal];
        [_delayButton addTarget:self action:@selector(mulSwitchDelay) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_delayButton];
        [_delayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 51));
            make.left.equalTo(self.timeButton_1.mas_right).offset(buttonGap);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(80.f + ySafeArea_Bottom)));
        }];
        
        UILabel *delayLabel = [[UILabel alloc] init];
        delayLabel.text = LocalString(@"延时");
        delayLabel.textColor = [UIColor whiteColor];
        delayLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Regular" size: 14];
        delayLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:delayLabel];
        [delayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 15));
            make.centerX.equalTo(self.delayButton.mas_centerX);
            make.top.equalTo(self.delayButton.mas_bottom);
        }];
        
    }
    return _delayButton;
}

- (UIButton *)closeAllButton_1{
    if (!_closeAllButton_1) {
        _closeAllButton_1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeAllButton_1 setImage:[UIImage imageNamed:@"img_switch_allclose"] forState:UIControlStateNormal];
        [_closeAllButton_1 addTarget:self action:@selector(mulSwitchAllClose_1) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_closeAllButton_1];
        [_closeAllButton_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51.f, 51));
            make.left.equalTo(self.timeButton_1.mas_right).offset(40.f);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(80.f + ySafeArea_Bottom)));
        }];
        
        UILabel *clodeAllLabel = [[UILabel alloc] init];
        clodeAllLabel.text = LocalString(@"全部关");
        clodeAllLabel.textColor = [UIColor whiteColor];
        clodeAllLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Regular" size: 14];
        clodeAllLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:clodeAllLabel];
        [clodeAllLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 15));
            make.centerX.equalTo(self.closeAllButton_1.mas_centerX);
            make.top.equalTo(self.closeAllButton_1.mas_bottom);
        }];
        
    }
    return _closeAllButton_1;
}

@end
