//
//  HouseSelectController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HouseSelectController.h"
#import "HouseSelectCell.h"
#import "HouseManagementController.h"

NSString *const CellIdentifier_HomeSelect = @"CellID_HomeSelect";
static CGFloat const Cell_Height = 50.f;

@interface HouseSelectController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *houseTable;

@property (strong, nonatomic) UIButton *dismissButton;

@end

@implementation HouseSelectController

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];

    self.houseTable = [self houseTable];
    self.dismissButton = [self dismissButton];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self.rdv_tabBarController setTabBarHidden:YES animated:YES];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inquireHouseList) name:@"updateHouseList" object:nil];
    
    //更新家庭列表
    [self inquireHouseList];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateHouseList" object:nil];
}

#pragma mark - Lazy Load
-(UITableView *)houseTable{
    if (!_houseTable) {
        _houseTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ([Database shareInstance].houseList.count + 2) * Cell_Height)];
            tableView.backgroundColor = [UIColor whiteColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[HouseSelectCell class] forCellReuseIdentifier:CellIdentifier_HomeSelect];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            UIView *footView = [[UIView alloc] init];
            footView.backgroundColor = [UIColor clearColor];
            tableView.tableFooterView = footView;
                    
            tableView;
        });
    }
    return _houseTable;
}

- (UIButton *)dismissButton{
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissButton.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        [_dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:_dismissButton atIndex:0];
    }
    return _dismissButton;
}

#pragma mark - UITableView delegate&datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Database shareInstance].houseList.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Database *db = [Database shareInstance];
    HouseSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeSelect];
    if (cell == nil) {
        cell = [[HouseSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeSelect];
    }
    if (indexPath.row == db.houseList.count) {
        cell.image.image = [UIImage imageNamed:@"img_houseManage"];
        cell.houseLabel.text = LocalString(@"家庭管理");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        HouseModel *house = db.houseList[indexPath.row];
        cell.image.image = [UIImage imageNamed:@"addFamily_uncheck"];
        //NSLog(@"%@",db.currentHouse.houseUid);
        NSLog(@"%@",house.houseUid);
        if ([house.houseUid isEqualToString:db.currentHouse.houseUid]) {
            cell.image.image = [UIImage imageNamed:@"addFamily_check"];
        }
        cell.houseLabel.text = house.name;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Database *data = [Database shareInstance];
    Network *net = [Network shareNetwork];
    if (indexPath.row == data.houseList.count) {
        //进入家庭管理
        [self dismissViewControllerAnimated:YES completion:nil];
        if (self.pushBlock) {
            self.pushBlock();
        }
        return;
    }
    HouseModel *house = data.houseList[indexPath.row];
    if (![data.currentHouse.houseUid isEqualToString:house.houseUid]) {
        //选择了不同家庭
        data.currentHouse = house;
        [data.shareDeviceArray removeAllObjects];
        [net.deviceArray removeAllObjects];
        [net.connectedDevice.gatewayMountDeviceList removeAllObjects];
        if (net.mySocket.isConnected) {
            [net.mySocket disconnect];
        }
    }
    [self dismissVC];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

#pragma mark - Actions
- (void)inquireHouseList{
    //[SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    Database *db = [Database shareInstance];
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/house/list",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Database shareInstance].user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[Database shareInstance].token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            if ([responseDic[@"data"] count] > 0) {
                [db.houseList removeAllObjects];
                [responseDic[@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    HouseModel *house = [[HouseModel alloc] init];
                    house.houseUid = [obj objectForKey:@"houseUid"];
                    house.name = [obj objectForKey:@"name"];
                    house.auth = [obj objectForKey:@"auth"];
                    house.mac = [obj objectForKey:@"mac"];
                    [db.houseList addObject:house];
                     
                    [db insertNewHouse:house];
                }];
            }
            CGFloat height = ([Database shareInstance].houseList.count + 2) * Cell_Height;
            self.houseTable.frame = CGRectMake(0, 0, ScreenWidth, height);
            [self.houseTable reloadData];
        }else{
            [NSObject showHudTipStr:LocalString(@"获取家庭列表失败")];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.houseTable.mj_header endRefreshing];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.houseTable.mj_header endRefreshing];
            [NSObject showHudTipStr:@"从服务器获取信息失败"];
        });
    }];
}

- (void)refreshTable{
    [self inquireHouseList];
}

- (void)dismissVC{
    Database *data = [Database shareInstance];
    if (!data.currentHouse && data.houseList.count > 0) {
        data.currentHouse = data.houseList[0];
    }
    if (data.currentHouse) {
        //更新家庭信息，避免家庭设置中修改了家庭信息而主页面未改变
        for (HouseModel *house in data.houseList) {
            if ([data.currentHouse.houseUid isEqualToString:house.houseUid]) {
                data.currentHouse = house;
            }
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}
@end
