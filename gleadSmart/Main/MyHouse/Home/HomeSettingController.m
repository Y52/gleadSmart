//
//  HomeDeviceSetController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/5/27.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "HomeSettingController.h"
#import "HomeNameSetCell.h"
#import "HomeDeviceSetCell.h"

NSString *const CellIdentifier_HomeSettingName = @"CellID_HomeSettingName";
NSString *const CellIdentifier_HomeDeviceSetName = @"CellID_HomeDeviceSetName";
static CGFloat const Cell_Height = 44.f;

@interface HomeSettingController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *homeSettingTable;
@property (nonatomic, strong) NSMutableArray *deviceList;
@property (nonatomic, strong) NSMutableArray *roomDeviceList;

@end

@implementation HomeSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"房间设置");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(editHomeDevice)];

    self.homeSettingTable = [self homeSettingTable];
    [self getDeviceList:self.houseUid];
}

- (void)viewDidDisappear:(BOOL)animated{
    editDeviceSucc = NO;
    editNameSucc = NO;
}

#pragma mark - private methods
- (void)getDeviceList:(NSString *)houseUid{
    self.deviceList = [[Database shareInstance] queryDevice:houseUid WithoutCenterlControlType:@(DeviceCenterlControl)];
    
    self.roomDeviceList = [[NSMutableArray alloc] init];
    [self.roomDeviceList removeAllObjects];
    
    for (int i = 0; i < self.deviceList.count; i++) {
        DeviceModel *device = self.deviceList[i];
        if ([device.roomUid isEqualToString:self.room.roomUid]) {
            [self.roomDeviceList addObject:device];
            [self.deviceList removeObject:device];
            i--;
        }
    }
    [self.homeSettingTable reloadData];
}

- (UIImage *)getImage:(DeviceType)type{
    switch (type) {
        case DeviceThermostat:
            return [UIImage imageNamed:@"img_thermostat_on"];
            break;
            
        case DeviceValve:
        case DeviceNTCValve:
        {
            return [UIImage imageNamed:@"img_valve_on"];
        }
            break;
            
        case DeviceWallhob:
        {
            return [UIImage imageNamed:@"img_wallHob"];
        }
            break;
            
        case DevicePlugOutlet:
        {
            return [UIImage imageNamed:@"img_thermostat_on"];
        }
            break;
            
        case DeviceFourSwitch:
        {
            return [UIImage imageNamed:@"img_thermostat_on"];
        }
            break;
            
        default:
            return [UIImage imageNamed:@"img_thermostat_on"];
            break;
        }
}

static BOOL editNameSucc = NO;
static BOOL editDeviceSucc = NO;
//点中右上角按键  进入编辑状态
-(void)editHomeDevice{
    [self editRoomNameByApi:^{
        editNameSucc = YES;
        if (editDeviceSucc && editNameSucc) {
            [NSObject showHudTipStr:LocalString(@"设置成功")];
            NSLog(@"设置成功");
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^{
        editNameSucc = NO;
    }];
    [self updateDeviceRoomByApi:^{
        editDeviceSucc = YES;
        if (editDeviceSucc && editNameSucc) {
            [NSObject showHudTipStr:LocalString(@"设置成功")];
            NSLog(@"设置成功");
            if (self.popBlock) {
                self.popBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^{
        editDeviceSucc = NO;
    }];
}

- (void)editRoomNameByApi:(void(^)(void))success failure:(void(^)(void))failure{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/room",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Database shareInstance].user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[Database shareInstance].token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"roomUid":self.room.roomUid,@"name":self.room.name};
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
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
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (failure) {
                failure();
            }
        });
    }];
}

- (void)updateDeviceRoomByApi:(void(^)(void))success failure:(void(^)(void))failure{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/device/room",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Database shareInstance].user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[Database shareInstance].token] forHTTPHeaderField:@"Authorization"];
    
    NSMutableArray *macList = [[NSMutableArray alloc] init];
    for (DeviceModel *device in self.roomDeviceList) {
        [macList addObject:@{@"mac":device.mac}];
    }
    NSDictionary *parameters;
    if (macList.count > 0) {
        parameters = @{@"roomUid":self.room.roomUid,@"macList":macList};
    }else{
        parameters = @{@"roomUid":self.room.roomUid};
    }
    NSLog(@"%@",parameters);

    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
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
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            if (failure) {
                failure();
            }
        });
    }];
}

