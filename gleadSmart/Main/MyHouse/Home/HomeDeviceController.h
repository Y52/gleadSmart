//
//  HomeDeviceController.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/14.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^reloadBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface HomeDeviceController : UIViewController

@property (nonatomic) CGFloat filledSpcingHeight;
@property (strong, nonatomic, nullable) RoomModel *room;
@property (nonatomic) reloadBlock reloadBlock;

@end

NS_ASSUME_NONNULL_END
