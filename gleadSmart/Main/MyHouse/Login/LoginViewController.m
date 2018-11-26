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
@interface LoginViewController () <UITextFieldDelegate>

//@property (nonatomic, strong) UIImageView *headerImage;
@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UITextField *verifyTF;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *verifyLoginBtn;
@property (nonatomic, strong) UIButton *verifyBtn;
@property (nonatomic, strong) UIButton *passwordLoginBtn;
@property (nonatomic, strong) UIButton *forgetPWBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
        //_headerImage = [self headerImage];
          _phoneTF = [self phoneTF];
          _verifyTF = [self passwordTF];
          _verifyBtn = [self verifyBtn];
          _loginBtn = [self loginBtn];
          _verifyLoginBtn = [self verifyLoginBtn];
          _passwordLoginBtn =[self passwordLoginBtn];
          _forgetPWBtn = [self forgetPWBtn];
    
}
- (UITextField *)phoneTF{
    if (!_phoneTF) {
        _phoneTF = [[UITextField alloc] init];
        _phoneTF.backgroundColor = [UIColor clearColor];
        _phoneTF.font = [UIFont systemFontOfSize:15.f];
        _phoneTF.placeholder = LocalString(@"请输入手机号");
        //_phoneTF.tintColor = [UIColor colorWithHexString:@"333333"];
        _phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _phoneTF.delegate = self;
        _phoneTF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        _phoneTF.borderStyle = UITextBorderStyleRoundedRect;
        //_phoneTF.layer.borderColor = [UIColor colorWithRed:<#(CGFloat)#> green:<#(CGFloat)#> blue:<#(CGFloat)#> alpha:<#(CGFloat)#>]
        _phoneTF.layer.cornerRadius = 80.f;
        [_phoneTF addTarget:self action:@selector(textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_phoneTF];
        __weak typeof (self) weakSelf = self;//防止循环使用
        [_phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
                //手机号text约束
            make.top.equalTo(weakSelf.view.mas_top).offset(300);//距离上面200px
            make.left.equalTo(weakSelf.view.mas_left).offset(45);//距离左边45px
            make.right.equalTo(weakSelf.view.mas_right).offset(-46); //距离右边46px
        }];
        
    }
    return _phoneTF;
}
- (UITextField *)passwordTF{
    if (!_verifyTF) {
        _verifyTF = [[UITextField alloc] init];
        _verifyTF.backgroundColor = [UIColor clearColor];
        _verifyTF.font = [UIFont systemFontOfSize:15.f];
        //_verifyTF.tintColor = [UIColor blackColor];
        _verifyTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _verifyTF.autocorrectionType = UITextAutocorrectionTypeNo;
        //_verifyTF.delegate = self;
        _verifyTF.secureTextEntry = YES;
        _verifyTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _verifyTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _verifyTF.borderStyle = UITextBorderStyleRoundedRect;
        _verifyTF.layer.cornerRadius = 200.f;
        _verifyTF.placeholder = LocalString(@"请输入验证码");
        [_verifyTF addTarget:self action:@selector(textFieldTextChange) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_verifyTF];
        [_verifyTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.phoneTF.mas_bottom).offset(20);//view2距离view1的下面20px
            make.left.equalTo(self.view.mas_left).offset(45);//距离左边45px
            make.right.equalTo(self.view.mas_right).offset(-128); //距离右边46px
        }];
        
          //  UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18/WScale, 0)];
          //  _passwordTF.leftView = paddingView;
          // _passwordTF.leftViewMode = UITextFieldViewModeAlways;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake( 192 ,350 , 1,30)];
        line.backgroundColor = [UIColor blueColor];
        [self.view addSubview:line];
    }
    return _verifyTF;
}
//监听文本框事件
- (void)textFieldTextChange{
    if (_phoneTF.text.length >0 && self.passwordTF.text > 0){
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        _loginBtn.enabled = YES;
    }else{
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _loginBtn.enabled = NO;
    }
}
- (UIButton *)verifyBtn{
    if (!_verifyBtn) {
        _verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_verifyBtn setTitle:LocalString(@"获取验证码") forState:UIControlStateNormal];
        [_verifyBtn.titleLabel setFont:[UIFont systemFontOfSize:10.f]];
        [_verifyBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_verifyBtn addTarget:self action:@selector(getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_verifyBtn];
        [_verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 10));
            make.left.equalTo(self.view.mas_left).offset(190);//距离左边160px
            make.right.equalTo(self.view.mas_right).offset(-50);
            make.centerY.equalTo(self.verifyTF.mas_centerY);
        }];
    }
    return _verifyBtn;
}
- (UIButton *)loginBtn{
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:LocalString(@"登录") forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        [_loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        _loginBtn.layer.borderWidth = 0.5;
       //_loginBtn.layer.borderColor = [UIColor colorWithHexString:@"4778CC"].CGColor;
        _loginBtn.layer.cornerRadius = 1.f;
        _loginBtn.enabled = YES;
        [self.view addSubview:_loginBtn];
        [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordTF.mas_bottom).offset(30);//view2距离view1的下面30px
            make.left.equalTo(self.view.mas_left).offset(46);//距离左边46px
            make.right.equalTo(self.view.mas_right).offset(-46); //距离右边46px
        }];
    }
    return _loginBtn;
}
- (UIButton *)passwordLoginBtn{
    if (!_passwordLoginBtn) {
        _passwordLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_passwordLoginBtn setTitle:LocalString(@"密码登录") forState:UIControlStateNormal];
        [_passwordLoginBtn.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
        [_passwordLoginBtn setBackgroundColor:[UIColor blueColor]];
        // [_passwordLoginBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_passwordLoginBtn addTarget:self action:@selector(passwordLogin) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_passwordLoginBtn];
        [_passwordLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(54, 13));
            make.left.equalTo(self.view.mas_left).offset(87);//距离左边87px
            //make.left.equalTo(self.loginBtn.mas_left);
            make.top.equalTo(self.loginBtn.mas_bottom).offset(20);
        }];
    }
    return _passwordLoginBtn;
}
- (UIButton *) forgetPWBtn{
    if (!_forgetPWBtn) {
        _forgetPWBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgetPWBtn setTitle:LocalString(@"忘记密码") forState:UIControlStateNormal];
        [_forgetPWBtn.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
        [_forgetPWBtn setBackgroundColor:[UIColor blueColor]];
       // [_forgetPWBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
        [_forgetPWBtn addTarget:self action:@selector(forgetPW) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_forgetPWBtn];
        [_forgetPWBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(54, 13));
            make.right.equalTo(self.view.mas_right).offset(-87); //距离右边87px
           // make.right.equalTo(self.loginBtn.mas_right);
            make.top.equalTo(self.loginBtn.mas_bottom).offset(20);
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
    MainViewController *MainVC = [[MainViewController alloc] init];
    [self presentViewController:MainVC animated:YES completion:^{
    }];
}

- (void)verifyLogin{
//        LoginViewController *loginVC = [[LoginViewController alloc] init];
//        [loginVC setModalTransitionStyle:(UIModalTransitionStyleCoverVertical)];
//        [self presentViewController:loginVC animated:YES completion:nil];
        [UIView animateWithDuration:2.0 animations:^{
            self.passwordLoginBtn.alpha = 0.0;
            self.verifyTF.alpha = 1.0;
            //self.verifyBtn.alpha = 1.0;
        }];
}
- (void)passwordLogin{
     _verifyLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
     [_verifyLoginBtn setTitle:LocalString(@"验证码登录") forState:UIControlStateNormal];
     [_verifyLoginBtn.titleLabel setFont:[UIFont systemFontOfSize:13.f]];
     [_verifyLoginBtn setBackgroundColor:[UIColor blueColor]];
     // [_verifyLoginBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
     [_verifyLoginBtn addTarget:self action:@selector(verifyLogin) forControlEvents:UIControlEventTouchUpInside];
     [_passwordLoginBtn removeFromSuperview];
     [_verifyBtn removeFromSuperview];
    
     _verifyTF.placeholder = LocalString(@"请输入密码");
     [self.view addSubview:_verifyLoginBtn];
     [_verifyLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
     make.size.mas_equalTo(CGSizeMake(67, 13));
     make.left.equalTo(self.view.mas_left).offset(73);//距离左边73px
     make.top.equalTo(self.loginBtn.mas_bottom).offset(20);
     }];
}
- (void)forgetPW{
    RetrievePasswordController *RetrieveVC = [[RetrievePasswordController alloc] init];
    [RetrieveVC setModalTransitionStyle:(UIModalTransitionStyleFlipHorizontal)];
    [self presentViewController:RetrieveVC animated:YES completion:nil];
}
- (void)getVerifyCode{
//    if (self.BtnBlock) {
//        BOOL result = self.BtnBlock();
//        if (result) {
//            [self openCountdown];
//        }
//    }
    [self openCountdown];
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
                [self.verifyBtn sizeToFit];
                //[self.verifyBtn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
                //[_verifyBtn setButtonStyleWithColor:[UIColor blackColor] Width:1.f cornerRadius:5.f];
                self.verifyBtn.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [self.verifyBtn setTitle:[NSString stringWithFormat:@"%2ds", seconds] forState:UIControlStateNormal];
                [self.verifyBtn sizeToFit];
                [self.verifyBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                //[_verifyBtn setButtonStyleWithColor:[UIColor lightGrayColor] Width:1.f cornerRadius:5.f];
                self.verifyBtn.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}
@end

