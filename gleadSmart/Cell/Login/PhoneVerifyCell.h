//
//  PhoneVerifyCell.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/3/11.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TFBlock)(NSString *text);
typedef BOOL(^BtnBlock)(void);

@interface PhoneVerifyCell : UITableViewCell

@property (nonatomic, strong) UITextField *codeTF;
@property (nonatomic, strong) UIButton *verifyBtn;
@property (nonatomic, strong) UIImageView *verifyimage;
@property (nonatomic) TFBlock TFBlock;
@property (nonatomic) BtnBlock BtnBlock;
@property (strong, nonatomic) dispatch_source_t timer;

-(void)openCountdown;

@end

NS_ASSUME_NONNULL_END
