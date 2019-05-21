//
//  ThreeSwitchController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/24.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "ThreeSwitchController.h"
#import "DeviceSettingController.h"
#import "MulSwitchTimingSetingController.h"

#define buttonGap ((ScreenWidth - 51*4)/5)

@interface ThreeSwitchController ()

@property (nonatomic, strong) UIView *mulSwitchView;
@property (nonatomic, strong) UIView *mulSwitchCloth;

@property (strong, nonatomic) UIButton *openAllButton;
@property (strong, nonatomic) UIButton *timeButton;
@property (strong, nonatomic) UIButton *delayButton;
@property (strong, nonatomic) UIButton *closeAllButton;
@property (strong, nonatomic) UIButton *switchButton3_1;//开关按钮
@property (strong, nonatomic) UIButton *switchButton3_2;//开关按钮
@property (strong, nonatomic) UIButton *switchButton3_3;//开关按钮

@end

@implementation ThreeSwitchController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0].CGColor;
    [self setNavItem];
    
    self.mulSwitchView = [self mulSwitchView];
    self.mulSwitchCloth = [self mulSwitchCloth_3];
    self.openAllButton = [self openAllButton];
    self.timeButton = [self timeButton];
    //self.delayButton = [self delayButton];不要了
    self.closeAllButton = [self closeAllButton];
    [self getSwitchStatus];
    //[self getSwitchDateTime];
    [self setBackgroundColor_3];
    [self setSwitchTimes];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshThreeSwitchUI) name:@"refreshMulSwitchUI" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshMulSwitchUI" object:nil];
}

#pragma mark - private methods
//获取开关状态查询
- (void)getSwitchStatus{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFC,@0x11,@0x00,@0x00];
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
}
//获取开关日期时间查询
- (void)getSwitchDateTime{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFC,@0x11,@0x01,@0x00];
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
}

//校准开关时间
- (void)setSwitchTimes{
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

- (void)goSetting_3{
    DeviceSettingController *VC = [[DeviceSettingController alloc] init];
    VC.device = self.device;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)mulSwitchAllOpen_3{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,@0x07];
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
}

- (void)mulSwitchClock_3{
    
    MulSwitchTimingSetingController *SetingVC = [[MulSwitchTimingSetingController alloc] init];
    SetingVC.device = self.device;
    [self.navigationController pushViewController:SetingVC animated:YES];
}

- (void)mulSwitchAllClose_3{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,@0x00];
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
}

- (void)switchClickThree_1:(UIButton *)sender{
    if (sender.tag == yUnselect) {
        sender.tag = ySelect;
        
        //[sender setImage:[UIImage imageNamed:@"img_switch1_on"] forState:UIControlStateNormal];
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,@([self.device.isOn intValue] | 0x01)];
        [self.device sendData69With:controlCode mac:self.device.mac data:data];
    }else{
        sender.tag = yUnselect;
        //[sender setImage:[UIImage imageNamed:@"img_switch1_off"] forState:UIControlStateNormal];
        
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,@([self.device.isOn intValue] & ~0x01)];
        [self.device sendData69With:controlCode mac:self.device.mac data:data];
    }
}

- (void)switchClickThree_2:(UIButton *)sender{
    if (sender.tag == yUnselect) {
        sender.tag = ySelect;
        
        //[sender setImage:[UIImage imageNamed:@"img_switch1_on"] forState:UIControlStateNormal];
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,@([self.device.isOn intValue] | 0x02)];
        [self.device sendData69With:controlCode mac:self.device.mac data:data];
    }else{
        sender.tag = yUnselect;
        //[sender setImage:[UIImage imageNamed:@"img_switch1_off"] forState:UIControlStateNormal];
        
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,@([self.device.isOn intValue] & ~0x02)];
        [self.device sendData69With:controlCode mac:self.device.mac data:data];
    }
}

