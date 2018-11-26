//
//  NSObject+Common.h
//  MOWOX
//
//  Created by Mac on 2017/11/18.
//  Copyright © 2017年 yusz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface NSObject (Common)

+ (void)showHudTipStr:(NSString *)tipStr;
+ (void)showHudTipStr2:(NSString *)tipStr;
+ (void)showHudTipStr:(NSString *)tipStr withTime:(float)time;
//+ (MBProgressHUD *)showHUDQueryStr:(NSString *)titleStr;

+ (NSDictionary *)readLocalFileWithName:(NSString *)name;

- (UInt8)getCS:(NSArray *)data;

@end
