//
//  MulSwitchEditTimingController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/5/20.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "MulSwitchEditTimingController.h"
#import "MulSwitchAddTimingCell.h"
#import "WeekendNameCell.h"
#import "MulSwitchWeekSelectController.h"
#import "ClockModel.h"

NSString *const CellIdentifier_MulSwitchEditTiming = @"CellID_MulSwitchEditTimingCell";
NSString *const CellIdentifier_EditWeekName = @"CellID_EditWeekNameCell";
static float HEIGHT_CELL = 50.f;

@interface MulSwitchEditTimingController ()<UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UIPickerView *timePicker;
@property (nonatomic, strong) NSMutableArray *hoursArray;
@property (nonatomic, strong) NSMutableArray *minutesArray;
@property (nonatomic, strong) NSMutableArray *weekArray;

@property (strong, nonatomic) UITableView *editTimingTable;

@end

@implementation MulSwitchEditTimingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0].CGColor;
    [self setNavItem];
    self.timePicker = [self timePicker];
    self.editTimingTable = [self editTimingTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchSetClock) name:@"switchSetClock" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"switchSetClock" object:nil];
}

#pragma mark - private methods
- (void)setClockListBySocket{
    UInt8 controlCode = 0x01;
    NSNumber *A = [NSNumber numberWithInt:self.clock.number |self.switchNumber];
    NSNumber *B = @1;
    NSNumber *C = [NSNumber numberWithInt:self.clock.week];
    NSNumber *D = [NSNumber numberWithInt:self.clock.hour];
    NSNumber *E = [NSNumber numberWithInt:self.clock.minute];
    NSNumber *F = [NSNumber numberWithInt:self.clock.action];
    NSArray *data = @[@0xFC,@0x11,@0x02,@0x01,A,B,C,D,E,F];
    
    [self.device sendData69With:controlCode mac:self.device.mac data:data];
    
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //异步等待4秒，如果未收到信息做如下处理
        sleep(4);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (switchSeted == NO) {
                [SVProgressHUD dismiss];
                [NSObject showHudTipStr:LocalString(@"设置失败，请重试")];
            }
        });
    });
}

#pragma mark - notification
static bool switchSeted = NO;
- (void)switchSetClock{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        switchSeted = YES;
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark - setters and getters
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"编辑定时");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setTitle:@"保存" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(setClockListBySocket) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}

-(UITableView *)editTimingTable{
    if (!_editTimingTable) {
        _editTimingTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 245.f, ScreenWidth, HEIGHT_CELL * 2) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            //tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[MulSwitchAddTimingCell class] forCellReuseIdentifier:CellIdentifier_MulSwitchEditTiming];
            [tableView registerClass:[WeekendNameCell class] forCellReuseIdentifier:CellIdentifier_EditWeekName];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = NO;
            tableView;
        });
    }
    return _editTimingTable;
}

-(UIPickerView *)timePicker{
    if (!_timePicker) {
        _timePicker = [[UIPickerView alloc] init];
        _timePicker.backgroundColor = [UIColor whiteColor];
        self.hoursArray = [[NSMutableArray alloc] init];
        self.minutesArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 24; i++) {
            [self.hoursArray addObject:[NSString stringWithFormat:@"%02d",i]];
        }
        for (int i = 0; i < 60; i++) {
            [self.minutesArray addObject:[NSString stringWithFormat:@"%02d",i]];
        }
        //self.hoursArray = [NSMutableArray arrayWithArray:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"]];
        //self.minutesArray = [NSMutableArray arrayWithArray:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59"]];
        self.timePicker.dataSource = self;
        self.timePicker.delegate = self;
        //在当前选择上显示一个透明窗口
        self.timePicker.showsSelectionIndicator = YES;
        //初始化，自动转一圈，避免第一次是数组第一个值造成留白
        [self.timePicker selectRow:self.clock.hour inComponent:0 animated:YES];
        [self.timePicker selectRow:self.clock.minute inComponent:1 animated:YES];
        [self.view addSubview:_timePicker];
        
        [_timePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth,195.f));
            make.top.equalTo(self.view.mas_top).offset(20.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _timePicker;
}

//自定义pick view的字体和颜色
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:18]];
        pickerLabel.textColor = [UIColor blackColor];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

#pragma mark - UIPickerViewDataSource

// 返回多少列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component __TVOS_PROHIBITED{
    return self.view.frame.size.width / 2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED {
    
    return 40;
}
// 返回多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView  numberOfRowsInComponent:(NSInteger)component
{
    return 16384;
}

// 返回的是component列的行显示的内容
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0){
        return self.hoursArray[row % _hoursArray.count];
    }else{
        return self.minutesArray[row % _minutesArray.count];
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component  {
    [self pickerViewLoaded:component];
}

-(void)pickerViewLoaded: (NSInteger)component {
    NSUInteger max = 16384;
    NSUInteger base10 = (max / 2) - (max / 2) % (component ? _minutesArray.count : _hoursArray.count);
    [_timePicker selectRow:[_timePicker selectedRowInComponent:component] % (component ? _minutesArray.count : _hoursArray.count) + base10 inComponent:component animated:NO];
    
    if (component == 0) {
        self.clock.hour = (int)[_timePicker selectedRowInComponent:component] % _hoursArray.count;
    }else{
        self.clock.minute = (int)[_timePicker selectedRowInComponent:component] % _minutesArray.count;
    }
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            WeekendNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_EditWeekName];
            if (cell == nil) {
                cell = [[WeekendNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_EditWeekName];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.leftLabel.text = LocalString(@"重复");
            cell.rightLabel.text = [self.clock getWeekString];
            return cell;
        }
            break;
            
        default:
        {
            MulSwitchAddTimingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_MulSwitchEditTiming];
            if (cell == nil) {
                cell = [[MulSwitchAddTimingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_MulSwitchEditTiming];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.leftName.text = LocalString(@"开关");
            cell.timeSwitch.on = YES;
            self.clock.isOn = YES;
            self.clock.action = clockActionOpen;//闹钟开关执行的动作
            cell.switchBlock = ^(BOOL isOn) {
                if (isOn) {
                    self.clock.action = clockActionOpen;
                }else{
                    self.clock.action = clockActionClose;
                }
            };
            return cell;
        }
            break;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            MulSwitchWeekSelectController *WeekVC = [[MulSwitchWeekSelectController alloc] init];
            WeekVC.clock = self.clock;
            WeekVC.popBlock = ^(ClockModel *clock){
                self.clock = clock;
                [self.editTimingTable reloadData];
            };
            [self.navigationController pushViewController:WeekVC animated:YES];
            
        }
            break;
            
        default:
        {
            
        }
            break;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}


@end
