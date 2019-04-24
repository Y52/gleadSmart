//
//  PlugOutletSaveAddDelayCell.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/23.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "PlugOutletSaveAddDelayCell.h"

@implementation PlugOutletSaveAddDelayCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        
        if (!_timeName) {
            _timeName = [[UILabel alloc] init];
            _timeName.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _timeName.font = [UIFont fontWithName:@"Helvetica" size:15];
            _timeName.textAlignment = NSTextAlignmentLeft;
            _timeName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_timeName];
            [_timeName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150, 15));
                make.left.equalTo(self.contentView.mas_left).offset((20.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
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
                make.centerY.equalTo(self.contentView.mas_centerY);
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
