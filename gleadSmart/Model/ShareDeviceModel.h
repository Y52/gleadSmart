//
//  ShareDeviceModel.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/25.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareDeviceModel : NSObject

@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *houseUid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *mac;
@property (strong, nonatomic) NSNumber *isOn;
@property (strong, nonatomic) NSNumber *isOnline;//判断在线离线

@end

NS_ASSUME_NONNULL_END
