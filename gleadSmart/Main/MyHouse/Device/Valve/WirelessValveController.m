//
//  WirelessValveController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/22.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "WirelessValveController.h"
#import "NodeDetailCell.h"
#import "NodeDetailViewController.h"
#import "NodeButton.h"
#import "alarmModel.h"
#import "DeviceSettingController.h"
#import "ValveAlertInfoController.h"

NSString *const CellIdentifier_NodeDetail = @"CellID_NodeDetail";

CGFloat const cell_Height = 44.f;
CGFloat const cellHeader_Height = 30.f;
CGFloat const nodeButtonWidth = 20.f;

@interface WirelessValveController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIImageView *headerBgImage;

@property (strong, nonatomic) UIView *leakStatusView;
@property (strong, nonatomic) UIImageView *leakImage;
@property (strong, nonatomic) UILabel *leakLabel;
@property (strong, nonatomic) UIImageView *leakMark;

@property (strong, nonatomic) UIView *valveStatusView;
@property (strong, nonatomic) UIImageView *valveImage;
@property (strong, nonatomic) UILabel *valveLabel;
@property (strong, nonatomic) UIImageView *valveMark;

@property (strong, nonatomic) UIView *switchStatusView;
@property (strong, nonatomic) UIImageView *switchImage;
@property (strong, nonatomic) UILabel *switchLabel;
@property (strong, nonatomic) UIImageView *switchMark;

@property (strong, nonatomic) NSMutableArray *nodeArray;
@property (strong, nonatomic) UIScrollView *nodesView;

@property (strong, nonatomic) UIButton *nodeLeakStatusButton;
@property (strong, nonatomic) UILabel *nodeLeakStatusLabel;
@property (strong, nonatomic) UIButton *nodeBatteryButton;
@property (strong, nonatomic) UILabel *nodeBatteryStatusLabel;
@property (strong, nonatomic) UIButton *nodeSetViewButton;
@property (strong, nonatomic) UILabel *nodeSetLabel;

@property (strong, nonatomic) UITableView *nodeLeakDetailTable;

@property (strong, nonatomic) UIButton *controlSwitchButton;

///@brief 漏水报警情况
@property (nonatomic, strong) NSMutableArray *leakageInfos;
@end

@implementation WirelessValveController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithHexString:@"EAE9E8"].CGColor;
    [self setNavItem];
    
    self.headerBgImage = [self headerBgImage];
    self.leakStatusView = [self leakStatusView];
    self.leakImage = [self leakImage];
    self.leakLabel = [self leakLabel];
    self.leakMark = [self leakMark];
    self.valveStatusView = [self valveStatusView];
    self.valveImage = [self valveImage];
    self.valveLabel = [self valveLabel];
    self.valveMark = [self valveMark];
    self.switchStatusView = [self switchStatusView];
    self.switchImage = [self switchImage];
    self.switchLabel = [self switchLabel];
    self.switchMark = [self switchMark];
    self.nodesView = [self nodesView];
    self.nodeLeakStatusButton = [self nodeLeakStatusButton];
    self.nodeBatteryButton = [self nodeBatteryButton];
    self.nodeSetViewButton = [self nodeSetViewButton];
    self.nodeLeakDetailTable = [self nodeLeakDetailTable];
    self.controlSwitchButton = [self controlSwitchButton];
    
    [self getAllNode];

    [self refreshDevice];//更新水阀的状态UI
    [self nodeLeakageAlarmInfoHttpGet];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    //设置navigationbar隐藏
    self.navigationController.navigationBar.translucent = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDevice) name:@"refreshValve" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshValveNodesUI) name:@"refreshValveHangingNodes" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valveNodesReport:) name:@"valveHangingNodesReport" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valveNodeRabbitmqReport:) name:@"valveHangingNodesRabbitmqReport" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valveReset) name:@"valveReset" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshValveNodesUI) name:@"valveDeleteHangingNode" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshValve" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshValveHangingNodes" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"valveHangingNodesReport" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"valveHangingNodesRabbitmqReport" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"valveReset" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"valveDeleteHangingNode" object:nil];
}
#pragma mark - private methods
//更新内容的kvc
- (void)refreshDevice{
    for (DeviceModel *device in [Network shareNetwork].connectedDevice.gatewayMountDeviceList) {
        if ([device.mac isEqualToString:self.device.mac]) {
            self.device = device;
        }
    }
    [self UITransformationByStatus];
}

//更新UI
- (void)UITransformationByStatus{
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"%@",self.device.isOn);
        if ([self.device.isOn boolValue]) {
            [self.controlSwitchButton setImage:[UIImage imageNamed:@"thermostatControl_on"] forState:UIControlStateNormal];
            [self valveStatus:YES];
        }else{
            [self.controlSwitchButton setImage:[UIImage imageNamed:@"thermostatControl"] forState:UIControlStateNormal];
            [self valveStatus:NO];
        }
    });
}

//tabbar rightbutton action
- (void)moreSetting{
    DeviceSettingController *setVC = [[DeviceSettingController alloc] init];
    setVC.device = self.device;
    [self.navigationController pushViewController:setVC animated:YES];
}

