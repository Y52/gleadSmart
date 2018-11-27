//
//  TextFieldCell.h
//  Heating
//
//  Created by Mac on 2018/11/12.
//  Copyright © 2018 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFBlock)(NSString *text);

@interface TextFieldCell : UITableViewCell

@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIImageView *passwordimage;
@property (nonatomic) TFBlock TFBlock;

@end
