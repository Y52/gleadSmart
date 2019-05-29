//
//  Database.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "Database.h"

static Database *_database = nil;
static dispatch_once_t oneToken;

@implementation Database

+(instancetype)shareInstance{
    if (_database == nil) {
        _database = [[self alloc] init];
    }
    return _database;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    dispatch_once(&oneToken, ^{
        if (_database == nil) {
            _database = [super allocWithZone:zone];
        }
    });
    return _database;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        if (!self.houseList) {
            self.houseList = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

+ (void)destroyInstance{
    _database = nil;
    oneToken = 0l;
}

#pragma mark - Database initial
- (void)initDB{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_gleadSmart.sql",_user.userId]];
    NSLog(@"%@",filePath);
    _queueDB = [FMDatabaseQueue databaseQueueWithPath:filePath];
    [self createTable];
    //_setting = [self setting];
    //[self querySetting];
    //[self deleteTable];
    //[self insertNewDevice:nil];
}

- (void)createTable{
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS userInfo (userId text PRIMARY KEY,mobile text,userName text NOT NULL,headUrl text)"];
        if (result) {
            NSLog(@"创建表userInfo成功");
        }else{
            NSLog(@"创建表userInfo失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS house (houseUid text PRIMARY KEY,mac text,name text NOT NULL,lat REAL,lon REAL,auth integer,deviceId text,apiKey text)"];
        if (result) {
            NSLog(@"创建表house成功");
        }else{
            NSLog(@"创建表house失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS room (roomUid text PRIMARY KEY,houseUid text NOT NULl,name text NOT NULL,sortId integer)"];
        if (result) {
            NSLog(@"创建表room成功");
        }else{
            NSLog(@"创建表room失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS device (mac text PRIMARY KEY,name text,roomUid text,houseUid text,type integer,deviceId text,apiKey text)"];
        if (result) {
            NSLog(@"创建表device成功");
        }else{
            NSLog(@"创建表device失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS shareDevice (mac text PRIMARY KEY,name text,houseUid text,apiKey text,deviceId text,houseMac text)"];
        if (result) {
            NSLog(@"创建表shareDevice成功");
        }else{
            NSLog(@"创建表shareDevice失败");
        }
    }];
}

#pragma mark - database select
/*
 *家庭
 */
- (NSMutableArray *)queryAllHouse{
    NSMutableArray *houseArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM house"];
        while ([set next]) {
            HouseModel *house = [[HouseModel alloc] init];
            house.houseUid = [set stringForColumn:@"houseUid"];
            house.name = [set stringForColumn:@"name"];
            house.mac = [set stringForColumn:@"mac"];
            house.deviceId = [set stringForColumn:@"deviceId"];
            house.apiKey = [set stringForColumn:@"apiKey"];
            house.lat = [NSNumber numberWithFloat:[set doubleForColumn:@"lat"]];
            house.lon = [NSNumber numberWithFloat:[set doubleForColumn:@"lon"]];
            house.auth = [NSNumber numberWithInt:[set intForColumn:@"auth"]];
            [houseArray addObject:house];
        }
    }];
    return houseArray;
}

/*
 *查询特定家庭
 */
- (BOOL)queryHouse:(NSString *)houseUid{
    static BOOL isContain = NO;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM house WHERE houseUid = ?",houseUid];
        while ([set next]) {
            isContain = YES;
        }
    }];
    return isContain;
}

/*
 *房间
 */
- (NSMutableArray *)queryRoomsWith:(NSString *)houseUid{
    NSMutableArray *roomArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM room WHERE houseUid = ? ORDER BY sortId",houseUid];
        while ([set next]) {
            RoomModel *room = [[RoomModel alloc] init];
            room.roomUid = [set stringForColumn:@"roomUid"];
            room.name = [set stringForColumn:@"name"];
            room.sortId = [NSNumber numberWithInt:[set intForColumn:@"sortId"]];
            room.houseUid = houseUid;
            [roomArray addObject:room];
        }
    }];
    return roomArray;
}

- (RoomModel *)queryRoomWith:(NSString *)roomUid{
    RoomModel *room = [[RoomModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM room WHERE roomUid = ?",roomUid];
        while ([set next]) {
            room.name = [set stringForColumn:@"name"];
        }
    }];
    return room;
}

