//
//  RegisterController.m
//  Heating
//
//  Created by Mac on 2018/11/7.
//  Copyright © 2018 Mac. All rights reserved.
//

#import "RegisterController.h"
#import "LoginViewController.h"

@interface RegisterController ()

@property (nonatomic, strong) UIButton *registeNewBtn;
@property (nonatomic, strong) UIButton *registeOldBtn;

@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;

        _registeNewBtn = [self registeNewBtn];
        _registeOldBtn = [self registeOldBtn];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setShadowImage:nil];
}
-(UIButton *) registeNewBtn{
    if (!_registeNewBtn) {
        _registeNewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registeNewBtn setTitle:LocalString(@"注册新账号") forState:UIControlStateNormal];
        [_registeNewBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_registeNewBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_registeNewBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:0.4]];
        [_registeNewBtn addTarget:self action:@selector(registeNewUser) forControlEvents:UIControlEventTouchUpInside];
        _registeNewBtn.layer.borderWidth = 1.f;
        _registeNewBtn.layer.borderColor = [UIColor colorWithHexString:@"4778CC"].CGColor;
        _registeNewBtn.layer.cornerRadius = 1.f;
        _registeNewBtn.enabled = NO;
        [self.view addSubview:_registeNewBtn];
        [_registeNewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(447);
            make.left.equalTo(self.view).with.offset(53);//距离左边53px
            make.right.equalTo(self.view).with.offset(-53); //距离右边53px
        }];
    }
    return _registeNewBtn;
}
-(UIButton *) registeOldBtn{
    if (!_registeOldBtn) {
        _registeOldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registeOldBtn setTitle:LocalString(@"已有账户登录") forState:UIControlStateNormal];
        [_registeOldBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_registeOldBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_registeOldBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:0.4]];
        [_registeOldBtn addTarget:self action:@selector(existingAccountLogin) forControlEvents:UIControlEventTouchUpInside];
        _registeOldBtn.layer.borderWidth = 1.f;
        _registeOldBtn.layer.cornerRadius = 1.f;
        _registeOldBtn.enabled = YES;
        [self.view addSubview:_registeOldBtn];
        [_registeOldBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.registeNewBtn.mas_bottom).with.offset(20);
            make.left.equalTo(self.view).with.offset(53);//距离左边53px
            make.right.equalTo(self.view).with.offset(-53); //距离右边53px
        }];
    }
    return _registeOldBtn;
}
- (void)registeNewUser{
   // RegisterController *registVC = [[RegisterController alloc] init];
    //[self.navigationController pushViewController:registVC animated:YES];
    
}
-(void)existingAccountLogin
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [loginVC setModalTransitionStyle:(UIModalTransitionStyleCoverVertical)];
    [self presentViewController:loginVC animated:YES completion:^{
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