- (void)switchClickThree_3:(UIButton *)sender{
    if (sender.tag == yUnselect) {
        sender.tag = ySelect;
        
        //[sender setImage:[UIImage imageNamed:@"img_switch1_on"] forState:UIControlStateNormal];
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,@([self.device.isOn intValue] | 0x04)];
        [self.device sendData69With:controlCode mac:self.device.mac data:data];
    }else{
        sender.tag = yUnselect;
        //[sender setImage:[UIImage imageNamed:@"img_switch1_off"] forState:UIControlStateNormal];
        
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,@([self.device.isOn intValue] & ~0x04)];
        [self.device sendData69With:controlCode mac:self.device.mac data:data];
    }
}


#pragma mark - notification

- (void)refreshThreeSwitchUI{
    for (DeviceModel *device in [Network shareNetwork].deviceArray) {
        if ([device.mac isEqualToString:self.device.mac]) {
            self.device = device;
        }
    }
    [self ThreeSwitchUITransformationByStatus];
}

//更新UI
- (void)ThreeSwitchUITransformationByStatus{
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"%@",self.device.isOn);
        if ([self.device.isOn intValue] & 0x01) {
            [self.switchButton3_1 setImage:[UIImage imageNamed:@"img_switch1_on"] forState:UIControlStateNormal];
        }else{
            [self.switchButton3_1 setImage:[UIImage imageNamed:@"img_switch1_off"] forState:UIControlStateNormal];
        }
        if ([self.device.isOn intValue] & 0x02) {
            [self.switchButton3_2 setImage:[UIImage imageNamed:@"img_switch1_on"] forState:UIControlStateNormal];
        }else{
            [self.switchButton3_2 setImage:[UIImage imageNamed:@"img_switch1_off"] forState:UIControlStateNormal];
        }
        if ([self.device.isOn intValue] & 0x04) {
            [self.switchButton3_3 setImage:[UIImage imageNamed:@"img_switch1_on"] forState:UIControlStateNormal];
        }else{
            [self.switchButton3_3 setImage:[UIImage imageNamed:@"img_switch1_off"] forState:UIControlStateNormal];
        }
    });
}

#pragma mark - setters & getters
- (void)setBackgroundColor_3{
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
    [rightButton addTarget:self action:@selector(goSetting_3) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UIView *)mulSwitchView{
    if (!_mulSwitchView) {
        _mulSwitchView = [[UIView alloc] init];
        _mulSwitchView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_mulSwitchView];
        [_mulSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(290.f), 280.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(100.f);
        }];
        
        _mulSwitchView.layer.shadowColor = [UIColor colorWithRed:10/255.0 green:56/255.0 blue:106/255.0 alpha:0.49].CGColor;
        _mulSwitchView.layer.shadowOffset = CGSizeMake(0,9);
        _mulSwitchView.layer.shadowOpacity = 1;
        _mulSwitchView.layer.shadowRadius = 12;
        
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_switchback_back"]];
        image.frame = CGRectMake(0, 0, yAutoFit(290.f), 280.f);
        image.contentMode = UIViewContentModeScaleAspectFit;
        [_mulSwitchView addSubview:image];
    }
    return _mulSwitchView;
}