/*
 *设备
 */
- (DeviceModel *)queryGateway:(NSString *)houseUid{
    DeviceModel *device = [[DeviceModel alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM device WHERE houseUid = ? AND type = ?",houseUid, @0];
        while ([set next]) {
            device.mac = [set stringForColumn:@"mac"];
            device.name = [set stringForColumn:@"name"];
            device.houseUid = houseUid;
        }
    }];
    return device;
}

- (NSMutableArray *)queryAllDevice:(NSString *)houseUid{
    NSMutableArray *deviceArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM device WHERE houseUid = ?",houseUid];
        while ([set next]) {
            DeviceModel *device = [[DeviceModel alloc] init];
            device.mac = [set stringForColumn:@"mac"];
            device.name = [set stringForColumn:@"name"];
            device.roomUid = [set stringForColumn:@"roomUid"];
            device.type = [NSNumber numberWithInt:[set intForColumn:@"type"]];
            device.houseUid = houseUid;
            device.apiKey = [set stringForColumn:@"apiKey"];
            device.deviceId = [set stringForColumn:@"deviceId"];
            [deviceArray addObject:device];
        }
    }];
    NSLog(@"%lu",(unsigned long)deviceArray.count);
    return deviceArray;
}

- (NSMutableArray *)queryDevice:(NSString *)houseUid WithoutCenterlControlType:(NSNumber *)type{
    NSMutableArray *deviceArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM device WHERE houseUid = ? AND type != ?",houseUid,type];
        while ([set next]) {
            DeviceModel *device = [[DeviceModel alloc] init];
            device.mac = [set stringForColumn:@"mac"];
            device.name = [set stringForColumn:@"name"];
            device.roomUid = [set stringForColumn:@"roomUid"];
            device.type = [NSNumber numberWithInt:[set intForColumn:@"type"]];
            device.houseUid = houseUid;
            NSLog(@"%@,%@",device.name,device.mac);
            [deviceArray addObject:device];
        }
    }];
    NSLog(@"%lu",(unsigned long)deviceArray.count);
    return deviceArray;
}

- (NSMutableArray *)queryCenterlControlMountDevice:(NSString *)houseUid{
    NSMutableArray *deviceArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM device WHERE houseUid = ? AND type >= ? AND type <= ?",houseUid,[NSNumber numberWithInt:DeviceThermostat],[NSNumber numberWithInt:DeviceNTCValve]];
        while ([set next]) {
            DeviceModel *device = [[DeviceModel alloc] init];
            device.mac = [set stringForColumn:@"mac"];
            device.name = [set stringForColumn:@"name"];
            device.roomUid = [set stringForColumn:@"roomUid"];
            device.type = [NSNumber numberWithInt:[set intForColumn:@"type"]];
            device.houseUid = houseUid;
            NSLog(@"%@,%@",device.name,device.mac);
            [deviceArray addObject:device];
        }
    }];
    return deviceArray;
}

- (NSMutableArray *)queryAllShareDevice{
    NSMutableArray *deviceArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM shareDevice"];
        while ([set next]) {
            DeviceModel *device = [[DeviceModel alloc] init];
            device.mac = [set stringForColumn:@"mac"];
            device.name = [set stringForColumn:@"name"];
            device.houseUid = [set stringForColumn:@"houseUid"];
            device.deviceId = [set stringForColumn:@"deviceId"];
            device.apiKey = [set stringForColumn:@"apiKey"];
            device.shareDeviceHouseMac = [set stringForColumn:@"houseMac"];
            [deviceArray addObject:device];
        }
    }];
    return deviceArray;
}

- (BOOL)queryDevice:(NSString *)mac{
    static BOOL isContain = NO;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM device WHERE mac = ?",mac];
        while ([set next]) {
            isContain = YES;
        }
    }];
    return isContain;
}

- (NSMutableArray *)queryDevicesWith:(NSString *)roomUid{
    NSMutableArray *deviceArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM device WHERE roomUid = ?",roomUid];
        while ([set next]) {
            DeviceModel *device = [[DeviceModel alloc] init];
            device.mac = [set stringForColumn:@"mac"];
            device.name = [set stringForColumn:@"name"];
            device.apiKey = [set stringForColumn:@"apiKey"];
            device.deviceId = [set stringForColumn:@"deviceId"];
            device.roomUid = roomUid;
            [deviceArray addObject:device];
        }
    }];
    return deviceArray;
}

