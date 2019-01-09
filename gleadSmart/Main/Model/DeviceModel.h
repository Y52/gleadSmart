//
//  DeviceModel.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/23.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceModel : NSObject

@property (strong, nonatomic) NSString *mac;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *ipAddress;
@property (strong, nonatomic) NSNumber *type;
@property (strong, nonatomic) NSString *roomUid;
@property (strong, nonatomic) NSString *houseUid;
@property (strong, nonatomic) NSNumber *isOn;
@property (strong, nonatomic) NSNumber *isOnline;//判断在线离线

///@breif 温控器拥有的属性
@property (strong, nonatomic) NSNumber *mode;//0为手动，1为自动
@property (strong, nonatomic) NSNumber *indoorTemp;
@property (strong, nonatomic) NSNumber *modeTemp;
@property (strong, nonatomic) NSNumber *compensate;
@property (strong, nonatomic) NSArray *weekProgram;

///@brief 无线阀门拥有的属性
@property (strong, nonatomic) NSMutableArray *nodeArray;
@end

NS_ASSUME_NONNULL_END
