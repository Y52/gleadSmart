//
//  YRabbitMQ.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/1/14.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YRabbitMQ : NSObject

///@brief 单例模式生成和销毁
+ (instancetype)shareInstance;
+ (void)destroyInstance;

/**
 @brief 注册RabbitMQClient的topic模式
 @param routingKeys 由userId和houseId组成
 **/
- (void)receiveRabbitMessage:(NSArray *)routingKeys;

@end

NS_ASSUME_NONNULL_END
