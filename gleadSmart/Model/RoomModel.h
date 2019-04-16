//
//  RoomModel.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoomModel : NSObject

@property (strong, nonatomic) NSString *roomUid;
@property (strong, nonatomic) NSString *houseUid;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *sortId;
@property (strong, nonatomic) NSNumber *deviceNumber;
@property (strong, nonatomic) NSMutableArray *deviceArray;

@end

NS_ASSUME_NONNULL_END
