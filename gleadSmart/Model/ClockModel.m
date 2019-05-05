//
//  ClockModel.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/4/19.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "ClockModel.h"

@implementation ClockModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.week = 0x80;
        self.number = 0;
    }
    return self;
}

-(void)setMyWeek:(int)week{
    if (week & 0x7f) {
        //有选择某一天
        week &= 0x7f;
    }else{
        //一天都没有选择
        week |= 0x80;
    }
    self.week = week;
}

- (NSString *)getWeekString{
    self.week = self.week & 0xFF;
    NSString *weekStr = @"";
    if (self.week & 0x80) {
        return LocalString(@"仅一次");
    }else{
        if (self.week & 0x40) {
            weekStr = [weekStr stringByAppendingString:LocalString(@"周日、")];
        }
        if (self.week & 0x20){
            weekStr = [weekStr stringByAppendingString:LocalString(@"周一、")];
        }
        if (self.week & 0x10){
            weekStr = [weekStr stringByAppendingString:LocalString(@"周二、")];
        }
        if (self.week & 0x08){
            weekStr = [weekStr stringByAppendingString:LocalString(@"周三、")];
        }
        if (self.week & 0x04){
            weekStr = [weekStr stringByAppendingString:LocalString(@"周四、")];
        }
        if (self.week & 0x02){
            weekStr = [weekStr stringByAppendingString:LocalString(@"周五、")];
        }
        if (self.week & 0x01){
            weekStr = [weekStr stringByAppendingString:LocalString(@"周六、")];
        }
        if (![weekStr isEqualToString:@""]) {
            weekStr = [weekStr substringToIndex:weekStr.length - 1];
        }
    }
    return weekStr;
}

- (NSString *)getTimeString{
    return [NSString stringWithFormat:@"%02d:%02d",self.hour,self.minute];
}

- (NSString *)getClockActionString{
    switch (self.action) {
        case clockActionNone:
        {
            
        }
            break;
            
        case clockActionOpen:
        {
            return LocalString(@"开关: 开");
            
        }
            break;
            
        case clockActionClose:
        {
            return LocalString(@"开关: 关");
            
        }
            break;
            
        default:
            break;
    }
    return @"";
}
@end
