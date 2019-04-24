//
//  DelayModel.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/23.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "DelayModel.h"

@implementation DelayModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.number = 0;
    }
    return self;
}

- (NSString *)getDelayActionString{
    switch (self.action) {
        case delayActionNone:
        {
            
        }
            break;
            
        case delayActionOpen:
        {
            return [NSString stringWithFormat:@"%02d:%02d%@",self.hour,self.minute,@"后开启"];
            
        }
            break;
            
        case delayActionClose:
        {
            return [NSString stringWithFormat:@"%02d:%02d%@",self.hour,self.minute,@"后关闭"];
            
        }
            break;
            
        default:
            break;
    }
    return @"";
}

@end
