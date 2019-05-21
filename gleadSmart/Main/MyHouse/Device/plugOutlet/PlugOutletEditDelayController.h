//
//  PlugOutletEditDelayController.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/5/20.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DelayModel;

@interface PlugOutletEditDelayController : UIViewController

@property (nonatomic, strong) DeviceModel *device;
@property (nonatomic, strong) DelayModel *clock;

@end

NS_ASSUME_NONNULL_END
