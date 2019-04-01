//
//  ShareDeviceListController.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/27.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^popBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface ShareDeviceListController : UIViewController

@property (nonatomic) popBlock popBlock;

@end

NS_ASSUME_NONNULL_END
