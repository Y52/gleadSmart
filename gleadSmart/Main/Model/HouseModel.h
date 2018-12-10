//
//  HouseModel.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HouseModel : NSObject

@property (strong, nonatomic) NSString *houseUid;
@property (strong, nonatomic) NSString *mac;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *lat;
@property (strong, nonatomic) NSNumber *lon;
@property (strong, nonatomic) NSNumber *auth;
@property (strong, nonatomic) NSNumber *roomNumber;
@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSString *deviceId;
@property (strong, nonatomic) NSArray *members;

//定位时存储地理位置
@property (strong, nonatomic) NSString *location;

@end

NS_ASSUME_NONNULL_END
