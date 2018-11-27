//
//  AddFamilyTextCell.h
//  gleadSmart
//
//  Created by Mac on 2018/11/22.
//  Copyright © 2018 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFBlock)(NSString *text);

@interface AddFamilyTextCell : UITableViewCell

@property (strong, nonatomic) UILabel *leftLabel;
@property (strong, nonatomic) UITextField *inputTF;
@property (nonatomic) TFBlock TFBlock;

@end
