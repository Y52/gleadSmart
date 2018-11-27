//
//  RegisterController.m
//  Heating
//
//  Created by Mac on 2018/11/7.
//  Copyright © 2018 Mac. All rights reserved.
//

#import "RegisterController.h"
#import "LoginViewController.h"
#import "RegisterAccountController.h"
#import "MainViewController.h"

@interface RegisterController ()

@property (nonatomic, strong) UIButton *registeNewBtn;
@property (nonatomic, strong) UIButton *registeOldBtn;

@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
    [self setBackground];
    
    //自动登录功能
    [self autoLogin];

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

#pragma mark - Lazy load
- (void)setBackground{
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_launchBG"]];
    backgroundImage.frame = self.view.bounds;
    backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:backgroundImage atIndex:0];
    
    UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_launchTitle"]];
    [self.view addSubview:titleImage];
    [titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(254.f, 50.f));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(yAutoFit(158.f));
    }];
}

- (UIButton *)registeNewBtn{
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
        [self.view addSubview:_registeNewBtn];
        [_registeNewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).with.offset(447);
            make.left.equalTo(self.view).with.offset(53);//距离左边53px
            make.right.equalTo(self.view).with.offset(-53); //距离右边53px
        }];
    }
    return _registeNewBtn;
}

- (UIButton *)registeOldBtn{
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

#pragma mark - Actions
- (void)autoLogin{
    [SVProgressHUD show];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mobile = [userDefaults objectForKey:@"mobile"];
    NSString *password = [userDefaults objectForKey:@"passWord"];
    NSLog(@"%@",mobile);
    NSLog(@"%@",password);
    if (!mobile || !password) {
        [SVProgressHUD dismiss];
        return;
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = @{@"mobile":mobile,@"password":password};
    
    [manager POST:@"http://gleadsmart.thingcom.cn/api/user/login" parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"success:%@",daetr);
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  Database *db = [Database shareInstance];
                  NSDictionary *dic = [responseDic objectForKey:@"data"];
                  UserModel *user = [[UserModel alloc] init];
                  user.userId = [dic objectForKey:@"userId"];
                  db.user = user;
                  [db initDB];
                  db.token = [dic objectForKey:@"token"];
                  
                  if ([[dic objectForKey:@"houses"] count] > 0) {
                      [[dic objectForKey:@"houses"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                          HouseModel *house = [[HouseModel alloc] init];
                          house.houseUid = [obj objectForKey:@"houseUid"];
                          house.name = [obj objectForKey:@"name"];
                          house.auth = [obj objectForKey:@"auth"];
                          [db.houseList addObject:house];
                      }];
                  }
                  if (db.houseList.count > 0) {
                      db.currentHouse = db.houseList[0];
                  }
                  
                  //进入主页面
                  MainViewController *mainVC = [[MainViewController alloc] init];
                  [self presentViewController:mainVC animated:YES completion:nil];
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [SVProgressHUD dismiss];
                  });
              }else{
                  [NSObject showHudTipStr:LocalString(@"自动登录失败")];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [SVProgressHUD dismiss];
                  });
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              if (error.code == -1001) {
                  [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          }];
}

- (void)registeNewUser{
    RegisterAccountController *registVC = [[RegisterAccountController alloc] init];
    [self.navigationController pushViewController:registVC animated:YES];
}

- (void)existingAccountLogin
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    //[loginVC setModalTransitionStyle:(UIModalTransitionStyleCoverVertical)];
    [self presentViewController:loginVC animated:YES completion:^{
        
    }];
}

@end
