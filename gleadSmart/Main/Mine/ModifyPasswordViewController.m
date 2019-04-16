//
//  ModifyPasswordViewController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/2/28.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "ModifyPasswordViewController.h"
#import "PhoneTFCell.h"
#import "PhoneVerifyCell.h"
#import "TextFieldCell.h"

NSString *const CellIdentifier_ModifyUserPhone = @"CellID_ModifyuserPhone";
NSString *const CellIdentifier_ModifyUserPhoneVerify = @"CellID_ModifyuserPhoneVerify";
NSString *const CellIdentifier_ModifyTextField = @"CellID_ModifyTextField";

@interface ModifyPasswordViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *modifyTable;
@property (nonatomic, strong) UIButton *SureBtn;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *pwText;
@property (nonatomic, strong) NSString *pwConText;

@end

@implementation ModifyPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
    
    _modifyTable = [self modifyTable];
    _phone = @"";
    _code = @"";
    _pwText = @"";
    _pwConText = @"";
   
}
#pragma mark - LazyLoad
static float HEIGHT_CELL = 50.f;

- (UITableView *)modifyTable{
    if (!_modifyTable) {
        _modifyTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(yAutoFit(30.f),yAutoFit(150.f),yAutoFit(290.f),220.f) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[PhoneVerifyCell class] forCellReuseIdentifier:CellIdentifier_ModifyUserPhoneVerify];
            [tableView registerClass:[PhoneTFCell class] forCellReuseIdentifier:CellIdentifier_ModifyUserPhone];
            [tableView registerClass:[TextFieldCell class] forCellReuseIdentifier:CellIdentifier_ModifyTextField];
            tableView.separatorColor = [UIColor colorWithRed:99/255.0 green:144/255.0 blue:209/255.0 alpha:1];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            
            _SureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_SureBtn setTitle:LocalString(@"确定") forState:UIControlStateNormal];
            [_SureBtn.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
            [_SureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_SureBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
            [_SureBtn addTarget:self action:@selector(Sure) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_SureBtn];
            [_SureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), 42));
                make.top.equalTo(tableView.mas_bottom).offset(30.f);
                make.centerX.equalTo(self.view.mas_centerX);
            }];
            tableView;
        });
    }
    return _modifyTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row ==0) {
        PhoneTFCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ModifyUserPhone];;
        if (cell == nil) {
            cell = [[PhoneTFCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ModifyUserPhone];
        }
        cell.phoneimage.image = [UIImage imageNamed:@"Imag_retrieve_phoneuser"];
        cell.TFBlock = ^(NSString *text) {
            self.phone = text;
            [self textFieldChange];
        };
        return cell;
    }else if (indexPath.row == 1){
        PhoneVerifyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ModifyUserPhoneVerify];;
        if (cell == nil) {
            cell = [[PhoneVerifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ModifyUserPhoneVerify];
        }
        cell.verifyimage.image = [UIImage imageNamed:@"img_retrieve_verify"];
        cell.TFBlock = ^(NSString *text) {
            self.code = text;
            [self textFieldChange];
            
        };
        cell.BtnBlock = ^BOOL{
            PhoneVerifyCell *cell1 = [self.modifyTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            [cell1.codeTF resignFirstResponder];
            PhoneTFCell *cell2 = [self.modifyTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
            [cell2.phoneTF resignFirstResponder];
            TextFieldCell *cell3 = [self.modifyTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            [cell3.textField resignFirstResponder];
            TextFieldCell *cell4 = [self.modifyTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
            [cell4.textField resignFirstResponder];
            
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            //设置超时时间
            [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
            manager.requestSerializer.timeoutInterval = 6.f;
            [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
            
            NSString *url;
            if ([NSString validateMobile:self.phone]){
                url = [NSString stringWithFormat:@"%@/api/util/sms?mobile=%@",httpIpAddress,self.phone];
                url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
            }else {
                [NSObject showHudTipStr:LocalString(@"手机号码不正确")];
                return NO;
            }
            
            [manager GET:url parameters:nil progress:nil
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
                      NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
                      NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                      NSLog(@"success:%@",daetr);
                      if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                          [NSObject showHudTipStr:LocalString(@"已向您的手机发送验证码")];
                      }else{
                          [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
                      }
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      NSLog(@"Error:%@",error);
                      [NSObject showHudTipStr:LocalString(@"操作失败")];
                      
                  }
             ];
            return YES;
        };
        return cell;
    }else if (indexPath.row == 2){
        TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ModifyTextField];
        if (cell == nil) {
            cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ModifyTextField];
        }
        cell.textField.secureTextEntry = YES;
        cell.passwordimage.image = [UIImage imageNamed:@"img_retrieve_password"];
        cell.textField.placeholder = LocalString(@"请设置新密码（6位以上字符）");
        cell.TFBlock = ^(NSString *text) {
            self.pwText = text;
            [self textFieldChange];
        };
        return cell;
    }else{
        TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ModifyTextField];
        if (cell == nil) {
            cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ModifyTextField];
        }
        cell.textField.secureTextEntry = YES;
        cell.passwordimage.image = [UIImage imageNamed:@"img_retrieve_password"];
        cell.textField.placeholder = LocalString(@"请再次输入密码");
        cell.TFBlock = ^(NSString *text) {
            self.pwConText = text;
            [self textFieldChange];
        };
        
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//section头部间距

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}

#pragma mark - Actions

- (void)textFieldChange{
    if (![_code isEqualToString:@""] && ![_phone isEqualToString:@""] && ![_pwText isEqualToString:@""] && ![_pwConText isEqualToString:@""]) {
        [_SureBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
    }else{
        [_SureBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
    }

}

- (void)Sure{
    
    if (([NSString validateMobile:_phone]) && (_code.length == 6) && (_pwText.length >= 6) && (_pwConText.length >= 6) && [_pwText isEqualToString:_pwConText]) {
        PhoneVerifyCell *cell1 = [self.modifyTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [cell1.codeTF resignFirstResponder];
        PhoneTFCell *cell2 = [self.modifyTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];;
        [cell2.phoneTF resignFirstResponder];
        TextFieldCell *cell3 = [self.modifyTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        [cell3.textField resignFirstResponder];
        TextFieldCell *cell4 = [self.modifyTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        [cell4.textField resignFirstResponder];
        [self modifyPasswordByApi];
    }else if(!([NSString validateMobile:_phone])) {
        [NSObject showHudTipStr:@"手机号格式错误"];
    }else if (!(_code.length == 6)){
        [NSObject showHudTipStr:@"请输入6位验证码"];
    }else if (!(_pwText.length >= 6 && _pwConText.length >= 6)){
        [NSObject showHudTipStr:@"密码不少于6位"];
    }else if (![_pwText isEqualToString:_pwConText]){
        [NSObject showHudTipStr:@"两次密码输入不同"];
    }else{
        [NSObject showHudTipStr:@"输入信息有误"];
    }
    
}

#pragma mark - API
- (void)modifyPasswordByApi{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/user/password",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"mobile":self.phone,@"password":self.pwText,@"code":self.code};
   
    [manager PUT:url parameters: parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:@"修改密码成功"];
            [self resignFirstResponder];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NSObject showHudTipStr:LocalString(@"修改密码失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

@end
