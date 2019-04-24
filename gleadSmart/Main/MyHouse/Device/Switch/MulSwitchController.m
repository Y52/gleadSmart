//
//  MulSwitchController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/4/23.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "MulSwitchController.h"

#define buttonGap ((ScreenWidth - 51*4)/5)

@interface MulSwitchController ()
@property (nonatomic, strong) UIView *mulSwitchView;
@property (nonatomic, strong) UIView *mulSwitchCloth;

@property (strong, nonatomic) UIButton *openAllButton;
@property (strong, nonatomic) UIButton *timeButton;
@property (strong, nonatomic) UIButton *delayButton;
@property (strong, nonatomic) UIButton *closeAllButton;

@end

@implementation MulSwitchController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0].CGColor;
    [self setNavItem];

    self.mulSwitchView = [self mulSwitchView];
    self.mulSwitchCloth = [self mulSwitchCloth];
    [self setSwitchUI];
    self.openAllButton = [self openAllButton];
    self.timeButton = [self timeButton];
    //self.delayButton = [self delayButton];不要了
    self.closeAllButton = [self closeAllButton];
    
    [self setBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPlugOutletUI:) name:@"refreshPlugOutletUI" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshPlugOutletUI" object:nil];
}

#pragma mark - private methods

- (void)goSetting{
    
}

- (void)mulSwitchAllOpen{
    
}

- (void)mulSwitchClock{
    
}

- (void)mulSwitchDelay{
    
}

- (void)mulSwitchAllClose{
    
}

- (void)switchClick:(UIButton *)sender{
    if (sender.tag == yUnselect) {
        sender.tag = ySelect;
        [sender setImage:[UIImage imageNamed:@"img_switch1_on"] forState:UIControlStateNormal];
    }else{
        sender.tag = yUnselect;
        [sender setImage:[UIImage imageNamed:@"img_switch1_off"] forState:UIControlStateNormal];
    }
}

#pragma mark - setters & getters
- (void)setBackgroundColor{
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
    [rightButton addTarget:self action:@selector(goSetting) forControlEvents:UIControlEventTouchUpInside];
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

- (UIView *)mulSwitchCloth{
    if (!_mulSwitchCloth) {
        _mulSwitchCloth = [[UIView alloc] init];
        [_mulSwitchView addSubview:_mulSwitchCloth];
        [_mulSwitchCloth mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(270.f), 120.f));
            make.centerX.equalTo(self.mulSwitchView.mas_centerX);
            make.centerY.equalTo(self.mulSwitchView.mas_centerY);
        }];
        
        _mulSwitchCloth.layer.shadowColor = [UIColor colorWithRed:10/255.0 green:46/255.0 blue:84/255.0 alpha:0.66].CGColor;
        _mulSwitchCloth.layer.shadowOffset = CGSizeMake(0,6);
        _mulSwitchCloth.layer.shadowOpacity = 1;
        _mulSwitchCloth.layer.shadowRadius = 25;
        _mulSwitchCloth.layer.cornerRadius = 2.5;

        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_4switch_back"]];
        image.frame = CGRectMake(0, 0, yAutoFit(270.f), 120.f);
        image.contentMode = UIViewContentModeScaleAspectFit;
        [_mulSwitchCloth addSubview:image];
        
    }
    return _mulSwitchCloth;
}

- (void)setSwitchUI{
    for (int i = 0; i < 4; i++) {
        UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        switchButton.frame = CGRectMake(i*(yAutoFit(270.f)/4), 0, yAutoFit(270.f)/4, 120.f);
        switchButton.tag = yUnselect;
        [switchButton setImage:[UIImage imageNamed:@"img_switch1_off"] forState:UIControlStateNormal];
        [switchButton.imageView setClipsToBounds:YES];
        switchButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [switchButton addTarget:self action:@selector(switchClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.mulSwitchCloth addSubview:switchButton];
    }
}

- (UIButton *)openAllButton{
    if (!_openAllButton) {
        _openAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openAllButton setImage:[UIImage imageNamed:@"img_switch_allopen"] forState:UIControlStateNormal];
        [_openAllButton addTarget:self action:@selector(mulSwitchAllOpen) forControlEvents:UIControlEventTouchUpInside];
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
        [_timeButton addTarget:self action:@selector(mulSwitchClock) forControlEvents:UIControlEventTouchUpInside];
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
        [_closeAllButton addTarget:self action:@selector(mulSwitchAllClose) forControlEvents:UIControlEventTouchUpInside];
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
