//
//  LogOutCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/7.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "LogOutCell.h"

@implementation LogOutCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_logoutLabel) {
            _logoutLabel = [[UILabel alloc] init];
            _logoutLabel.textColor = [UIColor lightGrayColor];
            _logoutLabel.font = [UIFont systemFontOfSize:17.0];
            _logoutLabel.textAlignment = NSTextAlignmentCenter;
            _logoutLabel.adjustsFontSizeToFitWidth = YES;
            _logoutLabel.text = LocalString(@"退出登录");
            [self.contentView addSubview:_logoutLabel];
            
            [_logoutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(150.f, 23));
                make.centerX.equalTo(self.contentView.mas_centerX);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

@end
