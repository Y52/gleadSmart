//
//  PlugOutletDelayController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/23.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "PlugOutletDelayController.h"
#import "PlugOutletAddDelayController.h"
#import "PlugOutletSaveAddDelayCell.h"
#import "DelayModel.h"
#import "PlugOutletEditDelayController.h"

NSString *const CellIdentifier_PlugOutletDelayCell = @"CellID_PlugOutletDelay";

CGFloat const cellAddDelay_Height = 68.f;
static float HEIGHT_FOOT = 20.f;

@interface PlugOutletDelayController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *DelayTable;
@property (nonatomic, strong) UIButton *addDelayBtn;

@property (nonatomic, strong) NSMutableArray *delayclockList;

@end

@implementation PlugOutletDelayController

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    self.navigationItem.title = LocalString(@"添加设备");
    
    self.DelayTable = [self DelayTable];
    self.addDelayBtn = [self addDelayBtn];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getdelayclockList:) name:@"getdelayclockList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(plugoutDeleteDelay) name:@"plugoutDeleteDelayClock" object:nil];
    [self getdelayclockListBySocket];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getdelayclockList" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"plugoutDeleteDelayClock" object:nil];
}
#pragma mark - private methods
- (void)getdelayclockListBySocket{
    UInt8 controlCode = 0x00;
    NSArray *data = @[@0xFC,@0x11,@0x05,@0x00];
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
}

- (void)addDelay{
    if (self.delayclockList.count >= 5) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"定时器数量已经达到额度") message:LocalString(@"请先删除一个定时再添加") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    PlugOutletAddDelayController *addVC = [[PlugOutletAddDelayController alloc] init];
    addVC.device = self.device;
    addVC.clock = [[DelayModel alloc] init];
    for (int i = 0; i < self.delayclockList.count; i++) {
        DelayModel *clock = self.delayclockList[i];
        if (addVC.clock.number == clock.number) {
            addVC.clock.number++;
        }else{
            break;
        }
    }
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)deletedelayclockListBySocket:(DelayModel *)clock{
    UInt8 controlCode = 0x01;
    NSNumber *A = [NSNumber numberWithInt:clock.number];
    NSNumber *B = @0;
    NSNumber *C = @0;
    NSNumber *D = @0;
    NSNumber *E = @0;
    NSNumber *F = @0;
    NSArray *data = @[@0xFC,@0x11,@0x04,@0x01,A,B,C,D,E,F];
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
    
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //异步等待4秒，如果未收到信息做如下处理
        sleep(4);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (plugDeleted == NO) {
                [SVProgressHUD dismiss];
                [NSObject showHudTipStr:LocalString(@"删除失败，请重试")];
            }else{
                plugDeleted = NO;
            }
        });
    });
}

#pragma mark - nsnotification
static bool plugDeleted = NO;
- (void)plugoutDeleteDelay{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        plugDeleted = YES;
        //成功之后推送 刷新闹钟列表
        [self getdelayclockListBySocket];
    });
}

- (void)getdelayclockList:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSMutableArray *frame = [userInfo objectForKey:@"frame"];
    NSString *mac= [userInfo objectForKey:@"mac"];
    
    if ([mac isEqualToString:self.device.mac]) {
        if (!self.delayclockList) {
            self.delayclockList = [[NSMutableArray alloc] init];
        }
        [self.delayclockList removeAllObjects];
        
        for (int i = 0; i < 5; i++) {
            if (![frame[13+i*6] intValue]) {
                //无效状态
                continue;
            }
            DelayModel *clock = [[DelayModel alloc] init];
            clock.number = [frame[12+i*6] intValue] & 0x0f;
            if ([frame[13+i*6] intValue] == 1) {
                clock.isOn = YES;
            }else{
                clock.isOn = NO;
            }
            //十六进制转化十进制
            int by1 = ([frame[14+i*6] intValue] & 0xff);//高8位
            int by2 = ([frame[15+i*6] intValue] & 0xff);//中8位
            int by3 = ([frame[16+i*6] intValue] & 0xff);//低8位
            int temp;
            temp = (by3 | (by2 << 8) | (by1 << 16));
            clock.hour = temp / 3600;
            clock.minute = (temp % 3600)/60;
            clock.action = [frame[17+i*6] intValue];
            [self.delayclockList addObject:clock];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.DelayTable reloadData];
    });
}