//进入漏水节点详情
- (void)nodeSetDetail{
    if (self.device.nodeArray.count == 0) {
        [NSObject showHudTipStr:@"当前没有选中漏水节点"];
        return;
    }
    NodeDetailViewController *detailVC = [[NodeDetailViewController alloc] init];
    for (int i = 0; i < self.device.nodeArray.count; i++) {
        NodeModel *node = self.device.nodeArray[i];
        if (node.isSelected) {
            detailVC.node = node;
        }
    }
    detailVC.device = self.device;
    [self.navigationController pushViewController:detailVC animated:YES];
}

//漏水状态设置，只要有一个节点漏水就传入yes
- (void)nodesLeakStatus:(NSArray *)nodeArray{
    BOOL hasLeak = NO;
    
    for (NodeModel *node in nodeArray) {
        if (node.isLeak) {
            hasLeak = YES;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (hasLeak) {
            self.leakImage.image = [UIImage imageNamed:@"valveLeak_abnormal"];
            self.leakLabel.text = LocalString(@"漏水");
            self.leakMark.hidden = NO;
        }else{
            self.leakImage.image = [UIImage imageNamed:@"valveLeak_normal"];
            self.leakLabel.text = LocalString(@"正常");
            self.leakMark.hidden = YES;
        }
    });
}

//水阀开关状态设置
- (void)valveStatus:(BOOL)isOn{
    if (isOn) {
        _switchLabel.text = LocalString(@"打开");
    }else{
        _switchLabel.text = LocalString(@"关闭");
    }
}

//根据查询到的节点生成节点
- (void)drawRectNodeButtonList:(NSArray *)nodeArray{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger length = nodeArray.count;

        for (UIButton *button in self.nodesView.subviews) {
            //删除所有之前生成的uibutton，重新生成
            if (button.tag < 1000) {
                continue;
            }
            [button removeFromSuperview];
        }
        for (UIView *view in self.nodesView.subviews) {
            if (view.tag == 500) {//line
                [view removeFromSuperview];
            }
        }
        
        CGFloat height = 181.f - ScreenWidth / 3.f;
        self.nodesView.contentSize = CGSizeMake((20.f + nodeButtonWidth) * length + nodeButtonWidth + ScreenWidth/2.f, height);
        
        UIView *lineFlag;
        for (int i = 0; i < length; i++) {
            NodeModel *nodemodel = nodeArray[i];
            NodeButton *nodeButton = [[NodeButton alloc] init];
            if (nodemodel.isLeak || nodemodel.isLowVoltage) {
                if (i == 0) {
                    nodemodel.isSelected = YES;
                    [nodeButton setImage:[UIImage imageNamed:@"valveNode_selabnormal@2x.png"] forState:UIControlStateNormal];
                }else{
                    nodemodel.isSelected = NO;
                    [nodeButton setImage:[UIImage imageNamed:@"valveNode_abnormal@2x.png"] forState:UIControlStateNormal];
                }
            }else{
                if (i == 0) {
                    nodemodel.isSelected = YES;
                    [nodeButton setImage:[UIImage imageNamed:@"valveNode_selnormal@2x.png"] forState:UIControlStateNormal];
                }else{
                    nodemodel.isSelected = NO;
                    [nodeButton setImage:[UIImage imageNamed:@"valveNode_normal@2x.png"] forState:UIControlStateNormal];
                }
            }
            nodeButton.imageView.clipsToBounds = YES;
            nodeButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
            nodeButton.imageView.clipsToBounds = YES;
            nodeButton.clipsToBounds = YES;
            nodeButton.tag = 1000 + i;
            [nodeButton addTarget:self action:@selector(nodeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.nodesView addSubview:nodeButton];
            
            [nodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(nodeButtonWidth, nodeButtonWidth));
                if (i == 0) {
                    make.centerX.equalTo(self.nodesView.mas_centerX);
                }else{
                    make.left.equalTo(lineFlag.mas_right);
                }
                make.centerY.equalTo(self.nodesView.mas_centerY);
            }];
            
            if (i == length-1) {
                //最后一个不加横线
                continue;
            }
            
            UIView *lineNew = [[UIView alloc] init];
            lineNew.backgroundColor = [UIColor whiteColor];
            lineNew.tag = 500;
            [self.nodesView addSubview:lineNew];
            [lineNew mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20.f, 0.5));
                make.left.equalTo(nodeButton.mas_right);
                make.centerY.equalTo(self.nodesView.mas_centerY);
            }];
            
            lineFlag = lineNew;
        }
    });
}

