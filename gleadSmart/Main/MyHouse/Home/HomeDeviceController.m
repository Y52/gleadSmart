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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlReply:) name:@"valveStatusControlReply" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshDeviceTable" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"valveStatusControlReply" object:nil];
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
    return _deviceArray.count+2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeDevice];
    if (cell == nil) {
        cell = [[HomeDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeDevice];
    }
    if (indexPath.row == self.deviceArray.count) {
        cell.deviceImage.image = [UIImage imageNamed:@"img_valve_off"];
        cell.deviceName.text = @"无线水阀";
        cell.status.text = LocalString(@"未设置 | 已关闭");
        return cell;
    }
    if (indexPath.row == self.deviceArray.count + 1) {
        cell.deviceImage.image = [UIImage imageNamed:@"img_thermostat_off"];
        cell.deviceName.text = @"温控器";
        cell.status.text = LocalString(@"未设置 | 已关闭");
        return cell;
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
    if ([device.isOn integerValue]) {
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
    
    if (indexPath.row == self.deviceArray.count) {
        WirelessValveController *valveVC = [[WirelessValveController alloc] init];
        [self.navigationController pushViewController:valveVC animated:YES];
        return;
    }
    if (indexPath.row == self.deviceArray.count+1) {
        ThermostatController *thermostatVC = [[ThermostatController alloc] init];
        [self.navigationController pushViewController:thermostatVC animated:YES];
        return;
    }

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

#pragma mark - Actions
- (void)selectDevicesWithRoom{
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
    Network *net = [Network shareNetwork];
    [net onlineNodeInquire:[Database shareInstance].currentHouse.mac];
    [self.deviceTable.mj_header endRefreshing];
}

#pragma mark - Notification
- (void)refresh{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deviceTable reloadData];
    });
}

- (void)controlReply:(NSNotification *)notification{
    NSDictionary *replyDic = [notification userInfo];
    NSNumber *isOn = [replyDic objectForKey:@"isOn"];
    NSString *mac = [replyDic objectForKey:@"mac"];
    for (DeviceModel *device in self.deviceArray) {
        if ([device.mac isEqualToString:mac]) {
            device.isOn = isOn;
            NSLog(@"%@",isOn);
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deviceTable reloadData];
    });
}

@end
