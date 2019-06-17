//
//  PlugOutletElectricityDetailsController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/6/17.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "PlugOutletElectricityCurveView.h"
#import "DeviceSettingController.h"

@interface PlugOutletElectricityCurveView () 

@property (strong, nonatomic) UIView *electricityBackgroundView;
@property (strong, nonatomic) UIImageView *electricityImage;
@property (strong, nonatomic) UILabel *degreeLabel;

@property (strong, nonatomic) UILabel *rightElectricityLabel;

@end

@implementation PlugOutletElectricityCurveView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.backgroundColor = [UIColor colorWithHexString:@"EAE9E8"].CGColor;
    [self setNavItem];
    
    self.electricityBackgroundView = [self electricityBackgroundView];
    self.electricityImage = [self electricityImage];
    self.degreeLabel = [self degreeLabel];
    self.rightElectricityLabel = [self rightElectricityLabel];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - private methods

- (void)goSetting{
    DeviceSettingController *VC = [[DeviceSettingController alloc] init];
    VC.device = self.device;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - getters and setters

- (void)setNavItem{
    self.navigationItem.title = LocalString(@"电量详情");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"thermostatMoer"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UIView *)electricityBackgroundView{
    if (!_electricityBackgroundView) {
        _electricityBackgroundView = [[UIView alloc] init];
        _electricityBackgroundView.backgroundColor = [UIColor colorWithRed:130/255.0 green:181/255.0 blue:244/255.0 alpha:1.0];
        [self.view addSubview:_electricityBackgroundView];
        [_electricityBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, yAutoFit(238.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(20.f);
            
        }];
    }
    return _electricityBackgroundView;
}

- (UIImageView *)electricityImage{
    if (!_electricityImage) {
        _electricityImage = [[UIImageView alloc] init];
        _electricityImage.image = [UIImage imageNamed:@"currenttemperature"];
        [self.electricityBackgroundView addSubview:_electricityImage];
        [_electricityImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(158.f), yAutoFit(147.f)));
            make.centerX.equalTo(self.electricityBackgroundView.mas_centerX);
            make.centerY.equalTo(self.electricityBackgroundView.mas_centerY).offset(-yAutoFit(15.f));
        }];
    }
    return _electricityImage;
}

- (UILabel *)rightElectricityLabel{
    if (!_rightElectricityLabel) {
        _rightElectricityLabel = [[UILabel alloc] init];
        _rightElectricityLabel.text = [NSString stringWithFormat:@"%@%@",self.month,@"月份电量(度)"];
        _rightElectricityLabel.textAlignment = NSTextAlignmentCenter;
        _rightElectricityLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:254/255.0 alpha:1];
        _rightElectricityLabel.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        [self.electricityBackgroundView addSubview:_rightElectricityLabel];
        [_rightElectricityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), yAutoFit(13.f)));
            make.top.equalTo(self.electricityBackgroundView.mas_top).offset(yAutoFit(20.f));
            make.right.equalTo(self.electricityBackgroundView.mas_right).offset(-yAutoFit(15.f));
        }];
    }
    return _rightElectricityLabel;
}

- (UILabel *)degreeLabel{
    if (!_degreeLabel) {
        _degreeLabel = [[UILabel alloc] init];
        _degreeLabel.textAlignment = NSTextAlignmentCenter;
        _degreeLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:254/255.0 alpha:1];
        _degreeLabel.font = [UIFont fontWithName:@"Helvetica" size:30.f];
        _degreeLabel.adjustsFontSizeToFitWidth = YES;
        _degreeLabel.text = [NSString stringWithFormat:@"%.2f",[self.monthElectricity floatValue]];
        [self.electricityBackgroundView addSubview:_degreeLabel];
        [_degreeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(30.f)));
            make.centerX.equalTo(self.electricityImage.mas_centerX);
            make.centerY.equalTo(self.electricityImage.mas_centerY);
        }];
    }
    return _degreeLabel;
}

@end
