//
//  DeviceSelectView.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/29.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceSelectView.h"
#import "DeviceConfirmView.h"
#import "TouchTableView.h"
#import "DeviceSelectCell.h"

NSString *const CellIdentifier_deviceSelect = @"CellID_deviceSelect";

@interface DeviceSelectView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *devieceTable;
@property (nonatomic, strong) UIButton *nextBtn;

@end

@implementation DeviceSelectView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1]];

    self.navigationItem.title = LocalString(@"选择设备机型");
    
    _devieceTable = [self devieceTable];
    _nextBtn = [self nextBtn];
}

- (void)goNextView{
    DeviceConfirmView *confirmVC = [[DeviceConfirmView alloc] init];
    [self.navigationController pushViewController:confirmVC animated:YES];
}

#pragma mark - lazy load
- (UITableView *)devieceTable{
    if (!_devieceTable) {
        _devieceTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 600 / HScale) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [tableView registerClass:[DeviceSelectCell class] forCellReuseIdentifier:CellIdentifier_deviceSelect];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = NO;
            if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
                [tableView setSeparatorInset:UIEdgeInsetsZero];
            }
            if ([tableView respondsToSelector:@selector(setLayoutMargins:)])  {
                [tableView setLayoutMargins:UIEdgeInsetsZero];
            }
            
            tableView;
        });
    }
    return _devieceTable;
}

- (UIButton *)nextBtn{
    if (!_nextBtn) {
        self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextBtn setTitle:LocalString(@"下一步") forState:UIControlStateNormal];
        [_nextBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Medium" size:16]];
        [_nextBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
        _nextBtn.enabled = NO;
        [_nextBtn setButtonStyle1];
        [_nextBtn addTarget:self action:@selector(goNextView) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nextBtn];
        
        [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(345.f / WScale, 50.f / HScale));
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).offset(-15.f / HScale);
        }];
    }
    return _nextBtn;
}

#pragma mark - uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70 / HScale;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_deviceSelect];
    if (cell == nil) {
        cell = [[DeviceSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_deviceSelect];
    }
    switch (indexPath.row) {
        case 0:
        {
            cell.deviceName.text = LocalString(@"HB-M6G咖啡烘焙机");
            cell.image.image = [UIImage imageNamed:@"img_hb_m6g_small"];
            cell.tag = unselect;
        }
            break;
            
        case 1:
        {
            cell.deviceName.text = LocalString(@"HB-M6E咖啡烘焙机");
            cell.image.image = [UIImage imageNamed:@"img_hb_m6g_small"];
            cell.tag = unselect;
        }
            break;
            
        case 2:
        {
            cell.deviceName.text = LocalString(@"HB-L2咖啡烘焙机");
            cell.image.image = [UIImage imageNamed:@"img_hb_l2_small"];
            cell.tag = unselect;
        }
            break;
            
        case 3:
        {
            cell.deviceName.text = LocalString(@"PEAK-Edmund咖啡烘焙机");
            cell.image.image = [UIImage imageNamed:@"img_peak_edmund_small"];
            cell.tag = unselect;
        }
            break;
            
        case 4:{
            cell.deviceName.text = LocalString(@"其他机型");
            cell.image.image = [UIImage imageNamed:@"img_logo_gray"];
            cell.tag = unselect;
        }
            break;
            
        default:
            break;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *indexpathArr = [tableView indexPathsForVisibleRows];
    for (NSIndexPath *perIndexPath in indexpathArr) {
        DeviceSelectCell *cell = [tableView cellForRowAtIndexPath:perIndexPath];
        if (perIndexPath.row == indexPath.row) {
            if (cell.tag == unselect) {
                cell.tag = select;
                [cell.checkBtn setImage:[UIImage imageNamed:@"ic_selected"] forState:UIControlStateNormal];
                [NetWork shareNetWork].deviceType = [NSNumber numberWithInteger:indexPath.row];
                [_nextBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1]];
                _nextBtn.enabled = YES;
            }else{
                cell.tag = unselect;
                [cell.checkBtn setImage:[UIImage imageNamed:@"ic_select"] forState:UIControlStateNormal];
                [NetWork shareNetWork].deviceType = @0;
                [_nextBtn setBackgroundColor:[UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:0.4]];
                _nextBtn.enabled = NO;
            }
        }else{
            cell.tag = unselect;
            [cell.checkBtn setImage:[UIImage imageNamed:@"ic_select"] forState:UIControlStateNormal];
        }
    }
}

@end
