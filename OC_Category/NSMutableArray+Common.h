//
//  NSMutableArray+Common.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/5/25.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (Common)

- (void)updateOrAddDeviceModel:(DeviceModel *)device;

@end

NS_ASSUME_NONNULL_END
