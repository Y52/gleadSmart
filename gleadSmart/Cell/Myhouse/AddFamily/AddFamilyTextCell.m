//
//  AddFamilyTextCell.m
//  gleadSmart
//
//  Created by Mac on 2018/11/22.
//  Copyright © 2018 杭州轨物科技有限公司. All rights reserved.
//

#import "AddFamilyTextCell.h"

@implementation AddFamilyTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self) {
        if (!_leftLabel) {
            _leftLabel = [[UILabel alloc] init];
            _leftLabel.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _leftLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
            _leftLabel.textAlignment = NSTextAlignmentLeft;
            _leftLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_leftLabel];
            [_leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(60.f), 15.f));
                make.left.equalTo(self.contentView.mas_left).offset(20.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_inputTF) {
            _inputTF = [[UITextField alloc] init];
            _inputTF.backgroundColor = [UIColor clearColor];
            _inputTF.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
            _inputTF.textColor = [UIColor colorWithHexString:@"333333"];
            _inputTF.autocorrectionType = UITextAutocorrectionTypeNo;
            _inputTF.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            //设置为YES时文本会自动缩小以适应文本窗口大小.默认是保持原来大小,而让长文本滚动
            _inputTF.adjustsFontSizeToFitWidth = YES;
            //设置自动缩小显示的最小字体大小
            _inputTF.minimumFontSize = 11.f;
            [_inputTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
            [self.contentView addSubview:_inputTF];
            [_inputTF mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(200.f), 30.f));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.leftLabel.mas_right).offset(30.f);
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
