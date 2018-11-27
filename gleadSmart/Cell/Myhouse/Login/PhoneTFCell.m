//
//  PhoneTFCell.m
//  Heating
//
//  Created by Mac on 2018/11/12.
//  Copyright © 2018 Mac. All rights reserved.
//

#import "PhoneTFCell.h"

@implementation PhoneTFCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_phoneimage) {
            _phoneimage = [[UIImageView alloc] init];
            [self.contentView addSubview:_phoneimage];
            [_phoneimage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(15.f), yAutoFit(15.f)));
                make.left.equalTo(self.contentView.mas_left).offset(yAutoFit(50.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_phoneTF) {
            _phoneTF = [[UITextField alloc] init];
            _phoneTF.backgroundColor = [UIColor clearColor];
            _phoneTF.placeholder = LocalString(@"请输入手机号");
            _phoneTF.font = [UIFont fontWithName:@"Arial" size:15.0f];
            //_phoneTF.textColor = [UIColor colorWithHexString:@"222222"];
            //_phoneTF.borderStyle = UITextBorderStyleRoundedRect;
            _phoneTF.clearButtonMode = UITextFieldViewModeWhileEditing;
            _phoneTF.autocorrectionType = UITextAutocorrectionTypeNo;
            _phoneTF.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            //设置为YES时文本会自动缩小以适应文本窗口大小.默认是保持原来大小,而让长文本滚动
            _phoneTF.adjustsFontSizeToFitWidth = YES;
            //设置自动缩小显示的最小字体大小
            _phoneTF.minimumFontSize = 11.f;
            [_phoneTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
            [self.contentView addSubview:_phoneTF];
            
            [_phoneTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(180.f), yAutoFit(30.f)));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.phoneimage.mas_left).offset(yAutoFit(30));
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
