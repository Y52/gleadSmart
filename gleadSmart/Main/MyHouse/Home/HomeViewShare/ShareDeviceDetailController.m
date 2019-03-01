//
//  ShareDeviceDetailController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/27.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "ShareDeviceDetailController.h"
#import "ShareDeviceDetailCell.h"

NSString *const CellIdentifier_ShareDeviceDetail = @"Cell_ShareDeviceDetail";
static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 40.f;

@interface ShareDeviceDetailController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *deviceDetailTable;

@end

@implementation ShareDeviceDetailController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor;
    self.navigationItem.title = LocalString(@"共享详情");
    self.deviceDetailTable = [self deviceDetailTable];
    
#warning TODO 共享设备详情页面
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
}

#pragma mark - private methods

#pragma mark - setters and getters

#pragma mark - Lazy Load

- (UITableView *)deviceDetailTable{
    if (!_deviceDetailTable) {
        _deviceDetailTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 100.f) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[ShareDeviceDetailCell class] forCellReuseIdentifier:CellIdentifier_ShareDeviceDetail];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _deviceDetailTable;
}

#pragma mark - uitableview delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 2;
    }
    if (section == 1) {
       // return self.shareDeviceList.count;
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShareDeviceDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ShareDeviceDetail];
    cell.backgroundColor = [UIColor whiteColor];
    if (cell == nil) {
        cell = [[ShareDeviceDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ShareDeviceDetail];
    }
    if (indexPath.section == 0){
        if (indexPath.row == 0) {
            cell.leftLabel.text = LocalString(@"共享来自");
            cell.rightLabel.text = LocalString(@"杭州");
            return cell;
        }else{
            cell.leftLabel.text = LocalString(@"备注");
            cell.rightLabel.text = LocalString(@"哈哈");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.deviceLabel.text = LocalString(@"床头灯");
            cell.leftImage.image = [UIImage imageNamed:@"img_mine_editPW"];
            return cell;
        }else{
            cell.deviceLabel.text = LocalString(@"客厅小灯");
            cell.leftImage.image = [UIImage imageNamed:@"img_mine_logout"];
            return cell;
        }
    }else{
        return cell;
    }
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
    if (section == 1) {
        textLabel.text = LocalString(@"您收到的共享");
        
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 13));
            make.centerY.equalTo(headerView.mas_centerY);
            make.left.equalTo(headerView.mas_left).offset(20);
        }];
    }
    

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }else{
        return HEIGHT_HEADER;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
