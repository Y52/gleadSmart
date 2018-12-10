//
//  PasswordTableViewCell.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "PasswordTableViewCell.h"

@implementation PasswordTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_passwordTF) {
            _passwordTF = [[UITextField alloc] init];
            _passwordTF.backgroundColor = [UIColor clearColor];
            _passwordTF.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
            _passwordTF.textColor = [UIColor colorWithHexString:@"333333"];
            _passwordTF.placeholder = LocalString(@"请输入Wi-Fi密码");
            _passwordTF.secureTextEntry = YES;
            _passwordTF.autocorrectionType = UITextAutocorrectionTypeNo;
            _passwordTF.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            //设置为YES时文本会自动缩小以适应文本窗口大小.默认是保持原来大小,而让长文本滚动
            _passwordTF.adjustsFontSizeToFitWidth = YES;
            //设置自动缩小显示的最小字体大小
            _passwordTF.minimumFontSize = 11.f;
            [self.contentView addSubview:_passwordTF];
            [_passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(200.f), 30.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(20.f);
            }];
        }
    }
    return self;
}

@end
