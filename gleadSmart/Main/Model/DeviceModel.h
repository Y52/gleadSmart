//
//  DeviceModel.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceModel : NSObject

@property (strong, nonatomic) NSString *sn;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *state;

@end

NS_ASSUME_NONNULL_END
