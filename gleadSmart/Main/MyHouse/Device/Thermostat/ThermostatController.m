//
//  ThermostatController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/22.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ThermostatController.h"
#import "ThermostatTimerController.h"
#import "ThermostSettingController.h"

@interface ThermostatController ()

@property (strong, nonatomic) UIImageView *thermostatView;
@property (strong, nonatomic) UIView *circleView;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) UIButton *minusButton;

@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIButton *modeButton;
@property (strong, nonatomic) UIButton *timeButton;
@property (strong, nonatomic) UIButton *controlButton;
@property (strong, nonatomic) UIButton *setButton;

@end

@implementation ThermostatController{
    NSTimer *_sendTimer;//用来防止设置模式温度频率太快
    NSTimer *_inquireTimer;//用来每2分钟查询室温等
    BOOL setTempIsEnabled;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (!_sendTimer) {
            _sendTimer = [NSTimer scheduledTimerWithTimeInterval:3.f target:self selector:@selector(enableSetTemp) userInfo:nil repeats:YES];
        }
        if (!_inquireTimer) {
            _inquireTimer = [NSTimer scheduledTimerWithTimeInterval:120.f target:self selector:@selector(inquireModeAndIndoorTempAndModeTemp) userInfo:nil repeats:YES];
            if (![self.device.isOn boolValue]) {
                [_inquireTimer setFireDate:[NSDate distantFuture]];
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithHexString:@"EDEDEC"].CGColor;
    [self setNavItem];
    
    self.thermostatView = [self thermostatView];
    self.statusLabel = [self statusLabel];
    self.modeButton = [self modeButton];
    self.timeButton = [self timeButton];
    self.controlButton = [self controlButton];
    self.setButton = [self setButton];
    self.circleView = [self circleView];
    self.addButton = [self addButton];
    self.minusButton = [self minusButton];
    
    [self UITransformationByStatus];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDevice) name:@"refreshDevice" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshDevice" object:nil];
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
        _thermostatView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_thermostatView];
        [_thermostatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200.f, 200.f));
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
        _statusLabel.numberOfLines = 0;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_statusLabel];
        [_statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(130.f), yAutoFit(50.f)));
            make.centerX.equalTo(self.thermostatView.mas_centerX);
            make.centerY.equalTo(self.thermostatView.mas_centerY);
        }];
    }
    return _statusLabel;
}

