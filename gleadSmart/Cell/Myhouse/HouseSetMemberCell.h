//
//  HouseSetMemberCell.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HouseSetMemberCell : UITableViewCell

@property (strong, nonatomic) UIImageView *memberImage;
@property (strong, nonatomic) UILabel *memberName;
@property (strong, nonatomic) UILabel *mobile;
@property (strong, nonatomic) UILabel *identity;

@end

NS_ASSUME_NONNULL_END
