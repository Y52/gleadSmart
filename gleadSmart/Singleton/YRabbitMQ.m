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
    
    RMQExchange *exchange = [ch topic:@"jienuo" options:RMQExchangeDeclareDurable];
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
        if ([message.routingKey isEqualToString:[Database shareInstance].user.userId]) {
            [self analyzeMessageType:dic];
        }else{
            if ([[Database shareInstance].currentHouse.houseUid isEqualToString:message.routingKey]) {
                [self analyzeMessageType:dic];
            }
        }

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
 *修改中央控制器下挂设备开关
 */
- (void)analyzeMessageTypeB:(NSDictionary *)dic{
    NSDictionary *userInfo;
    NSString *mac = [dic objectForKey:@"mac"];
    NSNumber *on = [dic objectForKey:@"on"];
    NSNumber *online = [dic objectForKey:@"online"];
    
    Network *net = [Network shareNetwork];
    for (DeviceModel *device in net.deviceArray) {
        if ([device.mac isEqualToString:mac]) {
            device.isOn = on;
            device.isOnline = online;
            userInfo = @{@"device":device,@"isShare":@0};
        }
    }
    
    for (DeviceModel *device in net.connectedDevice.gatewayMountDeviceList) {
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
    //区分开关和插座的推送
    NSInteger type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[mac substringWithRange:NSMakeRange(2, 2)]]];
    if (type == DevicePlugOutlet) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"rabbitMQPlugOutletStatusUpdate" object:nil userInfo:userInfo];
    }else if (type >= DeviceOneSwitch && type <= DeviceFourSwitch){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"rabbitMQSwitchStatusUpdate" object:nil userInfo:userInfo];
    }
    
}

/*
 *中央控制器离线
 */
- (void)analyzeMessageTypeC:(NSDictionary *)dic{
    NSString *houseUid = [dic objectForKey:@"houseUid"];
    NSNumber *online = [dic objectForKey:@"online"];
    NSString *mac = [dic objectForKey:@"mac"];
    Database *db = [Database shareInstance];
    if (![db.currentHouse.houseUid isEqualToString:houseUid]) {
        return;
    }
    Network *net = [Network shareNetwork];
    for (DeviceModel *device in net.deviceArray) {
        if ([device.mac isEqualToString:mac]) {
            if ([device.type integerValue] == DeviceCenterlControl) {
                //中央控制器
                if ([online integerValue]) {
                    //上线的时候查询设备
                    UInt8 controlCode = 0x00;
                    NSArray *data = @[@0xFE,@0x01,@0x45,@0x00];//在网节点查询
                    [[Network shareNetwork] sendData69With:controlCode mac:[Database shareInstance].currentHouse.mac data:data failuer:nil];
                }else{
                    for (DeviceModel *device in [Network shareNetwork].connectedDevice.gatewayMountDeviceList) {
                        device.isOnline = online;
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTable" object:nil userInfo:nil];
            }else{
                //上线离线的除了中央控制器就是开关插座
                device.isOnline = online;
                NSDictionary *userInfo = @{@"device":device,@"isShare":@0};
                [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
            }
        }
    }
    for (DeviceModel *device in [Database shareInstance].shareDeviceArray) {
        if ([device.mac isEqualToString:mac]) {
            NSLog(@"%@",device.mac);
            device.isOnline = online;
            NSDictionary *userInfo = @{@"device":device,@"isShare":@1};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"oneDeviceStatusUpdate" object:nil userInfo:userInfo];
        }
    }
    
}

/*
 *添加时就提醒用户重新进入家庭主页面即可。删除时需要判断用户当前所在家庭是否是该家庭，然后根据用户下的家庭数量进行家庭的自动切换或者弹出创建家庭页面。
 */
- (void)analyzeMessageTypeD:(NSDictionary *)dic{
    NSString *houseUid = [dic objectForKey:@"houseUid"];
    NSNumber *option = [dic objectForKey:@"option"];// 0表示将其添加到家庭，1表示将其删除了
    NSString *houseName = [dic objectForKey:@"name"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([option integerValue] == 0) {
            NSString *message = [NSString stringWithFormat:@"您收到其他用户分享家庭的:%@",houseName];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"收到分享") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:cancelAction];
            [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
        }else{
            Database *db = [Database shareInstance];
            [db deleteHouse:houseUid];
            
            if ([houseUid isEqualToString:db.currentHouse.houseUid]) {
                NSString *title = [NSString stringWithFormat:@"您已被移出了家庭\"%@\"",houseName];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:LocalString(@"已无法操作该家庭") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [[self getCurrentVC] presentViewController:alertController animated:YES completion:nil];
                
                [db.houseList removeAllObjects];
                db.houseList = [db queryAllHouse];
                if (db.houseList.count > 0) {
                    db.currentHouse = db.houseList[0];
                }else{
                    db.currentHouse = nil;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"rabbitMQUpdateHouse" object:nil userInfo:nil];
            }
        }
    });
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
    switch ([leak integerValue]) {
        case 0:
        {
            node.isLeak = NO;
            node.isLowVoltage = NO;
        }
            break;
            
        case 2:
        {
            node.isLeak = YES;
            node.isLowVoltage = NO;
        }
            break;
            
        case 1:
        {
            node.isLeak = NO;
            node.isLowVoltage = YES;
        }
            break;
            
        case 3:
        {
            node.isLeak = YES;
            node.isLowVoltage = YES;
        }
            break;
            
        default:
            break;
    }
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

#pragma mark - VC的操作

//获取当前屏幕显示的viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    while (currentVC.presentedViewController && ![currentVC.presentedViewController isKindOfClass:[YAlertViewController class]]) {
        currentVC = [self getCurrentVCFrom:currentVC.presentedViewController];
    }
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    //    if ([rootVC presentedViewController]) {
    //        // 视图是被presented出来的
    //        rootVC = [rootVC presentedViewController];
    //    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}

- (void)restoreRootViewController:(UIViewController *)rootViewController {
    
    typedef void (^Animation)(void);
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    
    
    rootViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    Animation animation = ^{
        
        BOOL oldState = [UIView areAnimationsEnabled];
        
        [UIView setAnimationsEnabled:NO];
        
        window.rootViewController = rootViewController;
        
        [UIView setAnimationsEnabled:oldState];
        
    };
    
    
    
    [UIView transitionWithView:window
     
                      duration:0.5f
     
                       options:UIViewAnimationOptionTransitionCrossDissolve
     
                    animations:animation
     
                    completion:nil];
    
}

@end
