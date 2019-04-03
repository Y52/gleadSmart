//
//  NSString+Common.m
//  YSZfarm
//
//  Created by 杭州轨物科技有限公司 on 2018/1/25.
//  Copyright © 2018年 yusz. All rights reserved.
//

#import "NSString+Common.h"

@implementation NSString (Common)

+ (NSString *)HexByLong:(long)decimalLong{
    NSString *addressString = [NSString stringWithFormat:@"%04lx",decimalLong];
    return addressString;
}

+ (NSString *)HexByInt:(int)decimalInt{
    NSString *addressString = [NSString stringWithFormat:@"%02x",decimalInt];
    addressString = [addressString uppercaseString];
    return addressString;
}

+ (NSString *)HexByTextFieldDecemal:(NSString *)text{
    NSScanner *scanner = [NSScanner scannerWithString:text];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    int number;
    [scanner scanInt:&number];
    NSLog(@"%x",number);
    NSString *addressString = [NSString stringWithFormat:@"%04x",number];
    
    return addressString;
}

+ (int)String2long:(NSString *)text{
    NSScanner *scanner = [NSScanner scannerWithString:text];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    int number;
    [scanner scanInt:&number];
    return number;
}

/*
 *输入型监控点控制要把输入的浮点数转化为整数上传
 */
+ (NSString *)HexByTextFieldFloat:(NSString *)fieldText decimal:(int)decimal{
    float fieldFloat = [fieldText floatValue];
    int fieldInt = (int)(fieldFloat * pow(10, decimal));
    if (fieldInt > 65535) {
        fieldInt = 65535;
        [NSObject showHudTipStr:LocalString(@"Input number more than limit")];
    }
    NSString *fieldHex = [NSString stringWithFormat:@"%04x",fieldInt];
    return fieldHex;
}

+ (int)fieldText2long:(NSString *)fieldText decimal:(int)decimal{
    float fieldFloat = [fieldText floatValue];
    int fieldInt = (int)(fieldFloat * pow(10, decimal));
    if (fieldInt > 65535) {
        fieldInt = 65535;
    }
    return fieldInt;
}



/*
 *用整数位小数位和单位组成数据string
 */
+ (NSString *)valueFromIntDecUnit:(NSNumber *)N value:(NSNumber *)value unit:(NSString *)unit{
    switch ([N intValue]) {
        case 0:
            return [NSString stringWithFormat:@"%@%@",value,unit];
            break;
            
        case 1:
            return [NSString stringWithFormat:@"%.1f%@",[value floatValue] / 10,unit];
            break;
            
        case 2:
            //NSLog(@"%@",[NSString stringWithFormat:@"%.2f%@",[value floatValue],unit]);
            return [NSString stringWithFormat:@"%.2f%@",[value floatValue] / 100,unit];
            break;
            
        case 3:
            return [NSString stringWithFormat:@"%.3f%@",[value floatValue] / 1000,unit];
            break;
            
        case 4:
            return [NSString stringWithFormat:@"%.4f%@",[value floatValue] / 10000,unit];
            break;
        case 5:
            return [NSString stringWithFormat:@"%.5f%@",[value floatValue] / 100000,unit];
            break;
            
        default:
            return [NSString stringWithFormat:@"%@%@",value,unit];
            break;
    }
    return [NSString stringWithFormat:@"%@%@",value,unit];
}

/**
 * LRC计算
 * 计算该帧数据的LRC
 * frame： 需要计算的数据内容
 * return： 校验结果（2个字符）
 */
+ (NSString *)lrcFromFrame:(NSString *)frame{
    NSUInteger len = [frame length];
    NSUInteger sum = 0;
    NSUInteger lrc = 0;
    NSString *str = [frame substringWithRange:NSMakeRange(1, len - 1)];
    NSString *str_2byte = [[NSString alloc] init];
    for (int i = 0; i < (len - 1)/2; i++) {
        str_2byte = [str substringWithRange:NSMakeRange(i * 2, 2)];
        sum += [self stringScanToInt:str_2byte];
    }
    lrc = 256 - sum % 256;
    return [NSString transform2Hex:lrc];
}

