//
//  Database.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface Database : NSObject

+ (instancetype)shareInstance;
///@brief 销毁单例
+ (void)destroyInstance;

@property (strong, nonatomic) FMDatabaseQueue *queueDB;

///@brief User Information
@property (strong, nonatomic) UserModel *user;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSMutableArray *houseList;

///@brief Currently Selected House
@property (strong, nonatomic, nullable) HouseModel *currentHouse;

///@brief 共享家庭与设备,不在本地存储
@property (strong, nonatomic) NSMutableArray *shareDeviceArray;

///@brief data initial
- (void)initDB;

///@brief database select
- (NSMutableArray *)queryAllHouse;
- (BOOL)queryHouse:(NSString *)houseUid;
- (NSMutableArray *)queryRoomsWith:(NSString *)houseUid;
- (RoomModel *)queryRoomWith:(NSString *)roomUid;
- (NSMutableArray *)queryAllDevice:(NSString *)houseUid;
- (NSMutableArray *)queryDevice:(NSString *)houseUid WithoutCenterlControlType:(NSNumber *)type;
- (NSMutableArray *)queryCenterlControlMountDevice:(NSString *)houseUid;
- (DeviceModel *)queryGateway:(NSString *)houseUid;
- (BOOL)queryDevice:(NSString *)mac;
- (NSMutableArray *)queryDevicesWith:(NSString *)roomUid;
- (NSMutableArray *)queryAllShareDevice;
///@brief database insert
- (BOOL)insertNewHouse:(HouseModel *)house;
- (BOOL)insertNewRoom:(RoomModel *)room;
- (BOOL)insertNewDevice:(DeviceModel *)device;
- (BOOL)insertNewShareDevice:(DeviceModel *)device;
///@brief database update
- (BOOL)updateHouse:(HouseModel *)house;
///@brief database delete
- (BOOL)deleteDevice:(NSString *)mac;
- (BOOL)deleteRoom:(NSString *)roomUid;
- (BOOL)deleteShareDevice:(NSString *)mac;
- (BOOL)deleteHouse:(NSString *)houseUid;

///@brief API
- (void)getHouseHomeListAndDevice:(HouseModel *)house success:(void(^)(void))success failure:(void(^)(void))failure;
@end

NS_ASSUME_NONNULL_END
