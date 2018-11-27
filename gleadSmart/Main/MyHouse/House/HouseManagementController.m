//
//  HouseManagementController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HouseManagementController.h"
#import "HouseManagementTableViewCell.h"
#import "AddFamilyViewController.h"
#import "HouseNameCell.h"

NSString *const CellIdentifier_HouseManagement = @"CellID_HouseManagement";
NSString *const CellIdentifier_HouseManagementAdd = @"CellID_HouseManagementAdd";

static CGFloat const Cell_Height = 50.f;
static CGFloat const Header_Height = 25.f;

@interface HouseManagementController () <UITableViewDataSource,UITableViewDelegate>

#warning TODO 完成家庭管理UI
@property (nonatomic, strong) UITableView *HouseManagement;

@end

@implementation HouseManagementController

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"家庭管理");
    
    self.HouseManagement = [self HouseManagement];
}

#pragma mark - Lazy Load
-(UITableView *)HouseManagement{
    if (!_HouseManagement) {
        _HouseManagement = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,260) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[HouseNameCell class] forCellReuseIdentifier:CellIdentifier_HouseManagement];
            [tableView registerClass:[HouseManagementTableViewCell class] forCellReuseIdentifier:CellIdentifier_HouseManagementAdd];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = NO;
            tableView;
        });
    }
    return _HouseManagement;
}
#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            return [Database shareInstance].houseList.count;
        }
            break;
            
        case 1:
        {
            return 1;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            HouseNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseManagement];
            if (cell == nil) {
                cell = [[HouseNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseManagement];
            }
            HouseModel *house = [Database shareInstance].houseList[indexPath.row];
            cell.houseName.text = house.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
            break;
            
        case 1:
        {
            HouseManagementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseManagementAdd];
            if (cell == nil) {
                cell = [[HouseManagementTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseManagementAdd];
            }
            return cell;
        }
            break;
            
        default:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseManagement];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseManagement];
            }
            return cell;
        }
          break;
      }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        AddFamilyViewController *addVC = [[AddFamilyViewController alloc] init];
        [self.navigationController pushViewController:addVC animated:YES];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return Cell_Height;
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    
    return view ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 5.f;
    }else if (section == 1){
        return Header_Height;
    }
    return 0;
}

@end
