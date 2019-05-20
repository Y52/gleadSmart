//
//  MulSwitchEditTimingController.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/5/20.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ClockModel;

@interface MulSwitchEditTimingController : UIViewController

@property (nonatomic, strong) DeviceModel *device;
@property (nonatomic, strong) ClockModel *clock;
@property (nonatomic) int switchNumber;//开关编号

@end

NS_ASSUME_NONNULL_END
