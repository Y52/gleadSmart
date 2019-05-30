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
#import "ShareDeviceListController.h"
#import "NTCWirelessValveController.h"
#import "PlugOutletController.h"
#import "MulSwitchController.h"
#import "OneSwitchController.h"
#import "TwoSwitchController.h"
#import "ThreeSwitchController.h"

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
    
    if (self.deviceTable) {
        [self.deviceTable reloadData];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectDevicesWithRoom) name:@"refreshDeviceTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(oneDeviceStatusUpdate:) name:@"oneDeviceStatusUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valveHangingNodesRabbitmqReport:) name:@"valveHangingNodesRabbitmqReport" object:nil];
    [self selectDevicesWithRoom];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshDeviceTable" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"oneDeviceStatusUpdate" object:nil];
}

#pragma mark - Actions
- (void)selectDevicesWithRoom{
    [self.deviceTable.mj_header endRefreshing];
    [SVProgressHUD dismiss];
    Network *net = [Network shareNetwork];
    NSMutableArray *allDevice = [[NSMutableArray alloc] init];
    if (net.deviceArray.count > 0) {
        //从中央控制器得到了设备的回复信息
        [allDevice addObjectsFromArray:net.deviceArray];
    }
    if (net.connectedDevice && net.connectedDevice.gatewayMountDeviceList > 0) {
        [allDevice addObjectsFromArray:net.connectedDevice.gatewayMountDeviceList];
    }else{
        //未得到回复信息，用本地or服务器存储的信息
        NSMutableArray *mountDeviceList = [[Database shareInstance] queryCenterlControlMountDevice:[Database shareInstance].currentHouse.houseUid];
        [allDevice addObjectsFromArray:mountDeviceList];
    }
    if (!_room) {
        //所有设备房间列表
        self.deviceArray = allDevice;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.deviceTable reloadData];
        });
        return;
    }
    [self.deviceArray removeAllObjects];
    for (DeviceModel *device in allDevice) {
        if ([device.roomUid isEqualToString:_room.roomUid]) {
            [self.deviceArray addObject:device];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deviceTable reloadData];
    });
}

- (void)oneDeviceStatusUpdate:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    DeviceModel *device = [userInfo objectForKey:@"device"];
    NSNumber *isShare = [userInfo objectForKey:@"isShare"];
    if ([isShare boolValue]) {
        for (int i = 0; i < [Database shareInstance].shareDeviceArray.count; i++) {
            DeviceModel *shareDevice = [Database shareInstance].shareDeviceArray[i];
            if ([device.mac isEqualToString:shareDevice.mac]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    HomeDeviceCell *cell = [self.deviceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
                    cell.controlSwitch.enabled = YES;
                    cell.controlSwitch.on = [device.isOn boolValue];
                    cell.status.text = [self getDeviceRoomNameAndStatus:device isShare:YES];
                    NSInteger type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]];
                    [self differenceShareDiveceAction:type isOnline:[device.isOnline boolValue] device:device cell:cell indexpath:[NSIndexPath indexPathForRow:i inSection:1]];
                });
            }
        }
        //return;
    }
    
    for (int i = 0; i < self.deviceArray.count; i++) {
        DeviceModel *oldDevice = self.deviceArray[i];
        if ([device.mac isEqualToString:oldDevice.mac]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                HomeDeviceCell *cell = [self.deviceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                cell.controlSwitch.enabled = YES;
                cell.controlSwitch.on = [oldDevice.isOn boolValue];
                
                cell.status.text = [self getDeviceRoomNameAndStatus:oldDevice isShare:NO];
                [self differenceDiveceActionWithDevice:oldDevice cell:cell indexpath:[NSIndexPath indexPathForRow:i inSection:0]];
            });
        }
    }
}

