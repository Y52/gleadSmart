//
//  PhoneTFCell.h
//  Heating
//
//  Created by Mac on 2018/11/12.
//  Copyright © 2018 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^TFBlock)(NSString *text);

@interface PhoneTFCell : UITableViewCell

@property (nonatomic, strong) UITextField *phoneTF;
@property (nonatomic, strong) UIImageView *phoneimage;
@property (nonatomic) TFBlock TFBlock;

@end