#pragma mark - setters & getters
-(UITableView *)homeSettingTable{
    if (!_homeSettingTable) {
        _homeSettingTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeight - getRectNavAndStatusHight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
            [tableView registerClass:[HomeNameSetCell class] forCellReuseIdentifier:CellIdentifier_HomeSettingName];
            [tableView registerClass:[HomeDeviceSetCell class] forCellReuseIdentifier:CellIdentifier_HomeDeviceSetName];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = YES;
            tableView.tableFooterView = [[UIView alloc] init];
            
            [tableView setEditing:YES animated:YES];
            
            tableView;
        });
    }
    return _homeSettingTable;
}


#pragma mark - UITableView delegate&datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
            
        case 1:
            return self.roomDeviceList.count;
            break;
            
        case 2:
            return self.deviceList.count;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            HomeNameSetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeSettingName];
            if (cell == nil) {
                cell = [[HomeNameSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeSettingName];
            }
            cell.leftLabel.text = LocalString(@"房间");
            cell.nameTF.text = self.room.name;
            cell.TFBlock = ^(NSString *text) {
                self.room.name = text;
            };
            return cell;
        }
            break;
            
        case 1:
        {
            HomeDeviceSetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeDeviceSetName];
            if (cell == nil) {
                cell = [[HomeDeviceSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeDeviceSetName];
            }
            DeviceModel *device = self.roomDeviceList[indexPath.row];
            cell.deviceName.text = device.name;
            cell.deviceImage.image = [self getImage:[device.type integerValue]];
            return cell;
        }
            break;
            
        case 2:
        {
            HomeDeviceSetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeDeviceSetName];
            if (cell == nil) {
                cell = [[HomeDeviceSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeDeviceSetName];
            }
            DeviceModel *device = self.deviceList[indexPath.row];
            cell.deviceName.text = device.name;
            cell.deviceImage.image = [self getImage:[device.type integerValue]];
            return cell;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    headerView.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    switch (section) {
        case 0:
        case 1:
            break;
            
        case 2:
        {
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 20.f, 200.f, 20.f)];
            textLabel.textColor = [UIColor colorWithHexString:@"333333"];
            textLabel.text = LocalString(@"不在此房间的设备");
            textLabel.font = [UIFont systemFontOfSize:14.f];
            textLabel.textAlignment = NSTextAlignmentLeft;
            textLabel.backgroundColor = [UIColor clearColor];
            [headerView addSubview:textLabel];
        }
            break;
            
        default:
            break;
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 15.f;
    }else if(section == 1){
        return 20.f;
    }else{
        return 50.f;
    }
}


//可以编辑
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//每行编辑是什么样式
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return UITableViewCellEditingStyleNone;
            break;
            
        case 1:
            return UITableViewCellEditingStyleDelete;
            break;
            
        case 2:
            return UITableViewCellEditingStyleInsert;
            break;
            
        default:
            return UITableViewCellEditingStyleNone;
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return LocalString(@"移出");
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            break;
            
        case 1:
        {
            if (editingStyle == UITableViewCellEditingStyleDelete) {
                DeviceModel *device = self.roomDeviceList[indexPath.row];
                
                //修改数据源，在刷新 tableView
                [self.roomDeviceList removeObjectAtIndex:indexPath.row];
                [self.deviceList addObject:device];
                [tableView reloadData];
            }
        }
            break;
            
        case 2:
        {
            DeviceModel *device = self.deviceList[indexPath.row];
            
            //修改数据源，在刷新 tableView
            [self.deviceList removeObjectAtIndex:indexPath.row];
            [self.roomDeviceList addObject:device];
            [tableView reloadData];
        }
            break;
            
        default:
            break;
    }
    
}
//是否移动
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    //修改数据源
    //[_homeList exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
//    RoomModel *room = [_homeList objectAtIndex:sourceIndexPath.row];
//    [_homeList removeObjectAtIndex:sourceIndexPath.row];
//    [_homeList insertObject: room atIndex:destinationIndexPath.row];
//    //让表视图对应的行进行移动
//    [tableView exchangeSubviewAtIndex:sourceIndexPath.row withSubviewAtIndex:destinationIndexPath.row];
    
}


@end
