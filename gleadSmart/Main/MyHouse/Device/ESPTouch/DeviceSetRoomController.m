//
//  DeviceSetRoomController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/6/3.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceSetRoomController.h"

@interface DeviceSetRoomController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *deviceImage;
@property (nonatomic, strong) UITextField *nameButton;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation DeviceSetRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;

    self.navigationItem.title = LocalString(@"添加设备");
    
    self.titleLabel = [self titleLabel];
    self.deviceImage = [self deviceImage];
    self.nameButton = [self nameButton];
    self.buttonView = [self buttonView];
    self.doneButton = [self doneButton];
    
}

#pragma mark - setters and getters

@end
