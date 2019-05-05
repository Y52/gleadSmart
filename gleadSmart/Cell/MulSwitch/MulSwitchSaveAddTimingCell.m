//
//  MulSwitchSaveAddTimingCell.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/24.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "MulSwitchSaveAddTimingCell.h"

@implementation MulSwitchSaveAddTimingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        
        if (!_hourName) {
            _hourName = [[UILabel alloc] init];
            _hourName.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _hourName.font = [UIFont fontWithName:@"Helvetica" size:18];
            _hourName.textAlignment = NSTextAlignmentLeft;
            _hourName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_hourName];
            [_hourName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), yAutoFit(15.f)));
                make.left.equalTo(self.contentView.mas_left).offset(yAutoFit(20.f));
                make.bottom.equalTo(self.contentView.mas_centerY).offset(-3.5);
            }];
        }
        
        if (!_weekendName) {
            _weekendName = [[UILabel alloc] init];
            _weekendName.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _weekendName.font = [UIFont fontWithName:@"Helvetica" size:13];
            _weekendName.textAlignment = NSTextAlignmentLeft;
            //_weekendName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_weekendName];
            [_weekendName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(ScreenWidth - 80.f, yAutoFit(15.f)));
                make.left.equalTo(self.contentView.mas_left).offset(yAutoFit(20.f));
                make.top.equalTo(self.contentView.mas_centerY).offset(3.5);
            }];
        }
        if (!_status) {
            _status = [[UILabel alloc] init];
            _status.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _status.font = [UIFont fontWithName:@"Helvetica" size:15.f];
            _status.textAlignment = NSTextAlignmentRight;
            _status.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_status];
            
            [_status mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(15.f)));
                make.right.equalTo(self.contentView.mas_right).offset(yAutoFit(-10.f));
                make.bottom.equalTo(self.contentView.mas_centerY).offset(-3.5);
            }];
        }
        if (!_plugSwitch) {
            _plugSwitch = [[UISwitch alloc] init];
            _plugSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
            [_plugSwitch setOn:NO animated:YES];
            [_plugSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
            [self.contentView addSubview:_plugSwitch];
            [_plugSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.contentView.mas_right).offset(yAutoFit(-10.f));
                make.top.equalTo(self.contentView.mas_centerY).offset(3.5);
            }];
            
            _plugSwitch.tintColor = [UIColor colorWithHexString:@"A8A5A5"];
            _plugSwitch.onTintColor = [UIColor colorWithHexString:@"3987F8"];
            _plugSwitch.backgroundColor = [UIColor colorWithHexString:@"A8A5A5"];
            _plugSwitch.layer.cornerRadius = 15.5f;
            _plugSwitch.layer.masksToBounds = YES;
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
