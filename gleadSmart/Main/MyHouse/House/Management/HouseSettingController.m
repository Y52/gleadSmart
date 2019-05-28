//
//  HouseSettingController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HouseSettingController.h"
#import "HouseSetCommonCell.h"
#import "HouseSetMemberCell.h"
#import "YTFAlertController.h"
#import "FamilyLocationController.h"
#import <CoreLocation/CoreLocation.h>
#import "AddHouseMemberCell.h"
#import "AddMemberController.h"
#import "FamilyMemberController.h"
#import "HouseShareController.h"
#import "HomeManagementController.h"

NSString *const CellIdentifier_HouseSetCommon = @"CellID_HouseSetCommon";
NSString *const CellIdentifier_HouseSetMember = @"CellID_HouseSetMember";
NSString *const CellIdentifier_HouseAddMember = @"CellID_HouseAddMember";

@interface HouseSettingController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *houseSettingTable;
@property (strong, nonatomic) UIButton *removeHouseButton;

@end

@implementation HouseSettingController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    self.navigationItem.title = LocalString(@"家庭设置");
    
    self.houseSettingTable = [self houseSettingTable];
    self.removeHouseButton = [self removeHouseButton];
    
    [self houseLocation:self.house.lon lat:self.house.lat];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

#pragma mark - private methods
/**
 从服务器获取家庭信息详情
 **/
- (void)updateHouseDetailInfoWith:(NSString *)houseUid{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/house?houseUid=%@",httpIpAddress,houseUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0 && [responseDic objectForKey:@"data"]) {
            NSDictionary *dic = [responseDic objectForKey:@"data"];
            HouseModel *house = [[HouseModel alloc] init];
            house.houseUid = houseUid;
            house.name = [dic objectForKey:@"name"];
            house.roomNumber = [dic objectForKey:@"roomNumber"];
            house.lon = [dic objectForKey:@"lon"];
            house.lat = [dic objectForKey:@"lat"];
            NSMutableArray *members = [[NSMutableArray alloc] init];
            if ([[dic objectForKey:@"members"] count] > 0) {
                [[dic objectForKey:@"members"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MemberModel *member = [[MemberModel alloc] init];
                    member.name = [obj objectForKey:@"name"];
                    member.mobile = [obj objectForKey:@"mobile"];
                    member.auth = [obj objectForKey:@"auth"];
                    if ([member.mobile isEqualToString:db.user.mobile]) {
                        house.auth = member.auth;//当前用户在该家庭的权限
                    }
                    [members addObject:member];
                }];
                house.members = [members copy];
            }
            self.house = house;
            [self.houseSettingTable reloadData];
        }else{
            [NSObject showHudTipStr:LocalString(@"获取家庭详细信息失败")];
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

//移除家庭
- (void)removeHouse{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
        
    };
    alert.rBlock = ^{
        [self removeHouseHttpDelMethod];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        [alert showView];
        alert.titleLabel.text = LocalString(@"警告");
        alert.messageLabel.text = LocalString(@"确定移除该家庭吗，所有信息都会被删除？");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void)removeHouseHttpDelMethod{
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
    
    NSString *url = [NSString stringWithFormat:@"%@/api/house?houseUid=%@",httpIpAddress,self.house.houseUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager DELETE:url parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            for (HouseModel *house in db.houseList) {
                if ([house.houseUid isEqualToString:self.house.houseUid]) {
                    [db.houseList removeObject:house];
                    break;
                }
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"移除家庭失败"];
        });
    }];
}


/**
 根据经纬度获取地理位置详细信息
 @param lon 地理经度
 @param lat 地理纬度
 **/
- (void)houseLocation:(NSNumber *)lon lat:(NSNumber *)lat{
    //反地理编码
    CLGeocoder *geocodel = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
    [geocodel reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = placemarks[0];
            if (placeMark.administrativeArea == NULL) {
                self.house.location = [NSString stringWithFormat:@"%@%@",placeMark.locality,placeMark.subLocality];
            }else{
                self.house.location = [NSString stringWithFormat:@"%@%@%@",placeMark.administrativeArea,placeMark.locality,placeMark.subLocality];
            }
            if (!self.house.location) {
                self.house.location = @"无法定位当前城市";
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.houseSettingTable reloadData];
            });
            
            /*看需求定义一个全局变量来接收赋值*/
            NSLog(@"----%@",placeMark.country);//当前国家
            NSLog(@"%@",self.house.location);//当前的城市
            //            NSLog(@"%@",placeMark.subLocality);//当前的位置
            //            NSLog(@"%@",placeMark.thoroughfare);//当前街道
            //            NSLog(@"%@",placeMark.name);//具体地址
            
        }
    }];
}

