//
//  ShareDeviceListController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/27.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "ShareDeviceListController.h"
#import "ShareDeviceListCell.h"
#import "ShareDeviceDetailController.h"

NSString *const CellIdentifier_ShareDeviceList = @"Cell_ShareDeviceList";
static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 40.f;

@interface ShareDeviceListController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *deviceListTable;
@property (nonatomic, strong) NSMutableArray *shareDeviceList;


@end

@implementation ShareDeviceListController


#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor;
    self.navigationItem.title = LocalString(@"我收到的共享");
    
    self.deviceListTable = [self deviceListTable];
#warning TODO 共享设备列表页面
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
}

#pragma mark - private methods

#pragma mark - setters and getters

#pragma mark - Lazy Load

- (UITableView *)deviceListTable{
    if (!_deviceListTable) {
        _deviceListTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 100.f) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[ShareDeviceListCell class] forCellReuseIdentifier:CellIdentifier_ShareDeviceList];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _deviceListTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return self.shareDeviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShareDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ShareDeviceList];
    cell.backgroundColor = [UIColor whiteColor];
    if (cell == nil) {
        cell = [[ShareDeviceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ShareDeviceList];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row == 0) {
        cell.leftLabel.text = LocalString(@"哈哈");

    }
    return cell;
    
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
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textLabel];
    textLabel.text = LocalString(@"您收到的共享设备，对您的家庭成员不可见");
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, 13));
        make.centerY.equalTo(headerView.mas_centerY);
        make.centerX.equalTo(headerView.mas_centerX);
    }];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        ShareDeviceDetailController *ShareDeviceDetailVC = [[ShareDeviceDetailController alloc] init];
        [self.navigationController pushViewController:ShareDeviceDetailVC animated:YES];
    }
    
}


@end
