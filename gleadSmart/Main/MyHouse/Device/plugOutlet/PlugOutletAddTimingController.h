//
//  PlugOutletAddTimingController.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/17.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ClockModel;
NS_ASSUME_NONNULL_BEGIN

@interface PlugOutletAddTimingController : UIViewController

@property (nonatomic, strong) DeviceModel *device;
@property (nonatomic, strong) ClockModel *clock;

@end

NS_ASSUME_NONNULL_END
