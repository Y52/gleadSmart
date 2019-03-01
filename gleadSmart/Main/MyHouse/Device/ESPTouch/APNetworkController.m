//
//  APNetworkController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/3/1.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "APNetworkController.h"

#import <SystemConfiguration/CaptiveNetwork.h>

@interface APNetworkController () <UITableViewDelegate, UITableViewDataSource>


@end

@implementation APNetworkController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"AP模式");
}

@end
