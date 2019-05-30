//
//  PlugOutletElectricityController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/5/22.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "PlugOutletElectricityController.h"
#import "PlugOutletSettingController.h"
#import "PlugOutleDatatStatisticsCell.h"

NSString *const CellIdentifier_PlugOutleDatatStatistics = @"CellID_PlugOutleDatatStatistics";
static float HEIGHT_CELL = 44.f;
static float HEIGHT_HEADER = 30.f;

@interface PlugOutletElectricityController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UIView *todayElectricityView;
@property (strong, nonatomic) UIImageView *todayElectricityImage;
@property (strong, nonatomic) UILabel *todayDegreeLabel;
@property (strong, nonatomic) UIView *listView;

@property (strong, nonatomic) UILabel *todayElectricityLabel;

@property (strong, nonatomic) UILabel *currentLabel;
@property (strong, nonatomic) UILabel *currentValueLabel; //当前电流
@property (strong, nonatomic) UILabel *powerLabel;
@property (strong, nonatomic) UILabel *powerValueLabel;//当前功率
@property (strong, nonatomic) UILabel *voltageLabel;
@property (strong, nonatomic) UILabel *voltageValueLabel;//当前电压
@property (strong, nonatomic) UILabel *electricityLabel;
@property (strong, nonatomic) UILabel *electricityValueLabel;//总电量

@property (strong, nonatomic) UITableView *timeTableView;


@end

@implementation PlugOutletElectricityController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithHexString:@"EAE9E8"].CGColor;
    [self setNavItem];
    
    self.todayElectricityView = [self todayElectricityView];
    self.todayElectricityImage = [self todayElectricityImage];
    self.todayDegreeLabel = [self todayDegreeLabel];
    self.todayElectricityLabel = [self todayElectricityLabel];
    self.listView = [self listView];
    self.timeTableView = [self timeTableView];
    [self getElectricityBySocket];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getElectricityValue:) name:@"getElectricityValue" object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getElectricityValue" object:nil];
}

#pragma mark - notification

- (void)getElectricityValue:(NSNotification *)nsnotification
{
    NSDictionary *userInfo = [nsnotification userInfo];
    NSString *voltage = [userInfo objectForKey:@"Voltage"];
    NSString *current = [userInfo objectForKey:@"Current"];
    NSString *power = [userInfo objectForKey:@"Power"];
    NSString *todayEnergyUsed = [userInfo objectForKey:@"todayEnergyUsed"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        self.voltageValueLabel.text = voltage;
        self.currentValueLabel.text = current;
        self.powerValueLabel.text = power;
        self.todayDegreeLabel.text = todayEnergyUsed;
    });
    
}

#pragma mark - private methods

- (void)getElectricityBySocket{
    UInt8 controlCode = 0x00;
    NSArray *data = @[@0xFC,@0x11,@0x10,@0x00];
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
    [SVProgressHUD show];
}

- (void)goSetting{
    PlugOutletSettingController *VC = [[PlugOutletSettingController alloc] init];
    VC.device = self.device;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - getters and setters

- (void)setNavItem{
    self.navigationItem.title = LocalString(@"电量统计");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"thermostatMoer"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UIView *)todayElectricityView{
    if (!_todayElectricityView) {
        _todayElectricityView = [[UIView alloc] init];
        _todayElectricityView.backgroundColor = [UIColor colorWithRed:130/255.0 green:181/255.0 blue:244/255.0 alpha:1.0];
        [self.view addSubview:_todayElectricityView];
        [_todayElectricityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, yAutoFit(238.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(20.f);
            
        }];
    }
    return _todayElectricityView;
}

- (UIImageView *)todayElectricityImage{
    if (!_todayElectricityImage) {
        _todayElectricityImage = [[UIImageView alloc] init];
        _todayElectricityImage.image = [UIImage imageNamed:@"currenttemperature"];
        [self.todayElectricityView addSubview:_todayElectricityImage];
        [_todayElectricityImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(158.f), yAutoFit(147.f)));
            make.centerX.equalTo(self.todayElectricityView.mas_centerX);
            make.centerY.equalTo(self.todayElectricityView.mas_centerY).offset(-yAutoFit(15.f));
        }];
    }
    return _todayElectricityImage;
}

- (UILabel *)todayElectricityLabel{
    if (!_todayElectricityLabel) {
        _todayElectricityLabel = [[UILabel alloc] init];
        _todayElectricityLabel.text = LocalString(@"今日电量(度)");
        _todayElectricityLabel.textAlignment = NSTextAlignmentCenter;
        _todayElectricityLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:254/255.0 alpha:1];
        _todayElectricityLabel.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        [self.todayElectricityView addSubview:_todayElectricityLabel];
        [_todayElectricityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), yAutoFit(13.f)));
            make.top.equalTo(self.todayElectricityView.mas_top).offset(yAutoFit(20.f));
            make.right.equalTo(self.todayElectricityView.mas_right).offset(-yAutoFit(15.f));
        }];
    }
    return _todayElectricityLabel;
}

