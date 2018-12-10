//
//  ThermostatAddTimerController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/3.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ThermostatAddTimerController.h"
#import "TherAddTimerWeekCell.h"
#import "TherAddTimerSwitchCell.h"
#import "TherWeekSelectController.h"

NSString *const CellIdentifier_TherAddTimerWeek = @"CellID_TherAddTimerWeek";
NSString *const CellIdentifier_TherAddTimerSwitch = @"CellID_TherAddTimerSwitch";
static CGFloat const Cell_Height = 44.f;

@interface ThermostatAddTimerController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIDatePicker *timerPicker;
@property (strong, nonatomic) UITableView *addTimerTable;

@end

@implementation ThermostatAddTimerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    [self setNavItem];
    
    self.timerPicker = [self timerPicker];
    self.addTimerTable = [self addTimerTable];
}

#pragma mark - Lazy load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加定时");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setTitle:@"保存" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(completeAddTimer) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}

- (UIDatePicker *)timerPicker{
    if (!_timerPicker) {
        _timerPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 200.f)];
        _timerPicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
        _timerPicker.datePickerMode = UIDatePickerModeTime;
        _timerPicker.calendar = [NSCalendar currentCalendar];
        [_timerPicker addTarget:self action:@selector(timeChange:) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:_timerPicker];
    }
    return _timerPicker;
}

- (UITableView *)addTimerTable{
    if (!_addTimerTable) {
        _addTimerTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 200.f, ScreenWidth, self.view.frame.size.height - getRectNavAndStatusHight - 200.f)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[TherAddTimerWeekCell class] forCellReuseIdentifier:CellIdentifier_TherAddTimerWeek];
            [tableView registerClass:[TherAddTimerSwitchCell class] forCellReuseIdentifier:CellIdentifier_TherAddTimerSwitch];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _addTimerTable;
}


#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TherAddTimerWeekCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_TherAddTimerWeek];
        if (cell == nil) {
            cell = [[TherAddTimerWeekCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_TherAddTimerWeek];
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.leftImage.image = [UIImage imageNamed:@"img_ther_addTimerWeek"];
        cell.leftLabel.text = LocalString(@"重复");
        cell.rightLabel.text = LocalString(@"仅限一次");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else{
        TherAddTimerSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_TherAddTimerSwitch];
        if (cell == nil) {
            cell = [[TherAddTimerSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_TherAddTimerSwitch];
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.leftImage.image = [UIImage imageNamed:@"img_ther_addTimerSwitch"];
        cell.leftLabel.text = LocalString(@"开关");
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        TherWeekSelectController *weekVC = [[TherWeekSelectController alloc] init];
        weekVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        weekVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:weekVC animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    headerView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15.f;
}

#pragma mark - Actions
- (void)timeChange:(UIDatePicker *)timerPicker{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH : mm";
    NSString *dateStr = [formatter stringFromDate:timerPicker.date];
    NSLog(@"%@",dateStr);
}

- (void)completeAddTimer{
    
}
@end
