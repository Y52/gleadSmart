//
//  FamilyLocationController.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^dismissBlock)(HouseModel *house);

NS_ASSUME_NONNULL_BEGIN

@interface FamilyLocationController : UIViewController

@property (nonatomic) dismissBlock dismissBlock;
@property (nonatomic) CGFloat contentOriginY;

@end

NS_ASSUME_NONNULL_END
