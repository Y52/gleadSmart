//
//  LoginViewController.m
//  Heating
//
//  Created by Mac on 2018/11/7.
//  Copyright © 2018 Mac. All rights reserved.
//
#import "LoginViewController.h"
#import "PasswordLoginController.h"
#import "RegisterController.h"
#import "RetrievePasswordController.h"
#import "SelectDeviceTypeController.h"
#import "MainViewController.h"
#import "NoHouseBridgingController.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) dispatch_source_t timer;

@property (strong, nonatomic) UITextField *phoneTF;
@property (strong, nonatomic) UITextField *verifyTF;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIButton *verifyBtn;
@property (strong, nonatomic) UIButton *passwordVisiableBtn;
@property (strong, nonatomic) UIButton *changeLoginBtn;
@property (strong, nonatomic) UIButton *forgetPWBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
    [self setBackGroundUI];
    
    _phoneTF = [self phoneTF];
    _verifyTF = [self passwordTF];
    _verifyBtn = [self verifyBtn];
    _loginBtn = [self loginBtn];
    _changeLoginBtn =[self changeLoginBtn];
    _forgetPWBtn = [self forgetPWBtn];

}

#pragma mark - Lazy load
- (void)setBackGroundUI{
    UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_login_header"]];
    headerImage.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:headerImage];
    [headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(yAutoFit(90.f), yAutoFit(90.f)));
        make.top.equalTo(self.view.mas_top).offset(yAutoFit(123.f));
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

- (UITextField *)phoneTF{
    if (!_phoneTF) {
        UIView *phoneview = [[UIView alloc] initWithFrame:CGRectMake(yAutoFit(45.f),yAutoFit(303.f),yAutoFit(286.f),yAutoFit(36.f))];
        phoneview.layer.borderWidth = 1;
        phoneview.backgroundColor = [UIColor clearColor];
        phoneview.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        phoneview.layer.cornerRadius = 22.f;
        [self.view insertSubview:phoneview atIndex:0];
        [phoneview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), 44.f));
            make.top.equalTo(self.view.mas_top).offset(yAutoFit(300.f));
            make.centerX.equalTo(self.view.mas_centerX);
        }];
      
        _phoneTF = [[UITextField alloc] init];
        _phoneTF.backgroundColor = [UIColor clearColor];
        _phoneTF.font = [UIFont systemFontOfSize:14];
        _phoneTF.placeholder = LocalString(@"请输入手机号");
        _phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _phoneTF.keyboardType = UIKeyboardTypePhonePad;
        _phoneTF.delegate = self;
        _phoneTF.borderStyle = UITextBorderStyleNone;
        [phoneview addSubview:_phoneTF];
        [_phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(200.f),yAutoFit(30.f)));
            make.left.equalTo(phoneview.mas_left).offset(yAutoFit(55.f));
            make.centerY.equalTo(phoneview.mas_centerY);
        }];
        
        UIImageView *phoneleftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_login_phone"]];
        phoneleftImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:phoneleftImage];
        [phoneleftImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(15.f), yAutoFit(15.f)));
            make.left.equalTo(phoneview.mas_left).offset(yAutoFit(18.f));
            make.centerY.equalTo(phoneview.mas_centerY);
        }];
    
    }
    return _phoneTF;
}