- (UIButton *)modeButton{
    if (!_modeButton) {
        _modeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_modeButton setTitle:LocalString(@"手动") forState:UIControlStateNormal];
        [_modeButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [_modeButton setImage:[UIImage imageNamed:@"img_manual_off"] forState:UIControlStateNormal];
        [_modeButton.imageView sizeThatFits:CGSizeMake(51.f, 51.f)];
        _modeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.f];
        [_modeButton addTarget:self action:@selector(modeSwitchAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_modeButton];
        [_modeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 72));
            make.right.equalTo(self.timeButton.mas_left).offset(-20.f);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(30.f + ySafeArea_Bottom)));
        }];
        _modeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
        [_modeButton setTitleEdgeInsets:UIEdgeInsetsMake(_modeButton.imageView.frame.size.height + _modeButton.imageView.frame.origin.y + 15.f, -
                                                         _modeButton.imageView.frame.size.width - 5, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
        [_modeButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -
                                                         _modeButton.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
    }
    return _modeButton;
}

- (UIButton *)timeButton{
    if (!_timeButton) {
        _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeButton setTitle:LocalString(@"定时") forState:UIControlStateNormal];
        [_timeButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [_timeButton setImage:[UIImage imageNamed:@"thermostat_timing"] forState:UIControlStateNormal];
        [_timeButton.imageView sizeThatFits:CGSizeMake(51.f, 51.f)];
        _timeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.f];
        [_timeButton addTarget:self action:@selector(timingAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_timeButton];
        [_timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 72));
            make.right.equalTo(self.view.mas_centerX).offset(-10);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(30.f + ySafeArea_Bottom)));
        }];
        _timeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
        [_timeButton setTitleEdgeInsets:UIEdgeInsetsMake(_timeButton.imageView.frame.size.height + _timeButton.imageView.frame.origin.y + 15.f, -
                                                 _timeButton.imageView.frame.size.width - 5, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
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
        [_controlButton.imageView sizeThatFits:CGSizeMake(51.f, 51.f)];
        _controlButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.f];
        [_controlButton addTarget:self action:@selector(controlThermostat) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_controlButton];
        [_controlButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 72));
            make.left.equalTo(self.view.mas_centerX).offset(10.f);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(30.f + ySafeArea_Bottom)));
        }];
        _controlButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
        [_controlButton setTitleEdgeInsets:UIEdgeInsetsMake(_controlButton.imageView.frame.size.height + _controlButton.imageView.frame.origin.y + 15.f, -
                                                         _controlButton.imageView.frame.size.width - 5, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
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
        [_setButton.imageView sizeThatFits:CGSizeMake(51.f, 51.f)];
        _setButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.f];
        [_setButton addTarget:self action:@selector(thermostatSetting) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_setButton];
        [_setButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51.f, 72));
            make.left.equalTo(self.controlButton.mas_right).offset(20.f);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(30.f + ySafeArea_Bottom)));
        }];
        _setButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
        [_setButton setTitleEdgeInsets:UIEdgeInsetsMake(_setButton.imageView.frame.size.height + _setButton.imageView.frame.origin.y + 15.f, -
                                                         _setButton.imageView.frame.size.width - 5, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
        [_setButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -
                                                         _setButton.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
        
    }
    return _setButton;
}

- (UIView *)circleView{
    if (!_circleView) {
        _circleView = [[UIView alloc] init];
        _circleView.frame = CGRectMake(0, 0, 281.f, 240.f);
        _circleView.center = self.thermostatView.center;
        [self.view insertSubview:_circleView atIndex:0];
        
        CGFloat radius = 100.f + 25.f;//thermostatView的半径加上旁边圆圈到thermostatView的距离

        for (int i = 0; i < 9; i++) {
            UIImageView *circle = [[UIImageView alloc] init];
            circle.image = [UIImage imageNamed:@"thermostatCircle_off"];
            [_circleView addSubview:circle];
            
            circle.tag = 1000 + i;
            CGFloat angle = M_PI / 6 * i + -M_PI + -M_PI / 6;
            [circle mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(16.f, 16.f));
                make.centerX.equalTo(self.thermostatView.mas_centerX).offset(radius * cosf(angle));
                make.centerY.equalTo(self.thermostatView.mas_centerY).offset(radius * sinf(angle));
            }];
        }
        
        CGFloat angle = M_PI / 18 * 5;//50度
        UIImageView *maxImage = [[UIImageView alloc] init];
        maxImage.image = [UIImage imageNamed:@"thermostat_max"];
        maxImage.contentMode = UIViewContentModeScaleAspectFit;
        [_circleView addSubview:maxImage];
        [maxImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(21.f, 15.f));
            make.centerX.equalTo(self.thermostatView.mas_centerX).offset(radius * cosf(angle));
            make.centerY.equalTo(self.thermostatView.mas_centerY).offset(radius * sinf(angle));
        }];
        
        angle = M_PI / 18 * 13;//140度
        UIImageView *minImage = [[UIImageView alloc] init];
        minImage.image = [UIImage imageNamed:@"thermostat_min"];
        minImage.contentMode = UIViewContentModeScaleAspectFit;
        [_circleView addSubview:minImage];
        [minImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(21.f, 15.f));
            make.centerX.equalTo(self.thermostatView.mas_centerX).offset(radius * cosf(angle));
            make.centerY.equalTo(self.thermostatView.mas_centerY).offset(radius * sinf(angle));
        }];
    }
    return _circleView;
}

