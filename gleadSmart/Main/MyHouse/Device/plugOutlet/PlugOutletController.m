//
//  PlugOutletController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/3/29.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "PlugOutletController.h"
#import "PlugOutletSettingController.h"
#import "PlugOutletTimingController.h"
#import "PlugOutletDelayController.h"
#import "PlugOutletElectricityController.h"

@interface PlugOutletController ()

@property (nonatomic, strong) UIImageView *plugView;
@property (nonatomic, strong) UILabel *plugStatusLabel;
@property (nonatomic, strong) UIButton *plugButton;

@property (nonatomic, strong) UIView *buttonTablecloth;
@property (strong, nonatomic) UIButton *timeButton;
@property (strong, nonatomic) UIButton *delayButton;
@property (strong, nonatomic) UIButton *electricityButton;

@end

@implementation PlugOutletController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0].CGColor;
    [self setNavItem];

    self.plugView = [self plugView];
    self.plugButton = [self plugButton];
    self.plugStatusLabel = [self plugStatusLabel];
    self.buttonTablecloth = [self buttonTablecloth];
    self.timeButton = [self timeButton];
    self.delayButton = [self delayButton];
    self.electricityButton = [self electricityButton];
    
    [self PlugUITransformationByStatus];
    [self setPlugTimes];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rabbitMQPlugOutletStatusUpdate:) name:@"rabbitMQPlugOutletStatusUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPlugOutletUI:) name:@"refreshPlugOutletUI" object:nil];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshPlugOutletUI" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"rabbitMQPlugOutletStatusUpdate" object:nil];
}
#pragma mark - notification
- (void)refreshPlugOutletUI:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    DeviceModel *device = [userInfo objectForKey:@"device"];
    self.device = device;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self PlugUITransformationByStatus];
    });
}

- (void)rabbitMQPlugOutletStatusUpdate:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    DeviceModel *device = [userInfo objectForKey:@"device"];
    self.device = device;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self PlugUITransformationByStatus];
    });
}

#pragma mark - private methods
- (void)PlugUITransformationByStatus{
    if ([self.device.isOn boolValue]) {
        self.plugView.image = [UIImage imageNamed:@"img_plugView_on"];
        self.buttonTablecloth.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        self.buttonTablecloth.layer.shadowOpacity = 1;
        self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0].CGColor;
        self.plugStatusLabel.text = LocalString(@"插座已开启");
    }else{
        self.plugView.image = [UIImage imageNamed:@"img_plugView_off"];
        self.buttonTablecloth.backgroundColor = [UIColor colorWithRed:6/255.0 green:30/255.0 blue:59/255.0 alpha:1.0];
        self.buttonTablecloth.layer.shadowOpacity = 0;
        self.view.layer.backgroundColor = [UIColor colorWithRed:3/255.0 green:18/255.0 blue:36/255.0 alpha:1.0].CGColor;
        self.plugStatusLabel.text = LocalString(@"插座已关闭");
    }
}

- (void)plugClick{
    if ([self.device.isOn boolValue]) {
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,@0];
        [self.device sendData69With:controlCode mac:self.device.mac data:data];
    }else{
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,@1];
        [self.device sendData69With:controlCode mac:self.device.mac data:data];
    }
}

- (void)goSetting{
    PlugOutletSettingController *VC = [[PlugOutletSettingController alloc] init];
    VC.device = self.device;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)plugClock{
    
    PlugOutletTimingController *timingVC = [[PlugOutletTimingController alloc] init];
    timingVC.device = self.device;
    [self.navigationController pushViewController:timingVC animated:YES];
}

- (void)plugDelay{
    PlugOutletDelayController *DelayVC = [[PlugOutletDelayController alloc] init];
    DelayVC.device = self.device;
    [self.navigationController pushViewController:DelayVC animated:YES];
}

- (void)plugElectricity{
    
    PlugOutletElectricityController *ElectricityVC = [[PlugOutletElectricityController alloc] init];
    ElectricityVC.device = self.device;
    [self.navigationController pushViewController:ElectricityVC animated:YES];
}

//校准开关时间
- (void)setPlugTimes{
    NSDate *date = [NSDate date];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];    //IOS 8 之后
    NSUInteger integer = NSCalendarUnitYear | NSCalendarUnitMonth |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSDateComponents *dataCom = [currentCalendar components:integer fromDate:date];
    
    UInt8 controlCode = 0x01;
    NSNumber *A = [NSNumber numberWithUnsignedInteger:[dataCom year] % 100];
    NSNumber *B = [NSNumber numberWithUnsignedInteger:[dataCom month]];
    NSNumber *C = [NSNumber numberWithUnsignedInteger:[dataCom day]];
    NSNumber *D = [NSNumber numberWithUnsignedInteger:[dataCom hour]];
    NSNumber *E = [NSNumber numberWithUnsignedInteger:[dataCom minute]];
    NSNumber *F = [NSNumber numberWithUnsignedInteger:[dataCom second]];
    NSNumber *G = [NSNumber numberWithUnsignedInteger:[dataCom weekday]];
    //区分 星期天、星期一…星期六
    switch ([G intValue]) {
        case 1:
            G = [NSNumber numberWithInt: 0x01];
            break;
        case 2:
            G = [NSNumber numberWithInt: 0x02];
            break;
        case 3:
            G = [NSNumber numberWithInt: 0x04];
            break;
        case 4:
            G = [NSNumber numberWithInt: 0x08];
            break;
        case 5:
            G = [NSNumber numberWithInt: 0x10];
            break;
        case 6:
            G = [NSNumber numberWithInt: 0x20];
            break;
        case 7:
            G = [NSNumber numberWithInt: 0x40];
            break;
        default:
            break;
    }
    NSArray *data = @[@0xFC,@0x11,@0x01,@0x01,A,B,C,D,E,F,G];
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
}

