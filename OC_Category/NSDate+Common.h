//
//  NSDate+Common.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/30.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Common)

- (NSDate *)getLocalDateFromUTCDate:(NSDate *)UTCDate;
- (NSDate *)getUTCDateFromLocalDate:(NSDate *)LocalDate;
+ (NSString *)localStringFromUTCDate:(NSDate *)UTCDate;
- (NSString *)localStringFromUTCString:(NSString *)UTCString;
+ (NSDate *)UTCDateFromLocalString:(NSString *)localString;
- (NSString *)UTCStringFromLocalString:(NSString *)localString;
- (NSString *)UTCStringFromUTCDate:(NSDate *)UTCDate;
- (NSString *)timeStampFromUTCDate:(NSDate *)UTCDate;
- (NSString *)timeStamapFromLocalString:(NSString *)localString;
- (NSString *)timeStamapFromUTCString:(NSString *)UTCString;
- (NSDate *)UTCDateFromTimeStamap:(NSString *)timeStamap;

+(NSString *)YMDStringFromDate:(NSDate *)Date;
+(NSString *)YMDHMStringFromUTCDate:(NSDate *)UTCDate;
+ (NSDate *)YMDDateFromLocalString:(NSString *)localString;
@end
