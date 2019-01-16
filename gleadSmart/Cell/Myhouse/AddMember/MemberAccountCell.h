//
//  MemberAccountCell.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/1/16.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TFBlock)(NSString *text);

NS_ASSUME_NONNULL_BEGIN

@interface MemberAccountCell : UITableViewCell

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UITextField *accountLabel;
@property (nonatomic) TFBlock TFBlock;

@end

NS_ASSUME_NONNULL_END
