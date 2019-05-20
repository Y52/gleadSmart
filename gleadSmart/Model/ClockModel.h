//
//  ClockModel.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/4/19.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, clockAction) {
    clockActionNone = 0,
    clockActionOpen = 1,
    clockActionClose = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface ClockModel : NSObject

@property (nonatomic) int number;//闹钟编号
@property (nonatomic) int week;
@property (nonatomic) int hour;
@property (nonatomic) int minute;
@property (nonatomic) BOOL isOn;
@property (nonatomic) clockAction action;

- (NSString *)getWeekString;
- (NSString *)getTimeString;
- (NSString *)getClockActionString;
-(void)setMyWeek:(int)week;

@end

NS_ASSUME_NONNULL_END
