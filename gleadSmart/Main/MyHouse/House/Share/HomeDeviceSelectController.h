//
//  HomeDeviceSelectController.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/19.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeDeviceSelectController : UIViewController

@property (nonatomic, strong) HouseModel *house;
@property (nonatomic, strong) NSMutableArray *deviceList;

@end

NS_ASSUME_NONNULL_END
