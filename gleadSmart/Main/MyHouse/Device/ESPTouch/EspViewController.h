//
//  EspViewController.h
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/6/24.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ESPTouchResult;

typedef void(^espBlock)(ESPTouchResult *result);

@interface EspViewController : BaseViewController

@property (nonatomic,strong) NSString *ssid;
@property (nonatomic,strong) NSString *bssid;
@property (nonatomic, strong) espBlock block;

@end
