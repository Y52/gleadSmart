//
//  ThermostSettingController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/3.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ThermostSettingController.h"
#import "TherSettingCell.h"
#import "TherWeekProgramController.h"
#import "YPickerAlertController.h"

NSString *const CellIdentifier_TherSetting = @"CellID_TherSetting";
static CGFloat const Cell_Height = 44.f;

@interface ThermostSettingController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *settingTable;

@end

@implementation ThermostSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    
    self.settingTable = [self settingTable];
    [self inquireCompensate];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCompensate) name:@"refreshCompensate" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshCompensate" object:nil];
}

#pragma mark - Lazy load
- (UITableView *)settingTable{
    if (!_settingTable) {
        _settingTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - getRectNavAndStatusHight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            tableView.scrollEnabled = NO;
            [tableView registerClass:[TherSettingCell class] forCellReuseIdentifier:CellIdentifier_TherSetting];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
                        
            tableView;
        });
    }
    return _settingTable;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            break;
            
        case 1:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TherSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_TherSetting];
    if (cell == nil) {
        cell = [[TherSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_TherSetting];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.leftLabel.text = LocalString(@"温度单位切换");
            cell.rightLabel.text = LocalString(@"℃");
        }else{
            cell.leftLabel.text = LocalString(@"温度补偿");
            if (self.device.compensate) {
                cell.rightLabel.text = [NSString stringWithFormat:@"%@",self.device.compensate];
            }else{
                cell.rightLabel.text = [NSString stringWithFormat:@"0"];
            }
        }
    }else{
        cell.leftLabel.text = LocalString(@"周程序");
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        //温度补偿
        YPickerAlertController *VC = [[YPickerAlertController alloc] init];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        float i = -8;
        while (i <= 8) {
            [array addObject:[NSNumber numberWithFloat:i]];
            if (i == [self.device.compensate floatValue]) {
                VC.index = array.count-1;
            }
            i=i+0.5;
        }
        
        VC.pickerArr = [array mutableCopy];
        VC.pickerBlock = ^(NSInteger picker) {
            NSNumber *componsate = [array objectAtIndex:picker];
            [self sendCompensate:componsate];
        };
        VC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        VC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:VC animated:YES completion:nil];
        VC.titleLabel.text = LocalString(@"选择温度补偿值");
    }
    if (indexPath.section == 1) {
        TherWeekProgramController *weekProgramVC = [[TherWeekProgramController alloc] init];
        weekProgramVC.device = self.device;
        [self.navigationController pushViewController:weekProgramVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    headerView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 30.f;
            break;
            
        case 1:
            return 15.f;
            break;
            
        default:
            return 0.f;
            break;
    }
}

#pragma mark - Actions
- (void)inquireCompensate{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x12,@0x07,@0x00];
    [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data failuer:nil];
}

- (void)sendCompensate:(NSNumber *)compensate{
    UInt8 compensateData = (int)(fabsf([compensate floatValue]) * 2);//取绝对值
    if ([compensate floatValue] < 0) {
        compensateData = compensateData | 0x80;
    }
    
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x12,@0x07,@0x01,@(compensateData)];
    [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data failuer:nil];
}

#pragma mark - NSNotification
- (void)refreshCompensate{
    for (DeviceModel *device in [Network shareNetwork].deviceArray) {
        if ([device.mac isEqualToString:self.device.mac]) {
            self.device = device;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.settingTable reloadData];
    });
}

@end
