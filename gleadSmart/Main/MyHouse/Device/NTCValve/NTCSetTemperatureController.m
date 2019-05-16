//
//  SetTemperatureController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/25.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "NTCSetTemperatureController.h"

@interface NTCSetTemperatureController () <UITextFieldDelegate>

@property (strong, nonatomic) UIImageView *setheaderImage;
@property (strong, nonatomic) UIView *settemperatureView;
@property (strong, nonatomic) UIImageView *temperatureImage;
@property (strong, nonatomic) UILabel *middletemperatureLabel;
@property (strong, nonatomic) UILabel *currenttemperatureLabel;
@property (strong, nonatomic) UILabel *settemperatureLabel;

@property (strong, nonatomic) UITextField *setTF;
@property (strong, nonatomic) UIButton *sureButton;


@end

@implementation NTCSetTemperatureController{
    BOOL thresholdGeted;
    BOOL thresholdSeted;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithHexString:@"EAE9E8"].CGColor;
    self.navigationItem.title = LocalString(@"设置温度");
    self.setheaderImage = [self setheaderImage];
    self.settemperatureView = [self settemperatureView];
    self.temperatureImage = [self temperatureImage];
    self.middletemperatureLabel = [self middletemperatureLabel];
    self.currenttemperatureLabel = [self currenttemperatureLabel];
    self.settemperatureLabel = [self settemperatureLabel];
    self.setTF = [self setTF];
    self.sureButton = [self sureButton];
    [self getValveTemperature];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    //设置navigationbar隐藏
    self.navigationController.navigationBar.translucent = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getValveThreshold:) name:@"getValveThreshold" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setValveThresholdSucc:) name:@"setValveThresholdSucc" object:nil];

    thresholdGeted = NO;
    thresholdSeted = NO;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setValveThresholdSucc" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getValveThreshold" object:nil];
}

#pragma mark - notification
//水阀温度上报收到通知
- (void)getValveThreshold:(NSNotification *)notification{
    thresholdGeted = YES;
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *threshold = [userInfo objectForKey:@"getThreshold"];
    NSNumber *temp = [userInfo objectForKey:@"temp"];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.middletemperatureLabel.text = [NSString stringWithFormat:@"%d℃",[threshold intValue]];
        self.currenttemperatureLabel.text = [NSString stringWithFormat:@"当前温度：%d℃",[temp intValue]];
    });
    
    [SVProgressHUD dismiss];
}

//水阀设置阈值成功同志
- (void)setValveThresholdSucc:(NSNotification *)notification{
    thresholdSeted = YES;
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *threshold = [userInfo objectForKey:@"setThreshold"];
    dispatch_async(dispatch_get_main_queue(), ^{
       self.middletemperatureLabel.text = [NSString stringWithFormat:@"%d℃",[threshold intValue]];
    });
    
    [SVProgressHUD dismiss];
}

#pragma mark - private methods
- (void)getValveTemperature{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x13,@0x08,@0x00];
    if (self.device.isShare) {
        [[Network shareNetwork] sendData69With:controlCode shareDevice:self.device data:data failure:nil];
    }else{
        [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data failuer:nil];
    }
    
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //异步等待4秒，如果未收到信息做如下处理
        sleep(6);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self->thresholdGeted) {
                [NSObject showHudTipStr:LocalString(@"设置阈值失败")];
                [SVProgressHUD dismiss];
            }
        });
    });
}

- (void)setValveTemperature{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x13,@0x08,@0x01,[NSNumber numberWithFloat:[self.setTF.text floatValue]]];
    if (self.device.isShare) {
        [[Network shareNetwork] sendData69With:controlCode shareDevice:self.device data:data failure:nil];
    }else{
        [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data failuer:nil];
    }
    
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //异步等待4秒，如果未收到信息做如下处理
        sleep(6);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self->thresholdSeted) {
                [NSObject showHudTipStr:LocalString(@"查询当前阈值失败")];
                [SVProgressHUD dismiss];
            }
        });
    });
}

- (void)textFieldTextChange:(UITextField *)textField{
    if (self.setTF.text.length >2) {
        _setTF.text = [_setTF.text substringWithRange:NSMakeRange(0, 2)];
    }
    if ([_setTF.text intValue] >= 35 && [_setTF.text intValue] <= 60){
        _sureButton.enabled = YES;
    }else{
        _sureButton.enabled = NO;
    }
    
}

#pragma mark - getters and setters
- (UIImageView *)setheaderImage{
    if (!_setheaderImage) {
        _setheaderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_headerBg"]];
        [self.view insertSubview:_setheaderImage atIndex:0];
        [_setheaderImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 181.f + getRectNavAndStatusHight));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.mas_topLayoutGuideTop);
        }];
    }
    return _setheaderImage;
}