- (void)valveHangingNodesRabbitmqReport:(NSNotification *)notification{
#warning 修改，节点漏水或低电压的主页面表现先不做，以后改成图片变红色
    return;
    NSDictionary *userInfo = [notification userInfo];
    NodeModel *node = [userInfo objectForKey:@"node"];
    NSString *valveMac = node.valveMac;
    
    for (int i = 0; i < self.deviceArray.count; i++) {
        DeviceModel *oldDevice = self.deviceArray[i];
        if ([valveMac isEqualToString:oldDevice.mac]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                HomeDeviceCell *cell = [self.deviceTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                RoomModel *room = [[Database shareInstance] queryRoomWith:oldDevice.roomUid];
                NSString *status = room.name;
                if ([room.roomUid isEqualToString:@""]) {
                    status = LocalString(@"未设置");
                }
                if (node.isLeak || node.isLowVoltage) {
                    
                }else{
                    
                }
            });
        }
    }

}

- (void)refreshTable{
    Network *net = [Network shareNetwork];
    UInt8 controlCode = 0x00;
    NSArray *data = @[@0xFE,@0x01,@0x45,@0x00];//在网节点查询
    [net sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data failuer:nil];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //异步等待10秒，如果未收到信息做如下处理
        sleep(10);
        if ([self.deviceTable.mj_header isRefreshing]) {
            [self.deviceTable.mj_header endRefreshing];
        }
    });
}

