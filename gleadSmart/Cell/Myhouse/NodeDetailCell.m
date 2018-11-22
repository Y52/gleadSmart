//
//  NodeDetailCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/22.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "NodeDetailCell.h"

@implementation NodeDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_leakImage) {
            _leakImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_leakImage];
            [_leakImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 30));
                make.left.equalTo(self.contentView.mas_left).offset(20);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_detailLabel) {
            _detailLabel = [[UILabel alloc] init];
            _detailLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _detailLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
            _detailLabel.textAlignment = NSTextAlignmentLeft;
            _detailLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_detailLabel];
            [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100.f, 15.f));
                make.left.equalTo(self.leakImage.mas_right).offset((13.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_dateLabel) {
            _dateLabel = [[UILabel alloc] init];
            _dateLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _dateLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
            _dateLabel.textAlignment = NSTextAlignmentRight;
            _dateLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_dateLabel];
            [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100.f, 15.f));
                make.right.equalTo(self.contentView.mas_right).offset((-20.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