#pragma mark - setters and getters
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"插座");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"thermostatMoer"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UIImageView *)plugView{
    if (!_plugView) {
        _plugView = [[UIImageView alloc] init];
        _plugView.image = [UIImage imageNamed:@"img_plugView_on"];
        [self.view insertSubview:_plugView atIndex:0];
        [_plugView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(327.f), yAutoFit(343.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(50.f);
        }];
    }
    return _plugView;
}

- (UIButton *)plugButton{
    if (!_plugButton) {
        _plugButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_plugButton addTarget:self action:@selector(plugClick) forControlEvents:UIControlEventTouchUpInside];
        _plugButton.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_plugButton];
        [self.view bringSubviewToFront:_plugButton];
        [_plugButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(327.f), yAutoFit(343.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(50.f);
        }];
    }
    return _plugButton;
}

- (UILabel *)plugStatusLabel{
    if (!_plugStatusLabel) {
        _plugStatusLabel = [[UILabel alloc] init];
        _plugStatusLabel.text = LocalString(@"插座已开启");
        _plugStatusLabel.textColor = [UIColor colorWithRed:63/255.0 green:137/255.0 blue:228/255.0 alpha:1.0];
        _plugStatusLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Regular" size: 14];
        _plugStatusLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_plugStatusLabel];
        [_plugStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200, 15));
            make.centerX.equalTo(self.plugView.mas_centerX);
            make.bottom.equalTo(self.plugView.mas_bottom).offset(-25.f);
        }];
    }
    return _plugStatusLabel;
}

- (UIView *)buttonTablecloth{
    if (!_buttonTablecloth) {
        _buttonTablecloth = [[UIView alloc] init];
        _buttonTablecloth.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        _buttonTablecloth.layer.shadowColor = [UIColor colorWithRed:174/255.0 green:200/255.0 blue:249/255.0 alpha:0.3].CGColor;
        _buttonTablecloth.layer.shadowOffset = CGSizeMake(0,8);
        _buttonTablecloth.layer.shadowOpacity = 1;
        _buttonTablecloth.layer.shadowRadius = 8;
        _buttonTablecloth.layer.cornerRadius = 5;

        [self.view insertSubview:_buttonTablecloth atIndex:0];
        [_buttonTablecloth mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(355.f), 84.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(50.f + ySafeArea_Bottom)));
        }];
    }
    return _buttonTablecloth;
}

- (UIButton *)timeButton{
    if (!_timeButton) {
        _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeButton setImage:[UIImage imageNamed:@"img_plugClock"] forState:UIControlStateNormal];
        [_timeButton addTarget:self action:@selector(plugClock) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonTablecloth addSubview:_timeButton];
        [_timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 51));
            make.right.equalTo(self.delayButton.mas_left).offset(-40.f);
            make.top.equalTo(self.buttonTablecloth.mas_top).offset((85-15-51)/2);
        }];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = LocalString(@"定时");
        timeLabel.textColor = [UIColor colorWithRed:63/255.0 green:137/255.0 blue:228/255.0 alpha:1.0];
        timeLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Regular" size: 14];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.buttonTablecloth addSubview:timeLabel];
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 15));
            make.centerX.equalTo(self.timeButton.mas_centerX);
            make.top.equalTo(self.timeButton.mas_bottom);
        }];
    }
    return _timeButton;
}

- (UIButton *)delayButton{
    if (!_delayButton) {
        _delayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delayButton setImage:[UIImage imageNamed:@"img_plug_delayTime"] forState:UIControlStateNormal];
        [_delayButton addTarget:self action:@selector(plugDelay) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonTablecloth addSubview:_delayButton];
        [_delayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 51));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.buttonTablecloth.mas_top).offset((85-15-51)/2);
        }];
        
        UILabel *delayLabel = [[UILabel alloc] init];
        delayLabel.text = LocalString(@"延时");
        delayLabel.textColor = [UIColor colorWithRed:63/255.0 green:137/255.0 blue:228/255.0 alpha:1.0];
        delayLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Regular" size: 14];
        delayLabel.textAlignment = NSTextAlignmentCenter;
        [self.buttonTablecloth addSubview:delayLabel];
        [delayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 15));
            make.centerX.equalTo(self.delayButton.mas_centerX);
            make.top.equalTo(self.delayButton.mas_bottom);
        }];
        
    }
    return _delayButton;
}

- (UIButton *)electricityButton{
    if (!_electricityButton) {
        _electricityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_electricityButton setImage:[UIImage imageNamed:@"img_plug_electricity"] forState:UIControlStateNormal];
        [_electricityButton addTarget:self action:@selector(plugElectricity) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonTablecloth addSubview:_electricityButton];
        [_electricityButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51.f, 51));
            make.left.equalTo(self.delayButton.mas_right).offset(40.f);
            make.top.equalTo(self.buttonTablecloth.mas_top).offset((85-15-51)/2);
        }];
        
        UILabel *electricityLabel = [[UILabel alloc] init];
        electricityLabel.text = LocalString(@"电量");
        electricityLabel.textColor = [UIColor colorWithRed:63/255.0 green:137/255.0 blue:228/255.0 alpha:1.0];
        electricityLabel.font = [UIFont fontWithName:@"SourceHanSansCN-Regular" size: 14];
        electricityLabel.textAlignment = NSTextAlignmentCenter;
        [self.buttonTablecloth addSubview:electricityLabel];
        [electricityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 15));
            make.centerX.equalTo(self.electricityButton.mas_centerX);
            make.top.equalTo(self.electricityButton.mas_bottom);
        }];
        
    }
    return _electricityButton;
}

@end
