//
//  APStatusConfirmController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/4/9.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "APStatusConfirmController.h"
#import "APNetworkController.h"

@interface APStatusConfirmController ()

@property (strong, nonatomic) UIImageView *LampImageView;
@property (strong, nonatomic) UILabel *promptLabbel;
@property (strong, nonatomic) UIButton *SureBtn;

@end

@implementation APStatusConfirmController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    self.navigationItem.title = LocalString(@"AP模式");
    
    self.promptLabbel = [self promptLabbel];
    self.LampImageView = [self LampImageView];
    self.SureBtn = [self SureBtn];
}

#pragma mark - private methods
-(void)Sure{
    APNetworkController *apvc = [[APNetworkController alloc] init];
    [self.navigationController pushViewController:apvc animated:YES];
}

#pragma mark - getters and setters
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
        LampLabbel.text = LocalString(@"接通电源，请确认指示灯在慢闪");
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
        NSMutableAttributedString * underAttr = [[NSMutableAttributedString alloc] initWithString:@"如何将指示灯设置为慢闪？" attributes:underAttribtDic];
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
        [_SureBtn setTitle:LocalString(@"确认指示灯在慢闪") forState:UIControlStateNormal];
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
