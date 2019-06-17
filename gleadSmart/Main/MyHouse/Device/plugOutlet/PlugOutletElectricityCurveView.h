//
//  PlugOutletElectricityCurveView.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/6/17.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlugOutletElectricityCurveView : UIViewController

@property (nonatomic, strong) DeviceModel *device;
@property (nonatomic,strong) NSString *year;
@property (nonatomic, strong) NSString *month;
@property (nonatomic, strong) NSString *monthElectricity;

@end

NS_ASSUME_NONNULL_END
