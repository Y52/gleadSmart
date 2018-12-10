//
//  HomeDeviceCell.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^switchBlock)(BOOL isOn);

NS_ASSUME_NONNULL_BEGIN

@interface HomeDeviceCell : UITableViewCell

@property (strong, nonatomic) UIImageView *deviceImage;
@property (strong, nonatomic) UILabel *deviceName;
@property (strong, nonatomic) UILabel *belongingHome;
@property (strong, nonatomic) UILabel *status;
@property (strong, nonatomic) UISwitch *controlSwitch;
@property (nonatomic) switchBlock switchBlock;

@end

NS_ASSUME_NONNULL_END
