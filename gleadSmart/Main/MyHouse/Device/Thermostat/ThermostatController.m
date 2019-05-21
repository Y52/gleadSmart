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
#import "DeviceSettingController.h"

#define ToRad(deg)      ( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)      ( (180.0 * (rad)) / M_PI )
#define SQR(x)          ( (x) * (x) )

static float UIGestureRecognizerStateMovedTemp = 0.0;

@interface ThermostatController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImageView *thermostatView;
@property (strong, nonatomic) UIView *circleView;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) UIButton *minusButton;

@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIButton *modeButton;
@property (strong, nonatomic) UIButton *timeButton;
@property (strong, nonatomic) UIButton *controlButton;
@property (strong, nonatomic) UIButton *setButton;

@property (nonatomic, strong) UIPanGestureRecognizer *panGest;//旋转手势

@end

@implementation ThermostatController{
    dispatch_source_t _sendTimer;//用来防止设置模式温度频率太快
    dispatch_source_t _inquireTimer;//用来每2分钟查询室温等
    BOOL isInquireTimerSuspend;
    float nowSetTemp;//用来判断最新的温度设置数据是否上报，该值只有在确认设置温度后才改变为设置温度
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithHexString:@"EDEDEC"].CGColor;
    [self setNavItem];
    [self initTimer];
    
    self.thermostatView = [self thermostatView];
    self.statusLabel = [self statusLabel];
    self.modeButton = [self modeButton];
    //self.timeButton = [self timeButton];
    self.controlButton = [self controlButton];
    self.setButton = [self setButton];
    self.circleView = [self circleView];
    self.addButton = [self addButton];
    self.minusButton = [self minusButton];
    
    [self UITransformationByStatus];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDevice) name:@"refreshThermostat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSetBackModeTemp:) name:@"postSetBackModeTemp" object:nil];
    
    //打开温控器或者是切换模式后要查询温控器当前温度和设置温度
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inquireModeAndIndoorTempAndModeTemp) name:@"openThermostat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inquireModeAndIndoorTempAndModeTemp) name:@"switchThermostatMode" object:nil];

    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshThermostat" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"postSetBackModeTemp" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openThermostat" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"switchThermostatMode" object:nil];


    dispatch_source_cancel(_sendTimer);
    
    if (isInquireTimerSuspend) {
        dispatch_resume(_inquireTimer);
    }
    dispatch_source_cancel(_inquireTimer);
}

