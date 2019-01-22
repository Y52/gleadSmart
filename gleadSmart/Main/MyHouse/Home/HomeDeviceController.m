//
//  HomeDeviceController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/14.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HomeDeviceController.h"
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
    [self selectDevicesWithRoom];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.deviceTable) {
        [self.deviceTable reloadData];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectDevicesWithRoom) name:@"refreshDeviceTable" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshDeviceTable" object:nil];
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
    DeviceModel *device = self.deviceArray[indexPath.row];
    cell.deviceName.text = device.name;
    RoomModel *room = [[Database shareInstance] queryRoomWith:device.roomUid];
    NSString *status = room.name;
    if (room.roomUid == nil) {
        status = LocalString(@"未设置");
    }
    switch ([device.type integerValue]) {
        case 1:
        {
            if ([device.isOnline boolValue]) {
                cell.deviceImage.image = [UIImage imageNamed:@"img_thermostat_on"];
            }else{
                cell.deviceImage.image = [UIImage imageNamed:@"img_thermostat_off"];
            }
            cell.switchBlock = ^(BOOL isOn) {
                UInt8 controlCode = 0x01;
                NSArray *data = @[@0xFE,@0x12,@0x01,@0x01,[NSNumber numberWithBool:isOn]];
                [[Network shareNetwork] sendData69With:controlCode mac:device.mac data:data];
            };
        }
            break;
            
        case 2:
        {
            if ([device.isOnline boolValue]) {
                cell.deviceImage.image = [UIImage imageNamed:@"img_valve_on"];
            }else{
                cell.deviceImage.image = [UIImage imageNamed:@"img_valve_off"];
            }
            cell.switchBlock = ^(BOOL isOn) {
                UInt8 controlCode = 0x01;
                NSArray *data = @[@0xFE,@0x13,@0x01,@0x01,[NSNumber numberWithBool:isOn]];
                [[Network shareNetwork] sendData69With:controlCode mac:device.mac data:data];
            };
        }
            break;
            
        case 3:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_wallHob"];
        }
            break;
            
        default:
            break;
    }
    //NSLog(@"%@---%@",device.isOn,device.mac);
    if ([device.isOn boolValue]) {
        cell.status.text = [status stringByAppendingString:LocalString(@" | 已开启")];
        cell.controlSwitch.on = YES;
    }else{
        cell.status.text = [status stringByAppendingString:LocalString(@" | 已关闭")];
        cell.controlSwitch.on = NO;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DeviceModel *device = self.deviceArray[indexPath.row];
    switch ([device.type integerValue]) {
        case 1:
        {
            ThermostatController *thermostatVC = [[ThermostatController alloc] init];
            thermostatVC.device = device;
            [self.navigationController pushViewController:thermostatVC animated:YES];
        }
            break;
            
        case 2:
        {
            WirelessValveController *valveVC = [[WirelessValveController alloc] init];
            valveVC.device = device;
            [self.navigationController pushViewController:valveVC animated:YES];
        }
            break;
            
        case 3:
        {
            
        }
            break;
            
        default:
            break;
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DeviceModel *device = self.deviceArray[indexPath.row];
        Network *net = [Network shareNetwork];
        UInt8 controlCode = 0x00;
        NSArray *data = @[@0xFE,@0x02,@0x92,@0x01,[NSNumber numberWithInt:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(0, 2)]]],[NSNumber numberWithInt:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]],[NSNumber numberWithInt:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(4, 2)]]],[NSNumber numberWithInt:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(6, 2)]]]];//删除节点
        [net sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data];
    }
}

#pragma mark - Actions
- (void)selectDevicesWithRoom{
    [self.deviceTable.mj_header endRefreshing];
    [SVProgressHUD dismiss];
    Network *net = [Network shareNetwork];
    if (!_room) {
        self.deviceArray = net.deviceArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.deviceTable reloadData];
        });
        return;
    }
    for (DeviceModel *device in net.deviceArray) {
        if ([device.roomUid isEqualToString:_room.roomUid]) {
            [self.deviceArray addObject:device];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deviceTable reloadData];
    });
}

- (void)refreshTable{
    [SVProgressHUD show];
    Network *net = [Network shareNetwork];
    UInt8 controlCode = 0x00;
    NSArray *data = @[@0xFE,@0x01,@0x45,@0x00];//在网节点查询
    [net sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //异步等待10秒，如果未收到信息做如下处理
        sleep(10);
        if ([self.deviceTable.mj_header isRefreshing]) {
            [NSObject showHudTipStr:@"设备或服务器异常，无法查询设备"];
            [SVProgressHUD dismiss];
            [self.deviceTable.mj_header endRefreshing];
        }
    });
}
@end
