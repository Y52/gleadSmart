//
//  TherTemerCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/5.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "TherTimerCell.h"

@implementation TherTimerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] init];
            _timeLabel.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _timeLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
            _timeLabel.textAlignment = NSTextAlignmentLeft;
            _timeLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_timeLabel];
            [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), 20.f));
                make.left.equalTo(self.contentView.mas_left).offset(23.f);
                make.bottom.equalTo(self.dayLabel.mas_top);
            }];
        }
        if (!_dayLabel) {
            _dayLabel = [[UILabel alloc] init];
            _dayLabel.textColor = [UIColor colorWithHexString:@"858585"];
            _dayLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
            _dayLabel.textAlignment = NSTextAlignmentLeft;
            _dayLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_dayLabel];
            [_dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), 20.f));
                make.left.equalTo(self.contentView.mas_left).offset(23.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_switchStatus) {
            _switchStatus = [[UILabel alloc] init];
            _switchStatus.textColor = [UIColor colorWithHexString:@"858585"];
            _switchStatus.font = [UIFont fontWithName:@"Helvetica" size:12];
            _switchStatus.textAlignment = NSTextAlignmentLeft;
            _switchStatus.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_switchStatus];
            [_switchStatus mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), 20.f));
                make.left.equalTo(self.contentView.mas_left).offset(23.f);
                make.top.equalTo(self.dayLabel.mas_bottom);
            }];
        }
        if (!_controlSwitch) {
            _controlSwitch = [[UISwitch alloc] init];
            _controlSwitch.transform = CGAffineTransformMakeScale(0.9, 0.9);
            [_controlSwitch setOn:NO animated:YES];
            [self.contentView addSubview:_controlSwitch];
            [_controlSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.contentView.mas_right).offset(-24.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
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

@end
