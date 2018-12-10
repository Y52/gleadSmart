//
//  TherWeekSelectController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/3.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "TherWeekSelectController.h"
#import "TherWeekSelCell.h"

NSString *const CellIdentifier_TherWeekSelect = @"CellID_TherWeekSelect";
static CGFloat const Cell_Height = 44.f;

@interface TherWeekSelectController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIButton *dismissButton;
@property (strong, nonatomic) UITableView *weekTable;
@property (strong, nonatomic) UIButton *confirmButton;

@end

@implementation TherWeekSelectController{
    NSArray *_weekList;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _weekList = @[@"星期天",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
    
    self.weekTable = [self weekTable];
    self.confirmButton = [self confirmButton];
    self.dismissButton = [self dismissButton];
}

#pragma mark - Lazy load
- (UITableView *)weekTable{
    if (!_weekTable) {
        _weekTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(18.f, yAutoFit(200.f), ScreenWidth - 18.f*2, Cell_Height * 7)];
            tableView.backgroundColor = [UIColor whiteColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            tableView.scrollEnabled = NO;
            [tableView registerClass:[TherWeekSelCell class] forCellReuseIdentifier:CellIdentifier_TherWeekSelect];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView.layer.cornerRadius = 5.f;
            
            tableView;
        });
    }
    return _weekTable;
}

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:LocalString(@"确定") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:[UIColor whiteColor]];
        [_confirmButton addTarget:self action:@selector(confirmSelectDate) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_confirmButton];
        [_confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(343.f), 44.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.weekTable.mas_bottom).offset(10.f);
        }];
        _confirmButton.layer.cornerRadius = 5.f;

    }
    return _confirmButton;
}

- (UIButton *)dismissButton{
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissButton.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        [_dismissButton setBackgroundColor:[UIColor clearColor]];
        [_dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:_dismissButton atIndex:0];
    }
    return _dismissButton;
}
#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TherWeekSelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_TherWeekSelect];
    if (cell == nil) {
        cell = [[TherWeekSelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_TherWeekSelect];
    }
    cell.leftLabel.text = _weekList[indexPath.row];
    cell.checkImage.image = [UIImage imageNamed:@"addFamily_uncheck"];
    cell.tag = yUnselect;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TherWeekSelCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == yUnselect) {
        cell.tag = ySelect;
        cell.checkImage.image = [UIImage imageNamed:@"addFamily_check"];
        //[self->checkedRoomArray addObject:cell.leftLabel.text];
    }else{
        cell.tag = yUnselect;
        cell.checkImage.image = [UIImage imageNamed:@"addFamily_uncheck"];
//        for (NSString *roomName in self->checkedRoomArray) {
//            if ([cell.leftLabel.text isEqualToString:roomName]) {
//                [self->checkedRoomArray removeObject:roomName];
//                break;
//            }
//        }
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
    return 0.f;
}

#pragma mark - Actions
- (void)confirmSelectDate{
    
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
