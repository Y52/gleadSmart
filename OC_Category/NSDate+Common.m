//
//  NSDate+Common.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/7/30.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "NSDate+Common.h"

@implementation NSDate (Common)

//将UTCDate(世界标准时间)转化为当地时区的标准Date（钟表显示的时间）
//NSDate *date = [NSDate date];   2018-03-27 06:54:41 +0000
//转化后：2018-03-27 14:54:41 +0000
-(NSDate *)getLocalDateFromUTCDate:(NSDate *)UTCDate{
    
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: UTCDate];
    return [NSDate dateWithTimeInterval: seconds sinceDate: UTCDate];
    
}

//将当地时区的标准Date转化为UTCDate
//当前当地的标准时间：2018-03-27 14:54:41 +0000
//转化为世界标准时间:2018-03-27 06:54:41 +0000
-(NSDate *)getUTCDateFromLocalDate:(NSDate *)LocalDate{
    
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: LocalDate];
    return [NSDate dateWithTimeInterval: seconds sinceDate: LocalDate];
    
}

//根据UTCDate获取当前时间字符串（钟表上显示的时间）
//输入：[NSDate date]     2018-03-27 07:44:05 +0000
//输出：2018-03-27 15:44:05
+(NSString *)localStringFromUTCDate:(NSDate *)UTCDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    [dateFormatter setTimeZone:tz];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* result=[dateFormatter stringFromDate:UTCDate];
    return result;
    
}

//根据UTC字符串获取当前时间字符串（钟表上显示的时间）
//输入：2018-03-27 07:44:05
//输出：2018-03-27 15:44:05
-(NSString *)localStringFromUTCString:(NSString *)UTCString{
    
    //先将UTC字符串转为UTCDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:tz];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *UTCDate = [dateFormatter dateFromString:UTCString];
    
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString* result = [dateFormatter stringFromDate:UTCDate];
    return result;
}

//将当前时间字符串转为UTCDate
+(NSDate *)UTCDateFromLocalString:(NSString *)localString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:localString];
    return date;
}

//将当前时间字符串转为UTC字符串
-(NSString *)UTCStringFromLocalString:(NSString *)localString{

    NSDate *date = [NSDate UTCDateFromLocalString:localString];
    NSString *string = [NSString stringWithFormat:@"%@",date];
    NSString *result = [string substringToIndex:string.length-6];
    return result;

}

//UTCDate转UTC字符串
-(NSString *)UTCStringFromUTCDate:(NSDate *)UTCDate{
    
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc]init];
    [dataFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dataFormatter setTimeZone:tz];
    NSString *UTCString = [dataFormatter stringFromDate:UTCDate];
    return UTCString;
    
}

//将当前时间（UTCDate）转为时间戳
-(NSString *)timeStampFromUTCDate:(NSDate *)UTCDate{
    
    NSTimeInterval timeInterval = [UTCDate timeIntervalSince1970];
    // *1000,是精确到毫秒；这里是精确到秒;
    NSString *result = [NSString stringWithFormat:@"%.0f",timeInterval];
    return result;
    
}

//当前时间字符串(钟表上显示的时间)转为时间戳
-(NSString *)timeStamapFromLocalString:(NSString *)localString{
    
    //先转为UTCDate
    NSDate *UTCDate = [NSDate UTCDateFromLocalString:localString];
    NSString *timeStamap = [self timeStampFromUTCDate:UTCDate];
    return timeStamap;
    
}

//将UTCString转为时间戳
-(NSString *)timeStamapFromUTCString:(NSString *)UTCString{
    
    //先将UTC字符串转为UTCDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatter setTimeZone:tz];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *UTCDate = [dateFormatter dateFromString:UTCString];
    
    NSString *timeStamap = [self timeStampFromUTCDate:UTCDate];
    return timeStamap;
}

//时间戳转UTCDate
-(NSDate *)UTCDateFromTimeStamap:(NSString *)timeStamap{
    
    NSTimeInterval timeInterval=[timeStamap doubleValue];
    //  /1000;传入的时间戳timeStamap如果是精确到毫秒的记得要/1000
    NSDate *UTCDate=[NSDate dateWithTimeIntervalSince1970:timeInterval];
    return UTCDate;
    
}

//转化为年月日
+(NSString *)YMDStringFromDate:(NSDate *)Date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString* result=[dateFormatter stringFromDate:Date];
    return result;
    
}

//将当前年月日时间字符串转为UTCDate
+ (NSDate *)YMDDateFromLocalString:(NSString *)localString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:localString];
    return date;
}


+(NSString *)YMDHMStringFromUTCDate:(NSDate *)UTCDate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    [dateFormatter setTimeZone:tz];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString* result=[dateFormatter stringFromDate:UTCDate];
    return result;
    
}
@end
