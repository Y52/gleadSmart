//
//  HouseNameCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HouseNameCell.h"

@implementation HouseNameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_houseName) {
            _houseName = [[UILabel alloc] init];
            _houseName.backgroundColor = [UIColor clearColor];
            _houseName.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _houseName.textAlignment = NSTextAlignmentLeft;
            _houseName.font = [UIFont fontWithName:@"Helvetica" size:15];
            _houseName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_houseName];
            [_houseName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150, 15));
                make.left.equalTo(self.contentView.mas_left).offset((20));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
