//
//  DeviceModel.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceModel.h"

@implementation DeviceModel

- (GCDAsyncSocket *)socket{
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:[Network shareNetwork] delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _socket;
}

@end