#pragma mark - database insert
/*
 *获取列表时插入
 */
- (BOOL)insertNewHouse:(HouseModel *)house{
    static BOOL result = NO;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"REPLACE INTO house (houseUid,name,auth,lat,lon,deviceId,apiKey) VALUES (?,?,?,?,?,?,?)",house.houseUid,house.name,house.auth,house.lat,house.lon,house.deviceId,house.apiKey];
        if ([house.mac isKindOfClass:[NSString class]] && house.mac.length > 0) {
            result = [db executeUpdate:@"REPLACE INTO device (mac,houseUid,type) VALUES (?,?,?)",house.mac,house.houseUid,@0];
        }
    }];
    return result;
}
/*
 *获取房间设备列表时插入
 */
- (BOOL)insertNewRoom:(RoomModel *)room{
    static BOOL result = NO;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"REPLACE INTO room (roomUid,houseUid,name,sortId) VALUES (?,?,?,?)",room.roomUid,room.houseUid,room.name,room.sortId];
    }];
    return result;
}
/*
 *获取房间设备列表时插入
 */
- (BOOL)insertNewDevice:(DeviceModel *)device{
    if (!device.houseUid) {
        device.houseUid = self.currentHouse.houseUid;
    }
    static BOOL result = NO;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"REPLACE INTO device (mac,roomUid,name,houseUid,type,deviceId,apiKey) VALUES (?,?,?,?,?,?,?)",device.mac,device.roomUid,device.name,device.houseUid,device.type,device.deviceId,device.apiKey];
    }];
    return result;
}

- (BOOL)insertNewShareDevice:(DeviceModel *)device{
    static BOOL result = NO;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"REPLACE INTO shareDevice (mac,name,houseUid,apiKey,deviceId,houseMac) VALUES (?,?,?,?,?,?)",device.mac,device.name,device.houseUid,device.apiKey,device.deviceId,device.shareDeviceHouseMac];
    }];
    return result;
}

#pragma mark - database update
/*
 *更新家庭信息
 */
- (BOOL)updateHouse:(HouseModel *)house{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"UPDATE house SET name = ?,auth = ?,lon = ?,lat = ? WHERE houseUid = ?",house.name,house.auth,house.lon,house.lat,house.houseUid];
        if (!result) {
            NSLog(@"更新家庭信息");
        }
    }];
    return result;
}

#pragma mark - database delete
- (BOOL)deleteDevice:(NSString *)mac{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from device where mac = ?",mac];
    }];
    return result;
}

- (BOOL)deleteShareDevice:(NSString *)mac{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from shareDevice where mac = ?",mac];
    }];
    return result;
}

- (BOOL)deleteRoom:(NSString *)roomUid{
    static BOOL result = YES;
    [_queueDB inDatabase:^(FMDatabase *db) {
        result = [db executeUpdate:@"delete from room where roomUid = ?",roomUid];
    }];
    return result;
}

- (BOOL)deleteHouse:(NSString *)houseUid{
    static BOOL result = YES;
    [_queueDB inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        result = [db executeUpdate:@"delete from room where houseUid = ?",houseUid];
        if (!result) {
            *rollback = YES;
            NSLog(@"删除关联房间失败");
            return;
        }
        
        result = [db executeUpdate:@"delete from device where houseUid = ?",houseUid];
        if (!result) {
            *rollback = YES;
            NSLog(@"删除关联设备失败");
            return;
        }
        
        result = [db executeUpdate:@"delete from house where houseUid = ?",houseUid];
        if (!result) {
            *rollback = YES;
            NSLog(@"删除家庭失败");
            return;
        }
        NSLog(@"删除家庭成功");
    }];
    return result;
}

