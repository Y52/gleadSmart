//
//  HouseSelectController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HouseSelectController.h"
#import "TouchTableView.h"
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
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Lazy Load
-(UITableView *)houseTable{
    if (!_houseTable) {
        _houseTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
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
            
            MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshTable)];
            // Set title
            [header setTitle:LocalString(@"下拉刷新") forState:MJRefreshStateIdle];
            [header setTitle:LocalString(@"松开刷新") forState:MJRefreshStatePulling];
            [header setTitle:LocalString(@"加载中") forState:MJRefreshStateRefreshing];
            
            // Set font
            header.stateLabel.font = [UIFont systemFontOfSize:15];
            header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
            
            // Set textColor
            header.stateLabel.textColor = [UIColor lightGrayColor];
            header.lastUpdatedTimeLabel.textColor = [UIColor lightGrayColor];
            tableView.mj_header = header;
            
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
    return _houseArray.count + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HouseSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeSelect];
    if (cell == nil) {
        cell = [[HouseSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeSelect];
    }
    if (indexPath.row == _houseArray.count) {
        cell.image.image = [UIImage imageNamed:@"img_houseManage"];
        cell.houseLabel.text = LocalString(@"家庭管理");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == _houseArray.count) {
        HouseManagementController  *HouseManagementVC = [[HouseManagementController alloc] init];
        [self.navigationController pushViewController:HouseManagementVC animated:YES];
        return;
    }
    HouseModel *house = _houseArray[indexPath.row];
    [self inquireHouseDetailWith:house];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

#pragma mark - Actions
- (void)inquireHouseDetailWith:(HouseModel *)house{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http:///api/house?houseUid=%@",house.houseUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSLog(@"%@",[Database shareInstance].user.userId);
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Database shareInstance].user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[Database shareInstance].token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        NSDictionary *dataDic = responseDic[@"data"];
        Database *db = [Database shareInstance];
        db.currentHouse.houseUid = [dataDic objectForKey:@"houseUid"];
        db.currentHouse.name = [dataDic objectForKey:@"name"];
        db.currentHouse.auth = house.auth;
        db.currentHouse.roomNumber = [dataDic objectForKey:@"roomaNumber"];
        db.currentHouse.lon = [dataDic objectForKey:@"lon"];
        db.currentHouse.lat = [dataDic objectForKey:@"lat"];
#warning db.members是否添加,保存在数据库？
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self dismissVC];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"从服务器获取信息失败"];
        });
    }];
}

- (void)refreshTable{
    
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}
@end
