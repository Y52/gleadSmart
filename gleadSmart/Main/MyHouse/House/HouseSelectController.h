//
//  HouseSelectController.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dismissBlock)(void);
typedef void(^pushBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface HouseSelectController : UIViewController

@property (nonatomic) dismissBlock dismissBlock;
@property (nonatomic) pushBlock pushBlock;

@end

NS_ASSUME_NONNULL_END
