//
//  DeviceSettingCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/4/1.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceSettingCell.h"

@implementation DeviceSettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_leftName) {
            _leftName = [[UILabel alloc] init];
            _leftName.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _leftName.font = [UIFont fontWithName:@"Helvetica" size:15];
            _leftName.textAlignment = NSTextAlignmentLeft;
            _leftName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_leftName];
            [_leftName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150, 15));
                make.left.equalTo(self.contentView.mas_left).offset((20.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_rightName) {
            _rightName = [[UILabel alloc] init];
            _rightName.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _rightName.font = [UIFont fontWithName:@"Helvetica" size:15];
            _rightName.textAlignment = NSTextAlignmentRight;
            _rightName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_rightName];
            [_rightName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100, 15));
                make.right.equalTo(self.contentView.mas_right).offset((5.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}


@end
