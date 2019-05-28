//
//  HomeManagementController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HomeManagementController.h"
#import "HomeManagementCell.h"
#import "AddRoomsViewController.h"
#import "HomeSettingController.h"

NSString *const CellIdentifier_HomeManagementTable = @"CellID_HomeManagementTable";
static CGFloat const Cell_Height = 50.f;

@interface HomeManagementController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *homeManagementTable;
@property (strong, nonatomic) UIButton *addRoomsBtn;

@end

@implementation HomeManagementController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"房间管理");
    self.homeManagementTable = [self homeManagementTable];
    self.addRoomsBtn = [self addRoomsBtn];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editTableView:)];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self getHomeList];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Lazy Load
-(UITableView *)homeManagementTable{
    if (!_homeManagementTable) {
        _homeManagementTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeight - getRectNavAndStatusHight - 120.f) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor whiteColor];
            [tableView registerClass:[HomeManagementCell class] forCellReuseIdentifier:CellIdentifier_HomeManagementTable];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = YES;
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _homeManagementTable;
}

- (UIButton *)addRoomsBtn{
    if (!_addRoomsBtn) {
        _addRoomsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addRoomsBtn setTitle:LocalString(@"添加房间") forState:UIControlStateNormal];
        [_addRoomsBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_addRoomsBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_addRoomsBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_addRoomsBtn.layer setBorderWidth:1.0];
        _addRoomsBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _addRoomsBtn.layer.cornerRadius = 20.f;
        [_addRoomsBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_addRoomsBtn addTarget:self action:@selector(goRooms) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_addRoomsBtn];
        [_addRoomsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), 40.f));
            make.bottom.equalTo(self.homeManagementTable.mas_bottom).offset(yAutoFit(60.f));
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _addRoomsBtn;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _homeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeManagementTable];
    if (cell == nil) {
        cell = [[HomeManagementCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeManagementTable];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    RoomModel *room = _homeList[indexPath.row];
    cell.leftLabel.text = room.name;
    if (room.deviceNumber) {
        cell.rightLabel.text = [NSString stringWithFormat:@"%@个设备",room.deviceNumber];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RoomModel *room = self.homeList[indexPath.row];
    HomeSettingController *homeSetVC = [[HomeSettingController alloc] init];
    homeSetVC.houseUid = self.houseUid;
    homeSetVC.room = room;
    homeSetVC.popBlock = ^{
        Database *data = [Database shareInstance];
        [data getHouseHomeListAndDevice:data.currentHouse success:^{
            [self getHomeList];
        } failure:^{
            
        }];
    };
    [self.navigationController pushViewController:homeSetVC animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

//可以编辑
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//每行编辑是什么样式
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    //返回 插入
    //  return UITableViewCellEditingStyleInsert;
    //返回 删除
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleNone:
        {
        }
            break;
        case UITableViewCellEditingStyleDelete:
        {
        
            RoomModel *room = _homeList[indexPath.row];
            [self deleteroomsByApi:room success:^{
                //修改数据源，在刷新 tableView
                [self.homeList removeObjectAtIndex:indexPath.row];
                
                //让表视图删除对应的行 //必须执行在移除数组后面
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [NSObject showHudTipStr:LocalString(@"删除成功")];
            } failure:^{
                
            }];

        }
            break;
        case UITableViewCellEditingStyleInsert:
        {
            [_homeList insertObject:@"新增行" atIndex:indexPath.row];
            //让表视图添加对应的行
            [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }
            break;
        default:
            break;
    }
}
//是否移动
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //修改数据源
    //[_homeList exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    RoomModel *room = [_homeList objectAtIndex:sourceIndexPath.row];
    [_homeList removeObjectAtIndex:sourceIndexPath.row];
    [_homeList insertObject: room atIndex:destinationIndexPath.row];
    //让表视图对应的行进行移动
    [tableView exchangeSubviewAtIndex:sourceIndexPath.row withSubviewAtIndex:destinationIndexPath.row];
 
}

#pragma mark - private methods
- (void)modifyEditedHomebyApi{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/room/list",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Database shareInstance].user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[Database shareInstance].token] forHTTPHeaderField:@"Authorization"];
    
    NSMutableArray *roomsDicArr = [[NSMutableArray alloc] init];
    for (RoomModel *roomname in self.homeList) {
        NSDictionary *dic = @{@"name":roomname.name,@"name":roomname.name};
        [roomsDicArr addObject:dic];
    }
    NSDictionary *parameters = @{@"rooms":roomsDicArr};
    
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [NSObject showHudTipStr:LocalString(@"修改房间失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

//删除房间列表的API
- (void)deleteroomsByApi:(RoomModel *)room success:(void(^)(void))success failure:(void(^)(void))failure{
    
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/room",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];//不加这句代码，delete方法会把字典以param形式加到url后面，而不是生成一个body，服务器会收不到信息
    
    NSDictionary *parameters = @{@"houseUid":_houseUid,@"roomUid":room.roomUid};
    
    [manager DELETE:url parameters: parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            //[NSObject showHudTipStr:@"删除房间成功"];
            [[Database shareInstance] deleteRoom:room.roomUid];
            [self.homeManagementTable reloadData];
            if (success) {
                success();
            }
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
            if (failure) {
                failure();
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NSObject showHudTipStr:LocalString(@"删除房间失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            NSLog(@"%@",error);
            if (failure) {
                failure();
            }
        });
    }];
}


//移动房间列表的API
- (void)MoveRoomsByApi{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/room/sort",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Database shareInstance].user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[Database shareInstance].token] forHTTPHeaderField:@"Authorization"];
    
    NSMutableArray *roomsDicArr = [[NSMutableArray alloc] init];
    for (RoomModel *room in self.homeList) {
        NSDictionary *dic = @{@"sortId":room.sortId,@"roomUid":room.roomUid};
        [roomsDicArr addObject:dic];
    }
    NSDictionary *parameters = @{@"roomSort":roomsDicArr};
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        [NSObject showHudTipStr:LocalString(@"移动房间失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}
#pragma mark - Actions
/*
 *更新房间列表
 */
- (void)getHomeList{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/room/list?houseUid=%@",httpIpAddress,self.houseUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            if ([responseDic objectForKey:@"data"] && [[responseDic objectForKey:@"data"] count] > 0) {
                if (!self.homeList) {
                    self.homeList = [[NSMutableArray alloc] init];
                }
                [self.homeList removeAllObjects];
                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (![obj isKindOfClass:[NSNull class]]) {
                        RoomModel *room = [[RoomModel alloc] init];
                        room.name = [obj objectForKey:@"name"];
                        room.roomUid = [obj objectForKey:@"roomUid"];
                        room.deviceNumber = [obj objectForKey:@"deviceNumber"];
                        room.sortId = [obj objectForKey:@"sortId"];
                        room.houseUid = self.houseUid;
                        [self.homeList addObject:room];
                        
                        [db insertNewRoom:room];
                    }
                
                }];
                [self.homeManagementTable reloadData];
            }
        }else{
            [NSObject showHudTipStr:LocalString(@"获取家庭房间列表失败")];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//
//        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
//
//        NSLog(@"error--%@",serializedData);
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"从服务器获取信息失败"];
        });
    }];
}

-(void)goRooms{
    AddRoomsViewController *AddRoomsVC = [[AddRoomsViewController alloc] init];
    AddRoomsVC.houseUid = self.houseUid;
    AddRoomsVC.sortId = [NSNumber numberWithInteger:self.homeList.count];
    [self.navigationController pushViewController:AddRoomsVC animated:YES];
}

//点中右上角按键  进入编辑状态
-(void)editTableView:(UIBarButtonItem *)sender {
    [self.homeManagementTable setEditing:!self.homeManagementTable.editing animated:YES];
    //   isEditing editing的getter方法的 新名字
    if ([sender.title isEqualToString:@"完成"]) {
        [self.homeManagementTable reloadData];
        for (int i = 0; i < self.homeList.count ; i++) {
            RoomModel *room = self.homeList[i];
            room.sortId = [NSNumber numberWithInteger: i];
            
        }
        [self MoveRoomsByApi];
    }
    sender.title = self.homeManagementTable.isEditing ? @"完成" : @"编辑";
  
}

@end
