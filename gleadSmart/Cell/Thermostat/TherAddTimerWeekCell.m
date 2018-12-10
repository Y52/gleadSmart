//
//  TherAddTimerWeekCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/3.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "TherAddTimerWeekCell.h"

@implementation TherAddTimerWeekCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        if (!_leftImage) {
            _leftImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_leftImage];
            [_leftImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(18.f), yAutoFit(18.f)));
                make.left.equalTo(self.contentView.mas_left).offset(yAutoFit(23.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_leftLabel) {
            _leftLabel = [[UILabel alloc] init];
            _leftLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _leftLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
            _leftLabel.textAlignment = NSTextAlignmentLeft;
            _leftLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_leftLabel];
            [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(60.f), 15.f));
                make.left.equalTo(self.leftImage.mas_right).offset(13.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_rightLabel) {
            _rightLabel = [[UILabel alloc] init];
            _rightLabel.textColor = [UIColor colorWithHexString:@"7C7C7B"];
            _rightLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
            _rightLabel.textAlignment = NSTextAlignmentRight;
            _rightLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_rightLabel];
            [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), 15.f));
                make.right.equalTo(self.contentView.mas_right);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
