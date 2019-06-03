//
//  YPickerAlertController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "YPickerAlertController.h"

@interface YPickerAlertController () <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *myPicker;
@property (nonatomic, strong) UIButton *dismissBtn;

@end

@implementation YPickerAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];

    self.myPicker = [self myPicker];
    self.dismissBtn = [self dismissBtn];
    [self.myPicker selectRow:_index inComponent:0 animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_myPicker) {
        [_myPicker reloadAllComponents];
    }
    NSLog(@"%ld",_pickerArr.count);
}

#pragma mark - LazyLoad
- (UIPickerView *)myPicker{
    if (!_myPicker) {
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, ScreenHeight - 260, ScreenWidth, 260);
        view.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1].CGColor;
        [self.view addSubview:view];
        
        _myPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 60, ScreenWidth, 200)];
        _myPicker.delegate = self;
        _myPicker.dataSource = self;
        [view addSubview:_myPicker];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.frame = CGRectMake(0,0,ScreenWidth,60);
        _titleLabel.font = [UIFont systemFontOfSize:17.f];
        _titleLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [view addSubview:_titleLabel];
        
        
    }
    return _myPicker;
}

- (UIButton *)dismissBtn{
    if (!_dismissBtn) {
        _dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissBtn.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 260);
        [_dismissBtn setBackgroundColor:[UIColor clearColor]];
        [_dismissBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_dismissBtn];
    }
    return _dismissBtn;
}
#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _pickerArr.count;
}

//返回指定列，行的高度，就是自定义行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 39.f;
    
}

//显示的标题
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *str = [NSString stringWithFormat:@"%@",_pickerArr[row]];
    
    return str;
    
}

//显示的标题字体、颜色等属性
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSString *str = [NSString stringWithFormat:@"%@",_pickerArr[row]];

    NSMutableAttributedString *AttributedString = [[NSMutableAttributedString alloc]initWithString:str];
    
    [AttributedString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"222222"]} range:NSMakeRange(0, [AttributedString  length])];
    return AttributedString;
    
}//NS_AVAILABLE_IOS(6_0);

//被选择的行
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (self.pickerBlock) {
        self.pickerBlock(row);
    }
    [self dismissVC];
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
