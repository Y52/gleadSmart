//
//  LoginViewController.h
//  Heating
//
//  Created by Mac on 2018/11/7.
//  Copyright © 2018 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^TFBlock)(NSString *text);
typedef BOOL(^BtnBlock)(void);
@interface LoginViewController : UIViewController

@property (strong, nonatomic) dispatch_source_t timer;
@property (nonatomic) BtnBlock BtnBlock;
-(void)openCountdown;

@end
