//
//  NodeModel.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/10.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NodeModel : NSObject

@property (strong, nonatomic) NSString *mac;
@property (nonatomic) BOOL isLeak;
@property (nonatomic) BOOL isLowVoltage;

@end

NS_ASSUME_NONNULL_END
