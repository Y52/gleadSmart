//
//  PlugOutletSaveAddTimingCell.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/17.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^switchBlock)(BOOL isOn);

@interface PlugOutletSaveAddTimingCell : UITableViewCell

@property (strong, nonatomic) UILabel *hourName;
@property (strong, nonatomic) UILabel *weekendName;
@property (strong, nonatomic) UILabel *status;
@property (strong, nonatomic) UISwitch *plugSwitch;
@property (nonatomic) switchBlock switchBlock;

@end

NS_ASSUME_NONNULL_END
