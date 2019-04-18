//
//  PlugOutletAddTimingController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/17.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "PlugOutletAddTimingController.h"
#import "PlugOutletAddTimingCell.h"
#import "WeekendNameCell.h"

NSString *const CellIdentifier_PlugOutletAddTiming = @"CellID_PlugOutletAddTimingCell";
NSString *const CellIdentifier_WeekendName = @"CellID_WeekendNameCell";
static float HEIGHT_CELL = 50.f;

@interface PlugOutletAddTimingController () <UIPickerViewDataSource,UIPickerViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UIPickerView *TimePicker;
@property (nonatomic, strong) NSMutableArray *HoursArray;
@property (nonatomic, strong) NSMutableArray *SecondArray;

@property (strong, nonatomic) UITableView *AddTimingTable;

@end

@implementation PlugOutletAddTimingController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0].CGColor;
    [self setNavItem];
    self.TimePicker = [self TimePicker];
    self.AddTimingTable = [self AddTimingTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

#pragma mark - setters and getters
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加定时");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setTitle:@"保存" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(saveClock) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}

-(UITableView *)AddTimingTable{
    if (!_AddTimingTable) {
        _AddTimingTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 245.f, ScreenWidth, HEIGHT_CELL * 2) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            //tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[PlugOutletAddTimingCell class] forCellReuseIdentifier:CellIdentifier_PlugOutletAddTiming];
            [tableView registerClass:[WeekendNameCell class] forCellReuseIdentifier:CellIdentifier_WeekendName];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = NO;
            tableView;
        });
    }
    return _AddTimingTable;
}

-(UIPickerView *)TimePicker{
    if (!_TimePicker) {
        _TimePicker = [[UIPickerView alloc] init];
        _TimePicker.backgroundColor = [UIColor whiteColor];
        self.HoursArray = [NSMutableArray arrayWithArray:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23"]];
        self.SecondArray = [NSMutableArray arrayWithArray:@[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59"]];
        self.TimePicker.dataSource = self;
        self.TimePicker.delegate = self;
        [self.TimePicker selectRow:0 inComponent:0 animated:YES];
        [self.view addSubview:_TimePicker];
        
        [_TimePicker mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth,195.f));
            make.top.equalTo(self.view.mas_top).offset(20.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
        return _TimePicker;
}

//自定义pick view的字体和颜色
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
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
    return 160;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED {
    
    return 40;
}
// 返回多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView  numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0){
        return self.HoursArray.count;
    }else{
        return self.SecondArray.count;
    }
}

// 返回的是component列的行显示的内容
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0){
        return self.HoursArray[row];
    }else{
        return self.SecondArray[row];
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
            WeekendNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_WeekendName];
            if (cell == nil) {
                cell = [[WeekendNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_WeekendName];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.leftLabel.text = LocalString(@"重复");
            cell.rightLabel.text = LocalString(@"星期二");
            return cell;
        }
            break;
            
        default:
        {
            PlugOutletAddTimingCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_PlugOutletAddTiming];
            if (cell == nil) {
                cell = [[PlugOutletAddTimingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_PlugOutletAddTiming];
            }
            cell.leftName.text = LocalString(@"开关");
            cell.timeSwitch.on = YES;
            
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (void)saveClock{
    
}

@end