//节点信息上报收到通知
- (void)valveNodesReport:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSMutableArray *data = [userInfo objectForKey:@"recivedData69"];

    //取出mac
    NSString *mac = @"";
    mac = [mac stringByAppendingString:[NSString HexByInt:[data[5] intValue]]];
    mac = [mac stringByAppendingString:[NSString HexByInt:[data[4] intValue]]];
    mac = [mac stringByAppendingString:[NSString HexByInt:[data[3] intValue]]];
    mac = [mac stringByAppendingString:[NSString HexByInt:[data[2] intValue]]];
    
    if (![self.device.mac isEqualToString:mac]) {
        return;
    }

    //获取节点信息
    NodeModel *node = [[NodeModel alloc] init];
    node.mac = @"";
    node.mac = [node.mac stringByAppendingString:[NSString HexByInt:[data[15] intValue]]];
    node.mac = [node.mac stringByAppendingString:[NSString HexByInt:[data[14] intValue]]];
    node.mac = [node.mac stringByAppendingString:[NSString HexByInt:[data[13] intValue]]];
    node.mac = [node.mac stringByAppendingString:[NSString HexByInt:[data[12] intValue]]];
    UInt8 nodeInfo = [data[16] unsignedIntegerValue];
    if (nodeInfo & 0b00000010) {
        node.isLeak = YES;
    }else{
        node.isLeak = NO;
    }
    if (nodeInfo & 0b00000001){
        node.isLowVoltage = YES;
    }else{
        node.isLowVoltage = NO;
    }
    [self handleNodeReportInfoWithNode:node];
}

//rabbitmq推送信息
- (void)valveNodeRabbitmqReport:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NodeModel *node = [userInfo objectForKey:@"node"];
    if (![self.device.mac isEqualToString:node.valveMac]) {
        return;
    }
    [self handleNodeReportInfoWithNode:node];
}

//处理所有推送或上报的节点的信息
- (void)handleNodeReportInfoWithNode:(NodeModel *)node{
    static BOOL isContain = NO;
    for (NodeModel *containedNode in self.device.nodeArray) {//查找水阀下是否有该节点
        if ([containedNode.mac isEqualToString:node.mac]) {
            isContain = YES;
            containedNode.isLeak = node.isLeak;
            containedNode.isLowVoltage = node.isLowVoltage;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateNodeStatus];//更新该节点信息
            });
        }
    }
    if (!isContain) {//该节点是之前没有的
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawNewReportNode:node];
        });
        if (self.device.nodeArray.count == 0) {
            //这个添加的节点是唯一一个节点，选中该节点，并更新状态
            node.isSelected = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateSelectedNodeStatus:node];
            });
            [self updateSelectedNodeStatus:node];
        }
        [self.device.nodeArray addObject:node];
    }
    
    [self nodesLeakStatus:self.device.nodeArray];//根据漏水信息更新UI
}

//添加新的节点按钮
- (void)drawNewReportNode:(NodeModel *)node{
    UIButton *lastButton;
    for (UIButton *button in self.nodesView.subviews) {
        if (button.tag > lastButton.tag) {
            //获取最后一个button，如果lastButton为空，则表示之前没有节点，生成第一个节点
            lastButton = button;
        }
    }
    
    UIView *lineNew;
    if (lastButton) {
        lineNew = [[UIView alloc] init];
        lineNew.backgroundColor = [UIColor whiteColor];
        lineNew.tag = 500;
        [self.nodesView addSubview:lineNew];
        [lineNew mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20.f, 1.f));
            make.left.equalTo(lastButton.mas_right);
            make.centerY.equalTo(self.nodesView.mas_centerY);
        }];
    }
    
    NodeButton *nodeButton = [[NodeButton alloc] init];
    if (node.isLeak || node.isLowVoltage) {
        if (!lastButton) {
            [nodeButton setImage:[UIImage imageNamed:@"valveNode_selabnormal"] forState:UIControlStateNormal];
        }else{
            [nodeButton setImage:[UIImage imageNamed:@"valveNode_abnormal"] forState:UIControlStateNormal];
        }
    }else{
        if (!lastButton) {
            [nodeButton setImage:[UIImage imageNamed:@"valveNode_selnormal"] forState:UIControlStateNormal];
        }else{
            [nodeButton setImage:[UIImage imageNamed:@"valveNode_normal"] forState:UIControlStateNormal];
        }
    }
    nodeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    nodeButton.tag = lastButton.tag + 1;
    [nodeButton addTarget:self action:@selector(nodeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.nodesView addSubview:nodeButton];
    
    [nodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(nodeButtonWidth, nodeButtonWidth));
        if (!lastButton) {
            make.centerX.equalTo(self.nodesView.mas_centerX);
        }else{
            make.left.equalTo(lineNew.mas_right);
        }
        make.centerY.equalTo(self.nodesView.mas_centerY);
    }];
}

//更新所有节点按钮的状态
- (void)updateNodeStatus{
    for (NodeButton *button in self.nodesView.subviews) {
        if (button.tag < 1000) {
            continue;
        }
        NSInteger index = button.tag - 1000;
        NodeModel *node = self.device.nodeArray[index];
        if (node.isLeak || node.isLowVoltage) {
            if (node.isSelected) {
                [button setImage:[UIImage imageNamed:@"valveNode_selabnormal"] forState:UIControlStateNormal];
            }else{
                [button setImage:[UIImage imageNamed:@"valveNode_abnormal"] forState:UIControlStateNormal];
            }
        }else{
            if (node.isSelected) {
                [button setImage:[UIImage imageNamed:@"valveNode_selnormal"] forState:UIControlStateNormal];
            }else{
                [button setImage:[UIImage imageNamed:@"valveNode_normal"] forState:UIControlStateNormal];
            }
        }
        if (node.isSelected) {//该节点被选中时，节点状态信息要更新
            [self updateSelectedNodeStatus:node];
        }
    }
}

