//
//  Network.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/15.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "Network.h"

static Network *_network = nil;

@implementation Network{
    int _frameCount;
    dispatch_queue_t _queue;
}

+ (instancetype)shareNetwork{
    if (_network == nil) {
        _network = [[self alloc] init];
    }
    return _network;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        if (_network == nil) {
            _network = [super allocWithZone:zone];
        }
    });
    return _network;
}

- (instancetype)init{
    if (self = [super init]) {
        dispatch_queue_t queue = dispatch_queue_create("netQueue", DISPATCH_QUEUE_SERIAL);
        if (!_mySocket) {
            _mySocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
        }
        if (!_sendSignal) {
            _sendSignal = dispatch_semaphore_create(2);
        }
        if (!_recivedData68) {
            _recivedData68 = [[NSMutableArray alloc] init];
        }
        _queue = dispatch_queue_create("com.thingcom.queue", DISPATCH_QUEUE_SERIAL);
        _frameCount = 0;
    }
    return self;
}

#pragma mark - Tcp Delegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"连接成功");
    _frameCount = 0;
    
    [_mySocket readDataWithTimeout:-1 tag:1];
    [_mySocket readDataWithTimeout:-1 tag:1];
    [_mySocket readDataWithTimeout:-1 tag:1];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"连接失败");
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject showHudTipStr:LocalString(@"连接已断开")];
    });
    self.connectedDevice = nil;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"接收到消息%@",data);
    NSLog(@"socket成功收到帧, tag: %ld", tag);
    [self checkOutFrame:data];
    dispatch_semaphore_signal(self.sendSignal);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //NSLog(@"发送了一条帧");
    _frameCount++;
}

#pragma mark - Actions
//tcp connect
- (BOOL)connectToHost:(NSString *)host onPort:(uint16_t)port error:(NSError *__autoreleasing *)errPtr{
    if (![_mySocket isDisconnected]) {
        NSLog(@"主动断开");
        [_mySocket disconnect];
    }
    return [_mySocket connectToHost:host onPort:port error:errPtr];
}

//帧的发送
- (void)send:(NSMutableArray *)msg withTag:(NSUInteger)tag
{
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2.f * 1000 * 1000 * 1000);
    dispatch_semaphore_wait(_sendSignal, time);
    if (![self.mySocket isDisconnected])
    {
        NSUInteger len = msg.count;
        UInt8 sendBuffer[len];
        for (int i = 0; i < len; i++)
        {
            sendBuffer[i] = [[msg objectAtIndex:i] unsignedCharValue];
        }
        
        NSData *sendData = [NSData dataWithBytes:sendBuffer length:len];
        NSLog(@"发送一条帧： %@",sendData);
        if (tag == 100) {
            [self.mySocket writeData:sendData withTimeout:-1 tag:1];
            [self.mySocket readDataWithTimeout:-1 tag:1];
        }
        
        //[NSThread sleepForTimeInterval:0.6];
        
    }
    else
    {
        NSLog(@"Socket未连接");
    }
}

/*
 *在网节点查询
 */
- (void)onlineNodeInquire:(NSString *)mac{
    NSMutableArray *inquireNode = [[NSMutableArray alloc ] init];
    [inquireNode addObject:[NSNumber numberWithUnsignedChar:0x69]];
    [inquireNode addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [inquireNode addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(0, 2)]]]];
    [inquireNode addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]]];
    [inquireNode addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(4, 2)]]]];
    [inquireNode addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(6, 2)]]]];
    [inquireNode addObject:[NSNumber numberWithUnsignedChar:_frameCount]];
    [inquireNode addObject:[NSNumber numberWithUnsignedChar:0x04]];
    [inquireNode addObject:[NSNumber numberWithUnsignedChar:0xFE]];
    [inquireNode addObject:[NSNumber numberWithUnsignedChar:0x01]];
    [inquireNode addObject:[NSNumber numberWithUnsignedChar:0x45]];
    [inquireNode addObject:[NSNumber numberWithUnsignedChar:0x00]];
    [inquireNode addObject:[NSNumber numberWithUnsignedChar:[NSObject getCS:inquireNode]]];
    [inquireNode addObject:[NSNumber numberWithUnsignedChar:0x17]];
    dispatch_async(_queue, ^{
        [self send:inquireNode withTag:100];
    });
}

#pragma mark - Frame69 接收处理
- (void)checkOutFrame:(NSData *)data{
    //把读到的数据复制一份
    NSData *recvBuffer = [NSData dataWithData:data];
    NSUInteger recvLen = [recvBuffer length];
    //NSLog(@"%lu",(unsigned long)recvLen);
    UInt8 *recv = (UInt8 *)[recvBuffer bytes];
    if (recvLen > 1000) {
        return;
    }
    //把接收到的数据存放在recvData数组中
    NSMutableArray *recvData = [[NSMutableArray alloc] init];
    NSUInteger j = 0;
    while (j < recvLen) {
        [recvData addObject:[NSNumber numberWithUnsignedChar:recv[j]]];
        j++;
    }
    [self handle68Message:recvData];
}

- (void)handle68Message:(NSArray *)data
{
    if (![self frameIsRight:data])
    {
        //68帧数据错误
        return;
    }
    if (_recivedData68)
    {
        [_recivedData68 removeAllObjects];
        [_recivedData68 addObjectsFromArray:data];
    }
    switch ([_recivedData68[9] unsignedIntegerValue]) {
        case 01:
        case 02:
        {
            /*
             *中央控制器
             */
            
            if ([_recivedData68[10] unsignedIntegerValue] == 0x45 && [_recivedData68[11] unsignedIntegerValue] == 0x00) {
                //在网节点查询
                [[NSNotificationCenter defaultCenter] postNotificationName:@"inquireNode" object:nil userInfo:nil];
            }
            if ([_recivedData68[10] unsignedIntegerValue] == 0x92 && [_recivedData68[11] unsignedIntegerValue] == 0x01) {
                //在网节点删除
                
            }
            if ([_recivedData68[10] unsignedIntegerValue] == 0x04 && [_recivedData68[11] unsignedIntegerValue] == 0x00) {
                //新增节点信息上报
            }
            if ([_recivedData68[10] unsignedIntegerValue] == 0x05 && [_recivedData68[11] unsignedIntegerValue] == 0x00) {
                //恢复出厂设置
            }
        }
            break;
            
        default:
            break;
    }
    
    
}

-(BOOL)frameIsRight:(NSArray *)data
{
    NSUInteger count = data.count;
    UInt8 front = [data[0] unsignedCharValue];
    UInt8 end1 = [data[count-1] unsignedCharValue];
    
    //判断帧头帧尾
    if (front != 0x69 || end1 != 0x17)
    {
        NSLog(@"帧头帧尾错误");
        return NO;
    }
    //判断cs位
    UInt8 csTemp = 0x00;
    for (int i = 0; i < count - 2; i++)
    {
        csTemp += [data[i] unsignedCharValue];
    }
    if (csTemp != [data[count-2] unsignedCharValue])
    {
        NSLog(@"校验错误");
        return NO;
    }
    return YES;
}

@end
