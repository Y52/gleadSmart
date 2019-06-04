//
//  DeviceSetRoomController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/6/3.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceSetRoomController.h"

@interface DeviceSetRoomController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *deviceImage;
@property (nonatomic, strong) UITextField *nameButton;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation DeviceSetRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;

    self.navigationItem.title = LocalString(@"添加设备");
    
    self.titleLabel = [self titleLabel];
    self.deviceImage = [self deviceImage];
    self.nameButton = [self nameButton];
    self.buttonView = [self buttonView];
    self.doneButton = [self doneButton];
    
}

#pragma mark - setters and getters

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel =[[UILabel alloc] init];
        _titleLabel.text = LocalString(@"添加设备成功");
        _titleLabel.font = [UIFont boldSystemFontOfSize:25.f];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.numberOfLines = 0;
        [self.view addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(290.f), 50.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(yAutoFit(50.f));
        }];
    }
    return _titleLabel;
}

-(UIImageView *)deviceImage{
    if (!_deviceImage) {
        _deviceImage = [[UIImageView alloc] init];
        _deviceImage.contentMode = UIViewContentModeScaleAspectFit;
        _deviceImage.image = [UIImage imageNamed:@"img_switch_icon_1"];
        [self.view addSubview:_deviceImage];
        [_deviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(44.f), yAutoFit(44.f)));
            make.left.equalTo(self.view.mas_left).offset(yAutoFit(40.f));
            make.top.equalTo(self.titleLabel.mas_bottom).offset(yAutoFit(30.f));
        }];
    }
    return _deviceImage;
}

//- (UIButton *)nameButton{
//    if (!_nameButton) {
//        _nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_nameButton setTitle:LocalString(@"") forState:UIControlStateNormal];
//        [_nameButton setImage:[UIImage imageNamed:@"addRoom_hand"] forState:UIControlStateNormal];
//        [_nameButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
//        [_nameButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
//        [_nameButton setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
//        //[_recommendBtn.layer setBorderWidth:1.0];
//        //_recommendBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
//        //_recommendBtn.layer.cornerRadius = 15.f;
//        [_nameButton setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
//        [self.buttonView addSubview:_nameButton];
//        [_nameButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(yAutoFit(20.f), 20.f));
//            make.left.equalTo(self.buttonView.mas_left).offset(yAutoFit(15.f));
//            make.top.equalTo(self.buttonView.mas_top).offset(yAutoFit(5.f));
//        }];
//    }
//    return _nameButton;
//}

- (UIView *)buttonView{
    if (!_buttonView) {
        _buttonView = [[UIView alloc] init];
        _buttonView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_buttonView];
        [_buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth , 180.f));
            make.top.equalTo(self.deviceImage.mas_bottom).offset(yAutoFit(30.f));
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
        UIButton *hostbedRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [hostbedRoomBtn setTitle:LocalString(@"主卧") forState:UIControlStateNormal];
        [hostbedRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [hostbedRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [hostbedRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [hostbedRoomBtn.layer setBorderWidth:1.0];
        hostbedRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        hostbedRoomBtn.layer.cornerRadius = 1.f;
        [hostbedRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [hostbedRoomBtn addTarget:self action:@selector(hostbedRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonView addSubview:hostbedRoomBtn];
        [hostbedRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.buttonView.mas_left).offset(yAutoFit(15.f));
            make.top.equalTo(self.buttonView.mas_top).offset(yAutoFit(40.f));
        }];
        
        
    }
    return _buttonView;
}

@end