//刷新节点UI的notification@selector，即获得了节点信息帧
- (void)refreshValveNodesUI{
    for (DeviceModel *device in [Network shareNetwork].connectedDevice.gatewayMountDeviceList) {
        if ([device.mac isEqualToString:self.device.mac]) {
            self.device = device;
        }
    }
    [self nodeHttpGet];
    [self drawRectNodeButtonList:self.device.nodeArray];
    [self nodesLeakStatus:self.device.nodeArray];
}


//节点按钮点击
- (void)nodeButtonAction:(UIButton *)nodeButton{
    for (NodeButton *button in self.nodesView.subviews) {
        if (button == nodeButton || button.tag < 1000) {//tag小于1000就不是节点按钮,防止崩溃
            continue;
        }
        
        NSInteger index = button.tag - 1000;
        NodeModel *node = self.device.nodeArray[index];
        node.isSelected = NO;
        if (node.isLeak || node.isLowVoltage) {
            [button setImage:[UIImage imageNamed:@"valveNode_abnormal"] forState:UIControlStateNormal];
        }else{
            [button setImage:[UIImage imageNamed:@"valveNode_normal"] forState:UIControlStateNormal];
        }
    }

    NSInteger index = nodeButton.tag - 1000;
    CGFloat xoffset = index * (20.f + nodeButtonWidth);
    CGFloat yoffset = self.nodesView.contentOffset.y;
    [UIView animateWithDuration:0.5 animations:^{
        self.nodesView.contentOffset = CGPointMake(xoffset, yoffset);
    }];
    
    NodeModel *node = self.device.nodeArray[index];
    node.isSelected = YES;
    if (node.isLeak || node.isLowVoltage) {
        [nodeButton setImage:[UIImage imageNamed:@"valveNode_selabnormal"] forState:UIControlStateNormal];
    }else{
        [nodeButton setImage:[UIImage imageNamed:@"valveNode_selnormal"] forState:UIControlStateNormal];
    }
    [self updateSelectedNodeStatus:node];
}

//选择节点后更新该节点内漏水和电量的状态信息
- (void)updateSelectedNodeStatus:(NodeModel *)node{
    if (node.isLeak) {
        [self.nodeLeakStatusButton setImage:[UIImage imageNamed:@"nodeLeakBig_abnormal"] forState:UIControlStateNormal];
        self.nodeLeakStatusLabel.text = LocalString(@"当前节点漏水");
    }else{
        [self.nodeLeakStatusButton setImage:[UIImage imageNamed:@"nodeLeakBig_normal"] forState:UIControlStateNormal];
        self.nodeLeakStatusLabel.text = LocalString(@"当前节点正常");
    }
    if (node.isLowVoltage) {
        [self.nodeBatteryButton setImage:[UIImage imageNamed:@"nodeBattery_abnormal"] forState:UIControlStateNormal];
        self.nodeBatteryStatusLabel.text = LocalString(@"当前节点电量过低");
    }else{
        [self.nodeBatteryButton setImage:[UIImage imageNamed:@"nodeBattery_normal"] forState:UIControlStateNormal];
        self.nodeBatteryStatusLabel.text = LocalString(@"当前节点电量正常");
    }
}

//清除所有水阀节点(UI)
- (void)valveReset{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIButton *button in self.nodesView.subviews) {
            //删除所有之前生成的uibutton
            if (button.tag < 1000) {
                continue;
            }
            [button removeFromSuperview];
        }
        for (UIView *view in self.nodesView.subviews) {
            if (view.tag == 500) {
                [view removeFromSuperview];
            }
        }
    });
    
}

#pragma mark - Frame private method
//水阀开关
- (void)controlSwitch{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x13,@0x01,@0x01,[NSNumber numberWithBool:![self.device.isOn boolValue]]];
    if (self.device.isShare) {
        [[Network shareNetwork] sendData69With:controlCode shareDevice:self.device data:data failure:nil];
    }else{
        [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data failuer:nil];
    }
}

//获取所有下挂漏水节点
- (void)getAllNode{
    [SVProgressHUD show];
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x13,@0x04,@0x00];
    if (self.device.isShare) {
        [[Network shareNetwork] sendData69With:controlCode shareDevice:self.device data:data failure:nil];
    }else{
        [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data failuer:nil];
    }
}

- (NSMutableArray *)sortLeakageInfosByDate:(NSMutableArray *)arr{
    [arr sortUsingComparator:^NSComparisonResult(alarmModel *obj1, alarmModel *obj2) {
        return NSOrderedDescending;
    }];
    return arr;
}