/**
 修改服务器家庭名称
 **/
- (void)houseSetting{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/house?houseUid=%@",httpIpAddress,self.house.houseUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"name":self.house.name,@"lon":self.house.lon,@"lat":self.house.lat};
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            for (int i = 0; i < [Database shareInstance].houseList.count; i++) {
                HouseModel *house = [Database shareInstance].houseList[i];
                if ([self.house.houseUid isEqualToString:house.houseUid]) {
                    [[Database shareInstance].houseList replaceObjectAtIndex:i withObject:self.house];
                }
            }
        }else{
            [NSObject showHudTipStr:@"修改家庭信息失败"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [self.houseSettingTable reloadData];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"修改家庭信息失败"];
        });
    }];
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSLog(@"11111%@",self.house.auth);
    if ([self.house.auth intValue] == 0) {
        return 4;//管理员有添加成员的section
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 3;
    }
    if (section == 1) {
        return 1;
    }
    if (section == 2) {
        return self.house.members.count;
    }
    if (section == 3) {
        return 1;//添加成员
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            HouseSetCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseSetCommon];
            if (cell == nil) {
                cell = [[HouseSetCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseSetCommon];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.leftLabel.text = LocalString(@"家庭名称");
                cell.rightLabel.text = _house.name;
            }
            if (indexPath.row == 1) {
                cell.leftLabel.text = LocalString(@"房间管理");
                cell.rightLabel.text = [NSString stringWithFormat:@"%@%@",_house.roomNumber,LocalString(@"个房间")];
            }
            if (indexPath.row == 2) {
                cell.leftLabel.text = LocalString(@"家庭位置");
                cell.rightLabel.text = self.house.location;
            }
            
            return cell;
        }
            break;
            
        case 1:
        {
            HouseSetCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseSetCommon];
            if (cell == nil) {
                cell = [[HouseSetCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseSetCommon];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.leftLabel.text = LocalString(@"设备共享");
            return cell;
        }
            break;
            
        case 2:
        {
            HouseSetMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseSetMember];
            if (cell == nil) {
                cell = [[HouseSetMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseSetMember];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            MemberModel *member = _house.members[indexPath.row];
            cell.memberImage.image = [UIImage imageNamed:@"img_account_header"];
            cell.memberName.text = member.name;
            cell.mobile.text = member.mobile;
            if ([member.auth intValue] == 0) {
                cell.identity.text = LocalString(@"管理员");
            }else{
                cell.identity.text = LocalString(@"成员");
            }
            return cell;
        }
            break;
            
        case 3:
        {
            AddHouseMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseAddMember];
            if (cell == nil) {
                cell = [[AddHouseMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseAddMember];
            }
            cell.addLabel.text = LocalString(@"添加成员");
            return cell;
        }
            break;
        default:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellindetify_houseSetdefaultcell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellindetify_houseSetdefaultcell"];
            }
            return cell;
        }
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Database *db = [Database shareInstance];
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                if ([self.house.auth integerValue]) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:LocalString(@"您没有该权限") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return;
                }
                YTFAlertController *alert = [[YTFAlertController alloc] init];
                alert.lBlock = ^{
                };
                alert.rBlock = ^(NSString * _Nullable text) {
                    self.house.name = text;
                    //使用Api更新
                    [self houseSetting];
                };
                alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                [self presentViewController:alert animated:NO completion:^{
                    alert.titleLabel.text = LocalString(@"更改家庭名称");
                    alert.textField.text = self.house.name;
                    [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
                    [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
                }];
            }else if (indexPath.row == 1){
                HomeManagementController *HomeManagementVC = [[HomeManagementController alloc] init];
                HomeManagementVC.homeList = [db queryRoomsWith:self.house.houseUid];
                HomeManagementVC.houseUid = self.house.houseUid;
                [self.navigationController pushViewController:HomeManagementVC animated:YES];
            }else if (indexPath.row == 2){
                if ([self.house.auth integerValue]) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:LocalString(@"您没有该权限") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return;
                }
                FamilyLocationController *locaVC = [[FamilyLocationController alloc] init];
                locaVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                locaVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                locaVC.contentOriginY = 100.f + getRectNavAndStatusHight;
                locaVC.dismissBlock = ^(HouseModel *house) {
                    if (house.lon && house.lat) {
                        self.house.lon = house.lon;
                        self.house.lat = house.lat;
                        [self houseSetting];
                        [self houseLocation:self.house.lon lat:self.house.lat];
                    }
                };
                [self presentViewController:locaVC animated:YES completion:nil];
            }
            break;
            
        case 1:{
            if ([self.house.auth intValue] == 0) {
                HouseShareController *shareVC = [[HouseShareController alloc] init];
                shareVC.house = self.house;
                [self.navigationController pushViewController:shareVC animated:YES];
            }else{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:LocalString(@"您没有该权限") preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
            break;
            
        case 2:{
            MemberModel *member = _house.members[indexPath.row];
            FamilyMemberController *memberVC = [[FamilyMemberController alloc] init];
            memberVC.member = member;
            memberVC.house = self.house;
            memberVC.popBlock = ^{
                [self updateHouseDetailInfoWith:self.house.houseUid];
            };
            [self.navigationController pushViewController:memberVC animated:YES];
        }
            break;
            
        case 3:{
            AddMemberController *addmemberVC = [[AddMemberController alloc] init];
            addmemberVC.houseUid = self.house.houseUid;
            addmemberVC.popBlock = ^{
                [self updateHouseDetailInfoWith:self.house.houseUid];
            };
            [self.navigationController pushViewController:addmemberVC animated:YES];
        }
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0.f;
            break;
            
        case 1:
            return 20.f;
            break;
            
        case 2:
            return 40.f;
            break;
            
        case 3:
            return 5.f;
            break;
            
        default:
            return 0.f;
            break;
    }
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    
    if (section == 2) {
        UILabel *label = [[UILabel alloc] init];
        label.text = LocalString(@"家庭成员");
        label.font = [UIFont fontWithName:@"Helvetica" size:17];
        label.textColor = [UIColor colorWithHexString:@"7C7C7B"];
        label.textAlignment = NSTextAlignmentLeft;
        [view addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(250.f), 20.f));
            make.left.equalTo(view.mas_left).offset(20.f);
            make.centerY.equalTo(view.mas_centerY);
        }];
    }
    
    return view ;
}
//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - Lazy load
- (UITableView *)houseSettingTable{
    if (!_houseSettingTable) {
        _houseSettingTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[HouseSetCommonCell class] forCellReuseIdentifier:CellIdentifier_HouseSetCommon];
            [tableView registerClass:[HouseSetMemberCell class] forCellReuseIdentifier:CellIdentifier_HouseSetMember];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [self tableFooterView];
            tableView;
        });
    }
    return _houseSettingTable;
}

