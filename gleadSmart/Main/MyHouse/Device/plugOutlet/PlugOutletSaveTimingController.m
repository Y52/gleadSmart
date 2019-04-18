//
//  PlugOutletSaveTimingController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/17.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "PlugOutletSaveTimingController.h"
#import "PlugOutletSaveAddTimingCell.h"

NSString *const CellIdentifier_PlugOutletSaveAddTimingCell = @"CellID_PlugOutletSaveAddTiming";

CGFloat const cellAddTiming_Height = 68.f;
static float HEIGHT_HEADER = 20.f;
static float HEIGHT_FOOT = 20.f;

@interface PlugOutletSaveTimingController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *TimingTable;
@property (nonatomic, strong) UIButton *AddTimingBtn;

@end

@implementation PlugOutletSaveTimingController

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    self.navigationItem.title = LocalString(@"添加设备");
    
    self.TimingTable = [self TimingTable];
    self.AddTimingBtn = [self AddTimingBtn];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}
#pragma mark - Actions

#pragma mark - setters and getters
- (UITableView *)TimingTable{
    if (!_TimingTable) {
        _TimingTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - getRectNavAndStatusHight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            tableView.scrollEnabled = NO;
            [tableView registerClass:[PlugOutletSaveAddTimingCell class] forCellReuseIdentifier:CellIdentifier_PlugOutletSaveAddTimingCell];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _TimingTable;
}

- (UIButton *)AddTimingBtn{
    if (!_AddTimingBtn) {
        _AddTimingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_AddTimingBtn setTitle:LocalString(@"添加定时") forState:UIControlStateNormal];
        [_AddTimingBtn setTitleColor:[UIColor colorWithHexString:@"639DF8"] forState:UIControlStateNormal];
        [_AddTimingBtn setBackgroundColor:[UIColor whiteColor]];
        [_AddTimingBtn addTarget:self action:@selector(Addtiming) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_AddTimingBtn];
        [_AddTimingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(276.f), 44.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_bottom).offset(-100.f);
        }];
        _AddTimingBtn.layer.cornerRadius = 22.f;
        _AddTimingBtn.layer.borderWidth = 1.f;
        _AddTimingBtn.layer.borderColor = [UIColor colorWithHexString:@"3987F8"].CGColor;
        
    }
    return _AddTimingBtn;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlugOutletSaveAddTimingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_PlugOutletSaveAddTimingCell];
    if (cell == nil) {
        cell = [[PlugOutletSaveAddTimingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_PlugOutletSaveAddTimingCell];
    }
    cell.backgroundColor = [UIColor whiteColor];
    switch (indexPath.row) {
        case 0:
        {
            cell.hourName.text = LocalString(@"10:37");
            cell.weekendName.text = LocalString(@"星期二");
            cell.status.text = LocalString(@"开关:开");
            cell.plugSwitch.on = YES;
        }
            break;
            
        case 1:
        {
            cell.hourName.text = LocalString(@"10:37");
            cell.weekendName.text = LocalString(@"星期二");
            cell.status.text = LocalString(@"开关:关");
            cell.plugSwitch.on = NO;
        }
            break;
            
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellAddTiming_Height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    footView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(23.f, 0, ScreenWidth, 44.f)];
    textLabel.textColor = [UIColor colorWithRed:124/255.0 green:124/255.0 blue:123/255.0 alpha:1.0];
    textLabel.font = [UIFont systemFontOfSize:14.f];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.backgroundColor = [UIColor clearColor];
    [footView addSubview:textLabel];
    textLabel.text = LocalString(@"定时可能存在30s的误差");
    
    return footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return HEIGHT_FOOT;
}

@end
