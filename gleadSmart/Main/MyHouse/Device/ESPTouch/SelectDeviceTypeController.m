//
//  SelectDeviceTypeController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "SelectDeviceTypeController.h"
#import "SelectDeviceTypeCell.h"
#import "DeviceViewController.h"
#import "StatusConfirmController.h"

NSString *const CellIdentifier_SelectDeviceType = @"CellID_SelectDeviceType";
static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 40.f;

#warning 捷诺项目显示插座和开关
static int deviceCount = 2;

@interface SelectDeviceTypeController () <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) UITableView *deviceTypeTable;

@end

@implementation SelectDeviceTypeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    [self setNavItem];
    self.deviceTypeTable = [self deviceTypeTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    Network *net = [Network shareNetwork];
    net.isDeviceVC = NO;
    [net.udpSocket beginReceiving:nil];
    [net.udpTimer setFireDate:[NSDate date]];
}

#pragma mark - private methods
- (void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Lazy Load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"选择设备类型");
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 30, 30);
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarButton;

}

- (UITableView *)deviceTypeTable{
    if (!_deviceTypeTable) {
        _deviceTypeTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[SelectDeviceTypeCell class] forCellReuseIdentifier:CellIdentifier_SelectDeviceType];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = NO;
            tableView;
        });
    }
    return _deviceTypeTable;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return deviceCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectDeviceTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_SelectDeviceType];
    if (cell == nil) {
        cell = [[SelectDeviceTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_SelectDeviceType];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row) {
        case 0:
        {
            cell.deviceName.text = LocalString(@"插座");
            cell.deviceImage.image = [UIImage imageNamed:@"img_plug_icon"];
        }
            break;
            
        case 1:
        {
            cell.deviceName.text = LocalString(@"开关");
            cell.deviceImage.image = [UIImage imageNamed:@"img_switch_icon_4"];
        }
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    StatusConfirmController *scVC = [[StatusConfirmController alloc] init];
    [self.navigationController pushViewController:scVC animated:YES];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
    headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
    textLabel.textColor = [UIColor colorWithHexString:@"999999"];
    textLabel.font = [UIFont systemFontOfSize:13.f];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textLabel];
    textLabel.text = LocalString(@"所有设备");
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 13));
        make.centerY.equalTo(headerView.mas_centerY);
        make.left.equalTo(headerView.mas_left).offset(20);
    }];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER;
}

@end