- (UITextField *)passwordTF{
    if (!_verifyTF) {
       UIView *verifyTFView = [[UIView alloc] initWithFrame:CGRectMake(yAutoFit(45.f),yAutoFit(367.f),yAutoFit(286.f),yAutoFit(36.f))];
        verifyTFView.layer.borderWidth = 1;
        verifyTFView.backgroundColor = [UIColor clearColor];
        verifyTFView.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        verifyTFView.layer.cornerRadius = 22.f;
        [self.view insertSubview:verifyTFView atIndex:0];
        [verifyTFView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), 44.f));
            make.top.equalTo(self.view.mas_top).offset(yAutoFit(367.f));
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(yAutoFit(249),yAutoFit(369), yAutoFit(1),yAutoFit(30))];
        line.backgroundColor = [UIColor colorWithRed:99/255.0 green:144/255.0 blue:209/255.0 alpha:1.0];
        [verifyTFView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(1.f, 40.f));
            make.centerY.equalTo(verifyTFView.mas_centerY);
            make.right.equalTo(verifyTFView.mas_right).offset(-yAutoFit(80.f));
        }];
        
        _verifyTF = [[UITextField alloc] init];
        _verifyTF.backgroundColor = [UIColor clearColor];
        _verifyTF.font = [UIFont systemFontOfSize:14];
        _verifyTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _verifyTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _verifyTF.delegate = self;
        _verifyTF.secureTextEntry = NO;
        _verifyTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _verifyTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _verifyTF.borderStyle = UITextBorderStyleNone;
        _verifyTF.placeholder = LocalString(@"请输入验证码");
        [verifyTFView addSubview:_verifyTF];
        [_verifyTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(130.f),yAutoFit(30.f)));
            make.left.equalTo(verifyTFView.mas_left).offset(yAutoFit(55.f));
            make.centerY.equalTo(verifyTFView.mas_centerY);
        }];

        UIImageView *verifyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_login_password"]];
        verifyImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:verifyImage];
        [verifyImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(15.f), yAutoFit(15.f)));
            make.left.equalTo(verifyTFView.mas_left).offset(yAutoFit(18.f));
            make.centerY.equalTo(verifyTFView.mas_centerY);
        }];
        
        _verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_verifyBtn setTitle:LocalString(@"获取验证码") forState:UIControlStateNormal];
        [_verifyBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_verifyBtn setTitleColor:[UIColor colorWithHexString:@"0465C5"] forState:UIControlStateNormal];
        _verifyBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_verifyBtn addTarget:self action:@selector(getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
        [verifyTFView addSubview:_verifyBtn];
        [_verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80),yAutoFit(44.f)));
            make.right.equalTo(verifyTFView.mas_right);
            make.centerY.equalTo(verifyTFView.mas_centerY);
        }];
        
        _passwordVisiableBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_passwordVisiableBtn setImage:[UIImage imageNamed:@"img_pwd_unvisiable"] forState:UIControlStateNormal];
        [_passwordVisiableBtn addTarget:self action:@selector(passwordVisiableControl) forControlEvents:UIControlEventTouchUpInside];
        _passwordVisiableBtn.tag = yUnselect;//默认隐藏，选择后显示
        _passwordVisiableBtn.hidden = YES;
        [verifyTFView addSubview:_passwordVisiableBtn];
        [_passwordVisiableBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80),yAutoFit(44.f)));
            make.right.equalTo(verifyTFView.mas_right);
            make.centerY.equalTo(verifyTFView.mas_centerY);
        }];
    }
    return _verifyTF;
}

- (UIButton *)loginBtn{
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:LocalString(@"登录") forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0]];
        [_loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        _loginBtn.layer.cornerRadius = 3.f;
        _loginBtn.enabled = YES;
        [self.view addSubview:_loginBtn];
        [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), 42));
            make.top.equalTo(self.verifyTF.mas_bottom).offset(60.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _loginBtn;
}

- (UIButton *)changeLoginBtn{
    if (!_changeLoginBtn) {
        _changeLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeLoginBtn setTitle:LocalString(@"密码登录") forState:UIControlStateNormal];
        [_changeLoginBtn.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
        [_changeLoginBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_changeLoginBtn addTarget:self action:@selector(changeLoginMode) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_changeLoginBtn];
        [_changeLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100.f, 20.f));
            make.centerX.equalTo(self.view.mas_centerX).offset(-ScreenWidth/4);//距离左边87px
            make.top.equalTo(self.loginBtn.mas_bottom).offset(20);
        }];
        
        _changeLoginBtn.tag = yUnselect;//等于当前是验证码登录模式
    }
    return _changeLoginBtn;
}

- (UIButton *)forgetPWBtn{
    if (!_forgetPWBtn) {
        _forgetPWBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgetPWBtn setTitle:LocalString(@"忘记密码") forState:UIControlStateNormal];
        [_forgetPWBtn.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
        [_forgetPWBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_forgetPWBtn addTarget:self action:@selector(forgetPW) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_forgetPWBtn];
        [_forgetPWBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(100.f, 20.f));
            make.centerX.equalTo(self.view.mas_centerX).offset(ScreenWidth/4); //距离右边87px
            make.top.equalTo(self.loginBtn.mas_bottom).offset(20);
        }];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(yAutoFit(187),yAutoFit(500), yAutoFit(1),yAutoFit(30))];
        line.backgroundColor = [UIColor colorWithRed:99/255.0 green:144/255.0 blue:209/255.0 alpha:1.0];
        [self.view addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(1.f, 30.f));
            make.centerX.equalTo(self.view.mas_centerX); //距离右边87px
            make.centerY.equalTo(self.changeLoginBtn.mas_centerY);
        }];
    }
    
    return _forgetPWBtn;
}
    
#pragma mark - uitextfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
    
}

