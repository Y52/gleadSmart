//
//  TextFieldCell.m
//  Heating
//
//  Created by Mac on 2018/11/12.
//  Copyright © 2018 Mac. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_textField) {
            _textField = [[UITextField alloc] init];
            _textField.backgroundColor = [UIColor clearColor];
            _textField.font = [UIFont fontWithName:@"Arial" size:13.0f];
            //_textField.textColor = [UIColor colorWithHexString:@"222222"];
            //_textField.borderStyle = UITextBorderStyleRoundedRect;
            _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            _textField.autocorrectionType = UITextAutocorrectionTypeNo;
            _textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            //设置为YES时文本会自动缩小以适应文本窗口大小.默认是保持原来大小,而让长文本滚动
            _textField.adjustsFontSizeToFitWidth = YES;
            //设置自动缩小显示的最小字体大小
            _textField.minimumFontSize = 11.f;
            [_textField addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
            [self.contentView addSubview:_textField];
            
            [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(350, 30));
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.equalTo(self.contentView.mas_left).offset(18);
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
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
