//
//  ShareDeviceDetailController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/27.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "ShareDeviceDetailController.h"
#import "ShareDeviceDetailCell.h"

NSString *const CellIdentifier_ShareDeviceDetail = @"Cell_ShareDeviceDetail";
static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 40.f;

@interface ShareDeviceDetailController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *deviceDetailTable;

@end

@implementation ShareDeviceDetailController{
    NSString *houseName;
    NSMutableArray *deviceList;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor;
    self.navigationItem.title = LocalString(@"共享详情");
    self.deviceDetailTable = [self deviceDetailTable];
    [self getHouseSharerInfo];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

#pragma mark - private methods
- (void)getHouseSharerInfo{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/share/ownerList/deviceList",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"houseUid":self.houseUid,@"ownerName":self.ownerName};
    
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSDictionary *data = [responseDic objectForKey:@"data"];
            self->houseName = [data objectForKey:@"name"];
            self.houseUid = [data objectForKey:@"houseUid"];
            if ([[data objectForKey:@"deviceList"] isKindOfClass:[NSArray class]] && [[data objectForKey:@"deviceList"] count] > 0) {
                if (!self->deviceList) {
                    self->deviceList = [[NSMutableArray alloc] init];
                }
                [self->deviceList removeAllObjects];
                
                [[data objectForKey:@"deviceList"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    DeviceModel *device = [[DeviceModel alloc] init];
                    device.name = [obj objectForKey:@"name"];
                    device.mac = [obj objectForKey:@"mac"];
                    [self->deviceList addObject:device];
                }];
            }
            [self.deviceDetailTable reloadData];
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"获取拥有者详细信息失败"];
        });
    }];
}

- (void)removeSharerDevicceHttpDelMethod:(NSString *)mac success:(void(^)(void))success failure:(void(^)(void))failure{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];//不加这句代码，delete方法会把字典以param形式加到url后面，而不是生成一个body，服务器会收不到信息
    
    NSDictionary *parameters = @{@"houseUid":self.houseUid,@"mac":mac};
    
    NSString *url = [NSString stringWithFormat:@"%@/api/share/house/device",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager DELETE:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            if (success) {
                success();
            }
        }else{
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            if (failure) {
                failure();
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        if (failure) {
            failure();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"移除设备失败"];
        });
    }];
}
#pragma mark - setters and getters
- (UITableView *)deviceDetailTable{
    if (!_deviceDetailTable) {
        _deviceDetailTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 100.f) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[ShareDeviceDetailCell class] forCellReuseIdentifier:CellIdentifier_ShareDeviceDetail];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _deviceDetailTable;
}

#pragma mark - uitableview delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 2;
    }
    if (section == 1) {
        return deviceList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShareDeviceDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ShareDeviceDetail];
    cell.backgroundColor = [UIColor whiteColor];
    if (cell == nil) {
        cell = [[ShareDeviceDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ShareDeviceDetail];
    }
    if (indexPath.section == 0){
        if (indexPath.row == 0) {
            cell.leftLabel.text = LocalString(@"共享来自");
            cell.rightLabel.text = houseName;
            return cell;
        }else{
            cell.leftLabel.text = LocalString(@"备注");
            cell.rightLabel.text = self.ownerName;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }else if (indexPath.section == 1){
        DeviceModel *device = deviceList[indexPath.row];
        cell.deviceLabel.text = device.name;
        
        NSInteger type = [[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]];
        switch (type) {
            case DeviceThermostat:
            {
                cell.leftImage.image = [UIImage imageNamed:@"img_thermostat_on"];
            }
                break;
                
            case DeviceValve:
            {
                cell.leftImage.image = [UIImage imageNamed:@"img_valve_on"];
            }
                break;
                
            case DeviceWallhob:
            {
                cell.leftImage.image = [UIImage imageNamed:@"img_wallHob"];
            }
                break;
                
            default:
                break;
        }
        return cell;
    }else{
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
    headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
    textLabel.textColor = [UIColor colorWithHexString:@"999999"];
    textLabel.font = [UIFont systemFontOfSize:13.f];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textLabel];
    if (section == 1) {
        textLabel.text = LocalString(@"您收到的共享");
        
        [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 13));
            make.centerY.equalTo(headerView.mas_centerY);
            make.left.equalTo(headerView.mas_left).offset(20);
        }];
    }
    

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }else{
        return HEIGHT_HEADER;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DeviceModel *device = self->deviceList[indexPath.row];
        [self removeSharerDevicceHttpDelMethod:device.mac success:^{
            [self->deviceList removeObject:device];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [NSObject showHudTipStr:LocalString(@"删除成功")];
        } failure:^{
            
        }];
    }
}

@end