#pragma mark - Actions
- (void)login{
    if (![NSString validateMobile:self.phoneTF.text] || self.verifyTF.text.length == 0){
        [NSObject showHudTipStr:LocalString(@"请输入正确的账号密码")];
        return;
    }
    
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = [[NSDictionary alloc] init];
    NSString *url = [[NSString alloc] init];
    if (_changeLoginBtn.tag == yUnselect){
        parameters = @{@"mobile":self.phoneTF.text,@"code":self.verifyTF.text};
        url = [NSString stringWithFormat:@"%@/api/user/login/code",httpIpAddress];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
        
    }else{
        parameters = @{@"mobile":self.phoneTF.text,@"password":self.verifyTF.text};
        url = [NSString stringWithFormat:@"%@/api/user/login",httpIpAddress];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    }
    
    

    
    [manager POST:url parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData *data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString *daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"success:%@",daetr);
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  //获取userID和token
                  NSDictionary *dataDic = [responseDic objectForKey:@"data"];
                  Database *data = [Database shareInstance];
                  data.user.userId = [dataDic objectForKey:@"userId"];
                  [data initDB];//初始化单例，数据库等
                  data.token = [dataDic objectForKey:@"token"];
                  
                  //保存数据 用户信息；用户名；用户密码
                  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                  if (self.changeLoginBtn.tag == ySelect) {
                      //如果是密码登录，记录账号密码，验证码登录就无法记录
                      [userDefaults setObject:self.phoneTF.text forKey:@"mobile"];
                      [userDefaults setObject:self.verifyTF.text forKey:@"passWord"];
                      [userDefaults setObject:data.user.userId forKey:@"userId"];
                      [userDefaults synchronize];
                  }
                  
                  //获取家庭列表和信息，每次登录更新数据库
                  if ([[dataDic objectForKey:@"houses"] count] > 0) {
                      NSMutableArray *localHouseArr = [data queryAllHouse];
                      [[dataDic objectForKey:@"houses"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
                          [data insertNewHouse:house];
                          
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
                          [data deleteHouse:localHouse.houseUid];
                      }
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [SVProgressHUD dismiss];
                  });
                  
                  data.houseList = [data queryAllHouse];
                  if (data.houseList.count > 0) {
                      //选择第一个家庭为当前家庭
                      data.currentHouse = data.houseList[0];
                  }
                  
                  //RabbitMQ topic routingkeys生成
                  NSMutableArray *routingkeys = [[NSMutableArray alloc] init];
                  for (HouseModel *house in data.houseList) {
                      NSString *routingkey = [NSString stringWithFormat:@"%@.%@",data.user.userId,house.houseUid];
                      [routingkeys addObject:routingkey];
                  }
                  [[YRabbitMQ shareInstance] receiveRabbitMessage:routingkeys];
                  
                  if (data.houseList.count <= 0) {
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

              }else{
                  [NSObject showHudTipStr:LocalString(@"登录失败，请检查验证码或者密码是否填写错误")];
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
          }
     ];
    
}

- (void)changeLoginMode{
    if (_changeLoginBtn.tag == yUnselect) {
        _changeLoginBtn.tag = ySelect;
        [_changeLoginBtn setTitle:LocalString(@"验证码登录") forState:UIControlStateNormal];

        _verifyTF.placeholder = LocalString(@"请输入密码");
        _passwordVisiableBtn.hidden = NO;
        _verifyBtn.hidden = YES;
        _verifyTF.secureTextEntry = YES;
        _verifyTF.text = @"";
    }else{
        _changeLoginBtn.tag = yUnselect;
        [_changeLoginBtn setTitle:LocalString(@"密码登录") forState:UIControlStateNormal];

        _verifyTF.placeholder = LocalString(@"请输入验证码");
        _passwordVisiableBtn.hidden = YES;
        _verifyBtn.hidden = NO;
        _verifyTF.secureTextEntry = NO;
        _verifyTF.text = @"";
    }
}

- (void)passwordVisiableControl{
    if (_passwordVisiableBtn.tag == yUnselect) {
        _passwordVisiableBtn.tag = ySelect;
        [_passwordVisiableBtn setImage:[UIImage imageNamed:@"img_pwd_visiable"] forState:UIControlStateNormal];
        _verifyTF.secureTextEntry = NO;
    }else{
        _passwordVisiableBtn.tag = yUnselect;
        [_passwordVisiableBtn setImage:[UIImage imageNamed:@"img_pwd_unvisiable"] forState:UIControlStateNormal];
        _verifyTF.secureTextEntry = YES;
    }
}

- (void)forgetPW{
    RetrievePasswordController *RetrieveVC = [[RetrievePasswordController alloc] init];
    [RetrieveVC setModalTransitionStyle:(UIModalTransitionStyleFlipHorizontal)];
    [self presentViewController:RetrieveVC animated:YES completion:nil];
}

//获取验证码
- (void)getVerifyCode{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url;
    if ([NSString validateMobile:self.phoneTF.text]){
        url = [NSString stringWithFormat:@"%@/api/util/sms?mobile=%@",httpIpAddress,self.phoneTF.text];
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    }else {
        [NSObject showHudTipStr:LocalString(@"手机号码不正确")];
        return;
    }
    
    [manager GET:url parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
             NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
             NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"success:%@",daetr);
             if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                 [self openCountdown];
                 [NSObject showHudTipStr:LocalString(@"已向您的手机发送验证码")];
             }else{
                 [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error:%@",error);
             [NSObject showHudTipStr:LocalString(@"操作失败")];
             
         }
     ];
}

//开始倒计时
-(void)openCountdown{
    
    __block NSInteger time = 59; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(self.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                [self.verifyBtn setTitle:@"重新发送" forState:UIControlStateNormal];
                self.verifyBtn.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [self.verifyBtn setTitle:[NSString stringWithFormat:@"%2ds", seconds] forState:UIControlStateNormal];
                self.verifyBtn.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}
@end

