//
//  ValveAlertInfoController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/9.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "NTCValveAlertInfoController.h"
#import "NodeDetailCell.h"
#import "alarmModel.h"


NSString *const CellIdentifier_NTCValveAlert = @"CellID_NTCValveAlert";

CGFloat const cellAlert_NTCHeight = 44.f;

@interface NTCValveAlertInfoController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *nodeLeakDetailTable;

@end

@implementation NTCValveAlertInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithHexString:@"EAE9E8"].CGColor;
    self.navigationItem.title = LocalString(@"漏水详情");
    self.nodeLeakDetailTable = [self nodeLeakDetailTable];
    
}

-(UITableView *)nodeLeakDetailTable{
    if (!_nodeLeakDetailTable) {
        _nodeLeakDetailTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.frame.size.height)];
            
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
            tableView.scrollEnabled = NO;
            [tableView registerClass:[NodeDetailCell class] forCellReuseIdentifier:CellIdentifier_NTCValveAlert];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
        [_nodeLeakDetailTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth,ScreenHeight));
            make.top.equalTo(self.view.mas_top).offset(yAutoFit(30.f));
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _nodeLeakDetailTable;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.leakAlertInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NodeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_NTCValveAlert];
    if (cell == nil) {
        cell = [[NodeDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_NTCValveAlert];
    }
    alarmModel *alarm = [self.leakAlertInfo objectAtIndex:indexPath.row];
    cell.leakImage.image = [UIImage imageNamed:@"nodeLeakBig_abnormal"];
    cell.detailLabel.text = alarm.room;
    cell.dateLabel.text = [NSDate localStringFromUTCDate:alarm.time];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellAlert_NTCHeight;
}


@end
