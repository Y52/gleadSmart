//
//  NodeDetailViewController.h
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/8.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface NodeDetailViewController : UIViewController

@property (nonatomic, strong) NodeModel *node;
@property (nonatomic, strong) DeviceModel *device;

@end

NS_ASSUME_NONNULL_END
