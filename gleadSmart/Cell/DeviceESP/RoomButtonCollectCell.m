//
//  RoomButtonCollectCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/6/4.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "RoomButtonCollectCell.h"

@implementation RoomButtonCollectCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if (!_button) {
            _button = [UIButton buttonWithType:UIButtonTypeCustom];
            [_button setTitle:LocalString(@"") forState:UIControlStateNormal];
            [_button.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
            [_button setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
            [_button.layer setBorderWidth:1.0];
            _button.layer.borderColor = [UIColor colorWithHexString:@"999999"].CGColor;
            _button.layer.cornerRadius = 18.f;
            [_button setBackgroundColor:[UIColor clearColor]];
            [self.contentView addSubview:_button];
            [_button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100.f, 36.f));
                make.centerX.equalTo(self.contentView.mas_centerX);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }

    }
    return self;
}

@end
