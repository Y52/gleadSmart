//
//  YPickerAlertController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^pickerBlock)(NSInteger picker);

NS_ASSUME_NONNULL_BEGIN

@interface YPickerAlertController : UIViewController

@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSMutableArray *pickerArr;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) pickerBlock pickerBlock;

@end

NS_ASSUME_NONNULL_END
