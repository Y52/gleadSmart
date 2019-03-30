//
//  NSString+Common.h
//  YSZfarm
//
//  Created by 杭州轨物科技有限公司 on 2018/1/25.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)

+ (NSString *)HexByLong:(long)decimalLong;
+ (NSString *)HexByInt:(int)decimalInt;
+ (NSString *)HexByTextFieldDecemal:(NSString *)text;
+ (NSString *)HexByTextFieldFloat:(NSString *)fieldText decimal:(int)decimal;
+ (int)fieldText2long:(NSString *)fieldText decimal:(int)decimal;
+ (int)String2long:(NSString *)text;
+ (NSString *)transform2Hex:(long)decimal;
+ (NSString *)transform4Hex:(long)decimal;
+ (NSString *)lrcFromFrame:(NSString *)frame;
+ (NSString *)crcFromFrame:(NSString *)frame;
+ (int)stringScanToInt:(NSString *)str;
+ (int)hexToDecimal:(NSString *)str;
+ (NSString *)valueFromIntDecUnit:(NSNumber *)N value:(NSNumber *)value unit:(NSString *)unit;

+ (BOOL) validateMobile:(NSString *)mobile;
+ (BOOL) validateUserName:(NSString *)name;
+ (BOOL) validateEmail:(NSString *)email;
+ (BOOL) validatePassword:(NSString *)passWord;

///@brief Json与数组字典互相转换
+ (NSData *)toJSONData:(id)theData;
+ (id)toArrayOrNSDictionary:(NSData *)jsonData;

//单位转换
+ (double)diffWeightUnitStringWithWeight:(double)weight;
+ (double)diffTempUnitStringWithTemp:(double)temp;

///@brief 是否包含中文
- (BOOL)includeChinese;
@end