#pragma mark - server api
- (void)nodeHttpGet{
    Database *db = [Database shareInstance];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];

    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/valve?valveMac=%@",httpIpAddress,self.device.mac];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSArray *nodeData = [responseDic objectForKey:@"data"];
            [nodeData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (![obj isKindOfClass:[NSNull class]]) {
                    BOOL isContain = NO;
                    for (NodeModel *node in self.device.nodeArray) {
                        if ([node.mac isEqualToString:[obj objectForKey:@"mac"]]) {
                            node.number = [obj objectForKey:@"number"];
                            node.name = [obj objectForKey:@"name"];
                            node.room = [obj objectForKey:@"room"];
                            node.isAdd2Server = YES;
                            isContain = YES;
                        }
                    }
                    if (!isContain) {
                        //删除服务器的漏水节点，先不做，感觉不需要
                    }
                }
            }];
            
            for (int i = 0; i < self.device.nodeArray.count; i++) {
                NodeModel *node = self.device.nodeArray[i];
                if (!node.isAdd2Server) {
                    [self nodeInfoHttpPost:node number:[NSNumber numberWithInt:i]];
                }else{
                    if ([node.number intValue] != i) {
                        
                    }
                }
            }
            
        }else{
            [NSObject showHudTipStr:LocalString(@"从服务器获取漏水节点详细信息失败")];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        if (error.code == -1011) {
            [NSObject showHudTipStr:LocalString(@"无网络")];
            return;
        }
        [NSObject showHudTipStr:LocalString(@"从服务器获取漏水节点详细信息失败")];
    }];
}

- (void)nodeInfoHttpPost:(NodeModel *)node number:(NSNumber *)number{
    Database *db = [Database shareInstance];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.currentHouse.apiKey forHTTPHeaderField:@"api-key"];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/valve/node",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSDictionary *parameters = @{@"valveMac":self.device.mac,@"mac":node.mac,@"number":number};
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSLog(@"添加节点到服务器成功");
        }else{
            [NSObject showHudTipStr:LocalString(@"添加节点到服务器失败")];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == -1011) {
            [NSObject showHudTipStr:LocalString(@"无网络")];
            return;
        }
        [NSObject showHudTipStr:LocalString(@"添加节点到服务器失败")];
    }];
}

- (void)nodeInfoHttpPut:(NodeModel *)node number:(NSNumber *)number{
    Database *db = [Database shareInstance];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.currentHouse.apiKey forHTTPHeaderField:@"api-key"];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/valve/node",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSDictionary *parameters = @{@"valveMac":self.device.mac,@"mac":node.mac,@"number":@0};
    //@"5bfcb08be4b0c54526650eec"
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSLog(@"更新节点信息成功");
        }else{
            [NSObject showHudTipStr:LocalString(@"更新节点信息失败")];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error.code == -1011) {
            [NSObject showHudTipStr:LocalString(@"无网络")];
            return;
        }
        [NSObject showHudTipStr:LocalString(@"更新节点信息失败")];
    }];
}


- (void)nodeLeakageAlarmInfoHttpGet{
    Database *db = [Database shareInstance];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.currentHouse.apiKey forHTTPHeaderField:@"api-key"];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/valve/warn?valveMac=%@",httpIpAddress,self.device.mac];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSArray *data = [responseDic objectForKey:@"data"];
            if (data.count <= 0) {
                return;
            }
            if (!self.leakageInfos) {
                self.leakageInfos = [[NSMutableArray alloc] init];
            }
            [self.leakageInfos removeAllObjects];
            [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                alarmModel *alarm = [[alarmModel alloc] init];
                alarm.room = [obj objectForKey:@"room"];
                alarm.time = [NSDate UTCDateFromLocalString:[obj objectForKey:@"time"]];
                [self.leakageInfos addObject:alarm];
            }];
            self.leakageInfos = [self sortLeakageInfosByDate:self.leakageInfos];
            [self.nodeLeakDetailTable reloadData];
        }else{
            [NSObject showHudTipStr:LocalString(@"从服务器获取漏水报警情况失败")];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error:%@",error);
        if (error.code == -1011) {
            [NSObject showHudTipStr:LocalString(@"无网络")];
            return;
        }
        [NSObject showHudTipStr:LocalString(@"从服务器获取漏水报警情况失败")];
    }];
}

#pragma mark - getters and setters
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"无线水阀");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"valveTabMore"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(moreSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UIImageView *)headerBgImage{
    if (!_headerBgImage) {
        _headerBgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_headerBg"]];
        [self.view insertSubview:_headerBgImage atIndex:0];
        [_headerBgImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 181.f + getRectNavAndStatusHight));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.mas_topLayoutGuideTop);
        }];
    }
    return _headerBgImage;
}

- (UIView *)leakStatusView{
    if (!_leakStatusView) {
        _leakStatusView = [[UIView alloc] init];
        [self.view addSubview:_leakStatusView];
        [_leakStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth / 3.f, ScreenWidth / 3.f));
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.mas_topLayoutGuideTop).offset(getRectNavAndStatusHight);
        }];
        
        UIView *line1 = [[UIView alloc] init];
        line1.backgroundColor = [UIColor colorWithHexString:@"ADC1CE"];
        [self.view addSubview:line1];
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 1.f));
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.mas_topLayoutGuideTop).offset(getRectNavAndStatusHight);
        }];
        
        UIView *line2 = [[UIView alloc] init];
        line2.backgroundColor = [UIColor colorWithHexString:@"ADC1CE"];
        [self.view addSubview:line2];
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, 1.f));
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.mas_topLayoutGuideTop).offset(getRectNavAndStatusHight + ScreenWidth / 3.f);
        }];
    }
    return _leakStatusView;
}

