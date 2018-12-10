//
//  WeekProgramSetController.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/3.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^pickerBlock)(DeviceModel *device);


NS_ASSUME_NONNULL_BEGIN

@interface WeekProgramSetController : UIViewController

@property (nonatomic) pickerBlock pickerBlock;
@property (strong, nonatomic) NSIndexPath *indexpath;
@property (strong, nonatomic) NSString *mac;
@property (nonatomic) NSInteger timeRow;
@property (nonatomic) NSInteger tempRow;

@end

NS_ASSUME_NONNULL_END
