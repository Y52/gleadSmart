//
//  NodeDetailViewController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/8.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "NTCNodeDetailViewController.h"
#import "NodeInfoCell.h"

NSString *const CellIdentifier_NTCValveDetailInfo = @"CellID_NTCValveDetailInfo";
static CGFloat const Cell_NTCHeight = 44.f;

@interface NTCNodeDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *nodeDetailTable;
@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation NTCNodeDetailViewController

#pragma mark - life circle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    self.navigationItem.title = LocalString(@"漏水节点");
    
    self.nodeDetailTable = [self nodeDetailTable];
    self.deleteButton = [self deleteButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    //self.navigationController.navigationBar.topItem.title = @"";
}

#pragma mark - Actions
- (void)deleteNode{
    [self deleteAlertController];
}

- (void)deleteAlertController{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认删除提示" message:@"确认要删除该节点吗?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UInt8 controlCode = 0x01;
        NSArray *data = @[@0xFE,@0x13,@0x07,@0x01];
        NSMutableArray *muteData = [data mutableCopy];
        [muteData addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[self.node.mac substringWithRange:NSMakeRange(0, 2)]]]];
        [muteData addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[self.node.mac substringWithRange:NSMakeRange(2, 2)]]]];
        [muteData addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[self.node.mac substringWithRange:NSMakeRange(4, 2)]]]];
        [muteData addObject:[NSNumber numberWithInt:[NSString stringScanToInt:[self.node.mac substringWithRange:NSMakeRange(6, 2)]]]];
        [[Network shareNetwork] sendData69With:controlCode mac:self.device.mac data:muteData failuer:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - setters and getters
- (UITableView *)nodeDetailTable{
    if (!_nodeDetailTable) {
        _nodeDetailTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0.f, 0.f, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 100)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            tableView.scrollEnabled = NO;
            [tableView registerClass:[NodeInfoCell class] forCellReuseIdentifier:CellIdentifier_NTCValveDetailInfo];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _nodeDetailTable;
}

- (UIButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setTitle:LocalString(@"移除节点") forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor colorWithHexString:@"639DF8"] forState:UIControlStateNormal];
        [_deleteButton setBackgroundColor:[UIColor whiteColor]];
        [_deleteButton addTarget:self action:@selector(deleteNode) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_deleteButton];
        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(276.f), 44.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_bottom).offset(-100.f);
        }];
        _deleteButton.layer.cornerRadius = 22.f;
        _deleteButton.layer.borderWidth = 1.f;
        _deleteButton.layer.borderColor = [UIColor colorWithHexString:@"3987F8"].CGColor;

    }
    return _deleteButton;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NodeInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_NTCValveDetailInfo];
    if (cell == nil) {
        cell = [[NodeInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_NTCValveDetailInfo];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row) {
        case 0:
        {
            cell.leftLabel.text = LocalString(@"节点序号");
            cell.infoLabel.text = [NSString stringWithFormat:@"%@",self.node.number];
        }
            break;
            
        case 1:
        {
            cell.leftLabel.text = LocalString(@"节点名称");
            cell.infoLabel.text = self.node.name;
        }
            break;
            
        case 2:
        {
            cell.leftLabel.text = LocalString(@"节点位置");
            cell.infoLabel.text = self.node.room;
        }
            break;
            
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_NTCHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    headerView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(23.f, 0, ScreenWidth, 44.f)];
    textLabel.textColor = [UIColor colorWithRed:124/255.0 green:124/255.0 blue:123/255.0 alpha:1.0];
    textLabel.font = [UIFont systemFontOfSize:14.f];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textLabel];
    textLabel.text = LocalString(@"基本信息");

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.f;
}

@end
