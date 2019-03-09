//
//  NoHouseBridgingController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/3/8.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "NoHouseBridgingController.h"
#import "NoHouseAddController.h"

@interface NoHouseBridgingController ()

@property (nonatomic, strong) UIButton *addHouseButton;
@property (nonatomic, strong) UIButton *logoutButton;

@end

@implementation NoHouseBridgingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setBackground];
    self.addHouseButton = [self addHouseButton];
    self.logoutButton = [self logoutButton];
}

#pragma mark - private methods
- (void)addHouse{
    NoHouseAddController *addFamilyVC = [[NoHouseAddController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addFamilyVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)logout{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"mobile"];
    [userDefaults removeObjectForKey:@"passWord"];
    [userDefaults removeObjectForKey:@"userId"];
    //清除单例
    [Network destroyInstance];
    [Database destroyInstance];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setters and getters
- (void)setBackground{
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_launchTitle"]];
    [self.view addSubview:titleImage];
    [titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(254.f, 50.f));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(yAutoFit(158.f));
    }];
}

- (UIButton *)addHouseButton{
    if (!_addHouseButton) {
        _addHouseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addHouseButton setTitle:LocalString(@"创建家庭") forState:UIControlStateNormal];
        [_addHouseButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_addHouseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addHouseButton setBackgroundColor:[UIColor colorWithHexString:@"4778CC"]];
        [_addHouseButton addTarget:self action:@selector(addHouse) forControlEvents:UIControlEventTouchUpInside];
        _addHouseButton.layer.cornerRadius = 5.f;
        [self.view addSubview:_addHouseButton];
        [_addHouseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), 44.f));
            make.bottom.equalTo(self.view.mas_bottom).offset(-160.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _addHouseButton;
}

- (UIButton *)logoutButton{
    if (!_logoutButton) {
        _logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_logoutButton setTitle:LocalString(@"退出登录") forState:UIControlStateNormal];
        [_logoutButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_logoutButton setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_logoutButton setBackgroundColor:[UIColor clearColor]];
        [_logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_logoutButton];
        [_logoutButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), 44.f));
            make.bottom.equalTo(self.view.mas_bottom).offset(-100.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];

    }
    return _logoutButton;
}

@end
