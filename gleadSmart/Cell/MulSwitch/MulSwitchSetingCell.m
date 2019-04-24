//
//  MulSwitchSetingCell.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/24.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "MulSwitchSetingCell.h"

@implementation MulSwitchSetingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_deviceImage) {
            _deviceImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_deviceImage];
            [_deviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20, 20));
                make.left.equalTo(self.contentView.mas_left).offset(22.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_leftLabel) {
            _leftLabel = [[UILabel alloc] init];
            _leftLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _leftLabel.font = [UIFont systemFontOfSize:17.0];
            _leftLabel.textAlignment = NSTextAlignmentLeft;
            _leftLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_leftLabel];
            
            [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(120.f, 23));
                make.left.equalTo(self.deviceImage.mas_right).offset(15.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
