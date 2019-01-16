//
//  AreaCodeCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/1/16.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "AreaCodeCell.h"

@implementation AreaCodeCell

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
        if (!_areaCodeLabel) {
            _areaCodeLabel = [[UILabel alloc] init];
            _areaCodeLabel.textColor = [UIColor colorWithHexString:@"7C7C7B"];
            _areaCodeLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
            _areaCodeLabel.textAlignment = NSTextAlignmentLeft;
            _areaCodeLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_areaCodeLabel];
            
            [_areaCodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), yAutoFit(20.f)));
                make.left.equalTo(self.leftLabel.mas_right).offset(30.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}


@end