- (UIImageView *)leakImage{
    if (!_leakImage) {
        _leakImage = [[UIImageView alloc] init];
        _leakImage.image = [UIImage imageNamed:@"valveLeak_normal"];
        [self.leakStatusView addSubview:_leakImage];
        [_leakImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(60.f), yAutoFit(60.f)));
            make.centerX.equalTo(self.leakStatusView.mas_centerX);
            make.centerY.equalTo(self.leakStatusView.mas_centerY).offset(-yAutoFit(15.f));
        }];
    }
    return _leakImage;
}

- (UILabel *)leakLabel{
    if (!_leakLabel) {
        _leakLabel = [[UILabel alloc] init];
        _leakLabel.text = LocalString(@"正常");
        _leakLabel.textAlignment = NSTextAlignmentCenter;
        _leakLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:254/255.0 alpha:1];
        _leakLabel.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        [self.leakStatusView addSubview:_leakLabel];
        [_leakLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(60.f), yAutoFit(13.f)));
            make.centerX.equalTo(self.leakStatusView.mas_centerX);
            make.top.equalTo(self.leakImage.mas_bottom).offset(yAutoFit(5.f));
        }];
    }
    return _leakLabel;
}

- (UIImageView *)leakMark{
    if (!_leakMark) {
        _leakMark = [[UIImageView alloc] init];
        _leakMark.image = [UIImage imageNamed:@"valveAlertMark"];
        _leakMark.hidden = YES;
        [self.leakStatusView addSubview:_leakMark];
        [_leakMark mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(30.f), yAutoFit(30.f)));
            make.top.equalTo(self.leakStatusView.mas_top);
            make.right.equalTo(self.leakStatusView.mas_right);
        }];
    }
    return _leakMark;
}

- (UIView *)valveStatusView{
    if (!_valveStatusView) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithHexString:@"ADC1CE"];
        [self.view addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(1.f, ScreenWidth / 3.f));
            make.left.equalTo(self.leakStatusView.mas_right);
            make.top.equalTo(self.mas_topLayoutGuideTop).offset(getRectNavAndStatusHight);
        }];
        
        _valveStatusView = [[UIView alloc] init];
        [self.view addSubview:_valveStatusView];
        [_valveStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth / 3.f, ScreenWidth / 3.f));
            make.left.equalTo(self.leakStatusView.mas_right);
            make.top.equalTo(self.mas_topLayoutGuideTop).offset(getRectNavAndStatusHight);
        }];
    }
    return _valveStatusView;
}

- (UIImageView *)valveImage{
    if (!_valveImage) {
        _valveImage = [[UIImageView alloc] init];
        _valveImage.image = [UIImage imageNamed:@"valveStatus_normal"];
        [self.valveStatusView addSubview:_valveImage];
        [_valveImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(60.f), yAutoFit(60.f)));
            make.centerX.equalTo(self.valveStatusView.mas_centerX);
            make.centerY.equalTo(self.valveStatusView.mas_centerY).offset(-yAutoFit(15.f));
        }];
    }
    return _valveImage;
}

- (UILabel *)valveLabel{
    if (!_valveLabel) {
        _valveLabel = [[UILabel alloc] init];
        _valveLabel.text = LocalString(@"阀门正常");
        _valveLabel.textAlignment = NSTextAlignmentCenter;
        _valveLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:254/255.0 alpha:1];
        _valveLabel.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        _valveLabel.adjustsFontSizeToFitWidth = YES;
        [self.valveStatusView addSubview:_valveLabel];
        [_valveLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(60.f), yAutoFit(13.f)));
            make.centerX.equalTo(self.valveStatusView.mas_centerX);
            make.top.equalTo(self.valveImage.mas_bottom).offset(yAutoFit(5.f));
        }];
    }
    return _valveLabel;
}

- (UIImageView *)valveMark{
    if (!_valveMark) {
        _valveMark = [[UIImageView alloc] init];
        _valveMark.image = [UIImage imageNamed:@"valveAlertMark"];
        _valveMark.hidden = YES;
        [self.valveStatusView addSubview:_valveMark];
        [_valveMark mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(30.f), yAutoFit(30.f)));
            make.top.equalTo(self.valveStatusView.mas_top);
            make.right.equalTo(self.valveStatusView.mas_right);
        }];
    }
    return _valveMark;
}

- (UIView *)switchStatusView{
    if (!_switchStatusView) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor colorWithHexString:@"ADC1CE"];
        [self.view addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(1.f, ScreenWidth / 3.f));
            make.left.equalTo(self.valveStatusView.mas_right);
            make.top.equalTo(self.mas_topLayoutGuideTop).offset(getRectNavAndStatusHight);
        }];
        
        _switchStatusView = [[UIView alloc] init];
        [self.view addSubview:_switchStatusView];
        [_switchStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth / 3.f, ScreenWidth / 3.f));
            make.left.equalTo(self.valveStatusView.mas_right);
            make.top.equalTo(self.mas_topLayoutGuideTop).offset(getRectNavAndStatusHight);

        }];
    }
    return _switchStatusView;
}

