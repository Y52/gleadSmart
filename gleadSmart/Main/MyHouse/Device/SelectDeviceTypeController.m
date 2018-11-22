//
//  SelectDeviceTypeController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "SelectDeviceTypeController.h"
#import "TouchTableView.h"
#import "SelectDeviceTypeCell.h"

NSString *const CellIdentifier_SelectDeviceType = @"CellID_SelectDeviceType";
static CGFloat const Cell_Height = 40.f;

@interface SelectDeviceTypeController () <UITableViewDataSource,UITableViewDelegate>
#warning TODO 完成设备类型选择UI 
@property (strong, nonatomic) UITableView *deviceTypeTable;

@end

@implementation SelectDeviceTypeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"选择设备类型");
    
    self.deviceTypeTable = [self deviceTypeTable];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
}
#pragma mark - Lazy Load
-(UITableView *)deviceTypeTable{
    if (!_deviceTypeTable) {
        _deviceTypeTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,260) style:UITableViewStylePlain];
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
    return 4;
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
            cell.deviceName.text = LocalString(@"中央控制器");
            cell.deviceImage.image = [UIImage imageNamed:@"img_wallHob"];
        }
            break;
        case 1:
        {
            cell.deviceName.text = LocalString(@"温控器（LoRa）");
            cell.deviceImage.image = [UIImage imageNamed:@"img_wallHob"];
        }
            break;
        case 2:
        {
            cell.deviceName.text = LocalString(@"壁挂炉调节器（LoRa）");
            cell.deviceImage.image = [UIImage imageNamed:@"img_wallHob"];
        }
            break;
        case 3:
        {
            cell.deviceName.text = LocalString(@"无线阀门（LoRa）");
            cell.deviceImage.image = [UIImage imageNamed:@"img_wallHob"];
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
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"所有设备";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}


@end
