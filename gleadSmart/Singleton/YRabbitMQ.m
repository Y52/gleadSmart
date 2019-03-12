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
        [self analyzeMessageType:dic];

    }];
}

- (void)analyzeMessageType:(NSDictionary *)dic{
    NSString *type = [dic objectForKey:@"type"];
    if ([type isEqualToString:@"A"]) {
        [self analyzeMessageTypeA:dic];
    }else if ([type isEqualToString:@"B"]){
        [self analyzeMessageTypeB:dic];
    }else if ([type isEqualToString:@"C"]){
        [self analyzeMessageTypeC:dic];
    }else if ([type isEqualToString:@"D"]){
        [self analyzeMessageTypeD:dic];
    }else if ([type isEqualToString:@"E"]){
        [self analyzeMessageTypeE:dic];
    }
}

/*
 *修改当前用户对家庭的权限控制
 */
- (void)analyzeMessageTypeA:(NSDictionary *)dic{
    NSString *houseUid = [dic objectForKey:@"houseUid"];
    NSNumber *auth = [dic objectForKey:@"auth"];
    NSLog(@"%@",auth);
    
    Database *db = [Database shareInstance];
    if ([db.currentHouse.houseUid isEqualToString:houseUid]) {
        db.currentHouse.auth = auth;
    }
}

/*
 *修改开关
 */
- (void)analyzeMessageTypeB:(NSDictionary *)dic{
    NSDictionary *userInfo;
    NSString *mac = [dic objectForKey:@"mac"];
    NSNumber *on = [dic objectForKey:@"on"];
    NSNumber *online = [dic objectForKey:@"online"];
    
    for (DeviceModel *device in [Network shareNetwork].deviceArray) {
        if ([device.mac isEqualToString:mac]) {
            NSLog(@"%@",device.mac);
            device.isOn = on;
            device.isOnline = online;
            userInfo = @{@"device":device,@"isShare":@0};
        }
    }
    for (DeviceModel *device in [Database shareInstance].shareDeviceArray) {
        if ([device.mac isEqualToString:mac]) {
            NSLog(@"%@",device.mac);
            device.isOn = on;
            device.isOnline = online;
            userInfo = @{@"device":device,@"isShare":@1};
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshThermostat" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshValve" object:nil userInfo:nil];
}

/*
 *中央控制器离线
 */
- (void)analyzeMessageTypeC:(NSDictionary *)dic{
    NSString *houseUid = [dic objectForKey:@"houseUid"];
    NSNumber *online = [dic objectForKey:@"online"];
    Database *db = [Database shareInstance];
    if (![db.currentHouse.houseUid isEqualToString:houseUid]) {
        return;
    }
    if ([online integerValue]) {
        //上线的时候查询设备
        UInt8 controlCode = 0x00;
        NSArray *data = @[@0xFE,@0x01,@0x45,@0x00];//在网节点查询
        [[Network shareNetwork] sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data failuer:nil];
    }else{
        for (DeviceModel *device in [Network shareNetwork].deviceArray) {
            device.isOnline = online;
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
}

/*
 *添加时就提醒用户重新进入家庭主页面即可。删除时需要判断用户当前所在家庭是否是该家庭，然后根据用户下的家庭数量进行家庭的自动切换或者弹出创建家庭页面。
 */
- (void)analyzeMessageTypeD:(NSDictionary *)dic{
    NSString *houseUid = [dic objectForKey:@"houseUid"];
    NSNumber *option = [dic objectForKey:@"option"];// 0表示将其添加到家庭，1表示将其删除了
}

/*
 *漏水节点报警
 */
- (void)analyzeMessageTypeE:(NSDictionary *)dic{
    NSString *content = [dic objectForKey:@"content"];//还不知道具体用途
    NSString *valveMac = [dic objectForKey:@"valveMac"];
    NSString *nodeMac = [dic objectForKey:@"nodeMac"];
    NSNumber *leak = [dic objectForKey:@"leak"];
    
    NodeModel *node = [[NodeModel alloc] init];
    node.valveMac = valveMac;
    node.mac = nodeMac;
    node.isLeak = leak;
    NSDictionary *userInfo = @{@"node":node};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"valveHangingNodesRabbitmqReport" object:nil userInfo:userInfo];
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