- (void)shareInfo{
    ShareDeviceListController *vc = [[ShareDeviceListController alloc] init];
    vc.popBlock = ^(void) {
        [[Database shareInstance] getHouseHomeListAndDevice:[Database shareInstance].currentHouse success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.deviceTable reloadData];
                if (self.reloadBlock) {
                    self.reloadBlock();//通知wmpage也刷新，不然只刷新table没有效果
                }
            });
        } failure:^{

        }];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)getDeviceRoomNameAndStatus:(DeviceModel *)device isShare:(BOOL)isShare{
    NSString *status;
    if (isShare) {
        if ([device.type integerValue] < DeviceNTCValve) {
            if (device.isUnusual) {
                status = [status stringByAppendingString:LocalString(@"异常")];
            }else{
                if ([device.isOn boolValue]) {
                    status = [status stringByAppendingString:LocalString(@"已开启")];
                }else{
                    status = [status stringByAppendingString:LocalString(@"已关闭")];
                }
            }
        }else{
            if ([device.isOnline integerValue]) {
                status = [status stringByAppendingString:LocalString(@"在线")];
            }else{
                status = [status stringByAppendingString:LocalString(@"离线")];
            }
        }
    }else{
        RoomModel *room = [[Database shareInstance] queryRoomWith:device.roomUid];
        if ([room.roomUid isEqualToString:@""]) {
            status = LocalString(@"未设置");
        }else{
            status = room.name;
        }
        
        if ([device.type integerValue] < DeviceNTCValve) {
            if (device.isUnusual) {
                status = [status stringByAppendingString:LocalString(@" | 异常")];
            }else{
                if ([device.isOn boolValue]) {
                    status = [status stringByAppendingString:LocalString(@" | 已开启")];
                }else{
                    status = [status stringByAppendingString:LocalString(@" | 已关闭")];
                }
            }
        }else{
            if ([device.isOnline integerValue]) {
                status = [status stringByAppendingString:LocalString(@" | 在线")];
            }else{
                status = [status stringByAppendingString:LocalString(@" | 离线")];
            }
        }
    }
    return status;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return _deviceArray.count;
            break;
            
        case 1:
            return [Database shareInstance].shareDeviceArray.count;
            break;
            
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeDevice];
    if (cell == nil) {
        cell = [[HomeDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeDevice];
    }
    switch (indexPath.section) {
        case 0:
        {
            DeviceModel *device = self.deviceArray[indexPath.row];
            cell.deviceName.text = device.name;
            cell.status.text = [self getDeviceRoomNameAndStatus:device isShare:NO];
            [self differenceDiveceActionWithDevice:device cell:cell indexpath:indexPath];
        }
            break;
            
        case 1:
        {
            DeviceModel *device = [Database shareInstance].shareDeviceArray[indexPath.row];
            cell.deviceName.text = device.name;
            if ([device.isOn boolValue]) {
                cell.controlSwitch.on = YES;
            }else{
                cell.controlSwitch.on = NO;
            }
            cell.status.text = [self getDeviceRoomNameAndStatus:device isShare:YES];
            NSInteger type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]];
            [self differenceShareDiveceAction:type isOnline:[device.isOnline boolValue] device:device cell:cell indexpath:indexPath];
        }
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)differenceDiveceActionWithDevice:(DeviceModel *)device cell:(HomeDeviceCell *)cell indexpath:(NSIndexPath *)indexPath{
    __block typeof(cell) blockCell = cell;
    switch ([device.type integerValue]) {
        case DeviceThermostat:
        {
            if (device.isOnline) {
                cell.deviceImage.image = [UIImage imageNamed:@"img_thermostat_on"];
            }else{
                cell.deviceImage.image = [UIImage imageNamed:@"img_thermostat_off"];
            }
            cell.switchBlock = ^(BOOL isOn) {
                blockCell.controlSwitch.enabled = NO;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //异步等待4秒，如果未收到信息做如下处理
                    sleep(4);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DeviceModel *device = self.deviceArray[indexPath.row];
                        if ([device.isOn boolValue] != isOn) {
                            blockCell.controlSwitch.enabled = YES;
                            blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                        }
                    });
                });
                
                UInt8 controlCode = 0x01;
                NSArray *data = @[@0xFE,@0x12,@0x01,@0x01,[NSNumber numberWithBool:isOn]];
                [[Network shareNetwork] sendData69With:controlCode mac:device.mac data:data failuer:^{
                    blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                }];
            };
        }
            break;
            
        case DeviceValve:
        {
            if (device.isOnline) {
                cell.deviceImage.image = [UIImage imageNamed:@"img_valve_on"];
            }else{
                cell.deviceImage.image = [UIImage imageNamed:@"img_valve_off"];
            }
            cell.switchBlock = ^(BOOL isOn) {
                blockCell.controlSwitch.enabled = NO;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //异步等待4秒，如果未收到信息做如下处理
                    sleep(4);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DeviceModel *device = self.deviceArray[indexPath.row];
                        if ([device.isOn boolValue] != isOn) {
                            blockCell.controlSwitch.enabled = YES;
                            blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                        }
                    });
                });
                
                UInt8 controlCode = 0x01;
                NSArray *data = @[@0xFE,@0x13,@0x01,@0x01,[NSNumber numberWithBool:isOn]];
                [[Network shareNetwork] sendData69With:controlCode mac:device.mac data:data failuer:^{
                    blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                }];
            };
        }
            break;
            
        case DeviceNTCValve:
        {
            if (device.isOnline) {
                cell.deviceImage.image = [UIImage imageNamed:@"img_valve_on"];
            }else{
                cell.deviceImage.image = [UIImage imageNamed:@"img_valve_off"];
            }
            cell.switchBlock = ^(BOOL isOn) {
                blockCell.controlSwitch.enabled = NO;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //异步等待4秒，如果未收到信息做如下处理
                    sleep(4);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DeviceModel *device = self.deviceArray[indexPath.row];
                        if ([device.isOn boolValue] != isOn) {
                            blockCell.controlSwitch.enabled = YES;
                            blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                        }
                    });
                });
                
                UInt8 controlCode = 0x01;
                NSArray *data = @[@0xFE,@0x13,@0x01,@0x01,[NSNumber numberWithBool:isOn]];
                [[Network shareNetwork] sendData69With:controlCode mac:device.mac data:data failuer:^{
                    blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                }];
            };
        }
            break;
            
        case DeviceWallhob:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_wallHob"];
        }
            break;
            
        case DevicePlugOutlet:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_plug_icon"];
            cell.switchBlock = ^(BOOL isOn) {
                blockCell.controlSwitch.enabled = NO;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //异步等待4秒，如果未收到信息做如下处理
                    sleep(4);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DeviceModel *device = self.deviceArray[indexPath.row];
                        if ([device.isOn boolValue] != isOn) {
                            blockCell.controlSwitch.enabled = YES;
                            blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                        }
                    });
                });
                
                UInt8 controlCode = 0x01;
                NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,[NSNumber numberWithBool:isOn]];
                [device sendData69With:controlCode mac:device.mac data:data];
            };
        }
            break;
            
        case DeviceFourSwitch:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_icon_4"];
            blockCell.controlSwitch.hidden = YES;
        }
            break;
        case DeviceThreeSwitch:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_icon_3"];
            blockCell.controlSwitch.hidden = YES;
        }
            break;
        case DeviceTwoSwitch:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_icon_2"];
            blockCell.controlSwitch.hidden = YES;
        }
            break;
        case DeviceOneSwitch:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_icon_1"];
            blockCell.controlSwitch.hidden = YES;
            
        }
            break;
            
        default:
            break;
    }
}

