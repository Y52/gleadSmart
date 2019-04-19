//
//  WeekendNameCell.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/17.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "WeekendNameCell.h"

@implementation WeekendNameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    //self.backgroundColor = [UIColor clearColor];
    if (self) {
        if (!_leftLabel) {
            _leftLabel = [[UILabel alloc] init];
            _leftLabel.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _leftLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
            _leftLabel.textAlignment = NSTextAlignmentLeft;
            _leftLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_leftLabel];
            [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(60, 15));
                make.left.equalTo(self.contentView.mas_left).offset((20));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_rightLabel) {
            _rightLabel = [[UILabel alloc] init];
            _rightLabel.textColor = [UIColor darkGrayColor];
            _rightLabel.font = [UIFont systemFontOfSize:15.0];
            _rightLabel.textAlignment = NSTextAlignmentRight;
            _rightLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
            _rightLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_rightLabel];
            [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(ScreenWidth - 100, 30));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.contentView.mas_right);
            }];
        }
    }
    return self;
}


@end
