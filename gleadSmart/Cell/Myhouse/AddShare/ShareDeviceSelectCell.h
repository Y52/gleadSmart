//
//  ShareDeviceSelectCell.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/19.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareDeviceSelectCell : UITableViewCell

@property (strong, nonatomic) UIImageView *deviceImage;
@property (strong, nonatomic) UILabel *deviceName;
@property (strong, nonatomic) UILabel *status;
@property (strong, nonatomic) UIImageView *selectImage;

@end

NS_ASSUME_NONNULL_END
