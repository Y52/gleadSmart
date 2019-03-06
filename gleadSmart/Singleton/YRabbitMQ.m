//
//  YRabbitMQ.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/1/14.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "YRabbitMQ.h"
#import <RMQClient/RMQClient.h>

static YRabbitMQ *_yRabbitMQ = nil;
static dispatch_once_t onceToken;
static RMQConnection *_conn = nil;
static NSArray *_routingkeys = nil;

@implementation YRabbitMQ

#pragma mark - Instance Initial
+ (instancetype)shareInstance{
    if (_yRabbitMQ == nil) {
        _yRabbitMQ = [[self alloc] init];
    }
    return _yRabbitMQ;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    dispatch_once(&onceToken, ^{
        _yRabbitMQ = [super allocWithZone:zone];
    });
    return _yRabbitMQ;
}

+ (void)destroyInstance{
    _yRabbitMQ = nil;
    onceToken = 0l;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        _routingkeys = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - RMQClient
- (void)receiveRabbitMessage:(NSArray *)routingKeys{
    //tcp初始化
    if (_conn == nil) {
        _conn = [[RMQConnection alloc] initWithUri:@"amqp://thingcom:106ling106@116.62.155.56:5672" delegate:[RMQConnectionDelegateLogger new]];
    }
    [_conn start];
    _routingkeys = routingKeys;
    
    //初始化exchange、queue
    id<RMQChannel> ch = [_conn createChannel];
    
    RMQExchange *exchange = [ch topic:@"gleadSmart" options:RMQExchangeDeclareDurable];
    RMQQueue *queue = [ch queue:@"" options:RMQQueueDeclareExclusive];
    
    //queue绑定routingKeys
    for (NSString *routingKey in routingKeys) {
        [queue bind:exchange routingKey:routingKey];
    }
    
    NSLog(@"Waiting for logs");
    
    //queue接收报警
    [queue subscribe:^(RMQMessage * _Nonnull message) {
        NSLog(@"RabbitMQ---%@:%@", message.routingKey, [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding]);
        
        //把Json转为dic
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:message.body options:NSJSONReadingMutableContainers error:&err];
        

    }];
}

- (void)analyzeMessageBody{
    
}

#pragma mark - 系统通知监听
- (void)activeNotification:(NSNotification *)notification{
    if (_conn == nil) {
        [self receiveRabbitMessage:_routingkeys];
    }
}

- (void)backgroundNotification:(NSNotification *)notification{
    if (_conn) {
        [_conn close];
        _conn = nil;
    }
}

@end
