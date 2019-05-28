//
//  DeviceSettingController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/4/1.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceSettingController.h"
#import "DeviceSettingCell.h"
#import "DeviceShareController.h"
#import "DeviceLocationController.h"

NSString *const CellIdentifier_deviceSetting = @"CellID_deviceSetting";
static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 40.f;

@interface DeviceSettingController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *deviceSettingTable;
@property (strong, nonatomic) UIButton *removeDeviceBtn;

@end

@implementation DeviceSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"更多");
    
    self.deviceSettingTable = [self deviceSettingTable];
    self.removeDeviceBtn = [self removeDeviceBtn];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - private methods
- (void)removeDevice{
    NSLog(@"移除设备");
}


#pragma mark - setters and getters
-(UITableView *)deviceSettingTable{
    if (!_deviceSettingTable) {
        _deviceSettingTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[DeviceSettingCell class] forCellReuseIdentifier:CellIdentifier_deviceSetting];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = NO;
            tableView;
        });
    }
    return _deviceSettingTable;
}

- (UIButton *)removeDeviceBtn{
    if (!_removeDeviceBtn) {
        _removeDeviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_removeDeviceBtn setTitle:LocalString(@"移除设备") forState:UIControlStateNormal];
        [_removeDeviceBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_removeDeviceBtn setTitleColor:[UIColor colorWithHexString:@"639DF8"] forState:UIControlStateNormal];
        [_removeDeviceBtn.layer setBorderWidth:1.0];
        _removeDeviceBtn.layer.borderColor = [UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0].CGColor;
        _removeDeviceBtn.layer.cornerRadius = 20.f;
        [_removeDeviceBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_removeDeviceBtn addTarget:self action:@selector(removeDevice) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_removeDeviceBtn];
        [_removeDeviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), 40.f));
            make.bottom.equalTo(self.view.mas_bottom).offset(-40.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _removeDeviceBtn;
}
#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
        {
            return 2;
        }
            break;
        case 1:
        {
            if (self.device.isShare) {
                return 1;
            }else{
                return 2;
            }
        }
            break;
            
        default:
            return section;
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_deviceSetting];
    if (cell == nil) {
        cell = [[DeviceSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_deviceSetting];
    }
    switch (indexPath.section) {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if (indexPath.row == 0) {
                cell.leftName.text = LocalString(@"设备名称");
                cell.rightName.text = self.device.name;
            }
            if (indexPath.row == 1) {
                cell.leftName.text = LocalString(@"设备位置");
                RoomModel *room = [[Database shareInstance] queryRoomWith:self.device.roomUid];
                cell.rightName.text = room.name;
            }
        }
            break;
            
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if (self.device.isShare) {
                cell.leftName.text = LocalString(@"设备信息");
            }else{
                if (indexPath.row == 0) {
                    cell.leftName.text = LocalString(@"共享设备");
                }
                if (indexPath.row == 1) {
                    cell.leftName.text = LocalString(@"设备信息");
                }
            }
            
        }
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                
            }
            if (indexPath.row == 1) {
                
                DeviceLocationController *VC = [[DeviceLocationController alloc] init];
                VC.device = self.device;
                VC.popBlock = ^(NSString *roomUid) {
                    self.device.roomUid = roomUid;
                    [self.deviceSettingTable reloadData];
                };
                [self.navigationController pushViewController:VC  animated:YES];
                
            }
        }
            break;
            
        case 1:
        {
            if (!self.device.isShare) {
                if (indexPath.row == 0) {
                    DeviceShareController *VC = [[DeviceShareController alloc] init];
                    VC.device = self.device;
                    [self.navigationController pushViewController:VC  animated:YES];
                }
            }
        }
            break;
            
        default:
            break;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
    headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    
    switch (section) {
        case 0:
        {
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
            textLabel.textColor = [UIColor colorWithHexString:@"999999"];
            textLabel.font = [UIFont systemFontOfSize:13.f];
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.backgroundColor = [UIColor clearColor];
            [headerView addSubview:textLabel];
            textLabel.text = LocalString(@"设备基本信息");
            
            [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(80, 13));
                make.centerY.equalTo(headerView.mas_centerY);
                make.left.equalTo(headerView.mas_left).offset(20);
            }];
            
            return headerView;
        }
            break;
            
        case 1:
        {
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER*2 +HEIGHT_CELL * 4 )];
            textLabel.textColor = [UIColor colorWithHexString:@"999999"];
            textLabel.font = [UIFont systemFontOfSize:13.f];
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.backgroundColor = [UIColor clearColor];
            [headerView addSubview:textLabel];
            textLabel.text = LocalString(@"其他");
            
            [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(80, 13));
                make.centerY.equalTo(headerView.mas_centerY);
                make.left.equalTo(headerView.mas_left).offset(20);
            }];
            
            return headerView;
        }
            break;
            
        default:
            
            break;
    }
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER;
}
@end
