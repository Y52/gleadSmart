//
//  HomeDeviceCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HomeDeviceCell.h"

@implementation HomeDeviceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        UIView *baseView = [[UIView alloc] init];
        baseView.backgroundColor = [UIColor colorWithHexString:@"E8E7E7"];
        [self.contentView addSubview:baseView];
        [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(340.f), 60.f));
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.centerY.equalTo(self.contentView.mas_centerY);
        }];
        baseView.layer.cornerRadius = 8.f;
        baseView.layer.borderColor = [UIColor colorWithHexString:@"BFBFBF"].CGColor;
        baseView.layer.borderWidth = 1.f;
        
        if (!_deviceImage) {
            _deviceImage = [[UIImageView alloc] init];
            _deviceImage.contentMode = UIViewContentModeScaleAspectFit;
            [baseView addSubview:_deviceImage];
            [_deviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(44.f), yAutoFit(44.f)));
                make.left.equalTo(baseView.mas_left).offset(yAutoFit(18.f));
                make.centerY.equalTo(baseView.mas_centerY);
            }];
        }
        if (!_deviceName) {
            _deviceName = [[UILabel alloc] init];
            _deviceName.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _deviceName.font = [UIFont fontWithName:@"Helvetica" size:15];
            _deviceName.textAlignment = NSTextAlignmentLeft;
            _deviceName.adjustsFontSizeToFitWidth = YES;
            [baseView addSubview:_deviceName];
            
            [_deviceName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), yAutoFit(15.f)));
                make.left.equalTo(self.deviceImage.mas_right).offset(yAutoFit(13.f));
                make.bottom.equalTo(baseView.mas_centerY).offset(-4.5);
            }];
        }
//        if (!_belongingHome) {
//            _belongingHome = [[UILabel alloc] init];
//            _belongingHome.textColor = [UIColor colorWithHexString:@"4A4A4A"];
//            _belongingHome.font = [UIFont fontWithName:@"Helvetica" size:12.f];
//            _belongingHome.textAlignment = NSTextAlignmentLeft;
//            _belongingHome.adjustsFontSizeToFitWidth = YES;
//            [baseView addSubview:_belongingHome];
//
//            [_belongingHome mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.size.mas_equalTo(CGSizeMake(yAutoFit(25.f), yAutoFit(15.f)));
//                make.left.equalTo(self.deviceName.mas_left);
//                make.top.equalTo(baseView.mas_centerY).offset(4.5);
//            }];
//        }
//
//        UIView *dividingLine = [[UIView alloc] init];
//        dividingLine.backgroundColor = [UIColor colorWithHexString:@"4A4A4A"];
//        [baseView addSubview:dividingLine];
//        [dividingLine mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.size.mas_equalTo(CGSizeMake(1.f, 10.f));
//            make.left.equalTo(self.belongingHome.mas_right).offset(yAutoFit(5.f));
//            make.centerY.equalTo(self.belongingHome.mas_centerY);
//        }];
        
        if (!_status) {
            _status = [[UILabel alloc] init];
            _status.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _status.font = [UIFont fontWithName:@"Helvetica" size:12.f];
            _status.textAlignment = NSTextAlignmentLeft;
            _status.adjustsFontSizeToFitWidth = YES;
            [baseView addSubview:_status];
            
            [_status mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), yAutoFit(15.f)));
                make.left.equalTo(self.deviceName.mas_left);
                make.top.equalTo(baseView.mas_centerY).offset(4.5);
            }];
        }
        
        if (!_controlSwitch) {
            _controlSwitch = [[UISwitch alloc] init];
            _controlSwitch.transform = CGAffineTransformMakeScale(1, 1);
            [_controlSwitch setOn:NO animated:YES];
            [_controlSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [baseView addSubview:_controlSwitch];
            [_controlSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(baseView.mas_right).offset(yAutoFit(-16.f));
                make.centerY.equalTo(baseView.mas_centerY);
            }];
            
            _controlSwitch.tintColor = [UIColor colorWithHexString:@"A8A5A5"];
            _controlSwitch.onTintColor = [UIColor colorWithHexString:@"3987F8"];
            _controlSwitch.backgroundColor = [UIColor colorWithHexString:@"A8A5A5"];
            _controlSwitch.layer.cornerRadius = 15.5f;
            _controlSwitch.layer.masksToBounds = YES;
        }
    }
    return self;
}

- (void)switchAction:(UISwitch *)mySwitch{
    if (self.switchBlock) {
        self.switchBlock(mySwitch.isOn);
    }
}

@end
