//
//  FamilyLocationController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "FamilyLocationController.h"

@interface FamilyLocationController ()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIButton *autoLocationBtn;
@property (strong, nonatomic) UIPickerView *locationPicker;
@property (strong, nonatomic) UIButton *dismissButton;

@end

@implementation FamilyLocationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];

    self.contentView = [self contentView];
    self.autoLocationBtn = [self autoLocationBtn];
    self.locationPicker = [self locationPicker];
    self.dismissButton = [self dismissButton];
}

#pragma mark - Lazy load
-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(0, 200.f, ScreenWidth, ScreenHeight - 100.f);
        _contentView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        [self.view addSubview:_contentView];
    }
    return _contentView;
}

- (UIButton *)autoLocationBtn{
    if (!_autoLocationBtn) {
        _autoLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _autoLocationBtn.frame = CGRectMake(0, 0.f, ScreenWidth, 40.f);
        [_autoLocationBtn addTarget:self action:@selector(autoLocation) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_autoLocationBtn];
        [self.contentView bringSubviewToFront:_autoLocationBtn];
        
        UIImageView *leftImage = [[UIImageView alloc] init];
        leftImage.image = [UIImage imageNamed:@"img_autoLocation"];
        [self.contentView addSubview:leftImage];
        
        UILabel *rightLabel = [[UILabel alloc] init];
        rightLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:LocalString(@"帮我定位") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size: 13],NSForegroundColorAttributeName: [UIColor colorWithRed:158/255.0 green:159/255.0 blue:159/255.0 alpha:1.0]}];
        rightLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:rightLabel];
        [leftImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(12.f, 14.f));
            make.centerY.equalTo(self.autoLocationBtn.mas_centerY);
            make.left.equalTo(self.autoLocationBtn.mas_centerX).offset(-32.5f);
        }];
        
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(48.f, 14.f));
            make.left.equalTo(leftImage.mas_right).offset(5.f);
            make.centerY.equalTo(self.autoLocationBtn.mas_centerY);
        }];
    }
    return _autoLocationBtn;
}

- (UIButton *)dismissButton{
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissButton.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        [_dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:_dismissButton atIndex:0];
    }
    return _dismissButton;
}

#pragma mark - Actions
- (void)autoLocation{
    NSLog(@"as");
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock) {
        self.dismissBlock();
    }
}
@end
