//
//  HouseSelectCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HouseSelectCell.h"

@implementation HouseSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        if (!_image) {
            _image = [[UIImageView alloc] init];
            [self.contentView addSubview:_image];
            [_image mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(15.f), yAutoFit(15.f)));
                make.left.equalTo(self.contentView.mas_left).offset(yAutoFit(18.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_houseLabel) {
            _houseLabel = [[UILabel alloc] init];
            _houseLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _houseLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
            _houseLabel.textAlignment = NSTextAlignmentLeft;
            _houseLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_houseLabel];
            
            [_houseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), yAutoFit(23.f)));
                make.left.equalTo(self.image.mas_right).offset(yAutoFit(10.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}


@end
