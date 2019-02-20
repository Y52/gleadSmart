//
//  ShareDeviceSelectCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/19.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "ShareDeviceSelectCell.h"

@implementation ShareDeviceSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_deviceImage) {
            _deviceImage = [[UIImageView alloc] init];
            _deviceImage.contentMode = UIViewContentModeScaleAspectFit;
            [self.contentView addSubview:_deviceImage];
            [_deviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(44.f), yAutoFit(44.f)));
                make.left.equalTo(self.contentView.mas_left).offset(yAutoFit(18.f));
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
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), yAutoFit(15.f)));
                make.left.equalTo(self.deviceImage.mas_right).offset(yAutoFit(13.f));
                make.bottom.equalTo(self.contentView.mas_centerY).offset(-4.5);
            }];
        }
        
        if (!_status) {
            _status = [[UILabel alloc] init];
            _status.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _status.font = [UIFont fontWithName:@"Helvetica" size:12.f];
            _status.textAlignment = NSTextAlignmentLeft;
            _status.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_status];
            
            [_status mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), yAutoFit(15.f)));
                make.left.equalTo(self.deviceName.mas_left);
                make.top.equalTo(self.contentView.mas_centerY).offset(4.5);
            }];
        }
        if (!_selectImage) {
            _selectImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_selectImage];
            [_selectImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(17.f), yAutoFit(17.f)));
                make.right.equalTo(self.contentView.mas_right).offset(yAutoFit(-24.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
