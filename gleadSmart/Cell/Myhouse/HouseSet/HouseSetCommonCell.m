//
//  HouseSetCommonCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HouseSetCommonCell.h"

@implementation HouseSetCommonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_leftLabel) {
            _leftLabel = [[UILabel alloc] init];
            _leftLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _leftLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
            _leftLabel.textAlignment = NSTextAlignmentLeft;
            _leftLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_leftLabel];
            [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), 15.f));
                make.left.equalTo(self.contentView.mas_left).offset(20.f);
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
