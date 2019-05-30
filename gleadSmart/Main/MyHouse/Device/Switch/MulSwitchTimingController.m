//
//  MulSwitchTimingController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/24.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "MulSwitchTimingController.h"
#import "MulSwitchAddTimingController.h"
#import "MulSwitchSaveAddTimingCell.h"
#import "ClockModel.h"
#import "MulSwitchEditTimingController.h"

NSString *const CellIdentifier_MulSwitchTimingCell = @"CellID_MulSwitchTiming";

CGFloat const cellMulSwitch_Height = 68.f;
static float HEIGHT_FOOT = 20.f;

@interface MulSwitchTimingController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *timingTable;
@property (nonatomic, strong) UIButton *addTimingBtn;

@property (nonatomic, strong) NSMutableArray *clockList;

@end

@implementation MulSwitchTimingController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSwitchClockList:) name:@"getSwitchClockList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchDeleteClock) name:@"switchDeleteClock" object:nil];
    [self getClockListBySocket];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getSwitchClockList" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"switchDeleteClock" object:nil];
}
#pragma mark - private methods
- (void)getClockListBySocket{
    UInt8 controlCode = 0x00;
    NSNumber *A = [NSNumber numberWithInt:self.switchNumber];
    NSArray *data = @[@0xFC,@0x11,@0x02,@0x00,A];
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
}

- (void)addTiming{
    if (self.clockList.count >= 5) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"定时器数量已经达到额度") message:LocalString(@"请先删除一个定时再添加") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    MulSwitchAddTimingController *addVC = [[MulSwitchAddTimingController alloc] init];
    addVC.device = self.device;
    addVC.switchNumber = self.switchNumber & 0x7f;
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

- (void)deleteClockListBySocket:(ClockModel *)clock{
    UInt8 controlCode = 0x01;
    NSNumber *A = [NSNumber numberWithInt:clock.number |(self.switchNumber & 0x7f)];
    NSNumber *B = @0;
    NSNumber *C = @0;
    NSNumber *D = @0;
    NSNumber *E = @0;
    NSNumber *F = @0;
    NSArray *data = @[@0xFC,@0x11,@0x02,@0x01,A,B,C,D,E,F];
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
    
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //异步等待4秒，如果未收到信息做如下处理
        sleep(4);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (switchDeleted == NO) {
                [SVProgressHUD dismiss];
                [NSObject showHudTipStr:LocalString(@"删除失败，请重试")];
            }else{
                switchDeleted = NO;
            }
        });
    });
}

#pragma mark - nsnotification
static bool switchDeleted = NO;
- (void)switchDeleteClock{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        switchDeleted = YES;
        //成功之后推送 刷新闹钟列表
        [self getClockListBySocket];
    });
}

- (void)getSwitchClockList:(NSNotification *)notification{
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
            [tableView registerClass:[MulSwitchSaveAddTimingCell class] forCellReuseIdentifier:CellIdentifier_MulSwitchTimingCell];
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
    MulSwitchSaveAddTimingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_MulSwitchTimingCell];
    if (cell == nil) {
        cell = [[MulSwitchSaveAddTimingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_MulSwitchTimingCell];
    }
    cell.backgroundColor = [UIColor whiteColor];
    ClockModel *clock = self.clockList[indexPath.row];
    cell.hourName.text = [clock getTimeString];
    cell.weekendName.text = [clock getWeekString];
    cell.status.text = [clock getClockActionString];
    cell.plugSwitch.on = clock.isOn;
    
    cell.switchBlock = ^(BOOL isOn) {
        if (isOn == 0) {
            UInt8 controlCode = 0x01;
            NSNumber *A = [NSNumber numberWithInt:clock.number |(self.switchNumber & 0x7f)];
            NSNumber *B = @2;
            NSNumber *C = [NSNumber numberWithInt:clock.week];
            NSNumber *D = [NSNumber numberWithInt:clock.hour];
            NSNumber *E = [NSNumber numberWithInt:clock.minute];
            NSNumber *F = [NSNumber numberWithInt:clock.action];
            NSArray *data = @[@0xFC,@0x11,@0x02,@0x01,A,B,C,D,E,F];
            [self.device sendData69With:controlCode mac:self.device.mac data:data];
        }else{
            UInt8 controlCode = 0x01;
            NSNumber *A = [NSNumber numberWithInt:clock.number |(self.switchNumber & 0x7f)];
            NSNumber *B = @1;
            NSNumber *C = [NSNumber numberWithInt:clock.week];
            NSNumber *D = [NSNumber numberWithInt:clock.hour];
            NSNumber *E = [NSNumber numberWithInt:clock.minute];
            NSNumber *F = [NSNumber numberWithInt:clock.action];
            NSArray *data = @[@0xFC,@0x11,@0x02,@0x01,A,B,C,D,E,F];
            [self.device sendData69With:controlCode mac:self.device.mac data:data];
        }
        
    };
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MulSwitchEditTimingController *EditVC = [[MulSwitchEditTimingController alloc] init];
    EditVC.device = self.device;
    EditVC.switchNumber = self.switchNumber & 0x7f;
    EditVC.clock = self.clockList[indexPath.row];
    [self.navigationController pushViewController:EditVC animated:YES];

}

//左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:LocalString(@"删除") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"点击了删除");
        
        ClockModel *clock = self.clockList[indexPath.row];
        //提示框
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:LocalString(@"您确定要删除闹钟吗?")preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:LocalString(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self deleteClockListBySocket:clock];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    return @[deleteAction];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    editingStyle = UITableViewCellEditingStyleDelete;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellMulSwitch_Height;
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
