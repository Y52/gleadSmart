//
//  TouchTableView.m
//  YSZfarm
//
//  Created by Mac on 2017/12/21.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import "TouchTableView.h"

@implementation TouchTableView
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}

@end
