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

@property (strong, nonatomic) FMDatabaseQueue *queueDB;

///@brief User Information
@property (strong, nonatomic) UserModel *user;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSMutableArray *houseList;

///@brief Currently Selected House
@property (strong, nonatomic, nullable) HouseModel *currentHouse;

///@brief data initial
- (void)initDB;

///@brief database select
- (NSMutableArray *)queryAllDevice;
- (BOOL)queryDevice:(NSString *)mac;
- (NSMutableArray *)queryAllHouse;
- (BOOL)queryHouse:(NSString *)houseUid;
@end

NS_ASSUME_NONNULL_END
