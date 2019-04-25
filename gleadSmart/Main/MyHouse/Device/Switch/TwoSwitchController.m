//
//  TwoSwitchController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/24.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "TwoSwitchController.h"
#import "DeviceSettingController.h"
#import "MulSwitchTimingSetingController.h"

#define buttonGap ((ScreenWidth - 51*4)/5)

@interface TwoSwitchController ()

@property (nonatomic, strong) UIView *mulSwitchView_2;
@property (nonatomic, strong) UIView *mulSwitchCloth_2;

@property (strong, nonatomic) UIButton *openAllButton_2;
@property (strong, nonatomic) UIButton *timeButton_2;
@property (strong, nonatomic) UIButton *delayButton;
@property (strong, nonatomic) UIButton *closeAllButton_2;

@end

@implementation TwoSwitchController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0].CGColor;
    [self setNavItem];
    
    self.mulSwitchView_2 = [self mulSwitchView_2];
    self.mulSwitchCloth_2 = [self mulSwitchCloth_2_2];
    self.openAllButton_2 = [self openAllButton_2];
    self.timeButton_2 = [self timeButton_2];
    //self.delayButton = [self delayButton];不要了
    self.closeAllButton_2 = [self closeAllButton_2];
    
    [self setBackgroundColor_2];
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

- (void)goSetting_2{
    DeviceSettingController *VC = [[DeviceSettingController alloc] init];
    VC.device = self.device;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)mulSwitchAllOpen_2{
    
}

- (void)mulSwitchClock_2{
    
    MulSwitchTimingSetingController *SetingVC = [[MulSwitchTimingSetingController alloc] init];
    SetingVC.device = self.device;
    [self.navigationController pushViewController:SetingVC animated:YES];
}

- (void)mulSwitchAllClose_2{
    
}


- (void)switchClickTwo:(UIButton *)sender{
    if (sender.tag == yUnselect) {
        sender.tag = ySelect;
        [sender setImage:[UIImage imageNamed:@"img_switch2_on"] forState:UIControlStateNormal];
    }else{
        sender.tag = yUnselect;
        [sender setImage:[UIImage imageNamed:@"img_switch2_off"] forState:UIControlStateNormal];
    }
}


#pragma mark - setters & getters
- (void)setBackgroundColor_2{
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
    [rightButton addTarget:self action:@selector(goSetting_2) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UIView *)mulSwitchView_2{
    if (!_mulSwitchView_2) {
        _mulSwitchView_2 = [[UIView alloc] init];
        _mulSwitchView_2.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_mulSwitchView_2];
        [_mulSwitchView_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(290.f), 280.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(100.f);
        }];
        
        _mulSwitchView_2.layer.shadowColor = [UIColor colorWithRed:10/255.0 green:56/255.0 blue:106/255.0 alpha:0.49].CGColor;
        _mulSwitchView_2.layer.shadowOffset = CGSizeMake(0,9);
        _mulSwitchView_2.layer.shadowOpacity = 1;
        _mulSwitchView_2.layer.shadowRadius = 12;
        
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_switchback_back"]];
        image.frame = CGRectMake(0, 0, yAutoFit(290.f), 280.f);
        image.contentMode = UIViewContentModeScaleAspectFit;
        [_mulSwitchView_2 addSubview:image];
    }
    return _mulSwitchView_2;
}

- (UIView *)mulSwitchCloth_2_2{
    if (!_mulSwitchCloth_2) {
        _mulSwitchCloth_2 = [[UIView alloc] init];
        [_mulSwitchView_2 addSubview:_mulSwitchCloth_2];
        [_mulSwitchCloth_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(270.f), 120.f));
            make.centerX.equalTo(self.mulSwitchView_2.mas_centerX);
            make.centerY.equalTo(self.mulSwitchView_2.mas_centerY);
        }];
        
        _mulSwitchCloth_2.layer.shadowColor = [UIColor colorWithRed:10/255.0 green:46/255.0 blue:84/255.0 alpha:0.66].CGColor;
        _mulSwitchCloth_2.layer.shadowOffset = CGSizeMake(0,6);
        _mulSwitchCloth_2.layer.shadowOpacity = 1;
        _mulSwitchCloth_2.layer.shadowRadius = 25;
        _mulSwitchCloth_2.layer.cornerRadius = 2.5;
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_4switch_back"]];
        image.frame = CGRectMake(0, 0, yAutoFit(270.f), 120.f);
        image.contentMode = UIViewContentModeScaleAspectFit;
        [_mulSwitchCloth_2 addSubview:image];
        //分开两路开关
        for (int i = 0; i < 2; i++) {
            UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
            switchButton.frame = CGRectMake(i*(yAutoFit(270.f)/2), 0, yAutoFit(270.f)/2, 120.f);
            switchButton.tag = yUnselect;
            [switchButton setImage:[UIImage imageNamed:@"img_switch2_off"] forState:UIControlStateNormal];
            [switchButton.imageView setClipsToBounds:YES];
            switchButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [switchButton addTarget:self action:@selector(switchClickTwo:) forControlEvents:UIControlEventTouchUpInside];
            [self.mulSwitchCloth_2 addSubview:switchButton];
        }
    }
    return _mulSwitchCloth_2;
}

- (UIButton *)openAllButton_2{
    if (!_openAllButton_2) {
        _openAllButton_2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openAllButton_2 setImage:[UIImage imageNamed:@"img_switch_allopen"] forState:UIControlStateNormal];
        [_openAllButton_2 addTarget:self action:@selector(mulSwitchAllOpen_2) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_openAllButton_2];
        [_openAllButton_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 51));
            make.right.equalTo(self.timeButton_2.mas_left).offset(-40.f);
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
            make.centerX.equalTo(self.openAllButton_2.mas_centerX);
            make.top.equalTo(self.openAllButton_2.mas_bottom);
        }];
    }
    return _openAllButton_2;
}

- (UIButton *)timeButton_2{
    if (!_timeButton_2) {
        _timeButton_2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeButton_2 setImage:[UIImage imageNamed:@"img_switch_clock"] forState:UIControlStateNormal];
        [_timeButton_2 addTarget:self action:@selector(mulSwitchClock_2) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_timeButton_2];
        [_timeButton_2 mas_makeConstraints:^(MASConstraintMaker *make) {
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
            make.centerX.equalTo(self.timeButton_2.mas_centerX);
            make.top.equalTo(self.timeButton_2.mas_bottom);
        }];
    }
    return _timeButton_2;
}

- (UIButton *)delayButton{
    if (!_delayButton) {
        _delayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delayButton setImage:[UIImage imageNamed:@"img_switch_delay"] forState:UIControlStateNormal];
        [_delayButton addTarget:self action:@selector(mulSwitchDelay) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_delayButton];
        [_delayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 51));
            make.left.equalTo(self.timeButton_2.mas_right).offset(buttonGap);
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

- (UIButton *)closeAllButton_2{
    if (!_closeAllButton_2) {
        _closeAllButton_2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeAllButton_2 setImage:[UIImage imageNamed:@"img_switch_allclose"] forState:UIControlStateNormal];
        [_closeAllButton_2 addTarget:self action:@selector(mulSwitchAllClose_2) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_closeAllButton_2];
        [_closeAllButton_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51.f, 51));
            make.left.equalTo(self.timeButton_2.mas_right).offset(40.f);
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
            make.centerX.equalTo(self.closeAllButton_2.mas_centerX);
            make.top.equalTo(self.closeAllButton_2.mas_bottom);
        }];
        
    }
    return _closeAllButton_2;
}

@end
