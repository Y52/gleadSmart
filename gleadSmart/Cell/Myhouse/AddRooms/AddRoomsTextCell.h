//
//  AddRoomsTextCell.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/2/26.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^TFBlock)(NSString *text);

@interface AddRoomsTextCell : UITableViewCell

@property (strong, nonatomic) UILabel *leftLabel;
@property (strong, nonatomic) UITextField *inputTF;
@property (nonatomic) TFBlock TFBlock;


@end

NS_ASSUME_NONNULL_END
