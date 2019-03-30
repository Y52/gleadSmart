//
//  UsernameViewController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/2/28.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "UsernameViewController.h"

@interface UsernameViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userNameTF;
@property (nonatomic, strong) UIButton *rightButton;


@end

@implementation UsernameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    [self setNavItem];
    _userNameTF = [self userNameTF];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //[IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"修改昵称");
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"完成") style:UIBarButtonItemStylePlain target:self action:@selector(Done)];
    [rightBar setTintColor:[UIColor colorWithHexString:@"4778CC"]];
    [rightBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.f], NSFontAttributeName,nil] forState:(UIControlStateNormal)];
    self.navigationItem.rightBarButtonItem = rightBar;
    
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"取消") style:UIBarButtonItemStylePlain target:self action:@selector(Cancel)];
    [leftBar setTintColor:[UIColor colorWithHexString:@"222222"]];
    [leftBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.f], NSFontAttributeName,nil] forState:(UIControlStateNormal)];
    self.navigationItem.leftBarButtonItem = leftBar;
}

- (UITextField *)userNameTF{
    if (!_userNameTF) {
        _userNameTF = [[UITextField alloc] init];
        _userNameTF.backgroundColor = [UIColor whiteColor];
        _userNameTF.font = [UIFont systemFontOfSize:15.f];
        _userNameTF.tintColor = [UIColor blackColor];
        _userNameTF.text = [Database shareInstance].user.userName;
        _userNameTF.clearButtonMode = UITextFieldViewModeAlways;
        _userNameTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _userNameTF.delegate = self;
        [_userNameTF becomeFirstResponder];
        _userNameTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _userNameTF.frame = CGRectMake(0, 20, ScreenWidth, 44);
        [_userNameTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_userNameTF];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
        _userNameTF.leftView = paddingView;
        _userNameTF.leftViewMode = UITextFieldViewModeAlways;
    }
    return _userNameTF;
}

#pragma mark - Actions

- (void)Done{
    [SVProgressHUD show];
    
    Database *db = [Database shareInstance];
    db.user.userName = _userNameTF.text;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    NSString *url = [NSString stringWithFormat:@"%@/api/user/name",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"name":_userNameTF.text};
    
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:@"修改用户名成功"];
            [self resignFirstResponder];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NSObject showHudTipStr:LocalString(@"修改用户名失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

- (void)Cancel{
    [self.navigationController popViewControllerAnimated:YES];
    [self resignFirstResponder];
}

#pragma mark - UITextField Delegate
- (void)textFieldTextChange:(UITextField *)textField{
    if ([textField.text isEqualToString:[Database shareInstance].user.userName]) {
        _rightButton.enabled = NO;
        _rightButton.alpha = 0.4;
    }else{
        _rightButton.enabled = YES;
        _rightButton.alpha = 1;
    }
}


@end