#pragma mark - private method
- (void)UITransformationByStatus{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (DeviceModel *device in [Network shareNetwork].connectedDevice.gatewayMountDeviceList) {
            if ([device.mac isEqualToString:self.device.mac]) {
                self.device = device;
            }
        }
        if ([self.device.isOn boolValue]) {
            
            if (self->isInquireTimerSuspend) {
                //dispatch_resume(self->_inquireTimer);//温控器打开时每2分钟查询一次
            }
            
            self.thermostatView.image = [UIImage imageNamed:@"thermostatKnob_On"];
            self.thermostatView.userInteractionEnabled = YES;
            self.panGest.enabled = YES;

            [self.timeButton setTitleColor:[UIColor colorWithRed:69/255.0 green:142/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.timeButton setImage:[UIImage imageNamed:@"thermostat_timing_on"] forState:UIControlStateNormal];
            [self.controlButton setTitleColor:[UIColor colorWithRed:69/255.0 green:142/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.controlButton setTitle:LocalString(@"关闭") forState:UIControlStateNormal];
            [self.controlButton setImage:[UIImage imageNamed:@"thermostatControl_on"] forState:UIControlStateNormal];
            [self.setButton setTitleColor:[UIColor colorWithRed:69/255.0 green:142/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.setButton setImage:[UIImage imageNamed:@"thermostatSet_on"] forState:UIControlStateNormal];
            
            self.statusLabel.attributedText = [self generateStringByTemperature:[self.device.modeTemp floatValue] currentTemp:[self.device.indoorTemp floatValue]];
            self->nowSetTemp = [self.device.modeTemp floatValue];
            
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
            
            self.modeButton.enabled = YES;
            self.timeButton.enabled = YES;
            self.setButton.enabled = YES;
            
            [self updateModeTempUI];
            
            
        }else{
            if (!self->isInquireTimerSuspend) {
                //dispatch_suspend(self->_inquireTimer);//温控器未打开时不轮询室温等
            }
            
            self.thermostatView.image = [UIImage imageNamed:@"thermostatKnob"];
            self.thermostatView.userInteractionEnabled = YES;
            self.panGest.enabled = NO;

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
                [self.modeButton setImage:[UIImage imageNamed:@"img_auto_off"] forState:UIControlStateNormal];
                [self.modeButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
                [self.modeButton setTitle:LocalString(@"自动") forState:UIControlStateNormal];
            }else{
                [self.modeButton setImage:[UIImage imageNamed:@"img_manual_off"] forState:UIControlStateNormal];
                [self.modeButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
                [self.modeButton setTitle:LocalString(@"手动") forState:UIControlStateNormal];
            }
            
            self.modeButton.enabled = NO;
            self.timeButton.enabled = NO;
            self.setButton.enabled = NO;
            
            for (UIImageView *circle in self.circleView.subviews) {
                if (circle.tag == 2000) {
                    //max min 图片
                    continue;
                }
                circle.image = [UIImage imageNamed:@"thermostatCircle_off"];
            }
        }
    });
    
}

//根据设置温度改变仪表UI
- (void)updateModeTempUI{
    self.thermostatView.transform = CGAffineTransformMakeRotation((-30.f + [self.device.modeTemp floatValue]/(30.f/8)*30.f) / 180 * M_PI);//旋转

    //根据温度设置UI上圆圈颜色
    float needDiscolorationCircleCount = [self.device.modeTemp floatValue]/(30.f/8);//除以一个间隔的温度
    for (UIImageView *circle in self.circleView.subviews) {
        if (circle.tag == 2000) {
            //max min 图片
            continue;
        }
        if (circle.tag <= (1000+needDiscolorationCircleCount)) {
            circle.image = [UIImage imageNamed:@"thermostatCircle_on"];
        }else{
            circle.image = [UIImage imageNamed:@"thermostatCircle_off"];
        }
    }
}

//仪表旋转手势
- (void)panView:(UIPanGestureRecognizer *)panGest{
    //获得移动中的点
    CGPoint currentTouchPoint = [panGest locationInView:self.view];
    
    CGPoint center = self.thermostatView.center;
    
    // 这句由当前点到中心点连成的线段与x轴的夹角从而获取触摸的点的位置(point)
    CGFloat angleInRadians = AngleFromNorth(center, currentTouchPoint, NO);
    NSLog(@"%f",angleInRadians);
    
    if (angleInRadians > M_PI/6 && angleInRadians < M_PI*5/6) {
        if (UIGestureRecognizerStateMovedTemp > 20.f) {
            angleInRadians = M_PI/6;//设置为30.0摄氏度
        }else if (UIGestureRecognizerStateMovedTemp < 10.f){
            angleInRadians = M_PI*5/6;//设置为0.0摄氏度
        }
    }

    float temp = (30.f/8/(M_PI/6)) * (angleInRadians - M_PI + M_PI/6);
    if (angleInRadians - M_PI + M_PI/6 < 0) {
        //x轴下方是正的值，在AngleFromNorth函数中没有加2M_PI，所以在这里右下圆弧angleInRadians - M_PI + M_PI/6是负的，左下刚好到0，右下的需要特殊处理，加上2M_PI
        temp = (30.f/8/(M_PI/6)) * (angleInRadians + 2*M_PI - M_PI + M_PI/6);
    }
    
    //温度间隔是0.5，所以先乘2取整再除回来，可以有.5
    int tempFloor = floor(temp * 2);
    temp = tempFloor/2.f;
    
    UIGestureRecognizerStateMovedTemp = temp;//存储下来用来判断此时应该设置为30还是0摄氏度
    
    self.statusLabel.attributedText = [self generateStringByTemperature:temp currentTemp:[self.device.indoorTemp floatValue]];//显示设置的温度
    self.thermostatView.transform = CGAffineTransformMakeRotation(angleInRadians - M_PI);//旋转,减M_PI是因为图片是朝向左的，x轴是朝右的，所以将角度减M_PI
    //更新圆圈颜色
    float needDiscolorationCircleCount = temp/(30.f/8);//除以一个间隔的温度
    for (UIImageView *circle in self.circleView.subviews) {
        if (circle.tag == 2000) {
            //max min 图片
            continue;
        }
        if (circle.tag <= (1000+needDiscolorationCircleCount)) {
            circle.image = [UIImage imageNamed:@"thermostatCircle_on"];
        }else{
            circle.image = [UIImage imageNamed:@"thermostatCircle_off"];
        }
    }

    if (panGest.state == UIGestureRecognizerStateBegan) {
        
    }else if (panGest.state == UIGestureRecognizerStateEnded){
        self.device.modeTemp = [NSNumber numberWithFloat:temp];//设置后可以发送设置帧
    }else{
        
    }
}

//计算手势滑动的角度
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    //求单位向量
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);//返回的是原点至点(x,y)的方位角，即与 x 轴的夹角
    result = radians;
    return (result >= 0 ? result : result + 2*M_PI);//负的加2M_PI，即左边从5/6M_PI开始逐步增加到2M_PI，最右边下面30度为0到1/6M_PI
}

//查询室内温度
- (void)inquireModeAndIndoorTempAndModeTemp{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x12,@0x03,@0x00];
    if (self.device.isShare) {
        [[Network shareNetwork] sendData69With:controlCode shareDevice:self.device data:data failure:nil];
    }else{
        [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data failuer:nil];
    }
}

