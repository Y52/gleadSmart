//
//  PlugOutletSaveAddDelayCell.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/23.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^switchBlock)(BOOL isOn);

@interface PlugOutletSaveAddDelayCell : UITableViewCell

@property (strong, nonatomic) UILabel *timeName;
@property (strong, nonatomic) UISwitch *plugSwitch;
@property (nonatomic) switchBlock switchBlock;

@end

NS_ASSUME_NONNULL_END
