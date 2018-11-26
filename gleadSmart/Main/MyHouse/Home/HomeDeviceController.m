//
//  HomeDeviceController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/14.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HomeDeviceController.h"
#import "TouchTableView.h"
#import "HomeDeviceCell.h"
#import "ThermostatController.h"
#import "WirelessValveController.h"

NSString *const CellIdentifier_HomeDevice = @"CellID_HomeDevice";
static CGFloat const Cell_Height = 72.f;

@interface HomeDeviceController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *deviceTable;
@property (strong, nonatomic) NSMutableArray *deviceArray;

@end

@implementation HomeDeviceController

- (instancetype)init{
    if (self = [super init]) {
        self.deviceArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    self.deviceTable = [self deviceTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    Network *net = [Network shareNetwork];
    [net onlineNodeInquire:net.connectedDevice.mac];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inquireNode) name:@"inquireNode" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"inquireNode" object:nil];

}

#pragma mark - Lazy Load
-(UITableView *)deviceTable{
    if (!_deviceTable) {
        _deviceTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.frame.size.height - _filledSpcingHeight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[HomeDeviceCell class] forCellReuseIdentifier:CellIdentifier_HomeDevice];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
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
    return _deviceTable;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _deviceArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeDevice];
    if (cell == nil) {
        cell = [[HomeDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeDevice];
    }
    cell.deviceImage.image = [UIImage imageNamed:@"img_wallHob"];
    cell.deviceName.text = LocalString(@"温控器");
    cell.belongingHome.text = @"客厅";
    cell.status.text = @"已关闭";
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        ThermostatController *thermostatVC = [[ThermostatController alloc] init];
        [self.navigationController pushViewController:thermostatVC animated:YES];
    }else{
        WirelessValveController *valveVC = [[WirelessValveController alloc] init];
        [self.navigationController pushViewController:valveVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    headerView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    textLabel.textColor = [UIColor colorWithHexString:@"999999"];
    textLabel.font = [UIFont systemFontOfSize:14.f];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textLabel];
    
    
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 15.f;
    }else{
        return 0.f;
    }
}

#pragma mark - Actions
- (void)refreshTable{
    Network *net = [Network shareNetwork];
    [net onlineNodeInquire:net.connectedDevice.mac];
}

#pragma mark - NSNotificationCenter
- (void)inquireNode{
    Network *net = [Network shareNetwork];
    NSMutableArray *data = [[NSMutableArray alloc] init];
    [data addObjectsFromArray:net.recivedData68];
    int count = [data[7] intValue];
    if (count % 4 != 0) {
        [NSObject showHudTipStr:@"查询节点回复帧格式错误"];
        return;
    }
    for (int i = 1; i < count / 4; i++) {
        DeviceModel *device = [[DeviceModel alloc] init];
        device.mac = @"";
        [device.mac stringByAppendingString:[NSString HexByInt:[data[8 + i*4] intValue]]];
        [device.mac stringByAppendingString:[NSString HexByInt:[data[9 + i*4] intValue]]];
        [device.mac stringByAppendingString:[NSString HexByInt:[data[10 + i*4] intValue]]];
        [device.mac stringByAppendingString:[NSString HexByInt:[data[11 + i*4] intValue]]];
        [_deviceArray addObject:device];
    }
    [self.deviceTable reloadData];
    [self.deviceTable.mj_header endRefreshing];
}
@end