- (UIImageView *)switchImage{
    if (!_switchImage) {
        _switchImage = [[UIImageView alloc] init];
        _switchImage.image = [UIImage imageNamed:@"valveSwitch_normal"];
        [self.switchStatusView addSubview:_switchImage];
        [_switchImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(60.f), yAutoFit(60.f)));
            make.centerX.equalTo(self.switchStatusView.mas_centerX);
            make.centerY.equalTo(self.switchStatusView.mas_centerY).offset(-yAutoFit(15.f));
        }];
    }
    return _switchImage;
}

- (UILabel *)switchLabel{
    if (!_switchLabel) {
        _switchLabel = [[UILabel alloc] init];
        _switchLabel.text = LocalString(@"关闭");
        _switchLabel.textAlignment = NSTextAlignmentCenter;
        _switchLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:254/255.0 alpha:1];
        _switchLabel.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        [self.switchStatusView addSubview:_switchLabel];
        [_switchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(60.f), yAutoFit(13.f)));
            make.centerX.equalTo(self.switchStatusView.mas_centerX);
            make.top.equalTo(self.switchImage.mas_bottom).offset(yAutoFit(5.f));
        }];
    }
    return _switchLabel;
}

-(UIImageView *)switchMark{
    if (!_switchMark) {
        _switchMark = [[UIImageView alloc] init];
        _switchMark.image = [UIImage imageNamed:@"valveAlertMark"];
        _switchMark.hidden = YES;
        [self.switchStatusView addSubview:_switchMark];
        [_switchMark mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(30.f), yAutoFit(30.f)));
            make.top.equalTo(self.switchStatusView.mas_top);
            make.right.equalTo(self.switchStatusView.mas_right);
        }];
    }
    return _switchMark;
}

- (UIView *)nodesView{
    if (!_nodesView) {
        _nodesView = [[UIScrollView alloc] init];
        _nodesView.scrollEnabled = YES;
        _nodesView.showsHorizontalScrollIndicator = YES;
        [self.view addSubview:_nodesView];
        CGFloat height = 181.f - ScreenWidth / 3.f;//181是头部背景图片的高度
        [_nodesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, height));
            make.top.equalTo(self.switchStatusView.mas_bottom);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _nodesView;
}

-(UIButton *)nodeLeakStatusButton{
    if (!_nodeLeakStatusButton) {
        _nodeLeakStatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nodeLeakStatusButton setImage:[UIImage imageNamed:@"nodeLeakBig_normal"] forState:UIControlStateNormal];
        [self.view addSubview:_nodeLeakStatusButton];
        [_nodeLeakStatusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(52.f), yAutoFit(52.f)));
            make.centerX.equalTo(self.view.mas_left).offset(ScreenWidth / 6.f);
            make.top.equalTo(self.headerBgImage.mas_bottom).offset(15.f);
        }];
        
        _nodeLeakStatusLabel = [[UILabel alloc] init];
        _nodeLeakStatusLabel.textAlignment = NSTextAlignmentCenter;
        _nodeLeakStatusLabel.text = LocalString(@"当前节点正常");
        _nodeLeakStatusLabel.textColor = [UIColor colorWithHexString:@"3987F8"];
        _nodeLeakStatusLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        _nodeLeakStatusLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_nodeLeakStatusLabel];
        [_nodeLeakStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth / 3.f, yAutoFit(17.f)));
            make.left.equalTo(self.view.mas_left);
            make.top.equalTo(self.nodeLeakStatusButton.mas_bottom).offset(5.f);
        }];
    }
    return _nodeLeakStatusButton;
}

- (UIButton *)nodeBatteryButton{
    if (!_nodeBatteryButton) {
        _nodeBatteryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nodeBatteryButton setImage:[UIImage imageNamed:@"nodeBattery_normal"] forState:UIControlStateNormal];
        [self.view addSubview:_nodeBatteryButton];
        [_nodeBatteryButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(52.f), yAutoFit(52.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.headerBgImage.mas_bottom).offset(15.f);
        }];
        
        _nodeBatteryStatusLabel = [[UILabel alloc] init];
        _nodeBatteryStatusLabel.textAlignment = NSTextAlignmentCenter;
        _nodeBatteryStatusLabel.text = LocalString(@"当前节点电量正常");
        _nodeBatteryStatusLabel.textColor = [UIColor colorWithHexString:@"3987F8"];
        _nodeBatteryStatusLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        _nodeBatteryStatusLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_nodeBatteryStatusLabel];
        [_nodeBatteryStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth / 3.f, yAutoFit(17.f)));
            make.left.equalTo(self.nodeLeakStatusLabel.mas_right);
            make.top.equalTo(self.nodeBatteryButton.mas_bottom).offset(5.f);
        }];
    }
    return _nodeBatteryButton;
}