- (void)differenceShareDiveceAction:(NSInteger)type isOnline:(BOOL)isOnline device:(DeviceModel *)device cell:(HomeDeviceCell *)cell indexpath:(NSIndexPath *)indexPath{
    __block typeof(cell) blockCell = cell;
    switch (type) {
        case DeviceThermostat:
        {
            if (isOnline) {
                cell.deviceImage.image = [UIImage imageNamed:@"img_thermostat_on"];
            }else{
                cell.deviceImage.image = [UIImage imageNamed:@"img_thermostat_off"];
            }
            cell.switchBlock = ^(BOOL isOn) {
                blockCell.controlSwitch.enabled = NO;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //异步等待4秒，如果未收到信息做如下处理
                    sleep(4);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DeviceModel *device = [Database shareInstance].shareDeviceArray[indexPath.row];
                        if ([device.isOn boolValue] != isOn) {
                            blockCell.controlSwitch.enabled = YES;
                            blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                        }
                    });
                });
                
                UInt8 controlCode = 0x01;
                NSArray *data = @[@0xFE,@0x12,@0x01,@0x01,[NSNumber numberWithBool:isOn]];
                [[Network shareNetwork] sendData69With:controlCode shareDevice:device data:data failure:^{
                    blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                }];
            };
        }
            break;
            
        case DeviceValve:
        {
            if (isOnline) {
                cell.deviceImage.image = [UIImage imageNamed:@"img_valve_on"];
            }else{
                cell.deviceImage.image = [UIImage imageNamed:@"img_valve_off"];
            }
            cell.switchBlock = ^(BOOL isOn) {
                blockCell.controlSwitch.enabled = NO;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //异步等待4秒，如果未收到信息做如下处理
                    sleep(4);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DeviceModel *device = [Database shareInstance].shareDeviceArray[indexPath.row];
                        if ([device.isOn boolValue] != isOn) {
                            blockCell.controlSwitch.enabled = YES;
                            blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                        }
                    });
                });
                
                UInt8 controlCode = 0x01;
                NSArray *data = @[@0xFE,@0x13,@0x01,@0x01,[NSNumber numberWithBool:isOn]];
                [[Network shareNetwork] sendData69With:controlCode shareDevice:device data:data failure:^{
                    blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                }];
            };
        }
            break;
            
        case DeviceNTCValve:
        {
            if (isOnline) {
                cell.deviceImage.image = [UIImage imageNamed:@"img_valve_on"];
            }else{
                cell.deviceImage.image = [UIImage imageNamed:@"img_valve_off"];
            }
            cell.switchBlock = ^(BOOL isOn) {
                blockCell.controlSwitch.enabled = NO;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //异步等待4秒，如果未收到信息做如下处理
                    sleep(4);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DeviceModel *device = [Database shareInstance].shareDeviceArray[indexPath.row];
                        if ([device.isOn boolValue] != isOn) {
                            blockCell.controlSwitch.enabled = YES;
                            blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                        }
                    });
                });
                
                UInt8 controlCode = 0x01;
                NSArray *data = @[@0xFE,@0x13,@0x01,@0x01,[NSNumber numberWithBool:isOn]];
                [[Network shareNetwork] sendData69With:controlCode shareDevice:device data:data failure:^{
                    blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                }];
            };
        }
            break;
            
        case DeviceWallhob:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_wallHob"];
        }
            break;
            
        case DevicePlugOutlet:
        {
            cell.switchBlock = ^(BOOL isOn) {
                blockCell.controlSwitch.enabled = NO;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //异步等待4秒，如果未收到信息做如下处理
                    sleep(4);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DeviceModel *device = self.deviceArray[indexPath.row];
                        if ([device.isOn boolValue] != isOn) {
                            blockCell.controlSwitch.enabled = YES;
                            blockCell.controlSwitch.on = !isOn;//失败时把开关状态设置为操作前的状态
                        }
                    });
                });
                
                UInt8 controlCode = 0x01;
                NSArray *data = @[@0xFC,@0x11,@0x00,@0x01,[NSNumber numberWithBool:isOn]];
                [device sendData69With:controlCode mac:device.mac data:data];
            };
        }
            break;
            
        case DeviceFourSwitch:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_icon_4"];
            blockCell.controlSwitch.hidden = YES;
        }
            break;
        case DeviceThreeSwitch:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_icon_3"];
            blockCell.controlSwitch.hidden = YES;
        }
            break;
        case DeviceTwoSwitch:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_icon_2"];
            blockCell.controlSwitch.hidden = YES;
        }
            break;
        case DeviceOneSwitch:
        {
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_icon_1"];
            blockCell.controlSwitch.hidden = YES;
            
        }
            break;

            
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            DeviceModel *device = self.deviceArray[indexPath.row];
            switch ([device.type integerValue]) {
                case DeviceThermostat:
                {
                    ThermostatController *thermostatVC = [[ThermostatController alloc] init];
                    thermostatVC.device = device;
                    [self.navigationController pushViewController:thermostatVC animated:YES];
                }
                    break;
                    
                case DeviceValve:
                {
                    WirelessValveController *valveVC = [[WirelessValveController alloc] init];
                    valveVC.device = device;
                    [self.navigationController pushViewController:valveVC animated:YES];
                }
                    break;
                    
                case DeviceNTCValve:
                {
                    NTCWirelessValveController *valveVC = [[NTCWirelessValveController alloc] init];
                    valveVC.device = device;
                    [self.navigationController pushViewController:valveVC animated:YES];
                }
                    break;
                    
                case DeviceWallhob:
                {
                    
                }
                    break;
                    
                case DevicePlugOutlet:
                {
                    PlugOutletController *plugVC = [[PlugOutletController alloc] init];
                    plugVC.device = device;
                    [self.navigationController pushViewController:plugVC animated:YES];
                }
                    break;
                    
                case DeviceFourSwitch:
                {
                    MulSwitchController *switchVC = [[MulSwitchController alloc] init];
                    switchVC.device = device;
                    [self.navigationController pushViewController:switchVC animated:YES];
                }
                    break;
                    
                case DeviceThreeSwitch:
                {
                    ThreeSwitchController *switchVC = [[ThreeSwitchController alloc] init];
                    switchVC.device = device;
                    [self.navigationController pushViewController:switchVC animated:YES];
                }
                    break;
                   
                case DeviceTwoSwitch:
                {
                    TwoSwitchController *switchVC = [[TwoSwitchController alloc] init];
                    switchVC.device = device;
                    [self.navigationController pushViewController:switchVC animated:YES];
                }
                    break;
                    
                case DeviceOneSwitch:
                {
                    OneSwitchController *switchVC = [[OneSwitchController alloc] init];
                    switchVC.device = device;
                    [self.navigationController pushViewController:switchVC animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 1:
        {
            DeviceModel *device = [Database shareInstance].shareDeviceArray[indexPath.row];
            NSInteger type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]];
            switch (type) {
                case DeviceThermostat:
                {
                    ThermostatController *thermostatVC = [[ThermostatController alloc] init];
                    thermostatVC.device = device;
                    [self.navigationController pushViewController:thermostatVC animated:YES];
                }
                    break;
                    
                case DeviceValve:
                {
                    WirelessValveController *valveVC = [[WirelessValveController alloc] init];
                    valveVC.device = device;
                    [self.navigationController pushViewController:valveVC animated:YES];
                }
                    break;
                    
                case DeviceNTCValve:
                {
                    NTCWirelessValveController *valveVC = [[NTCWirelessValveController alloc] init];
                    valveVC.device = device;
                    [self.navigationController pushViewController:valveVC animated:YES];
                }
                    break;
                    
                case DeviceWallhob:
                {
                    
                }
                    break;
                    
                case DevicePlugOutlet:
                {
                    PlugOutletController *plugVC = [[PlugOutletController alloc] init];
                    plugVC.device = device;
                    [self.navigationController pushViewController:plugVC animated:YES];
                }
                    break;
                    
                case DeviceFourSwitch:
                {
                    MulSwitchController *switchVC = [[MulSwitchController alloc] init];
                    switchVC.device = device;
                    [self.navigationController pushViewController:switchVC animated:YES];
                }
                    break;
                    
                case DeviceThreeSwitch:
                {
                    ThreeSwitchController *switchVC = [[ThreeSwitchController alloc] init];
                    switchVC.device = device;
                    NSLog(@"%@",device.deviceId);
                    [self.navigationController pushViewController:switchVC animated:YES];
                }
                    break;
                    
                case DeviceTwoSwitch:
                {
                    TwoSwitchController *switchVC = [[TwoSwitchController alloc] init];
                    switchVC.device = device;
                    [self.navigationController pushViewController:switchVC animated:YES];
                }
                    break;
                    
                case DeviceOneSwitch:
                {
                    OneSwitchController *switchVC = [[OneSwitchController alloc] init];
                    switchVC.device = device;
                    [self.navigationController pushViewController:switchVC animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
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
    
    switch (section) {
        case 0:
            break;
            
        case 1:
        {
            if ([Database shareInstance].shareDeviceArray.count != 0) {
                UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.f, 0, 200.f, 20.f)];
                textLabel.textColor = [UIColor colorWithHexString:@"3987F8"];
                textLabel.text = LocalString(@"我收到的共享");
                textLabel.font = [UIFont systemFontOfSize:14.f];
                textLabel.textAlignment = NSTextAlignmentLeft;
                textLabel.backgroundColor = [UIColor clearColor];
                [headerView addSubview:textLabel];
                
                UIButton *shareInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [shareInfoButton setImage:[UIImage imageNamed:@"img_shareInfo"] forState:UIControlStateNormal];
                [shareInfoButton addTarget:self action:@selector(shareInfo) forControlEvents:UIControlEventTouchUpInside];
                [headerView addSubview:shareInfoButton];
                [shareInfoButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(20.f, 20.f));
                    make.centerY.equalTo(headerView.mas_centerY);
                    make.right.equalTo(headerView.mas_right).offset(-31.f);
                }];
            }
        }
            break;
            
        default:
            break;
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 15.f;
    }else{
        return 20.f;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            if (editingStyle == UITableViewCellEditingStyleDelete) {
                Network *net = [Network shareNetwork];
                DeviceModel *device = self.deviceArray[indexPath.row];
                if ([device.type intValue] >= DevicePlugOutlet && [device.type intValue] <= DeviceFourSwitch) {
                    [net removeJienuoOldDeviceWith:device success:^{
                        [self.deviceArray removeObject:device];
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        [NSObject showHudTipStr:LocalString(@"删除设备成功")];
                    } failure:^{
                        [NSObject showHudTipStr:LocalString(@"删除设备失败")];
                    }];
                }else if ([device.type intValue] >= DeviceThermostat && [device.type intValue] <= DeviceNTCValve){
                    UInt8 controlCode = 0x00;
                    NSArray *data = @[@0xFE,@0x02,@0x92,@0x01,[NSNumber numberWithInt:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(6, 2)]]],[NSNumber numberWithInt:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(4, 2)]]],[NSNumber numberWithInt:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]],[NSNumber numberWithInt:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(0, 2)]]]];//删除节点
                    [net sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data failuer:nil];
                    [net removeOldDeviceWith:device success:^{
                        [self.deviceArray removeObject:device];
                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        [NSObject showHudTipStr:LocalString(@"删除设备成功")];
                    } failure:^{
                        [NSObject showHudTipStr:LocalString(@"删除设备失败")];
                    }];
                }
            }
            break;
            
        default:
            break;
    }
}
@end
