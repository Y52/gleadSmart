//
//  PlugOutletWeekSeletController.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/18.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^popBlock)(NSMutableArray *);

@interface PlugOutletWeekSeletController : UIViewController

@property (nonatomic) popBlock popBlock;

@end

NS_ASSUME_NONNULL_END
