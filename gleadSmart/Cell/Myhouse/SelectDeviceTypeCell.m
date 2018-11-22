//
//  SelectDeviceTypeCell.m
//  gleadSmart
//
//  Created by Mac on 2018/11/16.
//  Copyright © 2018 杭州轨物科技有限公司. All rights reserved.
//

#import "SelectDeviceTypeCell.h"

@implementation SelectDeviceTypeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_deviceImage) {
            _deviceImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_deviceImage];
            [_deviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 30));
                make.left.equalTo(self.contentView.mas_left).offset(20);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_deviceName) {
            _deviceName = [[UILabel alloc] init];
            _deviceName.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _deviceName.font = [UIFont fontWithName:@"Helvetica" size:15];
            _deviceName.textAlignment = NSTextAlignmentLeft;
            _deviceName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_deviceName];
            [_deviceName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150, 15));
                make.left.equalTo(self.deviceImage.mas_right).offset((13.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