- (UIButton *)nodeSetViewButton{
    if (!_nodeSetViewButton) {
        _nodeSetViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nodeSetViewButton setImage:[UIImage imageNamed:@"nodeSet_normal"] forState:UIControlStateNormal];
        [_nodeSetViewButton addTarget:self action:@selector(nodeSetDetail) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nodeSetViewButton];
        [_nodeSetViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(52.f), yAutoFit(52.f)));
            make.centerX.equalTo(self.view.mas_right).offset(-ScreenWidth / 6.f);
            make.top.equalTo(self.headerBgImage.mas_bottom).offset(15.f);
        }];
        
        _nodeSetLabel = [[UILabel alloc] init];
        _nodeSetLabel.textAlignment = NSTextAlignmentCenter;
        _nodeSetLabel.text = LocalString(@"当前节点设置");
        _nodeSetLabel.textColor = [UIColor colorWithHexString:@"3987F8"];
        _nodeSetLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
        _nodeSetLabel.adjustsFontSizeToFitWidth = YES;
        [self.view addSubview:_nodeSetLabel];
        [_nodeSetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth / 3.f, yAutoFit(17.f)));
            make.left.equalTo(self.nodeBatteryStatusLabel.mas_right);
            make.top.equalTo(self.nodeSetViewButton.mas_bottom).offset(5.f);
        }];
    }
    return _nodeSetViewButton;
}

-(UITableView *)nodeLeakDetailTable{
    if (!_nodeLeakDetailTable) {
        _nodeLeakDetailTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.view.frame.size.height)];
            
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
            tableView.scrollEnabled = NO;
            [tableView registerClass:[NodeDetailCell class] forCellReuseIdentifier:CellIdentifier_NodeDetail];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
        [_nodeLeakDetailTable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, cellHeader_Height + cell_Height * 3));
            make.top.equalTo(self.nodeLeakStatusLabel.mas_bottom).offset(yAutoFit(15.f));
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _nodeLeakDetailTable;
}

- (UIButton *)controlSwitchButton{
    if (!_controlSwitchButton) {
        _controlSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_controlSwitchButton setTitle:LocalString(@"开关") forState:UIControlStateNormal];
        [_controlSwitchButton setTitleColor:[UIColor colorWithRed:160/255.0 green:159/255.0 blue:159/255.0 alpha:1] forState:UIControlStateNormal];
        [_controlSwitchButton setImage:[UIImage imageNamed:@"thermostatControl"] forState:UIControlStateNormal];
        _controlSwitchButton.tag = yUnselect;
        //[_controlSwitchButton.imageView sizeThatFits:CGSizeMake(51.f, 51.f)];
        _controlSwitchButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:17.f];
        [_controlSwitchButton addTarget:self action:@selector(controlSwitch) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_controlSwitchButton];
        [_controlSwitchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(51.f, 70.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(self.view.mas_bottom).offset(yAutoFit(-(30.f + ySafeArea_Bottom)));
        }];
        _controlSwitchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//使图片和文字水平居中显示
        [_controlSwitchButton setTitleEdgeInsets:UIEdgeInsetsMake(_controlSwitchButton.imageView.frame.size.height + _controlSwitchButton.imageView.frame.origin.y + 10.f, -
                                                         _controlSwitchButton.imageView.frame.size.width, 0.0, 5.0)];//文字距离上边框的距离增加imageView的高度，距离左边框减少imageView的宽度，距离下边框和右边框距离不变
        [_controlSwitchButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -
                                                         _controlSwitchButton.titleLabel.bounds.size.width)];//图片距离右边框距离减少图片的宽度，其它不边
    }
    return _controlSwitchButton;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.leakageInfos.count > 3) {
        return 3;
    }else{
        return self.leakageInfos.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NodeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_NodeDetail];
    if (cell == nil) {
        cell = [[NodeDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_NodeDetail];
    }
    alarmModel *alarm = [self.leakageInfos objectAtIndex:indexPath.row];
    cell.leakImage.image = [UIImage imageNamed:@"nodeLeakBig_abnormal"];
    cell.detailLabel.text = alarm.room;
    cell.dateLabel.text = [NSDate localStringFromUTCDate:alarm.time];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cell_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, cellHeader_Height)];
    headerView.layer.backgroundColor = [UIColor colorWithRed:215/255.0 green:215/255.0 blue:215/255.0 alpha:1].CGColor;
    
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [headerButton setImage:[UIImage imageNamed:@"nodeHeaderBtn"] forState:UIControlStateNormal];
    headerButton.frame = CGRectMake(20.f, 5.f, 150.f, 20.f);
    [headerButton setTitleColor:[UIColor colorWithHexString:@"3987F8"] forState:UIControlStateNormal];
    [headerButton setTitle:LocalString(@"查看所有节点漏水详情") forState:UIControlStateNormal];
    headerButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13.f];
    headerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [headerButton addTarget:self action:@selector(CheckedOut) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:headerButton];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return cellHeader_Height;
}

- (void)CheckedOut{
    ValveAlertInfoController *ValveAlertVC = [[ValveAlertInfoController alloc] init];
    ValveAlertVC.leakAlertInfo = self.leakageInfos;
    [self.navigationController pushViewController:ValveAlertVC animated:YES];
}

@end
