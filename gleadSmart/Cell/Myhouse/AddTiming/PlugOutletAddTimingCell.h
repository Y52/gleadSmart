//
//  PlugOutletAddTimingCell.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/17.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^switchBlock)(BOOL isOn);

NS_ASSUME_NONNULL_BEGIN

@interface PlugOutletAddTimingCell : UITableViewCell

@property (strong, nonatomic) UILabel *leftName;
@property (strong, nonatomic) UILabel *rightName;
@property (strong, nonatomic) UISwitch *timeSwitch;
@property (nonatomic, strong) switchBlock switchBlock;

@end

NS_ASSUME_NONNULL_END