- (UILabel *)todayDegreeLabel{
    if (!_todayDegreeLabel) {
        _todayDegreeLabel = [[UILabel alloc] init];
        _todayDegreeLabel.textAlignment = NSTextAlignmentCenter;
        _todayDegreeLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:254/255.0 alpha:1];
        _todayDegreeLabel.font = [UIFont fontWithName:@"Helvetica" size:30.f];
        _todayDegreeLabel.adjustsFontSizeToFitWidth = YES;
        _todayDegreeLabel.text = LocalString(@"");
        [self.todayElectricityView addSubview:_todayDegreeLabel];
        [_todayDegreeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(30.f)));
            make.centerX.equalTo(self.todayElectricityImage.mas_centerX);
            make.centerY.equalTo(self.todayElectricityImage.mas_centerY);
        }];
    }
    return _todayDegreeLabel;
}

- (UIView *)listView{
    if (!_listView) {
        _listView = [[UIView alloc] init];
        _listView.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        [self.view addSubview:_listView];
        [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth - 20.f, yAutoFit(75.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.todayElectricityView.mas_bottom).offset(-yAutoFit(20.f));
            
        }];
        
        _currentLabel = [[UILabel alloc] init];
        _currentLabel.text = LocalString(@"当前电流(mA)");
        _currentLabel.textAlignment = NSTextAlignmentCenter;
        _currentLabel.adjustsFontSizeToFitWidth = YES;
        _currentLabel.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1];
        _currentLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        [self.listView addSubview:_currentLabel];
        [_currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(13.f)));
            make.left.equalTo(self.listView.mas_left).offset(yAutoFit(10.f));
            make.bottom.equalTo(self.listView.mas_centerY).offset(-yAutoFit(5.5f));
        }];
        
        _currentValueLabel = [[UILabel alloc] init];
        _currentValueLabel.text = LocalString(@"");
        _currentValueLabel.textAlignment = NSTextAlignmentCenter;
        _currentValueLabel.adjustsFontSizeToFitWidth = YES;
        _currentValueLabel.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1];
        _currentValueLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        [self.listView addSubview:_currentValueLabel];
        [_currentValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(13.f)));
            make.left.equalTo(self.listView.mas_left).offset(yAutoFit(10.f));
            make.top.equalTo(self.listView.mas_centerY).offset(yAutoFit(5.5f));
        }];
        
        _powerLabel = [[UILabel alloc] init];
        _powerLabel.text = LocalString(@"当前功耗(W)");
        _powerLabel.textAlignment = NSTextAlignmentCenter;
        _powerLabel.adjustsFontSizeToFitWidth = YES;
        _powerLabel.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1];
        _powerLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        [self.listView addSubview:_powerLabel];
        [_powerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(13.f)));
            make.left.equalTo(self.currentLabel.mas_right).offset(yAutoFit(10.f));
            make.bottom.equalTo(self.listView.mas_centerY).offset(-yAutoFit(5.5f));
        }];
        
        _powerValueLabel = [[UILabel alloc] init];
        _powerValueLabel.text = LocalString(@"");
        _powerValueLabel.textAlignment = NSTextAlignmentCenter;
        _powerValueLabel.adjustsFontSizeToFitWidth = YES;
        _powerValueLabel.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1];
        _powerValueLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        [self.listView addSubview:_powerValueLabel];
        [_powerValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(13.f)));
            make.left.equalTo(self.currentValueLabel.mas_right).offset(yAutoFit(10.f));
            make.top.equalTo(self.listView.mas_centerY).offset(yAutoFit(5.5f));
        }];
        
        _voltageLabel = [[UILabel alloc] init];
        _voltageLabel.text = LocalString(@"当前电压(V)");
        _voltageLabel.textAlignment = NSTextAlignmentCenter;
        _voltageLabel.adjustsFontSizeToFitWidth = YES;
        _voltageLabel.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1];
        _voltageLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        [self.listView addSubview:_voltageLabel];
        [_voltageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(13.f)));
            make.left.equalTo(self.powerLabel.mas_right).offset(yAutoFit(10.f));
            make.bottom.equalTo(self.listView.mas_centerY).offset(-yAutoFit(5.5f));
        }];
        
        _voltageValueLabel = [[UILabel alloc] init];
        _voltageValueLabel.text = LocalString(@"");
        _voltageValueLabel.textAlignment = NSTextAlignmentCenter;
        _voltageValueLabel.adjustsFontSizeToFitWidth = YES;
        _voltageValueLabel.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1];
        _voltageValueLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        [self.listView addSubview:_voltageValueLabel];
        [_voltageValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(13.f)));
            make.left.equalTo(self.powerValueLabel.mas_right).offset(yAutoFit(10.f));
            make.top.equalTo(self.listView.mas_centerY).offset(yAutoFit(5.5f));
        }];
        
        _electricityLabel = [[UILabel alloc] init];
        _electricityLabel.text = LocalString(@"总电量(度)");
        _electricityLabel.textAlignment = NSTextAlignmentCenter;
        _electricityLabel.adjustsFontSizeToFitWidth = YES;
        _electricityLabel.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1];
        _electricityLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        [self.listView addSubview:_electricityLabel];
        [_electricityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(13.f)));
            make.right.equalTo(self.listView.mas_right).offset(-yAutoFit(5.f));
            make.bottom.equalTo(self.listView.mas_centerY).offset(-yAutoFit(5.5f));
        }];
        
        _electricityValueLabel = [[UILabel alloc] init];
        _electricityValueLabel.text = LocalString(@"");
        _electricityValueLabel.textAlignment = NSTextAlignmentCenter;
        _electricityValueLabel.adjustsFontSizeToFitWidth = YES;
        _electricityValueLabel.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1];
        _electricityValueLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        [self.listView addSubview:_electricityValueLabel];
        [_electricityValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(13.f)));
            make.right.equalTo(self.listView.mas_right).offset(-yAutoFit(5.f));
            make.top.equalTo(self.listView.mas_centerY).offset(yAutoFit(5.5f));
        }];
        
    }
    return _listView;
}

