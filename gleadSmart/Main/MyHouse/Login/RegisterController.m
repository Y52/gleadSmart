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
#import "NoHouseBridgingController.h"

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
        [_registeNewBtn setBackgroundColor:[UIColor whiteColor]];
        [_registeNewBtn addTarget:self action:@selector(registeNewUser) forControlEvents:UIControlEventTouchUpInside];
        _registeNewBtn.layer.borderWidth = 1.f;
        _registeNewBtn.layer.borderColor = [UIColor colorWithHexString:@"4778CC"].CGColor;
        _registeNewBtn.layer.cornerRadius = 1.f;
        [self.view addSubview:_registeNewBtn];
        [_registeNewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(270.f), 44.f));
            make.bottom.equalTo(self.registeOldBtn.mas_top).offset(-yAutoFit(30.f));
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
        _registeNewBtn.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.17].CGColor;
        _registeNewBtn.layer.shadowOffset = CGSizeMake(0,2);
        _registeNewBtn.layer.shadowOpacity = 1;
        _registeNewBtn.layer.shadowRadius = 14;
        _registeNewBtn.layer.borderWidth = 0.4;
        _registeNewBtn.layer.borderColor = [UIColor colorWithRed:23/255.0 green:53/255.0 blue:126/255.0 alpha:1.0].CGColor;
        _registeNewBtn.layer.cornerRadius = 5;
    }
    return _registeNewBtn;
}

- (UIButton *)registeOldBtn{
    if (!_registeOldBtn) {
        _registeOldBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registeOldBtn setTitle:LocalString(@"已有账户登录") forState:UIControlStateNormal];
        [_registeOldBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_registeOldBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_registeOldBtn setBackgroundColor:[UIColor whiteColor]];
        [_registeOldBtn addTarget:self action:@selector(existingAccountLogin) forControlEvents:UIControlEventTouchUpInside];
        _registeOldBtn.layer.borderWidth = 1.f;
        _registeOldBtn.layer.cornerRadius = 1.f;
        _registeOldBtn.enabled = YES;
        [self.view addSubview:_registeOldBtn];
        [_registeOldBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(270.f), 44.f));
            make.bottom.equalTo(self.view.mas_bottom).offset(-yAutoFit(100.f)-ySafeArea_Bottom);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
        _registeOldBtn.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.17].CGColor;
        _registeOldBtn.layer.shadowOffset = CGSizeMake(0,2);
        _registeOldBtn.layer.shadowOpacity = 1;
        _registeOldBtn.layer.shadowRadius = 14;
        _registeOldBtn.layer.borderWidth = 0.4;
        _registeOldBtn.layer.borderColor = [UIColor colorWithRed:23/255.0 green:53/255.0 blue:126/255.0 alpha:1.0].CGColor;
        _registeOldBtn.layer.cornerRadius = 5;
    }
    return _registeOldBtn;
}

#pragma mark - Actions
//自动登录功能
- (void)autoLogin{
    [SVProgressHUD show];
    Database *db = [Database shareInstance];
    db.user = [[UserModel alloc] init];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *mobile = [userDefaults objectForKey:@"mobile"];
    NSString *password = [userDefaults objectForKey:@"passWord"];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    NSLog(@"%@",mobile);
    NSLog(@"%@",password);
    if (!mobile || !password) {
        //如果没有保存账号密码，取消自动登录
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
    
    NSString *url = [NSString stringWithFormat:@"%@/api/user/login",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager POST:url parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"success:%@",daetr);
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  NSDictionary *dic = [responseDic objectForKey:@"data"];
                  if ([dic objectForKey:@"userId"]) {
                      db.user.userId = [dic objectForKey:@"userId"];
                  }
                  if ([dic objectForKey:@"mobile"]) {
                      db.user.mobile = [dic objectForKey:@"mobile"];
                  }
                  [db initDB];//初始化单例，数据库等
                  db.token = [dic objectForKey:@"token"];
                  
                  //获取家庭列表和信息，每次登录更新数据库
                  if ([[dic objectForKey:@"houses"] count] > 0) {
                      NSMutableArray *localHouseArr = [db queryAllHouse];
                      [[dic objectForKey:@"houses"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                          HouseModel *house = [[HouseModel alloc] init];
                          house.houseUid = [obj objectForKey:@"houseUid"];
                          house.name = [obj objectForKey:@"name"];
                          house.auth = [obj objectForKey:@"auth"];
                          house.mac = [obj objectForKey:@"mac"];
                          house.apiKey = [obj objectForKey:@"apiKey"];
                          house.deviceId = [obj objectForKey:@"deviceId"];
                          house.lon = [obj objectForKey:@"lon"];
                          house.lat = [obj objectForKey:@"lat"];
                          //本地数据库更新家庭信息
                          [db insertNewHouse:house];
                          
                          for (HouseModel *localHouse in localHouseArr) {
                              if ([localHouse.houseUid isEqualToString:house.houseUid]) {
                                  //存在的移除掉，剩下的就是本地未删除的
                                  [localHouseArr removeObject:localHouse];
                                  break;
                              }
                          }
                      }];
                      for (HouseModel *localHouse in localHouseArr) {
                          //删除掉本地未删除的家庭，做同步
                          [db deleteHouse:localHouse.houseUid];
                      }
                  }
              }else{
                  //自动登录失败，使用本地保存的信息
                  [NSObject showHudTipStr:LocalString(@"自动登录失败")];
                  db.user.userId = userId;
                  [db initDB];
              }
              db.houseList = [db queryAllHouse];
              NSLog(@"%lu",db.houseList.count);
              if (db.houseList.count > 0) {
                  db.currentHouse = db.houseList[0];
              }
              
              //RabbitMQ topic routingkeys生成
              NSMutableArray *routingkeys = [[NSMutableArray alloc] init];
              [routingkeys addObject:db.user.userId];
              for (HouseModel *house in db.houseList) {
                  [routingkeys addObject:house.houseUid];
              }
              [[YRabbitMQ shareInstance] receiveRabbitMessage:routingkeys];

              NSLog(@"%lu",db.houseList.count);
              
              if (db.houseList.count <= 0 && [[responseDic objectForKey:@"errno"] intValue] == 0) {
                  //如果登录失败就不能进入创建家庭页面
                  NoHouseBridgingController *vc = [[NoHouseBridgingController alloc] init];
                  [self presentViewController:vc animated:YES completion:nil];
              }else{
                  //进入主页面
                  MainViewController *mainVC = [[MainViewController alloc] init];
                  [self presentViewController:mainVC animated:YES completion:nil];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Error:%@",error);
              [NSObject showHudTipStr:LocalString(@"无法登录远程服务器，请检查网络状况")];
              
              //从本地获取上次登录用户信息
              db.user.userId = userId;
              [db initDB];
              db.houseList = [db queryAllHouse];
              if (db.houseList.count > 0) {
                  db.currentHouse = db.houseList[db.houseList.count-1];
              }
              
              //进入主页面
              MainViewController *mainVC = [[MainViewController alloc] init];
              [self presentViewController:mainVC animated:YES completion:nil];
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