- (UIView *)settemperatureView{
    if (!_settemperatureView) {
        _settemperatureView = [[UIView alloc] init];
        [self.view addSubview:_settemperatureView];
        [_settemperatureView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth / 3.f, ScreenWidth / 3.f));
            make.centerX.equalTo(self.setheaderImage.mas_centerX);
            make.top.equalTo(self.mas_topLayoutGuideTop).offset(getRectNavAndStatusHight + 20.f);
            
        }];
    }
    return _settemperatureView;
}

- (UIImageView *)temperatureImage{
    if (!_temperatureImage) {
        _temperatureImage = [[UIImageView alloc] init];
        _temperatureImage.image = [UIImage imageNamed:@"currenttemperature"];
        [self.settemperatureView addSubview:_temperatureImage];
        [_temperatureImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(110.f), yAutoFit(100.f)));
            make.centerX.equalTo(self.settemperatureView.mas_centerX);
            make.centerY.equalTo(self.settemperatureView.mas_centerY).offset(-yAutoFit(15.f));
        }];
    }
    return _temperatureImage;
}

- (UILabel *)currenttemperatureLabel{
    if (!_currenttemperatureLabel) {
        _currenttemperatureLabel = [[UILabel alloc] init];
        _currenttemperatureLabel.text = LocalString(@"当前温度：0℃");
        _currenttemperatureLabel.textAlignment = NSTextAlignmentCenter;
        _currenttemperatureLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:254/255.0 alpha:1];
        _currenttemperatureLabel.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        [self.settemperatureView addSubview:_currenttemperatureLabel];
        [_currenttemperatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(120.f), yAutoFit(13.f)));
            make.centerX.equalTo(self.settemperatureView.mas_centerX);
            make.top.equalTo(self.temperatureImage.mas_bottom).offset(yAutoFit(5.f));
        }];
    }
    return _currenttemperatureLabel;
}

- (UILabel *)middletemperatureLabel{
    if (!_middletemperatureLabel) {
        _middletemperatureLabel = [[UILabel alloc] init];
        _middletemperatureLabel.textAlignment = NSTextAlignmentCenter;
        _middletemperatureLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:254/255.0 alpha:1];
        _middletemperatureLabel.font = [UIFont fontWithName:@"Helvetica" size:30.f];
        [self.settemperatureView addSubview:_middletemperatureLabel];
        [_middletemperatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(30.f)));
            make.centerX.equalTo(self.temperatureImage.mas_centerX);
            make.centerY.equalTo(self.temperatureImage.mas_centerY);
        }];
    }
    return _middletemperatureLabel;
}

- (UILabel *)settemperatureLabel{
    if (!_settemperatureLabel) {
        _settemperatureLabel = [[UILabel alloc] init];
        _settemperatureLabel.text = LocalString(@"设置温度:");
        _settemperatureLabel.textAlignment = NSTextAlignmentCenter;
        _settemperatureLabel.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1];
        _settemperatureLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        [self.view addSubview:_settemperatureLabel];
        [_settemperatureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(15.f)));
            make.left.equalTo(self.view.mas_left).offset(yAutoFit(25.f));
            make.centerY.equalTo(self.setTF.mas_centerY);
        }];
    }
    return _settemperatureLabel;
}

- (UITextField *)setTF{
    if (!_setTF) {
        _setTF = [[UITextField alloc] init];
        _setTF.backgroundColor = [UIColor clearColor];
        _setTF.font = [UIFont systemFontOfSize:15.f];
        _setTF.textColor = [UIColor blackColor];
        _setTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _setTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _setTF.delegate = self;
        _setTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _setTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _setTF.borderStyle = UITextBorderStyleRoundedRect;
        _setTF.keyboardType = UIKeyboardTypeNumberPad;
        [_setTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_setTF];
        [_setTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(227.f), yAutoFit(32.f)));
            make.top.equalTo(self.setheaderImage.mas_bottom).offset(yAutoFit(30.f));
            make.left.equalTo(self.settemperatureLabel.mas_right).offset(yAutoFit(5.f));
        }];
        _setTF.layer.borderWidth = 1.0;
        _setTF.layer.borderColor = [UIColor colorWithHexString:@"666666"].CGColor;
        _setTF.layer.cornerRadius = 5.f;
    }
    return _setTF;
}

- (UIButton *)sureButton{
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sureButton setTitle:LocalString(@"确定") forState:UIControlStateNormal];
        [_sureButton.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
        [_sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sureButton setBackgroundColor:[UIColor colorWithRed:97/255.0 green:168/255.0 blue:233/255.0 alpha:1.0]];
        [_sureButton addTarget:self action:@selector(setValveTemperature) forControlEvents:UIControlEventTouchUpInside];
        _sureButton.enabled = NO;
        [self.view addSubview:_sureButton];
        [_sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(262.f),yAutoFit(44.f)));
            make.top.equalTo(self.setTF.mas_bottom).offset(yAutoFit(200.f));
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
        
        _sureButton.layer.borderWidth = 1.0;
        _sureButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _sureButton.layer.cornerRadius = 20.f;
    }
    return _sureButton;
}

@end
