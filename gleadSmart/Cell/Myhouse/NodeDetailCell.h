//
//  NodeDetailCell.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/22.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NodeDetailCell : UITableViewCell

@property (strong, nonatomic) UIImageView *leakImage;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UILabel *dateLabel;

@end

NS_ASSUME_NONNULL_END
