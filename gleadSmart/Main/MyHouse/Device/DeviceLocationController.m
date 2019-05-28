//
//  DeviceLocationController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/5/27.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceLocationController.h"
#import "DeviceLocationCell.h"

NSString *const CellIdentifier_DeviceLocation = @"CellID_DeviceLocationCell";

@interface DeviceLocationController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSArray *roomList;
@property (strong, nonatomic) UITableView *DeviceLocationTable;

@property (strong, nonatomic) NSString *selectRoomUid;

@end

@implementation DeviceLocationController{
   
    NSMutableArray *checkedRoomArray;
}

- (instancetype)init{
    if (self) {
        self->checkedRoomArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor;
    [self setNavItem];
    
    self.roomList = [[Database shareInstance] queryRoomsWith: self.device.houseUid];
    
    self.DeviceLocationTable = [self DeviceLocationTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"设备位置");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(completeAddFamily) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}

- (UITableView *)DeviceLocationTable{
    if (!_DeviceLocationTable) {
        _DeviceLocationTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[DeviceLocationCell class] forCellReuseIdentifier:CellIdentifier_DeviceLocation];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _DeviceLocationTable;
}


#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _roomList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DeviceLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_DeviceLocation];
    if (cell == nil) {
        cell = [[DeviceLocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_DeviceLocation];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.tag = yUnselect;
    RoomModel *room = _roomList[indexPath.row];
    cell.leftLabel.text = room.name;
    cell.checkImage.image = [UIImage imageNamed:@"addFamily_uncheck"];
    if ([room.roomUid isEqualToString:self.device.roomUid]) {
        cell.tag = ySelect;
        cell.checkImage.image = [UIImage imageNamed:@"addFamily_check"];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *indexpathArr = [tableView indexPathsForVisibleRows];
    for (NSIndexPath *perIndexPath in indexpathArr) {
        DeviceLocationCell *cell = [tableView cellForRowAtIndexPath:perIndexPath];
        if (perIndexPath.row == indexPath.row) {
            if (cell.tag == yUnselect) {
                cell.tag = ySelect;
                cell.checkImage.image = [UIImage imageNamed:@"addFamily_check"];
                RoomModel *room = _roomList[indexPath.row];
                self.selectRoomUid = room.roomUid;
                
            }else{
                cell.tag = yUnselect;
                cell.checkImage.image = [UIImage imageNamed:@"addFamily_uncheck"];
            }
        }else{
            cell.tag = yUnselect;
            cell.checkImage.image = [UIImage imageNamed:@"addFamily_uncheck"];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return 44.f;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;//section头部高度
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - Action
- (void)completeAddFamily{
    
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSMutableArray *maclist = [[NSMutableArray alloc] init];
    NSDictionary *dic = @{@"mac":self.device.mac};
    [maclist addObject:dic];
    
    NSDictionary *parameters = @{@"roomUid":self.selectRoomUid,@"macList":maclist};

    NSString *url = [NSString stringWithFormat:@"%@/api/device/room",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:@"修改设备位置成功"];
            if (self.popBlock) {
                self.popBlock(self.selectRoomUid);
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NSObject showHudTipStr:LocalString(@"修改设置位置失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

@end
