//
//  PhoneVerifyCell.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/9/19.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFBlock)(NSString *text);
typedef BOOL(^BtnBlock)(void);

@interface PhoneVerifyCell2 : UITableViewCell

@property (nonatomic, strong) UITextField *codeTF;
@property (nonatomic, strong) UIButton *verifyBtn;
@property (nonatomic) TFBlock TFBlock;
@property (nonatomic) BtnBlock BtnBlock;
@property (strong, nonatomic) dispatch_source_t timer;

-(void)openCountdown;
@end

