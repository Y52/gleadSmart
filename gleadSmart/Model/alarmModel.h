//
//  alarmModel.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/1/21.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface alarmModel : NSObject

@property (nonatomic, strong) NSString *room;
@property (nonatomic, strong) NSDate *time;
@end

NS_ASSUME_NONNULL_END
