//
//  ManagerSetCell.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/1/16.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^switchBlock)(BOOL isOn);

NS_ASSUME_NONNULL_BEGIN

@interface ManagerSetCell : UITableViewCell

@property (nonatomic,strong) UILabel *leftLabel;
@property (nonatomic,strong) UISwitch *controlSwitch;
@property (nonatomic) switchBlock switchBlock;

@end

NS_ASSUME_NONNULL_END
