//
//  Database.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "Database.h"

static Database *_database = nil;

@implementation Database

+(instancetype)shareInstance{
    if (_database == nil) {
        _database = [[self alloc] init];
    }
    return _database;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t oneToken;
    
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
        self.houseList = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Database initial
- (void)initDB{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Coffee.sql",_user.userId]];
    NSLog(@"%@",filePath);
    _queueDB = [FMDatabaseQueue databaseQueueWithPath:filePath];
    [self createTable];
    //_setting = [self setting];
    //[self querySetting];
    //[self deleteTable];
    //[self insertNewReport:nil];
}

- (void)createTable{
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS userInfo (userId text PRIMARY KEY,mobile text,userName text NOT NULL,headUrl text)"];
        if (result) {
            NSLog(@"创建表userInfo成功");
        }else{
            NSLog(@"创建表userInfo失败");
        }
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS house (houseUid text PRIMARY KEY,mac text,name text NOT NULL,lat REAL,lon REAL,auth integer)"];
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
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS device (mac text PRIMARY KEY,houseUid text NOT NULL,roomUid text,type REAL NOT NULL)"];
        if (result) {
            NSLog(@"创建表device成功");
        }else{
            NSLog(@"创建表device失败");
        }
    }];
}

#pragma mark - database select
/*
 *设备
 */
- (NSMutableArray *)queryAllDevice{
    NSMutableArray *deviceArray = [[NSMutableArray alloc] init];
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *set = [db executeQuery:@"SELECT * FROM device"];
        while ([set next]) {
            DeviceModel *device = [[DeviceModel alloc] init];
            device.mac = [set stringForColumn:@"mac"];
            device.name = [set stringForColumn:@"name"];
            device.type = [NSNumber numberWithInt:[set intForColumn:@"type"]];
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
            house.lat = [NSNumber numberWithFloat:[set doubleForColumn:@"lat"]];
            house.lon = [NSNumber numberWithFloat:[set doubleForColumn:@"lon"]];
            house.auth = [NSNumber numberWithInt:[set intForColumn:@"auth"]];
            [houseArray addObject:house];
        }
    }];
    return houseArray;
}

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

#pragma mark - database insert
/*
 *获取列表时插入
 */
- (BOOL)insertNewHouse:(HouseModel *)house{
    static BOOL result = NO;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"REPLACE INTO house (houseUid,name,auth) VALUES (?,?,?)",house.houseUid,house.name,house.auth];
    }];
    return result;
}
/*
 *获取房间列表时插入
 */
- (BOOL)insertNewRoom:(RoomModel *)room{
    static BOOL result = NO;
    [_queueDB inDatabase:^(FMDatabase * _Nonnull db) {
        result = [db executeUpdate:@"REPLACE INTO room (roomUid,houseUid,name) VALUES (?,?,?)",room.roomUid,self.currentHouse.houseUid,room.name];
    }];
    return result;
}
@end
