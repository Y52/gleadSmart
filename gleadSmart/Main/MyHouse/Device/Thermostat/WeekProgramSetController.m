//
//  WeekProgramSetController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/3.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "WeekProgramSetController.h"

@interface WeekProgramSetController () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) UIPickerView *myPicker;
@property (strong, nonatomic) UIButton *dismissBtn;
@property (strong, nonatomic) UIButton *confirmButton;

@end

@implementation WeekProgramSetController{
    NSArray *_timeArray;
    NSArray *_tempArray;
    NSArray *_titleArray;
    
    NSNumber *timeSel;
    NSNumber *tempSel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timeArray = [self generateTimeArray];
        _tempArray = [self generateTempArray];
        _titleArray = @[@"时间",@"温度(℃)"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];
    
    self.myPicker = [self myPicker];
    self.dismissBtn = [self dismissBtn];
    self.confirmButton = [self confirmButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_myPicker) {
        [_myPicker reloadAllComponents];
    }
}

#pragma mark - LazyLoad
- (UIPickerView *)myPicker{
    if (!_myPicker) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(20.f, ScreenHeight - 260.f - 70.f - ySafeArea_Bottom, ScreenWidth - 20.f*2, 260.f);
        view.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
        [self.view addSubview:view];
        view.layer.cornerRadius = 5.f;

        
        _myPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth - 20.f*2, 260.f)];
        _myPicker.backgroundColor = [UIColor whiteColor];
        _myPicker.delegate = self;
        _myPicker.dataSource = self;
        [view addSubview:_myPicker];
        _myPicker.layer.cornerRadius = 5.f;
        
        [_myPicker selectRow:self.timeRow inComponent:0 animated:YES];
        [_myPicker selectRow:self.tempRow inComponent:1 animated:YES];
        
    }
    return _myPicker;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        [_dismissBtn setBackgroundColor:[UIColor clearColor]];
        [_dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:_dismissBtn atIndex:0];
    }
    return _dismissBtn;
}

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(20.f, ScreenHeight - 64.f - ySafeArea_Bottom, ScreenWidth - 20.f*2, 44.f);
        [_confirmButton setTitle:LocalString(@"完成") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:[UIColor whiteColor]];
        [_confirmButton addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_confirmButton];
        _confirmButton.layer.cornerRadius = 5.f;
        
    }
    return _confirmButton;
}

#pragma mark - UIPickerViewDelegate&DataSource
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case 0:
            return _timeArray.count;
            break;
          
        case 1:
            return _tempArray.count;
            break;
            
        default:
            return 0;
            break;
    }
}

//返回指定列，行的高度，就是自定义行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 39.f;
    
}

//显示的标题
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    switch (component) {
        case 0:
            return _timeArray[row];
            break;
            
        case 1:
            return _tempArray[row];
            break;
            
        default:
            return @"";
            break;
    }
    
}

//被选择的行
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (component) {
        case 0:
            self.timeRow = row;
            break;
            
        case 1:
            self.tempRow = row;
            break;
            
        default:
            break;
    }
}

#pragma mark - Actions
- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirm{
    for (DeviceModel *device in [Network shareNetwork].connectedDevice.gatewayMountDeviceList) {
        if ([device.mac isEqualToString:self.mac]) {
            NSMutableArray *weekProgramArray = [NSMutableArray arrayWithArray:device.weekProgram];
            NSInteger index = (self.indexpath.section*4+self.indexpath.row)*2;
            [weekProgramArray replaceObjectAtIndex:index withObject:[NSNumber numberWithInteger:self.timeRow]];
            [weekProgramArray replaceObjectAtIndex:index+1 withObject:[NSNumber numberWithInteger:self.tempRow]];
            device.weekProgram = weekProgramArray;
            [self setWeekProgram:device];
            
            if (self.pickerBlock) {
                self.pickerBlock(device);
            }
        }
    }
    
    
    [self dismissVC];
}

- (void)setWeekProgram:(DeviceModel *)device{
    UInt8 controlCode = 0x01;
    NSInteger index = self.indexpath.section*4 + self.indexpath.row + 1;
    NSArray *data = @[@0xFE,@0x12,@0x04,@0x01,@0x01,[NSNumber numberWithInteger:index],[NSNumber numberWithInteger:self.timeRow],[NSNumber numberWithInteger:self.tempRow]];
    [[Network shareNetwork] sendData69With:controlCode mac:device.mac data:data failuer:nil];
}

@end
