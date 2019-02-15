//
//  FamilyMemberInfoCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/15.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "FamilyMemberInfoCell.h"

@implementation FamilyMemberInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!_memberImage) {
            _memberImage = [[UIImageView alloc] init];
            [self.contentView addSubview:_memberImage];
            [_memberImage mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(35.f), yAutoFit(35.f)));
                make.left.equalTo(self.contentView.mas_left).offset(20.f);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
        if (!_memberName) {
            _memberName = [[UILabel alloc] init];
            _memberName.textColor = [UIColor colorWithHexString:@"4D4D4C"];
            _memberName.font = [UIFont fontWithName:@"Helvetica" size:16];
            _memberName.textAlignment = NSTextAlignmentLeft;
            _memberName.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_memberName];
            
            [_memberName mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), yAutoFit(15.f)));
                make.left.equalTo(self.memberImage.mas_right).offset(7.f);
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
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), yAutoFit(15.f)));
                make.left.equalTo(self.memberName.mas_left);
                make.top.equalTo(self.contentView.mas_centerY).offset(4.5);
            }];
        }
    }
    return self;
}

@end
