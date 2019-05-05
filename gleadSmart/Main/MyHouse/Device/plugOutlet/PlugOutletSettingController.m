//
//  PlugOutletSettingController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/1.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "PlugOutletSettingController.h"
#import "PlugOutletSettingCell.h"
#import "DeviceShareController.h"

NSString *const CellIdentifier_PlugOutletSetting = @"CellID_PlugOutletSetting";
static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 40.f;

@interface PlugOutletSettingController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *plugOutletSettingTable;
@property (strong, nonatomic) UIButton *removeDeviceBtn;

@end

@implementation PlugOutletSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"更多");
    
    self.plugOutletSettingTable = [self plugOutletSettingTable];
    self.removeDeviceBtn = [self removeDeviceBtn];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];    
}
#pragma mark - Lazy Load
-(UITableView *)plugOutletSettingTable{
    if (!_plugOutletSettingTable) {
        _plugOutletSettingTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[PlugOutletSettingCell class] forCellReuseIdentifier:CellIdentifier_PlugOutletSetting];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = NO;
            tableView;
        });
    }
    return _plugOutletSettingTable;
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
    return 3;
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
            return 2;
        }
            break;
        case 2:
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
    
    switch (indexPath.section) {
        case 0:
        {
            PlugOutletSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_PlugOutletSetting];
            if (cell == nil) {
                cell = [[PlugOutletSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_PlugOutletSetting];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if (indexPath.row == 0) {
                cell.leftName.text = LocalString(@"设备名称");
                cell.rightName.text = LocalString(@"客厅插座");
            }
            if (indexPath.row == 1) {
                cell.leftName.text = LocalString(@"设备位置");
                cell.rightName.text = LocalString(@"客厅");
            }
            return cell;
        }
            break;
            
        case 1:
        {
            PlugOutletSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_PlugOutletSetting];
            if (cell == nil) {
                cell = [[PlugOutletSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_PlugOutletSetting];
            }
            return cell;
        }
            break;
            
        case 2:
        {
            PlugOutletSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_PlugOutletSetting];
            if (cell == nil) {
                cell = [[PlugOutletSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_PlugOutletSetting];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if (self.device.isShare) {
                cell.leftName.text = LocalString(@"检测固件更新");
            }else{
                if (indexPath.row == 0) {
                    cell.leftName.text = LocalString(@"共享设备");
                }
                if (indexPath.row == 1) {
                    cell.leftName.text = LocalString(@"检测固件更新");
                }
            }
            
            return cell;
        }
            break;
        default:
        {
            PlugOutletSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_PlugOutletSetting];
            if (cell == nil) {
                cell = [[PlugOutletSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_PlugOutletSetting];
            }
            return cell;
        }
            break;

    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                
            }
            if (indexPath.row == 1) {
              
            }
        }
            break;
            
        case 1:
        {
           
        }
            break;
            
        case 2:
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
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER + HEIGHT_CELL * 2 )];
            textLabel.textColor = [UIColor colorWithHexString:@"999999"];
            textLabel.font = [UIFont systemFontOfSize:13.f];
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.backgroundColor = [UIColor clearColor];
            [headerView addSubview:textLabel];
            textLabel.text = LocalString(@"支持的第三方控制");
            
            [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(120, 13));
                make.centerY.equalTo(headerView.mas_centerY);
                make.left.equalTo(headerView.mas_left).offset(20);
            }];
            
            return headerView;
        }
            break;
        case 2:
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

- (void)removeDevice{
    NSLog(@"移除设备");
}

@end
