//
//  PlugOutletSaveTimingController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/17.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//


#import "PlugOutletTimingController.h"
#import "PlugOutletAddTimingController.h"
#import "PlugOutletSaveAddTimingCell.h"
#import "ClockModel.h"

NSString *const CellIdentifier_PlugOutletTimingCell = @"CellID_PlugOutletTiming";

CGFloat const cellAddTiming_Height = 68.f;
static float HEIGHT_FOOT = 20.f;

@interface PlugOutletTimingController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *timingTable;
@property (nonatomic, strong) UIButton *addTimingBtn;

@property (nonatomic, strong) NSMutableArray *clockList;

@end

@implementation PlugOutletTimingController

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    self.navigationItem.title = LocalString(@"添加设备");
    
    self.timingTable = [self timingTable];
    self.addTimingBtn = [self addTimingBtn];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getClockList:) name:@"getClockList" object:nil];
    [self getClockListBySocket];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getClockList" object:nil];
}
#pragma mark - private methods
- (void)getClockListBySocket{
    UInt8 controlCode = 0x00;
    NSArray *data = @[@0xFC,@0x11,@0x03,@0x00];
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
}

- (void)addTiming{
    if (self.clockList.count >= 4) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"定时器数量已经达到额度") message:LocalString(@"请先删除一个定时再添加") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    PlugOutletAddTimingController *addVC = [[PlugOutletAddTimingController alloc] init];
    addVC.device = self.device;
    addVC.clock = [[ClockModel alloc] init];
    for (int i = 0; i < self.clockList.count; i++) {
        ClockModel *clock = self.clockList[i];
        if (addVC.clock.number == clock.number) {
            addVC.clock.number++;
        }else{
            break;
        }
    }
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - nsnotification
- (void)getClockList:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSMutableArray *frame = [userInfo objectForKey:@"frame"];
    NSString *mac= [userInfo objectForKey:@"mac"];

    if ([mac isEqualToString:self.device.mac]) {
        if (!self.clockList) {
            self.clockList = [[NSMutableArray alloc] init];
        }
        [self.clockList removeAllObjects];
        
        for (int i = 0; i < 5; i++) {
            if (![frame[13+i*6] intValue]) {
                //无效状态
                continue;
            }
            ClockModel *clock = [[ClockModel alloc] init];
            clock.number = [frame[12+i*6] intValue] & 0x0f;
            if ([frame[13+i*6] intValue] == 1) {
                clock.isOn = YES;
            }else{
                clock.isOn = NO;
            }
            clock.week = [frame[14+i*6] intValue];
            clock.hour = [frame[15+i*6] intValue];
            clock.minute = [frame[16+i*6] intValue];
            clock.action = [frame[17+i*6] intValue];
            [self.clockList addObject:clock];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.timingTable reloadData];
    });
}

#pragma mark - setters and getters
- (UITableView *)timingTable{
    if (!_timingTable) {
        _timingTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - getRectNavAndStatusHight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            tableView.scrollEnabled = NO;
            [tableView registerClass:[PlugOutletSaveAddTimingCell class] forCellReuseIdentifier:CellIdentifier_PlugOutletTimingCell];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _timingTable;
}

- (UIButton *)addTimingBtn{
    if (!_addTimingBtn) {
        _addTimingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addTimingBtn setTitle:LocalString(@"添加定时") forState:UIControlStateNormal];
        [_addTimingBtn setTitleColor:[UIColor colorWithHexString:@"639DF8"] forState:UIControlStateNormal];
        [_addTimingBtn setBackgroundColor:[UIColor whiteColor]];
        [_addTimingBtn addTarget:self action:@selector(addTiming) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_addTimingBtn];
        [_addTimingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(276.f), 44.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_bottom).offset(-100.f);
        }];
        _addTimingBtn.layer.cornerRadius = 22.f;
        _addTimingBtn.layer.borderWidth = 1.f;
        _addTimingBtn.layer.borderColor = [UIColor colorWithHexString:@"3987F8"].CGColor;
        
    }
    return _addTimingBtn;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.clockList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlugOutletSaveAddTimingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_PlugOutletTimingCell];
    if (cell == nil) {
        cell = [[PlugOutletSaveAddTimingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_PlugOutletTimingCell];
    }
    cell.backgroundColor = [UIColor whiteColor];
    ClockModel *clock = self.clockList[indexPath.row];
    cell.hourName.text = [clock getTimeString];
    cell.weekendName.text = [clock getWeekString];
    cell.status.text = [clock getClockActionString];
    cell.plugSwitch.on = clock.isOn;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellAddTiming_Height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    footView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(23.f, 0, ScreenWidth, 44.f)];
    textLabel.textColor = [UIColor colorWithRed:124/255.0 green:124/255.0 blue:123/255.0 alpha:1.0];
    textLabel.font = [UIFont systemFontOfSize:14.f];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.backgroundColor = [UIColor clearColor];
    [footView addSubview:textLabel];
    textLabel.text = LocalString(@"定时可能存在30s的误差");
    
    return footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return HEIGHT_FOOT;
}

@end
