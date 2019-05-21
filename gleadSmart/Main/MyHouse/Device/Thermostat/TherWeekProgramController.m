//
//  TherWeekProgramController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/3.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "TherWeekProgramController.h"
#import "TherWeekProgramCell.h"
#import "WeekProgramSetController.h"

NSString *const CellIdentifier_TherWeekProgram = @"CellID_TherWeekProgram";
static CGFloat const Cell_Height = 44.f;
static CGFloat const Header_Height = 35.f;

@interface TherWeekProgramController ()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *weekProgramTable;

@end

@implementation TherWeekProgramController{
    NSArray *_eventList;
    NSArray *_imageList;
    
    NSArray *_timeArray;
    NSArray *_tempArray;
    
    BOOL isWeekProgramGeted;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _eventList = @[@"起床",@"离家",@"回家",@"睡觉"];
        _imageList = @[@"img_weekProgram_getup",@"img_weekProgram_out",@"img_weekProgram_back",@"img_weekProgram_sleep"];
        
        _timeArray = [self generateTimeArray];
        _tempArray = [self generateTempArray];
        isWeekProgramGeted = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    self.navigationItem.title = LocalString(@"周程序设置");
    
    self.weekProgramTable = [self weekProgramTable];
    [self inquireWeekProgram];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWeekProgram) name:@"refreshWeekProgram" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshWeekProgram" object:nil];
}


#pragma mark - Lazy load
-(UITableView *)weekProgramTable{
    if (!_weekProgramTable) {
        _weekProgramTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - getRectNavAndStatusHight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            [tableView registerClass:[TherWeekProgramCell class] forCellReuseIdentifier:CellIdentifier_TherWeekProgram];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
                        
            tableView;
        });
    }
    return _weekProgramTable;
}

- (NSArray *)generateTimeArray{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int hour = 0;
    int minute = 0;
    while (1) {
        [array addObject:[NSString stringWithFormat:@"%02d:%02d",hour,minute]];
        minute += 15;
        if (minute == 60) {
            minute = 0;
            hour++;
        }
        if (hour == 24) {
            break;
        }
    }
    return [array copy];
}

- (NSArray *)generateTempArray{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    float temp = 0.0;
    while (temp <= 30.f) {
        [array addObject:[NSString stringWithFormat:@"%.1f℃",temp]];
        temp += 0.5;
    }
    return [array copy];
}
#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TherWeekProgramCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_TherWeekProgram];
    if (cell == nil) {
        cell = [[TherWeekProgramCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_TherWeekProgram];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.leftImage.image = [UIImage imageNamed:_imageList[indexPath.row]];
    cell.leftLabel.text = _eventList[indexPath.row];
    NSInteger timeRow = [self.device.weekProgram[(indexPath.row + indexPath.section*4)*2] unsignedIntegerValue];
    NSInteger tempRow = [self.device.weekProgram[(indexPath.row + indexPath.section*4)*2+1] unsignedIntegerValue];
    cell.rightLabel.text = [NSString stringWithFormat:@"%@ %@",_timeArray[timeRow],_tempArray[tempRow]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!isWeekProgramGeted) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"稍等") message:LocalString(@"请等待温控器回复周程序信息") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    NSInteger timeRow = [self.device.weekProgram[(indexPath.row + indexPath.section*4)*2] integerValue];
    NSInteger tempRow = [self.device.weekProgram[(indexPath.row + indexPath.section*4)*2+1] integerValue];
    
    WeekProgramSetController *wpSetVC = [[WeekProgramSetController alloc] init];
    wpSetVC.indexpath = indexPath;
    wpSetVC.mac = self.device.mac;
    wpSetVC.timeRow = timeRow;
    wpSetVC.tempRow = tempRow;
    wpSetVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    wpSetVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    wpSetVC.pickerBlock = ^(DeviceModel *device) {
        self.device = device;
        [self.weekProgramTable reloadData];
    };
    [self presentViewController:wpSetVC animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, Header_Height)];
    headerView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(23.f, 0, ScreenWidth, Header_Height)];
    textLabel.textColor = [UIColor colorWithRed:40/255.0 green:121/255.0 blue:255/255.0 alpha:1.0];
    textLabel.font = [UIFont systemFontOfSize:14.f];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textLabel];
    
    switch (section) {
        case 0:
            textLabel.text = LocalString(@"周一到周五");
            break;
            
        case 1:
            textLabel.text = LocalString(@"周六");
            break;
            
        case 2:
            textLabel.text = LocalString(@"周日");
            break;
            
        default:
            break;
    }

    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return Header_Height;
}

#pragma mark - Actions
- (void)inquireWeekProgram{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x12,@0x04,@0x00];
    [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data failuer:nil];
    [SVProgressHUD show];
}

#pragma mark - NSNotification
- (void)refreshWeekProgram{
    isWeekProgramGeted = YES;
    [SVProgressHUD dismiss];
    for (DeviceModel *device in [Network shareNetwork].connectedDevice.gatewayMountDeviceList) {
        if ([device.mac isEqualToString:self.device.mac]) {
            self.device = device;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.weekProgramTable reloadData];
    });
}


@end
