//
//  TherTemerCell.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/5.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TherTimerCell : UITableViewCell

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *dayLabel;
@property (strong, nonatomic) UILabel *switchStatus;
@property (strong, nonatomic) UISwitch *controlSwitch;

@end

NS_ASSUME_NONNULL_END
