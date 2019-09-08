//
//  NodeLocationController.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/8/12.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^popBlock)(NSString *roomName);

@interface NodeLocationController : UIViewController

@property (nonatomic, strong) NodeModel *node;
@property (nonatomic) popBlock popBlock;

@end

NS_ASSUME_NONNULL_END
