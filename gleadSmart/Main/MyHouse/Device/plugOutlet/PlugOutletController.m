//
//  PlugOutletController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/3/29.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "PlugOutletController.h"
#import "PlugOutletSettingController.h"
@interface PlugOutletController ()

@property (strong, nonatomic) UIButton *timeButton;
@property (strong, nonatomic) UIButton *delayButton;
@property (strong, nonatomic) UIButton *electricityButton;

@end

@implementation PlugOutletController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithHexString:@"EDEDEC"].CGColor;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"二维码"] forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goManage)			 forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;

    self.timeButton = [self timeButton];
    self.delayButton = [self delayButton];
    self.electricityButton = [self electricityButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

#pragma mark - setters and getters
- (UIButton *)timeButton{
    if (!_timeButton) {
        _timeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_timeButton setTitle:LocalString(@"定时") forState:UIControlStateNormal];
        [_timeButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [_timeButton setImage:[UIImage imageNamed:@"img_manual_off"] forState:UIControlStateNormal];
        [_timeButton.imageView sizeThatFits:CGSizeMake(51.f, 51.f)];
        _timeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.f];
        [_timeButton addTarget:self action:@selector(modeSwitchAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_timeButton];
        [_timeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 72));
            make.right.equalTo(self.delayButton.mas_left).offset(-20.f);
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

- (UIButton *)delayButton{
    if (!_delayButton) {
        _delayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_delayButton setTitle:LocalString(@"延时") forState:UIControlStateNormal];
        [_delayButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [_delayButton setImage:[UIImage imageNamed:@"thermostatControl"] forState:UIControlStateNormal];
        [_delayButton.imageView sizeThatFits:CGSizeMake(51.f, 51.f)];
        _delayButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.f];
        [_delayButton addTarget:self action:@selector(controlThermostat) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_delayButton];
        [_delayButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51, 72));
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(30.f + ySafeArea_Bottom)));
        }];
        _delayButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
        [_delayButton setTitleEdgeInsets:UIEdgeInsetsMake(_delayButton.imageView.frame.size.height + _delayButton.imageView.frame.origin.y + 15.f, -
                                                            _delayButton.imageView.frame.size.width - 5, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
        [_delayButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -
                                                            _delayButton.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
        
    }
    return _delayButton;
}

- (UIButton *)electricityButton{
    if (!_electricityButton) {
        _electricityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_electricityButton setTitle:LocalString(@"电量") forState:UIControlStateNormal];
        [_electricityButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [_electricityButton setImage:[UIImage imageNamed:@"thermostatSet"] forState:UIControlStateNormal];
        [_electricityButton.imageView sizeThatFits:CGSizeMake(51.f, 51.f)];
        _electricityButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.f];
        [_electricityButton addTarget:self action:@selector(thermostatSetting) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_electricityButton];
        [_electricityButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51.f, 72));
            make.left.equalTo(self.delayButton.mas_right).offset(20.f);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(30.f + ySafeArea_Bottom)));
        }];
        _electricityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
        [_electricityButton setTitleEdgeInsets:UIEdgeInsetsMake(_electricityButton.imageView.frame.size.height + _electricityButton.imageView.frame.origin.y + 15.f, -
                                                        _electricityButton.imageView.frame.size.width - 5, 0.0,0.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
        [_electricityButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -
                                                        _electricityButton.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
        
    }
    return _electricityButton;
}

- (void)goManage{
    PlugOutletSettingController *VC = [[PlugOutletSettingController alloc] init];
    VC.device = self.device;
    [self.navigationController pushViewController:VC animated:YES];
    
}

@end
