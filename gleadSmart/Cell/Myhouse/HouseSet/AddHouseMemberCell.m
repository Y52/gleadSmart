//
//  AddHouseMemberCell.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/1/16.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "AddHouseMemberCell.h"

@implementation AddHouseMemberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor whiteColor];
    if (self) {
        if (!_addLabel) {
            _addLabel = [[UILabel alloc] init];
            _addLabel.textColor = [UIColor colorWithHexString:@"639DF8"];
            _addLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
            _addLabel.textAlignment = NSTextAlignmentCenter;
            _addLabel.adjustsFontSizeToFitWidth = YES;
            [self.contentView addSubview:_addLabel];
            
            [_addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), yAutoFit(20.f)));
                make.centerX.equalTo(self.contentView.mas_centerX);
                make.centerY.equalTo(self.contentView.mas_centerY);
            }];
        }
    }
    return self;
}


@end
