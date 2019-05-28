//
//  HomeNameSetCell.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/5/27.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFBlock)(NSString *text);

NS_ASSUME_NONNULL_BEGIN

@interface HomeNameSetCell : UITableViewCell

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UITextField *nameTF;
@property (nonatomic) TFBlock TFBlock;

@end

NS_ASSUME_NONNULL_END
