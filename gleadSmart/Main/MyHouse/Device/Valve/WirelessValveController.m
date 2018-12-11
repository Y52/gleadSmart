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

NSString *const CellIdentifier_NodeDetail = @"CellID_NodeDetail";

CGFloat const cell_Height = 44.f;
CGFloat const cellHeader_Height = 30.f;

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
@end

@implementation WirelessValveController

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
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
    self.navigationController.navigationBar.translucent = YES;
}
#pragma mark - Lazy load
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
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, yAutoFit(181.f + getRectNavAndStatusHight)));
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
        _leakImage.image = [UIImage imageNamed:@"valveLeak_abnormal"];
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
        _leakLabel.text = LocalString(@"漏水");
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
        //_leakMark.hidden = YES;
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
        CGFloat height = 181.f - ScreenWidth / 3.f;
        [_nodesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, height));
            make.top.equalTo(self.switchStatusView.mas_bottom);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        _nodesView.contentSize = CGSizeMake(32.f*19 + 12.f, height);

        UIImageView *nodeView = [[UIImageView alloc] init];
        nodeView.image = [UIImage imageNamed:@"valveNode_normal"];
        nodeView.tag = 1000;
        [_nodesView addSubview:nodeView];
        [nodeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(12.f, 12.f));
            make.left.equalTo(self.nodesView.mas_left);
            make.centerY.equalTo(self.nodesView.mas_centerY);
        }];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor whiteColor];
        [_nodesView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20.f, 1.f));
            make.left.equalTo(nodeView.mas_right);
            make.centerY.equalTo(self.nodesView.mas_centerY);
        }];
        
        for (int i = 1; i < 20; i++) {
            UIImageView *nodeViewNew = [[UIImageView alloc] init];
            nodeViewNew.image = [UIImage imageNamed:@"valveNode_normal"];
            nodeViewNew.tag = 1000 + i;
            [_nodesView addSubview:nodeViewNew];
            [nodeViewNew mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(yAutoFit(12.f), yAutoFit(12.f)));
                make.left.equalTo(line.mas_right);
                make.centerY.equalTo(self.nodesView.mas_centerY);
            }];
            
            if (i == 19) {
                //最后一个不加横线
                continue;
            }
            
            UIView *lineNew = [[UIView alloc] init];
            lineNew.backgroundColor = [UIColor whiteColor];
            [_nodesView addSubview:lineNew];
            [lineNew mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20.f, 1.f));
                make.left.equalTo(nodeViewNew.mas_right);
                make.centerY.equalTo(self.nodesView.mas_centerY);
            }];
            
            line = lineNew;
        }
    }
    return _nodesView;
}

-(UIButton *)nodeLeakStatusButton{
    if (!_nodeLeakStatusButton) {
        _nodeLeakStatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nodeLeakStatusButton setImage:[UIImage imageNamed:@"nodeLeakBig_abnormal"] forState:UIControlStateNormal];
        [self.view addSubview:_nodeLeakStatusButton];
        [_nodeLeakStatusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(52.f), yAutoFit(52.f)));
            make.centerX.equalTo(self.view.mas_left).offset(ScreenWidth / 6.f);
            make.top.equalTo(self.headerBgImage.mas_bottom).offset(15.f);
        }];
        
        _nodeLeakStatusLabel = [[UILabel alloc] init];
        _nodeLeakStatusLabel.textAlignment = NSTextAlignmentCenter;
        _nodeLeakStatusLabel.text = LocalString(@"当前节点漏水");
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NodeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_NodeDetail];
    if (cell == nil) {
        cell = [[NodeDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_NodeDetail];
    }
    cell.leakImage.image = [UIImage imageNamed:@"nodeLeakBig_abnormal"];
    cell.detailLabel.text = @"厨房漏水";
    cell.dateLabel.text = @"2018.10.06 13:58:34";
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
    [headerView addSubview:headerButton];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return cellHeader_Height;
}

#pragma mark - Actions
- (void)moreSetting{
    
}

- (void)controlSwitch{
    if (self.controlSwitchButton.tag == yUnselect) {
        self.controlSwitchButton.tag = ySelect;
        [self.controlSwitchButton setImage:[UIImage imageNamed:@"thermostatControl_on"] forState:UIControlStateNormal];

    }else{
        self.controlSwitchButton.tag = yUnselect;
        [self.controlSwitchButton setImage:[UIImage imageNamed:@"thermostatControl"] forState:UIControlStateNormal];

    }
}

- (void)nodeSetDetail{
    NodeDetailViewController *detailVC = [[NodeDetailViewController alloc] init];
    [self.navigationController pushViewController:detailVC animated:YES];
}

//获取所有下挂漏水节点
- (void)getAllNode{
    UInt8 controlCode = 0x01;
    NSArray *data = @[@0xFE,@0x13,@0x04,@0x00];
    [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:data];
}
@end
