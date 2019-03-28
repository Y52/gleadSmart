//
//  ShareDeviceDetailCell.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/2/27.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "ShareDeviceDetailCell.h"

@implementation ShareDeviceDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_leftLabel) {
            _leftLabel = [[UILabel alloc] init];
            _leftLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _leftLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
            _leftLabel.textAlignment = NSTextAlignmentLeft;
            _leftLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_leftLabel];
            [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(60.f), 15.f));
                make.left.equalTo(self.contentView.mas_left).offset(20.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_rightLabel) {
            _rightLabel = [[UILabel alloc] init];
            _rightLabel.textColor = [UIColor colorWithHexString:@"7C7C7B"];
            _rightLabel.font = [UIFont systemFontOfSize:15.0];
            _rightLabel.textAlignment = NSTextAlignmentRight;
            _rightLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_rightLabel];
            
            [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(120.f, 23));
                make.right.equalTo(self.contentView.mas_right).offset(-15.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_leftImage) {
            _leftImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_leftImage];
            [_leftImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30.f, 30.f));
                make.left.equalTo(self.contentView.mas_left).offset(20.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_deviceLabel) {
            _deviceLabel = [[UILabel alloc] init];
            _deviceLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _deviceLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
            _deviceLabel.textAlignment = NSTextAlignmentLeft;
            _deviceLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_deviceLabel];
            [_deviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(200.f), 15.f));
                make.left.equalTo(self.leftImage.mas_right).offset(10.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }

    }
    return self;
}

@end
