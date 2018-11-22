//
//  ThermostatController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/22.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ThermostatController.h"

@interface ThermostatController ()

@property (strong, nonatomic) UIImageView *thermostatView;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIButton *timeButton;
@property (strong, nonatomic) UIButton *controlButton;
@property (strong, nonatomic) UIButton *setButton;

@end

@implementation ThermostatController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithHexString:@"EDEDEC"].CGColor;
    [self setNavItem];
    
    self.thermostatView = [self thermostatView];
    self.statusLabel = [self statusLabel];
    self.timeButton = [self timeButton];
    self.controlButton = [self controlButton];
    self.setButton = [self setButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

#pragma mark - Lazy load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"温控器");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"thermostatMoer"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(moreSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UIImageView *)thermostatView{
    if (!_thermostatView) {
        _thermostatView = [[UIImageView alloc] init];
        _thermostatView.image = [UIImage imageNamed:@"thermostatKnob"];
        [self.view addSubview:_thermostatView];
        [_thermostatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(193.f), yAutoFit(207.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(yAutoFit(200.f));
        }];
    }
    return _thermostatView;
}

- (UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [UIFont fontWithName:@"Helvetica" size:23];
        _statusLabel.textColor = [UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1];
        _statusLabel.text = LocalString(@"已关闭");
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_statusLabel];
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(130.f), yAutoFit(23.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.thermostatView.mas_centerY);
        }];
    }
    return _statusLabel;
}

- (UIButton *)timeButton{
    if (!_timeButton) {
        _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeButton setTitle:LocalString(@"定时") forState:UIControlStateNormal];
        [_timeButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [_timeButton setImage:[UIImage imageNamed:@"thermostatSet"] forState:UIControlStateNormal];
        [_timeButton.imageView sizeThatFits:CGSizeMake(44.f, 44.f)];
        _timeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.f];
        [_timeButton addTarget:self action:@selector(timingAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_timeButton];
        CGFloat padding = ScreenWidth / 4.f;
        [_timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44, 65));
            make.centerX.equalTo(self.view.mas_centerX).offset(-padding);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(30.f + ySafeArea_Bottom)));
        }];
        _timeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
        [_timeButton setTitleEdgeInsets:UIEdgeInsetsMake(_timeButton.imageView.frame.size.height + _timeButton.imageView.frame.origin.y + 15.f, -
                                                 _timeButton.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
        [_timeButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -
                                                 _timeButton.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
        
    }
    return _timeButton;
}

- (UIButton *)controlButton{
    if (!_controlButton) {
        _controlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_controlButton setTitle:LocalString(@"开启") forState:UIControlStateNormal];
        [_controlButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [_controlButton setImage:[UIImage imageNamed:@"thermostatControl"] forState:UIControlStateNormal];
        [_controlButton.imageView sizeThatFits:CGSizeMake(44.f, 44.f)];
        _controlButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.f];
        [_controlButton addTarget:self action:@selector(controlThermostat) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_controlButton];
        [_controlButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44, 65));
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(30.f + ySafeArea_Bottom)));
        }];
        _controlButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
        [_controlButton setTitleEdgeInsets:UIEdgeInsetsMake(_controlButton.imageView.frame.size.height + _controlButton.imageView.frame.origin.y + 15.f, -
                                                         _controlButton.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
        [_controlButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -
                                                         _controlButton.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
        
    }
    return _controlButton;
}

- (UIButton *)setButton{
    if (!_setButton) {
        _setButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_setButton setTitle:LocalString(@"设置") forState:UIControlStateNormal];
        [_setButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [_setButton setImage:[UIImage imageNamed:@"thermostatSet"] forState:UIControlStateNormal];
        [_setButton.imageView sizeThatFits:CGSizeMake(44.f, 44.f)];
        _setButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.f];
        [_setButton addTarget:self action:@selector(thermostatSetting) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_setButton];
        CGFloat padding = ScreenWidth / 4.f;
        [_setButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(44, 65));
            make.centerX.equalTo(self.view.mas_centerX).offset(padding);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(30.f + ySafeArea_Bottom)));
        }];
        _setButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
        [_setButton setTitleEdgeInsets:UIEdgeInsetsMake(_setButton.imageView.frame.size.height + _setButton.imageView.frame.origin.y + 15.f, -
                                                         _setButton.imageView.frame.size.width, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
        [_setButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -
                                                         _setButton.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
        
    }
    return _setButton;
}

#pragma mark - Actions
- (void)moreSetting{
    
}

- (void)timingAction{
    
}

- (void)controlThermostat{
    
}

- (void)thermostatSetting{
    
}
@end
