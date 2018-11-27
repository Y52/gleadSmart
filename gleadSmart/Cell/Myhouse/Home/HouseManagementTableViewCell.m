//
//  HomeManagementTableViewCell.m
//  gleadSmart
//
//  Created by Mac on 2018/11/19.
//  Copyright © 2018 杭州轨物科技有限公司. All rights reserved.
//

#import "HouseManagementTableViewCell.h"

@implementation HouseManagementTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_addhomeImage) {
            _addhomeImage = [[UIImageView alloc] init];
            _addhomeImage.image = [UIImage imageNamed:@"img_addDevice"];
            [self.contentView addSubview:_addhomeImage];
            [_addhomeImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(18, 18));
                make.right.equalTo(self.contentView.mas_right).offset(-15);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_cityName) {
            _cityName = [[UILabel alloc] init];
            _cityName.backgroundColor = [UIColor clearColor];
            _cityName.textColor = [UIColor colorWithHexString:@"4A4A4A"];
            _cityName.textAlignment = NSTextAlignmentLeft;
            _cityName.text = LocalString(@"添加家庭");
            _cityName.font = [UIFont fontWithName:@"Helvetica" size:15];
            _cityName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_cityName];
            [_cityName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150, 15));
                make.left.equalTo(self.contentView.mas_left).offset((20));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

-(void)addFamily{
    
    NSLog(@"aa");
}
@end
