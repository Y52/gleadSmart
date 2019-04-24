//
//  DelayModel.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/23.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, delayAction) {
    delayActionNone = 0,
    delayActionOpen = 1,
    delayActionClose = 2,
};

@interface DelayModel : NSObject

@property (nonatomic) int number;
@property (nonatomic) int hour;
@property (nonatomic) int minute;
@property (nonatomic) BOOL isOn;
@property (nonatomic) delayAction action;

- (NSString *)getDelayActionString;

@end

NS_ASSUME_NONNULL_END