#pragma mark - Actions
- (void)modeSwitchAction{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x12,@0x05,@0x01,[NSNumber numberWithBool:![self.device.mode boolValue]]];
    if (self.device.isShare) {
        [[Network shareNetwork] sendData69With:controlCode shareDevice:self.device data:data failure:nil];
    }else{
        [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data failuer:nil];
    }
}

- (void)moreSetting{
    DeviceSettingController *setVC = [[DeviceSettingController alloc] init];
    setVC.device = self.device;
    [self.navigationController pushViewController:setVC animated:YES];
}

- (void)addManualTemp{
    CGFloat temp = [self.device.modeTemp floatValue];
    if (temp == 30.f) {
        [NSObject showHudTipStr:LocalString(@"最高只能30℃哦～～")];
        return;
    }
    temp = temp + 0.5;
    self.device.modeTemp = [NSNumber numberWithFloat:temp];
    NSLog(@"%@",self.device.modeTemp);
    self.statusLabel.attributedText = [self generateStringByTemperature:[self.device.modeTemp floatValue] currentTemp:[self.device.indoorTemp floatValue]];
    [self updateModeTempUI];
}

- (void)minusManualTemp{
    CGFloat temp = [self.device.modeTemp floatValue];
    if (temp == 5.f) {
        [NSObject showHudTipStr:LocalString(@"最低只能5℃哦～～")];
        return;
    }
    temp = temp - 0.5;
    self.device.modeTemp = [NSNumber numberWithFloat:temp];
    self.statusLabel.attributedText = [self generateStringByTemperature:[self.device.modeTemp floatValue] currentTemp:[self.device.indoorTemp floatValue]];
    [self updateModeTempUI];
}

- (void)enableSetTemp{
    if ([self.device.modeTemp floatValue] != nowSetTemp && self.device.modeTemp && self.device.mode) {
        NSLog(@"%@",self.device.modeTemp);
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFE,@0x12,@0x03,@0x01,self.device.mode,[NSNumber numberWithFloat:[self.device.modeTemp floatValue]*2]];
        if (self.device.isShare) {
            [[Network shareNetwork] sendData69With:controlCode shareDevice:self.device data:data failure:nil];
        }else{
            [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data failuer:nil];
        }
        
        nowSetTemp = [self.device.modeTemp floatValue];
    }
}

- (void)timingAction{
    ThermostatTimerController *timerVC = [[ThermostatTimerController alloc] init];
    [self.navigationController pushViewController:timerVC animated:YES];
}

- (void)controlThermostat{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x12,@0x01,@0x01,[NSNumber numberWithBool:![self.device.isOn boolValue]]];
    if (self.device.isShare) {
        [[Network shareNetwork] sendData69With:controlCode shareDevice:self.device data:data failure:nil];
    }else{
        [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data failuer:nil];
    }
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

#pragma mark - NSNotification
- (void)refreshDevice{
    [self UITransformationByStatus];
}

- (void)getSetBackModeTemp:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSLog(@"%@",[userInfo objectForKey:@"modeTemp"]);
    nowSetTemp = [[userInfo objectForKey:@"modeTemp"] floatValue];
}

#pragma mark - Lazy load
- (void)initTimer{
    if (!_sendTimer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _sendTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_sendTimer, dispatch_walltime(NULL, 0), 1.f * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_sendTimer, ^{
            [self enableSetTemp];
        });
        dispatch_resume(_sendTimer);
    }
    if (!_inquireTimer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _inquireTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_inquireTimer, dispatch_walltime(NULL, 0), 120.f * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_inquireTimer, ^{
            [self inquireModeAndIndoorTempAndModeTemp];
        });
        if ([self.device.isOn intValue]) {
            dispatch_resume(_inquireTimer);
            isInquireTimerSuspend = NO;
        }else{
            dispatch_suspend(_inquireTimer);
            isInquireTimerSuspend = YES;
        }
    }
}

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
        //[_thermostatView sizeToFit];
        [self.view addSubview:_thermostatView];
        [_thermostatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200.f, 200.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(yAutoFit(150.f));
        }];
        
        _thermostatView.transform = CGAffineTransformMakeRotation(-30.f / 180 * M_PI);
        
        _thermostatView.userInteractionEnabled = YES;
        //_thermostatView.multipleTouchEnabled = YES;

        //初始化一个拖拽手势
        _panGest = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panView:)];
        _panGest.enabled = NO;
        [_thermostatView addGestureRecognizer:_panGest];
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
        _statusLabel.userInteractionEnabled = YES;
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
            make.right.equalTo(self.controlButton.mas_left).offset(-20.f);
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
    if (0) {
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
            make.centerX.equalTo(self.view.mas_centerX);
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
        maxImage.tag = 2000;
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
        minImage.tag = 2000;
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


@end