#pragma mark - API methods and update database
- (void)getHouseHomeListAndDevice:(HouseModel *)house success:(void(^)(void))success failure:(void(^)(void))failure{
    //[SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/house/device/list?houseUid=%@",httpIpAddress,house.houseUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:self.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",self.token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSDictionary *dic = [responseDic objectForKey:@"data"];
            
            /*
             *取出家庭详细信息
             */
            NSDictionary *houseInfo = [dic objectForKey:@"house"];
            house.lon = [houseInfo objectForKey:@"lon"];
            house.lat = [houseInfo objectForKey:@"lat"];
            house.apiKey = [houseInfo objectForKey:@"apiKey"];
            house.deviceId = [houseInfo objectForKey:@"deviceId"];
            /*
             *把houselist中的该house更新，防止在切换house时丢失数据
             */
            for (HouseModel *existHouse in self.houseList) {
                if (house.houseUid == existHouse.houseUid) {
                    [self.houseList addObject:house];
                    [self.houseList removeObject:existHouse];
                    break;
                }
            }
            /*
             *把本地数据库的该house更新
             */
            [self updateHouse:house];
            
            /*
             *取出房间内容
             */
            if ([[dic objectForKey:@"rooms"] count] > 0) {
                [[dic objectForKey:@"rooms"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    RoomModel *room = [[RoomModel alloc] init];
                    room.name = [obj objectForKey:@"roomName"];
                    room.roomUid = [obj objectForKey:@"roomUid"];
                    room.sortId = [obj objectForKey:@"sortId"];
                    room.houseUid = house.houseUid;
                    room.deviceArray = [[NSMutableArray alloc] init];
                    
                    //获取房间内关联的所有设备
                    if ([[obj objectForKey:@"devices"] count] > 0) {
                        [[obj objectForKey:@"devices"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            DeviceModel *device = [[DeviceModel alloc] init];
                            device.name = [obj objectForKey:@"deviceName"];
                            device.mac = [obj objectForKey:@"mac"];
                            device.roomUid = room.roomUid;
                            device.roomName = room.name;
                            device.apiKey = [obj objectForKey:@"apiKey"];
                            device.deviceId = [obj objectForKey:@"deviceId"];
                            device.houseUid = house.houseUid;
                            device.isShare = NO;
                            
                            if ([device.mac isKindOfClass:[NSString class]] && device.mac.length > 0) {
                                DeviceType type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]];
                                device.type = [NSNumber numberWithInt:type];

                                //插入设备到本地
                                [self insertNewDevice:device];
                            }
                        }];
                    }
                    [self insertNewRoom:room];
                    
                }];
            }
            
            /*
             *取出共享内容
             */
            if (!self.shareDeviceArray) {
                self.shareDeviceArray = [[NSMutableArray alloc] init];
            }
            if ([[dic objectForKey:@"shareHouse"] isKindOfClass:[NSArray class]] && [[dic objectForKey:@"shareHouse"] count] > 0) {
                [[dic objectForKey:@"shareHouse"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([[obj objectForKey:@"devices"] isKindOfClass:[NSArray class]] && [[obj objectForKey:@"devices"] count] > 0) {
                        [[obj objectForKey:@"devices"] enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                            DeviceModel *device = [[DeviceModel alloc] init];
                            device.name = [obj1 objectForKey:@"deviceName"];
                            device.mac = [obj1 objectForKey:@"mac"];
                            device.apiKey = [obj1 objectForKey:@"apiKey"];
                            device.deviceId = [obj1 objectForKey:@"deviceId"];
                            device.houseUid = [obj1 objectForKey:@"houseUid"];
                            device.isShare = YES;
                            if (![device.mac isKindOfClass:[NSNull class]] && device.mac.length == 8) {
                                DeviceType type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]];
                                device.type = [NSNumber numberWithInt:type];

                                //插入房间的设备
                                [self insertNewShareDevice:device];
                                [self.shareDeviceArray updateOrAddDeviceModel:device];
                            }
                        }];
                    }
                }];
                //分享设备onenet获取状态
                for (DeviceModel *device in self.shareDeviceArray) {
                    [[Network shareNetwork] inquireShareDeviceInfoByOneNetdatastream:device];
                }
            }
            if (success) {
                success();
            }
        }else{
            [NSObject showHudTipStr:LocalString(@"获取家庭详细信息失败")];
            if (failure) {
                failure();
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        /**
         以下错误信息处理方法在没有网时会报错，具体原因未查明
         **/
        //        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        //
        //        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        //
        //        NSLog(@"error--%@",serializedData);
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"从服务器获取信息失败"];
            if (failure) {
                failure();
            }
        });
    }];
}
@end
