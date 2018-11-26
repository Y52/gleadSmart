//
//  PasswordTableViewCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFBlock)(NSString *password);

@interface PasswordTableViewCell : UITableViewCell

@property (strong, nonatomic) UITextField *passwordTF;
@property (nonatomic) TFBlock TFBlock;

@end