- (UIView *)tableFooterView{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, ScreenWidth, 100.f);
    
    UIButton *removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeButton setTitle:LocalString(@"移除家庭") forState:UIControlStateNormal];
    [removeButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    [removeButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [removeButton setTitleColor:[UIColor colorWithHexString:@"3987F8"] forState:UIControlStateNormal];
    [removeButton.layer setBorderWidth:1.0];
    removeButton.layer.borderColor = [UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0].CGColor;
    removeButton.layer.cornerRadius = 20.f;
    [removeButton setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
    [removeButton addTarget:self action:@selector(removeHouse) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:removeButton];
    [removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), 40.f));
        make.centerY.equalTo(view.mas_centerY);
        make.centerX.equalTo(view.mas_centerX);
    }];
    
    return view;
}

- (UIButton *)removeHouseButton{
    if (!_removeHouseButton) {
        _removeHouseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_removeHouseButton setTitle:LocalString(@"移除家庭") forState:UIControlStateNormal];
        [_removeHouseButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_removeHouseButton setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_removeHouseButton.layer setBorderWidth:1.0];
        _removeHouseButton.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _removeHouseButton.layer.cornerRadius = 15.f;
        [_removeHouseButton setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_removeHouseButton addTarget:self action:@selector(removeHouse) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_removeHouseButton];
        
        [_removeHouseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(276.f), 44.f));
            make.bottom.equalTo(self.view.mas_bottom).offset(56.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _removeHouseButton;
}

@end
