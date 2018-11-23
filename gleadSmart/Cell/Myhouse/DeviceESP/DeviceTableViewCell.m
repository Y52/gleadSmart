//
//  DeviceTableViewCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceTableViewCell.h"

@implementation DeviceTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_deviceImage) {
            _deviceImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_hb_m6g_small"]];
            [self.contentView addSubview:_deviceImage];
            [_deviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(90 / WScale, 60 / HScale));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(15 / WScale);
            }];
        }
        if (!_deviceName) {
            _deviceName = [[UILabel alloc] init];
            _deviceName.textColor = [UIColor colorWithHexString:@"333333"];
            _deviceName.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
            _deviceName.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_deviceName];
            [_deviceName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150 / WScale, 21 / HScale));
                make.left.equalTo(self.deviceImage.mas_right).offset(10 / WScale);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