- (UITableView *)timeTableView{
    if (!_timeTableView) {
        _timeTableView = ({
            UITableView *tableView = [[UITableView alloc] init];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[PlugOutleDatatStatisticsCell class] forCellReuseIdentifier:CellIdentifier_PlugOutleDatatStatistics];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            
            [self.view addSubview:tableView];
            tableView.scrollEnabled = YES;
            
            [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(ScreenWidth, yAutoFit(ScreenHeight - 320)));
                make.top.equalTo(self.listView.mas_bottom).offset(yAutoFit(10.f));
                make.centerX.equalTo(self.view.mas_centerX);
            }];
            tableView;
        });
    }
    return _timeTableView;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
        {
            PlugOutleDatatStatisticsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_PlugOutleDatatStatistics];
            if (cell == nil) {
                cell = [[PlugOutleDatatStatisticsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_PlugOutleDatatStatistics];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if (indexPath.row == 0) {
                cell.leftName.text = LocalString(@"二月");
                cell.rightName.text = LocalString(@"3.19");
            }
            if (indexPath.row == 1) {
                cell.leftName.text = LocalString(@"一月");
                cell.rightName.text = LocalString(@"3.11");
            }
            return cell;
        }
            break;
            
        default:
        {
            PlugOutleDatatStatisticsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_PlugOutleDatatStatistics];
            if (cell == nil) {
                cell = [[PlugOutleDatatStatisticsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_PlugOutleDatatStatistics];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.leftName.text = LocalString(@"二月");
                cell.rightName.text = LocalString(@"3.19");
            }
            if (indexPath.row == 1) {
                cell.leftName.text = LocalString(@"一月");
                cell.rightName.text = LocalString(@"3.11");
            }
            
            return cell;
        }
            break;
            
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
    headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    
    switch (section) {
        case 0:
        {
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
            textLabel.textColor = [UIColor colorWithHexString:@"999999"];
            textLabel.font = [UIFont systemFontOfSize:13.f];
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.backgroundColor = [UIColor clearColor];
            [headerView addSubview:textLabel];
            textLabel.text = LocalString(@"2019年");
            
            [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(80, 13));
                make.centerY.equalTo(headerView.mas_centerY);
                make.left.equalTo(headerView.mas_left).offset(20);
            }];
            
            return headerView;
        }
            break;
        case 1:
        {
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER + HEIGHT_CELL * 2 )];
            textLabel.textColor = [UIColor colorWithHexString:@"999999"];
            textLabel.font = [UIFont systemFontOfSize:13.f];
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.backgroundColor = [UIColor clearColor];
            [headerView addSubview:textLabel];
            textLabel.text = LocalString(@"2018年");
            
            [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(120, 13));
                make.centerY.equalTo(headerView.mas_centerY);
                make.left.equalTo(headerView.mas_left).offset(20);
            }];
            
            return headerView;
        }
            break;
            
        default:
            
            break;
    }
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER;
}

@end
