//
//  ThermostatTimerController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/3.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "ThermostatTimerController.h"
#import "ThermostatAddTimerController.h"
#import "TherTimerCell.h"

NSString *const CellIdentifier_TherTimerCell = @"CellID_TherTimerCell";
static CGFloat const Cell_Height = 70.f;
static CGFloat const Header_Height = 45.f;

@interface ThermostatTimerController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIView *noTimerView;
@property (strong, nonatomic) UIButton *addTimerButton;

@property (strong, nonatomic) UITableView *timerTable;
@property (strong, nonatomic) NSMutableArray *timerArray;

@end

@implementation ThermostatTimerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    
    self.noTimerView = [self noTimerView];
    self.addTimerButton = [self addTimerButton];
    self.timerTable = [self timerTable];
}

#pragma mark - Lazy load
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加定时");
}

- (UIView *)noTimerView{
    if (!_noTimerView) {
        _noTimerView = [[UIView alloc] init];
        _noTimerView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight);
        _noTimerView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
        [self.view addSubview:_noTimerView];
        
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_thermos_moTimer"]];
        image.frame = CGRectMake((ScreenWidth - 139.f)/2.f, getRectNavAndStatusHight + yAutoFit(180.f), 139.f, 109.f);
        [_noTimerView addSubview:image];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - 200.f)/2, getRectNavAndStatusHight + yAutoFit(180.f) + 109.f + 30.f, 200.f, 23.f)];
        label.font = [UIFont systemFontOfSize:15.f];
        label.textColor = [UIColor colorWithRed:120/255.0 green:117/255.0 blue:117/255.0 alpha:1.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = LocalString(@"暂无定时，请添加");
        [_noTimerView addSubview:label];
    }
    return _noTimerView;
}

- (UIButton *)addTimerButton{
    if (!_addTimerButton) {
        _addTimerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addTimerButton setTitle:LocalString(@"添加定时") forState:UIControlStateNormal];
        [_addTimerButton setTitleColor:[UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_addTimerButton addTarget:self action:@selector(addTimer) forControlEvents:UIControlEventTouchUpInside];
        [self.noTimerView addSubview:_addTimerButton];
        [_addTimerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), 40.f));
            make.centerX.equalTo(self.noTimerView.mas_centerX);
            make.bottom.equalTo(self.noTimerView.mas_bottom).offset(-yAutoFit(60.f));
        }];
        _addTimerButton.layer.borderWidth = 1.f;
        _addTimerButton.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1.0].CGColor;
        _addTimerButton.layer.cornerRadius = 20.f;
    }
    return _addTimerButton;
}

- (UITableView *)timerTable{
    if (!_timerTable) {
        _timerTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 200.f, ScreenWidth, self.view.frame.size.height - getRectNavAndStatusHight - 200.f)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.hidden = YES;
            tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[TherTimerCell class] forCellReuseIdentifier:CellIdentifier_TherTimerCell];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _timerTable;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _timerArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TherTimerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_TherTimerCell];
    if (cell == nil) {
        cell = [[TherTimerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_TherTimerCell];
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
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(23.f, 0, ScreenWidth, Header_Height)];
    textLabel.textColor = [UIColor colorWithRed:40/255.0 green:121/255.0 blue:255/255.0 alpha:1.0];
    textLabel.font = [UIFont systemFontOfSize:14.f];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = LocalString(@"定时可能会存在30秒左右误差");
    [headerView addSubview:textLabel];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Header_Height;
}

#pragma mark - Actions
- (void)addTimer{
    ThermostatAddTimerController *addTimerVC = [[ThermostatAddTimerController alloc] init];
    [self.navigationController pushViewController:addTimerVC animated:YES];
}
@end