+ (NSString *)transform2Hex:(long)decimal{
    NSString *hexString = [NSString stringWithFormat:@"%02lx",decimal];
    return hexString;
}

+ (int)stringScanToInt:(NSString *)str{
    NSString *str_1 = [str substringWithRange:NSMakeRange(0, 1)];
    NSString *str_2 = [str substringWithRange:NSMakeRange(1, 1)];
    
    int number1 = [NSString hexToDecimal:str_1];
    int number2 = [NSString hexToDecimal:str_2];
    int number = number1 * 16 + number2;
    /*NSScanner *scanner = [NSScanner scannerWithString:str];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
    int number;
    [scanner scanInt:&number];
    NSLog(@"%@",str);*/
    return number;
}

+ (int)hexToDecimal:(NSString *)str{
    if ([str isEqualToString:@"1"]) {
        return 1;
    }else if ([str isEqualToString:@"2"]){
        return 2;
    }else if ([str isEqualToString:@"3"]){
        return 3;
    }else if ([str isEqualToString:@"4"]){
        return 4;
    }else if ([str isEqualToString:@"5"]){
        return 5;
    }else if ([str isEqualToString:@"6"]){
        return 6;
    }else if ([str isEqualToString:@"7"]){
        return 7;
    }else if ([str isEqualToString:@"8"]){
        return 8;
    }else if ([str isEqualToString:@"9"]){
        return 9;
    }else if ([str isEqualToString:@"A"] || [str isEqualToString:@"a"]){
        return 10;
    }else if ([str isEqualToString:@"B"] || [str isEqualToString:@"b"]){
        return 11;
    }else if ([str isEqualToString:@"C"] || [str isEqualToString:@"c"]){
        return 12;
    }else if ([str isEqualToString:@"D"] || [str isEqualToString:@"d"]){
        return 13;
    }else if ([str isEqualToString:@"E"] || [str isEqualToString:@"e"]){
        return 14;
    }else if ([str isEqualToString:@"F"] || [str isEqualToString:@"f"]){
        return 15;
    }else{
        return 0;
    }
}

/**
 * CRC计算
 * 计算该帧数据的CRC
 * frame： 需要计算的数据内容
 * return： 校验结果（2个字符）
 */
+ (NSString *)crcFromFrame:(NSString *)frame {
    NSUInteger len = [frame length];
    uint16_t size = len / 2;
    uint16_t crc = 0xffff;
    int j = 0;
    NSString *str_2byte = [[NSString alloc] init];
    uint8_t frameBuffer[size];
    for (int i = 0; i < size; i++) {
        str_2byte = [frame substringWithRange:NSMakeRange(i * 2, 2)];
        frameBuffer[i] = [self stringScanToInt:str_2byte];;
    }
    for (; size > 0; size--) {
        crc = crc ^ frameBuffer[j];
        j++;
        for (int i = 0; i < 8; i++) {
            if (crc & 0x0001) {
                crc = (crc >> 1) ^ 0xA001;
            }else{
                crc >>= 1;
            }
        }
    }
    return [NSString transform4Hex:crc];
}

+ (NSString *)transform4Hex:(long)decimal{
    long crc1 = decimal % 256;
    long crc2 = decimal / 256;
    NSString *hexString = [NSString stringWithFormat:@"%02lx%02lx",crc1,crc2];
    return hexString;
}

#pragma mark - 判断手机号、邮箱、用户名
+ (BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

+ (BOOL) validateUserName:(NSString *)name
{
    NSString *userNameRegex = @"^[A-Za-z0-9]{0,20}+$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    BOOL B = [userNamePredicate evaluateWithObject:name];
    return B;
}

+ (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL) validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,16}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

#pragma mark - JSON with Arr、Dic
+ (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

+ (id)toArrayOrNSDictionary:(NSData *)jsonData{
    
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
    
}

- (BOOL)includeChinese{
    for(int i=0; i < [self length];i++)
    {
        int a =[self characterAtIndex:i];
        if( a >0x4e00&& a <0x9fff){
            return YES;
        }
    }
    return NO;
}

@end
