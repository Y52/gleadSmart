//
//  EspViewController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "EspViewController.h"


#import "TouchTableView.h"
#import "SSIDTableViewCell.h"
#import "PasswordTableViewCell.h"
#import "DeviceSelectView.h"

#import <SystemConfiguration/CaptiveNetwork.h>

NSString *const CellIdentifier_ssid = @"CellID_ssid";
NSString *const CellNibName_ssid = @"SSIDTableViewCell";
NSString *const CellIdentifier_password = @"CellID_password";

#define HEIGHT_TEXT_FIELD 44

@interface EspViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *ssidPasswordTable;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) NSString *apPwd;

@end

@implementation EspViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1]];

    self.navigationItem.title = LocalString(@"添加设备");
    
    [self setSsidPasswordTable];
    _nextBtn = [self nextBtn];
    [self uiMasonry];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 懒加载
- (UIButton *)nextBtn{
    if (!_nextBtn) {
        self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn setTitle:LocalString(@"下一步") forState:UIControlStateNormal];
        [_nextBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_nextBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        [_nextBtn setButtonStyle1];
        _nextBtn.enabled = NO;
        [_nextBtn addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nextBtn];
    }
    return _nextBtn;
}

#pragma mark - masonry
- (void)uiMasonry{
    UIImageView *wifiImage = [[UIImageView alloc] init];
    wifiImage.image = [UIImage imageNamed:@"img_wifi"];
    [self.view addSubview:wifiImage];
    
    [wifiImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(150.f/WScale, 150/WScale));
        make.top.equalTo(self.view.mas_top).offset(15/HScale);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [_ssidPasswordTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, HEIGHT_TEXT_FIELD * 2));
        make.top.equalTo(wifiImage.mas_bottom).offset(15/HScale);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(345.f / WScale, 50.f / HScale));
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_ssidPasswordTable.mas_bottom).offset(20 / HScale);
    }];
}

#pragma mark - action
- (void)goNextView
{
    //获取Wi-Fi密码
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:1 inSection:0];
    PasswordTableViewCell *passwordCell = [_ssidPasswordTable cellForRowAtIndexPath:indexpath];
    _apPwd = passwordCell.passwordTF.text;
    
    [[NetWork shareNetWork] setSsid:_ssid];
    [[NetWork shareNetWork] setBssid:_bssid];
    [[NetWork shareNetWork] setApPwd:_apPwd];
    
    DeviceSelectView *selectVC = [[DeviceSelectView alloc] init];
    [self.navigationController pushViewController:selectVC animated:YES];
}


#pragma mark - tableview
- (void)setSsidPasswordTable{
    _ssidPasswordTable = ({
        TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 300, ScreenWidth, HEIGHT_TEXT_FIELD * 2) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //[tableView registerClass:[WorktimeCell class] forCellReuseIdentifier:kCellIdentifier_WorkTime];
        [tableView registerNib:[UINib nibWithNibName:CellNibName_ssid bundle:nil] forCellReuseIdentifier:CellIdentifier_ssid];
        [tableView registerClass:[PasswordTableViewCell class] forCellReuseIdentifier:CellIdentifier_password];
        [self.view addSubview:tableView];
        tableView.estimatedRowHeight = 0;
        tableView.estimatedSectionHeaderHeight = 0;
        tableView.estimatedSectionFooterHeight = 0;
        tableView.scrollEnabled = NO;
        if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([tableView respondsToSelector:@selector(setLayoutMargins:)])  {
            [tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        
        tableView;
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SSIDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ssid];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:CellNibName_ssid owner:self options:nil] lastObject];
        }
        if (_ssid) {
            cell.ssidLabel.text = _ssid;
            cell.ssidLabel.tintColor = [UIColor blackColor];
        }
        return cell;
    }else{
        PasswordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_password];
        if (cell == nil) {
            cell = [[PasswordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_password];
        }
        [cell.passwordTF addTarget:self action:@selector(passwordTFTextChange:) forControlEvents:UIControlEventEditingChanged];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - passwordTF value change
- (void)passwordTFTextChange:(UITextField *)sender{
    if (sender.text.length > 6 && _ssid) {
        [_nextBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
        _nextBtn.enabled = YES;
    }else{
        [_nextBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _nextBtn.enabled = NO;
    }
}

@end
