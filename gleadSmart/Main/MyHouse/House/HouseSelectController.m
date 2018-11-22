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
static NSString *const CellIdentifier_HomeSelect = @"CellID_HomeSelect";
static CGFloat const Cell_Height = 50.f;

@interface HouseSelectController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *houseTable;
@property (strong, nonatomic) NSMutableArray *houseArray;

@property (strong, nonatomic) UIButton *dismissButton;

@end

@implementation HouseSelectController

-(instancetype)init{
    if (self = [super init]) {
        self.houseArray = [[NSMutableArray alloc] init];
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
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, -10, ScreenWidth, 100)];
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
    HouseManagementController  *HouseManagementVC = [[HouseManagementController alloc] init];
    [self.navigationController pushViewController:HouseManagementVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

#pragma mark - Actions
- (void)refreshTable{
    
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}
@end