- (UIButton *)addButton{
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setImage:[UIImage imageNamed:@"thermostat_+"] forState:UIControlStateNormal];
        _addButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_addButton addTarget:self action:@selector(addManualTemp) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_addButton];
        [_addButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(37.f, 37.f));
            make.left.equalTo(self.view.mas_centerX).offset(39.f);
            make.top.equalTo(self.thermostatView.mas_bottom).offset(20.f);
        }];
    }
    return _addButton;
}

- (UIButton *)minusButton{
    if (!_minusButton) {
        _minusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_minusButton setImage:[UIImage imageNamed:@"thermostat_-"] forState:UIControlStateNormal];
        _minusButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_minusButton addTarget:self action:@selector(minusManualTemp) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_minusButton];
        [_minusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(37.f, 37.f));
            make.right.equalTo(self.view.mas_centerX).offset(-39.f);
            make.top.equalTo(self.thermostatView.mas_bottom).offset(20.f);
        }];
    }
    return _minusButton;
}

#pragma mark - Actions
- (void)modeSwitchAction{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x12,@0x05,@0x01,[NSNumber numberWithBool:![self.device.mode boolValue]]];
    [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data];
}

- (void)moreSetting{
    
}

- (void)addManualTemp{
    CGFloat temp = [self.device.modeTemp floatValue];
    temp = temp + 0.5;
    self.device.modeTemp = [NSNumber numberWithFloat:temp];
    NSLog(@"%@",self.device.modeTemp);
    self.statusLabel.attributedText = [self generateStringByTemperature:[self.device.modeTemp floatValue] currentTemp:[self.device.indoorTemp floatValue]];
    
    if (setTempIsEnabled) {
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFE,@0x12,@0x03,@0x01,self.device.mode,[NSNumber numberWithFloat:temp*2]];
        [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data];
        setTempIsEnabled = NO;
    }

}

- (void)minusManualTemp{
    CGFloat temp = [self.device.modeTemp floatValue];
    temp = temp - 0.5;
    self.device.modeTemp = [NSNumber numberWithFloat:temp];
    self.statusLabel.attributedText = [self generateStringByTemperature:[self.device.modeTemp floatValue] currentTemp:[self.device.indoorTemp floatValue]];

    if (setTempIsEnabled) {
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFE,@0x12,@0x03,@0x01,self.device.mode,[NSNumber numberWithFloat:temp*2]];
        [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data];
        
        setTempIsEnabled = NO;
    }
}

- (void)timingAction{
    ThermostatTimerController *timerVC = [[ThermostatTimerController alloc] init];
    [self.navigationController pushViewController:timerVC animated:YES];
}

- (void)controlThermostat{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x12,@0x01,@0x01,[NSNumber numberWithBool:![self.device.isOn boolValue]]];
    [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data];
}

- (void)thermostatSetting{
    ThermostSettingController *settingVC = [[ThermostSettingController alloc] init];
    settingVC.device = self.device;
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (NSMutableAttributedString *)generateStringByTemperature:(CGFloat)temp currentTemp:(CGFloat)currentTemp{
    NSString *tempStr = [NSString stringWithFormat:@"%.1f℃",temp];
    NSString *currentTempStr = [NSString stringWithFormat:@"%@%.1f℃",LocalString(@"当前温度"),currentTemp];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",tempStr,currentTempStr]];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"79A4E3"] range:NSMakeRange(0, tempStr.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"989796"] range:NSMakeRange(tempStr.length + 1, currentTempStr.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.f] range:NSMakeRange(0, tempStr.length)];
    [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.f] range:NSMakeRange(tempStr.length + 1, currentTempStr.length)];
    return str;
}

