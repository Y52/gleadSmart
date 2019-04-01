//
//  MemberAccountCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/1/16.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "MemberAccountCell.h"

@implementation MemberAccountCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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
        if (!_accountLabel) {
            _accountLabel = [[UITextField alloc] init];
            _accountLabel.backgroundColor = [UIColor clearColor];
            _accountLabel.placeholder = LocalString(@"请输入手机号");
            _accountLabel.font = [UIFont fontWithName:@"Arial" size:15.0f];
            _accountLabel.textColor = [UIColor colorWithHexString:@"7C7C7B"];
            //_phoneTF.borderStyle = UITextBorderStyleRoundedRect;
            //_accountLabel.clearButtonMode = UITextFieldViewModeWhileEditing;
            _accountLabel.autocorrectionType = UITextAutocorrectionTypeNo;
            _accountLabel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            //设置为YES时文本会自动缩小以适应文本窗口大小.默认是保持原来大小,而让长文本滚动
            _accountLabel.adjustsFontSizeToFitWidth = YES;
            //设置自动缩小显示的最小字体大小
            _accountLabel.minimumFontSize = 11.f;
            [_accountLabel addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
            [self.contentView addSubview:_accountLabel];
            
            [_accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), yAutoFit(20.f)));
                make.left.equalTo(self.leftLabel.mas_right).offset(30.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}

-(void)textFieldTextChange:(UITextField *)textField{
    if (self.TFBlock) {
        self.TFBlock(textField.text);
    }
}

@end
