//
//  NSMutableArray+Common.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/5/25.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "NSMutableArray+Common.h"

@implementation NSMutableArray (Common)

- (void)updateOrAddDeviceModel:(DeviceModel *)device{
    BOOL isExist = NO;
    for (DeviceModel *existDevice in self) {
        if ([existDevice.mac isEqualToString:device.mac]) {
            existDevice.name = device.name;
            existDevice.mac = device.mac;
            existDevice.apiKey = device.apiKey;
            existDevice.deviceId = device.deviceId;
            existDevice.houseUid = device.houseUid;
            
            //普通设备
            existDevice.roomUid = device.roomUid;
            existDevice.roomName = device.roomName;
            
            //分享设备
            existDevice.isShare = device.isShare;

            isExist = YES;
        }
    }
    if (!isExist) {
        [self addObject:device];
    }
}

@end
