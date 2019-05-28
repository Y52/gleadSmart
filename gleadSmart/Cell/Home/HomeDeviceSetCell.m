//
//  HomeDeviceSetCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/5/27.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "HomeDeviceSetCell.h"

@implementation HomeDeviceSetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        if (!_deviceImage) {
            _deviceImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_deviceImage];
            [_deviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(30), yAutoFit(30)));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(15);
            }];
        }
        if (!_deviceName) {
            _deviceName = [[UILabel alloc] init];
            _deviceName.textColor = [UIColor colorWithHexString:@"333333"];
            _deviceName.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
            _deviceName.textAlignment = NSTextAlignmentLeft;
            [self.contentView addSubview:_deviceName];
            [_deviceName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150), 21));
                make.left.equalTo(self.deviceImage.mas_right).offset(10);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
