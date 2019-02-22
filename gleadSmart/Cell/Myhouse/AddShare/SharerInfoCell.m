//
//  SharerInfoCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/21.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "SharerInfoCell.h"

@implementation SharerInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_sharerImage) {
            _sharerImage = [[UIImageView alloc] init];
            _sharerImage.contentMode = UIViewContentModeScaleAspectFit;
            [self.contentView addSubview:_sharerImage];
            [_sharerImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(44.f), yAutoFit(44.f)));
                make.left.equalTo(self.contentView.mas_left).offset(yAutoFit(18.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_sharerName) {
            _sharerName = [[UILabel alloc] init];
            _sharerName.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _sharerName.font = [UIFont fontWithName:@"Helvetica" size:15];
            _sharerName.textAlignment = NSTextAlignmentLeft;
            _sharerName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_sharerName];
            
            [_sharerName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), yAutoFit(15.f)));
                make.left.equalTo(self.sharerImage.mas_right).offset(yAutoFit(13.f));
                make.bottom.equalTo(self.contentView.mas_centerY).offset(-4.5);
            }];
        }
        
        if (!_mobile) {
            _mobile = [[UILabel alloc] init];
            _mobile.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _mobile.font = [UIFont fontWithName:@"Helvetica" size:13.f];
            _mobile.textAlignment = NSTextAlignmentLeft;
            _mobile.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_mobile];
            
            [_mobile mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), yAutoFit(15.f)));
                make.left.equalTo(self.sharerName.mas_left);
                make.top.equalTo(self.contentView.mas_centerY).offset(4.5);
            }];
        }
        }
    return self;
}


@end
