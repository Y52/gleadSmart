//
//  AddFamilySelectCell.m
//  gleadSmart
//
//  Created by Mac on 2018/11/22.
//  Copyright © 2018 杭州轨物科技有限公司. All rights reserved.
//

#import "AddFamilySelectCell.h"

@implementation AddFamilySelectCell

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
                make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), 15.f));
                make.left.equalTo(self.contentView.mas_left).offset(35.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_checkImage) {
            _checkImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_checkImage];
            [_checkImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(23.f, 23.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.equalTo(self.contentView.mas_right).offset(-35.f);
            }];
        }
    }
    return self;
}

@end