- (UIView *)mulSwitchCloth_3{
    if (!_mulSwitchCloth) {
        _mulSwitchCloth = [[UIView alloc] init];
        [_mulSwitchView addSubview:_mulSwitchCloth];
        [_mulSwitchCloth mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(202.5f), 120.f));
            make.centerX.equalTo(self.mulSwitchView.mas_centerX);
            make.centerY.equalTo(self.mulSwitchView.mas_centerY);
        }];
        
        _mulSwitchCloth.layer.shadowColor = [UIColor colorWithRed:10/255.0 green:46/255.0 blue:84/255.0 alpha:0.66].CGColor;
        _mulSwitchCloth.layer.shadowOffset = CGSizeMake(0,6);
        _mulSwitchCloth.layer.shadowOpacity = 1;
        _mulSwitchCloth.layer.shadowRadius = 25;
        _mulSwitchCloth.layer.cornerRadius = 2.5;
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_3switch_back"]];
        image.frame = CGRectMake(0, 0, yAutoFit(202.5f), 120.f);
        image.contentMode = UIViewContentModeScaleAspectFit;
        [_mulSwitchCloth addSubview:image];
        //分开三路开关
        self.switchButton3_1 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.switchButton3_1.frame = CGRectMake(0*(yAutoFit(202.5f)/3), 0, yAutoFit(202.5f)/3, 120.f);
        self.switchButton3_1.tag = yUnselect;
        [self.switchButton3_1 setImage:[UIImage imageNamed:@"img_switch1_off"] forState:UIControlStateNormal];
        [self.switchButton3_1.imageView setClipsToBounds:YES];
        self.switchButton3_1.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.switchButton3_1 addTarget:self action:@selector(switchClickThree_1:) forControlEvents:UIControlEventTouchUpInside];
        [self.mulSwitchCloth addSubview:self.switchButton3_1];
        
        self.switchButton3_2 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.switchButton3_2.frame = CGRectMake(1*(yAutoFit(202.5f)/3), 0, yAutoFit(202.5f)/3, 120.f);
        self.switchButton3_2.tag = yUnselect;
        [self.switchButton3_2 setImage:[UIImage imageNamed:@"img_switch1_off"] forState:UIControlStateNormal];
        [self.switchButton3_2.imageView setClipsToBounds:YES];
        self.switchButton3_2.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.switchButton3_2 addTarget:self action:@selector(switchClickThree_2:) forControlEvents:UIControlEventTouchUpInside];
        [self.mulSwitchCloth addSubview:self.switchButton3_2];
        
        self.switchButton3_3 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.switchButton3_3.frame = CGRectMake(2*(yAutoFit(202.5f)/3), 0, yAutoFit(202.5f)/3, 120.f);
        self.switchButton3_3.tag = yUnselect;
        [self.switchButton3_3 setImage:[UIImage imageNamed:@"img_switch1_off"] forState:UIControlStateNormal];
        [self.switchButton3_3.imageView setClipsToBounds:YES];
        self.switchButton3_3.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.switchButton3_3 addTarget:self action:@selector(switchClickThree_3:) forControlEvents:UIControlEventTouchUpInside];
        [self.mulSwitchCloth addSubview:self.switchButton3_3];
        
    }
    return _mulSwitchCloth;
}

- (UIButton *)openAllButton{
    if (!_openAllButton) {
        _openAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openAllButton setImage:[UIImage imageNamed:@"img_switch_allopen"] forState:UIControlStateNormal];
        [_openAllButton addTarget:self action:@selector(mulSwitchAllOpen_3) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_openAllButton];
        [_openAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 51));
            make.right.equalTo(self.timeButton.mas_left).offset(-40.f);
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
            make.centerX.equalTo(self.openAllButton.mas_centerX);
            make.top.equalTo(self.openAllButton.mas_bottom);
        }];
    }
    return _openAllButton;
}

- (UIButton *)timeButton{
    if (!_timeButton) {
        _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeButton setImage:[UIImage imageNamed:@"img_switch_clock"] forState:UIControlStateNormal];
        [_timeButton addTarget:self action:@selector(mulSwitchClock_3) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_timeButton];
        [_timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
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
            make.centerX.equalTo(self.timeButton.mas_centerX);
            make.top.equalTo(self.timeButton.mas_bottom);
        }];
    }
    return _timeButton;
}

- (UIButton *)delayButton{
    if (!_delayButton) {
        _delayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delayButton setImage:[UIImage imageNamed:@"img_switch_delay"] forState:UIControlStateNormal];
        [_delayButton addTarget:self action:@selector(mulSwitchDelay) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_delayButton];
        [_delayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 51));
            make.left.equalTo(self.timeButton.mas_right).offset(buttonGap);
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

- (UIButton *)closeAllButton{
    if (!_closeAllButton) {
        _closeAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeAllButton setImage:[UIImage imageNamed:@"img_switch_allclose"] forState:UIControlStateNormal];
        [_closeAllButton addTarget:self action:@selector(mulSwitchAllClose_3) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_closeAllButton];
        [_closeAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51.f, 51));
            make.left.equalTo(self.timeButton.mas_right).offset(40.f);
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
            make.centerX.equalTo(self.closeAllButton.mas_centerX);
            make.top.equalTo(self.closeAllButton.mas_bottom);
        }];
        
    }
    return _closeAllButton;
}

@end
