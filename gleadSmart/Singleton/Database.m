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
        if (!self.localDeviceArray) {
            self.localDeviceArray = [[NSMutableArray alloc] init];
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
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS room (roomUid text PRIMARY KEY,houseUid text NOT NULl,name text NOT NULL)"];
        if (result) {
            NSLog(@"创建表room成功");
        }else{
            NSLog(@"创建表room失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS device (mac text PRIMARY KEY,name text,roomUid text,houseUid text,type integer)"];
        if (result) {
            NSLog(@"创建表device成功");
        }else{
            NSLog(@"创建表device失败");
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
        FMResultSet *set = [db executeQuery:@"SELECT * FROM room WHERE houseUid = ?",houseUid];
        while ([set next]) {
            RoomModel *room = [[RoomModel alloc] init];
            room.roomUid = [set stringForColumn:@"roomUid"];
            room.name = [set stringForColumn:@"name"];
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
        if (house.mac) {
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
        result = [db executeUpdate:@"REPLACE INTO room (roomUid,houseUid,name) VALUES (?,?,?)",room.roomUid,room.houseUid,room.name];
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
        result = [db executeUpdate:@"REPLACE INTO device (mac,roomUid,name,houseUid,type) VALUES (?,?,?,?,?)",device.mac,device.roomUid,device.name,device.houseUid,device.type];
    }];
//    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
//        result = [db executeUpdate:@"REPLACE INTO device (mac,roomUid,name,houseUid,type) VALUES (?,?,?,?,?)",@"01040001",nil,@"01040001",@"5bfcb08be4b0c54526650eeb",@0];
//    }];
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
@end