#pragma mark - Thermostat Control
- (void)UITransformationByStatus{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (DeviceModel *device in [Network shareNetwork].deviceArray) {
            if ([device.mac isEqualToString:self.device.mac]) {
                self.device = device;
            }
        }
        
        if ([self.device.isOn boolValue]) {
            [self inquireModeAndIndoorTempAndModeTemp];//在温控器打开的时候查询室温等
            [self->_inquireTimer setFireDate:[NSDate date]];//温控器打开时每2分钟查询一次
            
            self.thermostatView.image = [UIImage imageNamed:@"thermostatKnob_On"];
            [self.timeButton setTitleColor:[UIColor colorWithRed:69/255.0 green:142/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.timeButton setImage:[UIImage imageNamed:@"thermostat_timing_on"] forState:UIControlStateNormal];
            [self.controlButton setTitleColor:[UIColor colorWithRed:69/255.0 green:142/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.controlButton setTitle:LocalString(@"关闭") forState:UIControlStateNormal];
            [self.controlButton setImage:[UIImage imageNamed:@"thermostatControl_on"] forState:UIControlStateNormal];
            [self.setButton setTitleColor:[UIColor colorWithRed:69/255.0 green:142/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.setButton setImage:[UIImage imageNamed:@"thermostatSet_on"] forState:UIControlStateNormal];
            
            self.statusLabel.attributedText = [self generateStringByTemperature:[self.device.modeTemp floatValue] currentTemp:[self.device.indoorTemp floatValue]];
            
            self.addButton.hidden = NO;
            self.minusButton.hidden = NO;
            
            if ([self.device.mode boolValue]) {
                [self.modeButton setImage:[UIImage imageNamed:@"img_auto_on"] forState:UIControlStateNormal];
                [self.modeButton setTitleColor:[UIColor colorWithRed:69/255.0 green:142/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];
                [self.modeButton setTitle:LocalString(@"自动") forState:UIControlStateNormal];
            }else{
                [self.modeButton setImage:[UIImage imageNamed:@"img_manual_on"] forState:UIControlStateNormal];
                [self.modeButton setTitleColor:[UIColor colorWithRed:69/255.0 green:142/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];
                [self.modeButton setTitle:LocalString(@"手动") forState:UIControlStateNormal];
            }
            
        }else{
            [self->_inquireTimer setFireDate:[NSDate distantFuture]];//温控器未打开时不轮询室温等
            
            self.thermostatView.image = [UIImage imageNamed:@"thermostatKnob"];
            [self.timeButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
            [self.timeButton setImage:[UIImage imageNamed:@"thermostat_timing"] forState:UIControlStateNormal];
            [self.controlButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
            [self.controlButton setTitle:LocalString(@"开启") forState:UIControlStateNormal];
            [self.controlButton setImage:[UIImage imageNamed:@"thermostatControl"] forState:UIControlStateNormal];
            [self.setButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
            [self.setButton setImage:[UIImage imageNamed:@"thermostatSet"] forState:UIControlStateNormal];
            
            self.statusLabel.text = LocalString(@"已关闭");
            
            self.addButton.hidden = YES;
            self.minusButton.hidden = YES;
            
            if ([self.device.mode boolValue]) {
                [self.modeButton setImage:[UIImage imageNamed:@"img_atuo_off"] forState:UIControlStateNormal];
                [self.modeButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
                [self.modeButton setTitle:LocalString(@"自动") forState:UIControlStateNormal];
            }else{
                [self.modeButton setImage:[UIImage imageNamed:@"img_manual_off"] forState:UIControlStateNormal];
                [self.modeButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
                [self.modeButton setTitle:LocalString(@"手动") forState:UIControlStateNormal];
            }
        }
    });

}

//查询室内温度
- (void)inquireModeAndIndoorTempAndModeTemp{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x12,@0x03,@0x00];
    [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data];
}

#pragma mark - NSNotification
- (void)refreshDevice{
    [self UITransformationByStatus];
}

- (void)enableSetTemp{
    setTempIsEnabled = YES;
}
@end
