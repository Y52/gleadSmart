//
//  MineViewController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/6.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "MineViewController.h"
#import "MineNormalCell.h"
#import "AccountViewController.h"
#import "HouseManagementController.h"

NSString *const CellIdentifier_Mine = @"CellID_Mine";
static CGFloat const HEIGHT_CELL = 51.f;

@interface MineViewController ()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *headButton;
@property (nonatomic, strong) UILabel *nickLabel;
@property (nonatomic, strong) NSString *rssiStr;

@property (nonatomic, strong) UITableView *mineTableView;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    
    _headerView = [self headerView];
    _mineTableView = [self mineTableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self getUserInfoByApi];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recieveRouterRSSIValue:) name:@"getRouterRSSIValue" object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    //[self.navigationController.navigationBar setShadowImage:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getRouterRSSIValue" object:nil];
}

#pragma mark - Lazyload
-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 220.f)];
        [self.view addSubview:_headerView];
        UIImageView *bgImg = [[UIImageView alloc] initWithFrame:_headerView.bounds];
        [bgImg setImage:[UIImage imageNamed:@"img_mine_headerBG"]];
        [_headerView addSubview:bgImg];
        [_headerView sendSubviewToBack:bgImg];
        
        _headButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_headButton setImage:[UIImage imageNamed:@"img_mine_header"] forState:UIControlStateNormal];
        [_headButton addTarget:self action:@selector(accountSetAction) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:_headButton];
        [_headButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(70, 70));
            make.centerX.equalTo(self.headerView.mas_centerX);
            make.top.equalTo(self.headerView.mas_top).offset(64);
        }];
        
        _nickLabel = [[UILabel alloc] init];
        _nickLabel.text = [Database shareInstance].user.userName;
        _nickLabel.font = [UIFont systemFontOfSize:17.f];
        _nickLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        _nickLabel.textAlignment = NSTextAlignmentCenter;
        _nickLabel.adjustsFontSizeToFitWidth = YES;
        [_headerView addSubview:_nickLabel];
        [_nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(300, 24));
            make.centerX.equalTo(self.headerView.mas_centerX);
            make.top.equalTo(self.headButton.mas_bottom).offset(12);
        }];
    }
    return _headerView;
}

- (UITableView *)mineTableView{
    if (!_mineTableView) {
        _mineTableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 220, ScreenWidth, ScreenHeight - (220 + 44))];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[MineNormalCell class] forCellReuseIdentifier:CellIdentifier_Mine];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            
            [self.view addSubview:tableView];
            
            tableView.scrollEnabled = NO;
            tableView;
        });
    }
    return _mineTableView;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
#warning 去掉微信测试
        return 2;
    }else{
#warning 去掉检查更新
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MineNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Mine];
    if (cell == nil) {
        cell = [[MineNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_Mine];
    }
    
    if (indexPath.section == 0){
        if (indexPath.row == 0) {
            cell.normalLabel.text = LocalString(@"我的账号");
            cell.normalImage.image = [UIImage imageNamed:@"img_mine_account"];
            cell.rightLabel.text = [Database shareInstance].user.mobile;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }else if(indexPath.row == 1){
            cell.normalLabel.text = LocalString(@"家庭管理");
            cell.normalImage.image = [UIImage imageNamed:@"img_mine_houseManage"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }else{
            cell.normalLabel.text = LocalString(@"微信账号");
            cell.normalImage.image = [UIImage imageNamed:@"img_mine_wechat"];
            cell.rightLabel.text = LocalString(@"未绑定");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        
    }else if (indexPath.section == 1){
        if (indexPath.row == 0){
            cell.normalLabel.text = LocalString(@"关于我们");
            cell.normalImage.image = [UIImage imageNamed:@"img_mine_aboutus"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }else{
            cell.normalLabel.text = LocalString(@"信号测试");
            cell.normalImage.image = [UIImage imageNamed:@"img_mine_aboutus"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }else{
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        if (indexPath.row == 0) {
            AccountViewController *accountVC = [[AccountViewController alloc] init];
            [self.navigationController pushViewController:accountVC animated:YES];
        }else if (indexPath.row == 1){
            HouseManagementController *HouseManagementVC = [[HouseManagementController alloc] init];
            [self.navigationController pushViewController:HouseManagementVC animated:YES];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 1) {

        }else if (indexPath.row == 0){
            
        }else if (indexPath.row == 2){
         
            [self getRouterRSSIValue];
            
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}

//section头部间距

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;//section头部高度
}
//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}
//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - notification

- (void)recieveRouterRSSIValue:(NSNotification *)nsnotification
{
    NSDictionary *dataDic = [nsnotification userInfo];
    NSNumber *RSSI = [dataDic objectForKey:@"RSSI"];
    self.rssiStr = [NSString stringWithFormat:@"%@%@",LocalString(@"RSSI:-"),RSSI];
    //提示框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"当前网络信号") message:self.rssiStr preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LocalString(@"OK") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - Actions
- (void)accountSetAction{

}

- (void)scanAction{
    
}

- (void)getRouterRSSIValue{
    UInt8 controlCode = 0x00;
    NSArray *data = @[@0xFE,@0x03,@0x01,@0x00];
    [[Network shareNetwork] sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data failuer:nil];
}

#pragma mark - API
- (void)getUserInfoByApi{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/user",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSLog(@"success:%@",daetr);
            if ([responseDic objectForKey:@"data"]) {
                NSDictionary *userinfoDic = [responseDic objectForKey:@"data"];
                db.user.userName = [userinfoDic objectForKey:@"name"];
                db.user.mobile = [userinfoDic objectForKey:@"mobile"];
                self.nickLabel.text = db.user.userName;
                [self.mineTableView reloadData];
            }
        }else{
            [NSObject showHudTipStr:LocalString(@"获取用户信息失败")];
            NSLog(@"获取用户信息失败");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        [NSObject showHudTipStr:LocalString(@"获取用户信息失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

@end
