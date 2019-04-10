//
//  StatusConfirmController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/4/8.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "StatusConfirmController.h"
#import "EspViewController.h"
#import "APStatusConfirmController.h"

@interface StatusConfirmController ()

@property (strong, nonatomic) UIImageView *LampImageView;
@property (strong, nonatomic) UILabel *promptLabbel;
@property (strong, nonatomic) UIButton *SureBtn;

@end

@implementation StatusConfirmController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    [self setNavItem];
    
    self.promptLabbel = [self promptLabbel];
    self.LampImageView = [self LampImageView];
    self.SureBtn = [self SureBtn];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    Network *net = [Network shareNetwork];
    net.isDeviceVC = YES;
    [net.udpSocket pauseReceiving];
    [net.udpTimer setFireDate:[NSDate distantFuture]];
}

#pragma mark - private methods
-(void)Sure{
    EspViewController *EspVC = [[EspViewController alloc] init];
    [self.navigationController pushViewController:EspVC animated:YES];
}

- (void)goAP{
    APStatusConfirmController *apVC = [[APStatusConfirmController alloc] init];
    [self.navigationController pushViewController:apVC animated:YES];
}

#pragma mark - getters and setters
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加设备");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 60, 30);
    [rightButton setTitle:LocalString(@"AP模式") forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [rightButton addTarget:self action:@selector(goAP) forControlEvents:UIControlEventTouchUpInside];
    rightButton.titleLabel.textAlignment = NSTextAlignmentRight;
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UIImageView *)LampImageView{
    if (!_LampImageView) {
        _LampImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_Lamp"]];
        [self.view addSubview:_LampImageView];
        
        [_LampImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(189.f),yAutoFit(189.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(yAutoFit(130.f));
        }];
        
        UILabel *LampLabbel = [[UILabel alloc] init];
        LampLabbel.text = LocalString(@"接通电源，请确认指示灯在快闪");
        LampLabbel.font = [UIFont systemFontOfSize:13.f];
        LampLabbel.textColor = [UIColor colorWithRed:120/255.0 green:117/255.0 blue:117/255.0 alpha:1.0];
        LampLabbel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:LampLabbel];
        
        [LampLabbel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(200.f), yAutoFit(15.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.LampImageView.mas_bottom).offset(yAutoFit(15.f));
        }];
    }
    return _LampImageView;
}

- (UILabel *)promptLabbel{
    if (!_promptLabbel) {
        _promptLabbel = [[UILabel alloc] init];
        _promptLabbel.font = [UIFont systemFontOfSize:13.0];
        _promptLabbel.textAlignment = NSTextAlignmentCenter;
        _promptLabbel.adjustsFontSizeToFitWidth = YES;
        //添加下划线
        NSDictionary * underAttribtDic  = @{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],NSForegroundColorAttributeName:[UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0]};
        NSMutableAttributedString * underAttr = [[NSMutableAttributedString alloc] initWithString:@"如何将指示灯设置为快闪？" attributes:underAttribtDic];
        _promptLabbel.attributedText = underAttr;
        [self.view addSubview:_promptLabbel];
        [_promptLabbel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(200.f), yAutoFit(15.f)));
            make.top.equalTo(self.LampImageView.mas_bottom).offset(yAutoFit(170.f));
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
    }
    return _promptLabbel;
}

- (UIButton *)SureBtn{
    if (!_SureBtn) {
        _SureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_SureBtn setTitle:LocalString(@"确认指示灯在快闪") forState:UIControlStateNormal];
        [_SureBtn.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
        [_SureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_SureBtn setBackgroundColor:[UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0]];
        [_SureBtn addTarget:self action:@selector(Sure) forControlEvents:UIControlEventTouchUpInside];
        _SureBtn.layer.cornerRadius = 3.f;
        _SureBtn.enabled = YES;
        [self.view addSubview:_SureBtn];
        [_SureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), yAutoFit(42.f)));
            make.top.equalTo(self.LampImageView.mas_bottom).offset(yAutoFit(200.f));
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _SureBtn;
}

@end
