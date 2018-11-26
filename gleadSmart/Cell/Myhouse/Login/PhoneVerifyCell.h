//
//  PhoneVerifyCell.h
//  Heating
//
//  Created by Mac on 2018/11/12.
//  Copyright © 2018 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^TFBlock)(NSString *text);
typedef BOOL(^BtnBlock)(void);

@interface PhoneVerifyCell : UITableViewCell

@property (nonatomic, strong) UITextField *codeTF;
@property (nonatomic, strong) UIButton *verifyBtn;
@property (nonatomic) TFBlock TFBlock;
@property (nonatomic) BtnBlock BtnBlock;

@property (strong, nonatomic) dispatch_source_t timer;

-(void)openCountdown;

@end
