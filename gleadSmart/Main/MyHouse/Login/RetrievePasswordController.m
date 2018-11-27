//
//  RetrievePasswordController.m
//  Heating
//
//  Created by Mac on 2018/11/12.
//  Copyright © 2018 Mac. All rights reserved.
//

#import "RetrievePasswordController.h"
#import "PhoneTFCell.h"
#import "PhoneVerifyCell.h"
#import "TextFieldCell.h"
#import "LoginViewController.h"
#import "SelectDeviceTypeController.h"
#import "MainViewController.h"
NSString *const CellIdentifier_RetrieveUserPhone = @"CellID_RetrieveuserPhone";
NSString *const CellIdentifier_RetrieveUserPhoneVerify = @"CellID_RetrieveuserPhoneVerify";
NSString *const CellIdentifier_RetrieveTextField = @"CellID_RetrieveTextField";

@interface RetrievePasswordController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *retrieveTable;
@property (nonatomic, strong) UIButton *SureBtn;
@property (nonatomic, strong) UIButton *BackBtn;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *pwText;
@property (nonatomic, strong) NSString *pwConText;

@end

@implementation RetrievePasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor;
    
    _retrieveTable = [self retrieveTable];
    _phone = @"";
    _code = @"";
    _pwText = @"";
    _pwConText = @"";
}
#pragma mark - LazyLoad
static float HEIGHT_CELL = 50.f;

- (UITableView *)retrieveTable{
    if (!_retrieveTable) {
        _retrieveTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,100,300,250)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[PhoneVerifyCell class] forCellReuseIdentifier:CellIdentifier_RetrieveUserPhoneVerify];
            [tableView registerClass:[PhoneTFCell class] forCellReuseIdentifier:CellIdentifier_RetrieveUserPhone];
            [tableView registerClass:[TextFieldCell class] forCellReuseIdentifier:CellIdentifier_RetrieveTextField];
            tableView.separatorColor = [UIColor colorWithRed:99/255.0 green:144/255.0 blue:209/255.0 alpha:1];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            
            _SureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_SureBtn setTitle:LocalString(@"确定") forState:UIControlStateNormal];
            [_SureBtn.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
            [_SureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_SureBtn setBackgroundColor:[UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0]];
            [_SureBtn addTarget:self action:@selector(Sure) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_SureBtn];
            [_SureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(tableView.mas_bottom).offset(20);
                make.left.equalTo(self.view.mas_left).offset(46);//距离左边46px
                make.right.equalTo(self.view.mas_right).offset(-46); //距离右边46px
            }];
            _BackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_BackBtn setTitle:LocalString(@"返回") forState:UIControlStateNormal];
            [_BackBtn.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
            [_BackBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
            [_BackBtn setBackgroundColor:[UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]];
            [_BackBtn.layer setBorderWidth:1.0];
            _BackBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
            [_BackBtn addTarget:self action:@selector(Back) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_BackBtn];
            [_BackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.SureBtn.mas_bottom).offset(20);
                make.left.equalTo(self.view.mas_left).offset(46);//距离左边46px
                make.right.equalTo(self.view.mas_right).offset(-46); //距离右边46px
            }];
           tableView;
        });
    }
    return _retrieveTable;
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
            PhoneTFCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_RetrieveUserPhone];;
            if (cell == nil) {
                cell = [[PhoneTFCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_RetrieveUserPhone];
            }
            cell.phoneimage.image = [UIImage imageNamed:@"img_houseManage"];
            cell.TFBlock = ^(NSString *text) {
                self.phone = text;
                [self textFieldChange];
            };
            return cell;
    }else if (indexPath.row == 1){
            PhoneVerifyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_RetrieveUserPhoneVerify];;
            if (cell == nil) {
                cell = [[PhoneVerifyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_RetrieveUserPhoneVerify];
            }
        cell.verifyimage.image = [UIImage imageNamed:@"img_houseManage"];
            cell.TFBlock = ^(NSString *text) {
                self.code = text;
                [self textFieldChange];
            };
            return cell;
    }else if (indexPath.row == 2){
            TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_RetrieveTextField];
            if (cell == nil) {
                cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_RetrieveTextField];
            }
                cell.textField.secureTextEntry = YES;
                cell.passwordimage.image = [UIImage imageNamed:@"img_houseManage"];
                cell.textField.placeholder = LocalString(@"请设置新密码（6位以上字符）");
                cell.TFBlock = ^(NSString *text) {
                    self.pwText = text;
                    [self textFieldChange];
                };
            return cell;
    }else{
            TextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_RetrieveTextField];
            if (cell == nil) {
                cell = [[TextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_RetrieveTextField];
            }
                cell.textField.secureTextEntry = YES;
                cell.passwordimage.image = [UIImage imageNamed:@"img_houseManage"];
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
- (void)Back{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self presentViewController:loginVC animated:YES completion:^{
    }];
}
- (void)Sure{
    MainViewController *MainVC = [[MainViewController alloc] init];
    [self presentViewController:MainVC animated:YES completion:^{
    }];}
@end
