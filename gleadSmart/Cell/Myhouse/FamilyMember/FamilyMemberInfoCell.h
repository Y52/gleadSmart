//
//  FamilyMemberInfoCell.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/15.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FamilyMemberInfoCell : UITableViewCell

@property (strong, nonatomic) UIImageView *memberImage;
@property (strong, nonatomic) UILabel *memberName;
@property (strong, nonatomic) UILabel *mobile;

@end

NS_ASSUME_NONNULL_END
