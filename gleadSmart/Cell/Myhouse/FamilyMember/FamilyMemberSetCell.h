//
//  FamilyMemberSetCell.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/15.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^switchBlock)(BOOL isOn);

NS_ASSUME_NONNULL_BEGIN

@interface FamilyMemberSetCell : UITableViewCell

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UISwitch *controlSwitch;
@property (nonatomic, strong) switchBlock switchBlock;

@end

NS_ASSUME_NONNULL_END
