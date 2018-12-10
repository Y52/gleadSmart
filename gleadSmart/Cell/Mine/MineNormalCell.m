//
//  MineNormalCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/6.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "MineNormalCell.h"

@implementation MineNormalCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_normalImage) {
            _normalImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_normalImage];
            [_normalImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20, 20));
                make.left.equalTo(self.contentView.mas_left).offset(22.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_normalLabel) {
            _normalLabel = [[UILabel alloc] init];
            _normalLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _normalLabel.font = [UIFont systemFontOfSize:17.0];
            _normalLabel.textAlignment = NSTextAlignmentLeft;
            _normalLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_normalLabel];
            
            [_normalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(120.f, 23));
                make.left.equalTo(self.normalImage.mas_right).offset(15.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_rightLabel) {
            _rightLabel = [[UILabel alloc] init];
            _rightLabel.textColor = [UIColor colorWithHexString:@"7C7C7B"];
            _rightLabel.font = [UIFont systemFontOfSize:15.0];
            _rightLabel.textAlignment = NSTextAlignmentRight;
            _rightLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_rightLabel];
            
            [_rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(120.f, 23));
                make.right.equalTo(self.contentView.mas_right);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
