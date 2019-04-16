//
//  ManagerSetCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/1/16.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "ManagerSetCell.h"

@implementation ManagerSetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor whiteColor];
    if (self) {
        if (!_leftLabel) {
            _leftLabel = [[UILabel alloc] init];
            _leftLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _leftLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
            _leftLabel.textAlignment = NSTextAlignmentLeft;
            _leftLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_leftLabel];
            
            [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(20.f)));
                make.left.equalTo(self.contentView.mas_left).offset(20.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_controlSwitch) {
            _controlSwitch = [[UISwitch alloc] init];
            _controlSwitch.transform = CGAffineTransformMakeScale(0.9, 0.9);
            [_controlSwitch setOn:NO animated:YES];
            [_controlSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
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

- (void)switchAction:(UISwitch *)mySwitch{
    if (self.switchBlock) {
        self.switchBlock(mySwitch.isOn);
    }
}

@end
