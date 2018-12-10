//
//  NodeDetailViewController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/8.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "NodeDetailViewController.h"
#import "NodeInfoCell.h"

NSString *const CellIdentifier_ValveDetailInfo = @"CellID_ValveDetailInfo";
static CGFloat const Cell_Height = 44.f;

@interface NodeDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *nodeDetailTable;

@end

@implementation NodeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    
    self.nodeDetailTable = [self nodeDetailTable];
}

#pragma mark - Lazy load
- (UITableView *)nodeDetailTable{
    if (!_nodeDetailTable) {
        _nodeDetailTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - getRectNavAndStatusHight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            tableView.scrollEnabled = NO;
            [tableView registerClass:[NodeInfoCell class] forCellReuseIdentifier:CellIdentifier_ValveDetailInfo];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _nodeDetailTable;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NodeInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ValveDetailInfo];
    if (cell == nil) {
        cell = [[NodeInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ValveDetailInfo];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row) {
        case 0:
        {
            cell.leftLabel.text = LocalString(@"节点序号");
            cell.infoLabel.text = @"3";
        }
            break;
            
        case 1:
        {
            cell.leftLabel.text = LocalString(@"节点名称");
            cell.infoLabel.text = @"节点000";
        }
            break;
            
        case 2:
        {
            cell.leftLabel.text = LocalString(@"节点位置");
            cell.infoLabel.text = @"主卧";
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
    return Cell_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    headerView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(23.f, 0, ScreenWidth, 44.f)];
    textLabel.textColor = [UIColor colorWithRed:124/255.0 green:124/255.0 blue:123/255.0 alpha:1.0];
    textLabel.font = [UIFont systemFontOfSize:14.f];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textLabel];
    textLabel.text = LocalString(@"基本信息");

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.f;
}

@end