#pragma mark - setters and getters
- (UITableView *)DelayTable{
    if (!_DelayTable) {
        _DelayTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - getRectNavAndStatusHight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            tableView.scrollEnabled = NO;
            [tableView registerClass:[PlugOutletSaveAddDelayCell class] forCellReuseIdentifier:CellIdentifier_PlugOutletDelayCell];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _DelayTable;
}

- (UIButton *)addDelayBtn{
    if (!_addDelayBtn) {
        _addDelayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addDelayBtn setTitle:LocalString(@"添加延时") forState:UIControlStateNormal];
        [_addDelayBtn setTitleColor:[UIColor colorWithHexString:@"639DF8"] forState:UIControlStateNormal];
        [_addDelayBtn setBackgroundColor:[UIColor whiteColor]];
        [_addDelayBtn addTarget:self action:@selector(addDelay) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_addDelayBtn];
        [_addDelayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(276.f), 44.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_bottom).offset(-100.f);
        }];
        _addDelayBtn.layer.cornerRadius = 22.f;
        _addDelayBtn.layer.borderWidth = 1.f;
        _addDelayBtn.layer.borderColor = [UIColor colorWithHexString:@"3987F8"].CGColor;
        
    }
    return _addDelayBtn;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.delayclockList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PlugOutletSaveAddDelayCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_PlugOutletDelayCell];
    if (cell == nil) {
        cell = [[PlugOutletSaveAddDelayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_PlugOutletDelayCell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    DelayModel *clock = self.delayclockList[indexPath.row];
    cell.timeName.text = [clock getDelayActionString];
    cell.plugSwitch.on = clock.isOn;
    
    cell.switchBlock = ^(BOOL isOn) {
        //十进制转化为十六进制
        int temp ;
        temp = clock.hour * 3600 + clock.minute *60;
        int by1 = (temp & 0xff0000) >>16; //高8位
        int by2 = (temp & 0xff00)>>8; //中8位
        int by3 = (temp & 0xff); //低8位
        
        if (isOn == 0) {
            UInt8 controlCode = 0x01;
            NSNumber *A = [NSNumber numberWithInt:clock.number];
            NSNumber *B = @2;
            NSNumber *C = [NSNumber numberWithInt:by1];
            NSNumber *D = [NSNumber numberWithInt:by2];
            NSNumber *E = [NSNumber numberWithInt:by3];
            NSNumber *F = [NSNumber numberWithInt:clock.action];
            NSArray *data = @[@0xFC,@0x11,@0x04,@0x01,A,B,C,D,E,F];
            [self.device sendData69With:controlCode mac:self.device.mac data:data];
        }else{
            UInt8 controlCode = 0x01;
            NSNumber *A = [NSNumber numberWithInt:clock.number];
            NSNumber *B = @1;
            NSNumber *C = [NSNumber numberWithInt:by1];
            NSNumber *D = [NSNumber numberWithInt:by2];
            NSNumber *E = [NSNumber numberWithInt:by3];
            NSNumber *F = [NSNumber numberWithInt:clock.action];
            NSArray *data = @[@0xFC,@0x11,@0x04,@0x01,A,B,C,D,E,F];
            [self.device sendData69With:controlCode mac:self.device.mac data:data];
        }
        
    };
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PlugOutletEditDelayController *DelayVC = [[PlugOutletEditDelayController alloc] init];
    DelayVC.device = self.device;
    DelayVC.clock = self.delayclockList[indexPath.row];
    [self.navigationController pushViewController:DelayVC animated:YES];
    
}

//左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:LocalString(@"删除") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@"点击了删除");
        
        DelayModel *clock = self.delayclockList[indexPath.row];
        //提示框
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:LocalString(@"您确定要删除闹钟吗?")preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:LocalString(@"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [self deletedelayclockListBySocket:clock];
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
    return cellAddDelay_Height;
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
    textLabel.text = LocalString(@"延时可能存在30s的误差");
    
    return footView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return HEIGHT_FOOT;
}

@end
