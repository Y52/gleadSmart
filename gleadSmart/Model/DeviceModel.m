//
//  DeviceModel.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceModel.h"

@implementation DeviceModel

//帧的发送
- (void)send:(NSMutableArray *)msg withTag:(NSUInteger)tag
{
    if (self.socket && ![self.socket isDisconnected]){
        NSUInteger len = msg.count;
        UInt8 sendBuffer[len];
        for (int i = 0; i < len; i++)
        {
            sendBuffer[i] = [[msg objectAtIndex:i] unsignedCharValue];
        }
        
        NSData *sendData = [NSData dataWithBytes:sendBuffer length:len];
        NSLog(@"设备%@发送一条帧： %@",self.mac,sendData);
        if (tag == 100) {
            [self.socket writeData:sendData withTimeout:-1 tag:1];
            [self.socket readDataWithTimeout:-1 tag:1];
            frameCount++;
        }
    }else{
        NSLog(@"Socket未连接");
    }
}

static int frameCount = 0;
- (void)sendData69With:(UInt8)controlCode mac:(NSString *)mac data:(NSArray *)data{
    if (!self.socket) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:[Network shareNetwork] delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    if (!self.queue) {
        self.queue = dispatch_queue_create((char *)[self.mac UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    if (!self.sendSignal) {
        self.sendSignal = dispatch_semaphore_create(1);
    }
    if (self.queue) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_sync(self.queue, ^{
                //线程锁需要放在最前面，放在后面锁不住
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.6 * NSEC_PER_SEC);
                dispatch_semaphore_wait(self.sendSignal, time);
                
                NSMutableArray *data69 = [[NSMutableArray alloc] init];
                [data69 addObject:[NSNumber numberWithUnsignedInteger:0x69]];
                [data69 addObject:[NSNumber numberWithUnsignedInteger:controlCode]];
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(0, 2)]]]];
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]]];
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(4, 2)]]]];
                [data69 addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(6, 2)]]]];
                [data69 addObject:[NSNumber numberWithInt:frameCount]];
                [data69 addObject:[NSNumber numberWithInteger:data.count]];
                [data69 addObjectsFromArray:data];
                [data69 addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:data69]]];
                [data69 addObject:[NSNumber numberWithUnsignedChar:0x17]];
                
                if (self.socket && [self.socket isConnected]) {
                    [self send:data69 withTag:100];
                }else{
                    Network *net = [Network shareNetwork];
                    [net oneNETSendData:data69 apiKey:self.apiKey deviceId:self.deviceId failure:^{
                        
                    }];//OneNet发送
                }
            });
        });
    }
}

//获取继电器状态
- (void)getRelayStatus{
    if (!self.socket) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:[Network shareNetwork] delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    if (![self.socket isDisconnected]) {
        UInt8 controlCode = 0x00;
        NSArray *data = @[@0xFC,@0x11,@0x00,@0x00];//在网节点查询
        [self sendData69With:controlCode mac:self.mac data:data];
    }else{
        NSMutableArray *deviceArray = [NSMutableArray arrayWithObject:self];
        [[Network shareNetwork] inquireDeviceInfoByOneNetdatastreams:deviceArray apiKey:self.apiKey deviceId:self.deviceId];
    }
}

@end
