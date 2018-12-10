//
//  NodeInfoCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/8.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "NodeInfoCell.h"

@implementation NodeInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_leftLabel) {
            _leftLabel = [[UILabel alloc] init];
            _leftLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _leftLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
            _leftLabel.textAlignment = NSTextAlignmentLeft;
            _leftLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_leftLabel];
            [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100.f, 15.f));
                make.left.equalTo(self.contentView.mas_left).offset((23.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_infoLabel) {
            _infoLabel = [[UILabel alloc] init];
            _infoLabel.textColor = [UIColor colorWithHexString:@"7C7C7B"];
            _infoLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
            _infoLabel.textAlignment = NSTextAlignmentRight;
            _infoLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_infoLabel];
            [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100.f, 15.f));
                make.right.equalTo(self.contentView.mas_right).offset((-20.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
