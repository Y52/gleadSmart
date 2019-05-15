//
//  MulSwitchTimingSetingController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/24.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "MulSwitchTimingSetingController.h"
#import "MulSwitchSetingCell.h"
#import "MulSwitchTimingController.h"

static float HEIGHT_HEADER = 20.f;
NSString *const CellIdentifier_MulSwitchSetingCell = @"CellID_MulSwitchSeting";

@interface MulSwitchTimingSetingController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *switchSetingTable;

@end

@implementation MulSwitchTimingSetingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor;
    self.navigationItem.title = LocalString(@"定时设置");
    self.switchSetingTable = [self switchSetingTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


#pragma mark - Lazyload

- (UITableView *)switchSetingTable{
    if (!_switchSetingTable) {
        _switchSetingTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[MulSwitchSetingCell class] forCellReuseIdentifier:CellIdentifier_MulSwitchSetingCell];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _switchSetingTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //区分几路开关
    switch ([self.device.type integerValue]) {
        case DeviceOneSwitch:
            return 1;
            break;
        case DeviceTwoSwitch:
            return 2;
            break;
        case DeviceThreeSwitch:
            return 3;
            break;
            
        default:
            return 4;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MulSwitchSetingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_MulSwitchSetingCell];
    if (cell == nil) {
        cell = [[MulSwitchSetingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_MulSwitchSetingCell];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row) {
        case 0:
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_allopen"];
            cell.leftLabel.text = @"开关1";
            
            break;
        case 1:
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_allopen"];
            cell.leftLabel.text = @"开关2";
            
            break;
        case 2:
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_allopen"];
            cell.leftLabel.text = @"开关3";
            
            break;
            
        default:
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_allopen"];
            cell.leftLabel.text = @"开关4";
            break;
    }
  
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MulSwitchTimingController *timingVC = [[MulSwitchTimingController alloc] init];
    timingVC.device = self.device;
    [self.navigationController pushViewController:timingVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 41.f;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEIGHT_HEADER;
}

@end
