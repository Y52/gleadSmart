//
//  MulSwitchWeekSelectController.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/24.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ClockModel;
NS_ASSUME_NONNULL_BEGIN

typedef void(^popBlock)(ClockModel *clock);
@interface MulSwitchWeekSelectController : UIViewController

@property (nonatomic) popBlock popBlock;
@property (nonatomic, strong) ClockModel *clock;

@end

NS_ASSUME_NONNULL_END
