//
//  SharerDetailController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/21.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "SharerDetailController.h"
#import "HouseSetCommonCell.h"
#import "ShareDeviceSelectCell.h"

NSString *const CellIdentifier_SharerDetailInfo = @"CellID_SharerDetailInfo";
NSString *const CellIdentifier_SharerDetailDevice = @"CellID_SharerDetailDevice";

@interface SharerDetailController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *sharerDetailTable;
@property (nonatomic, strong) NSMutableArray *deviceList;

@end

@implementation SharerDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];

    self.sharerDetailTable = [self sharerDetailTable];
    [self getSharerInfo];
}

#pragma mark - private methods
- (void)getSharerInfo{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://gleadsmart.thingcom.cn/api/share/sharer?sharerUid=%@",self.sharer.sharerUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    NSLog(@"%@",url);
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"ownerUid"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            if ([[responseDic objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = [responseDic objectForKey:@"data"];
                self.sharer.name = [dic objectForKey:@"name"];
                self.sharer.mobile = [dic objectForKey:@"mobile"];
                
                if ([[dic objectForKey:@"deviceList"] isKindOfClass:[NSArray class]] && [[dic objectForKey:@"deviceList"] count] > 0) {
                    if (!self.deviceList) {
                        self.deviceList = [[NSMutableArray alloc] init];
                    }
                    [self.deviceList removeAllObjects];
                    [[dic objectForKey:@"deviceList"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![obj isKindOfClass:[NSNull class]]) {
                            DeviceModel *device = [[DeviceModel alloc] init];
                            device.name = [obj objectForKey:@"name"];
                            device.mac = [obj objectForKey:@"mac"];
                            device.roomName = [obj objectForKey:@"roomName"];
                            device.type = [NSNumber numberWithInteger:[[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]]];
                            [self.deviceList addObject:device];
                        }
                    }];
                    [self.sharerDetailTable reloadData];
                }

            }
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        
        NSLog(@"error--%@",serializedData);
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"获取分享者详细信息失败"];
        });
    }];
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 2;
    }
    if (section == 1) {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            HouseSetCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_SharerDetailInfo];
            if (cell == nil) {
                cell = [[HouseSetCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_SharerDetailInfo];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.leftLabel.text = LocalString(@"共享给");
                cell.rightLabel.text = self.sharer.mobile;
            }
            if (indexPath.row == 1) {
                cell.leftLabel.text = LocalString(@"备注");
                cell.rightLabel.text = self.sharer.name;
            }
            return cell;
        }
            break;
            
        case 1:
        {
            ShareDeviceSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_SharerDetailDevice];
            if (cell == nil) {
                cell = [[ShareDeviceSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_SharerDetailDevice];
            }
            DeviceModel *device = self.deviceList[indexPath.row];
            cell.deviceName.text = device.name;
            cell.status.text = device.roomName;
            
            switch ([device.type integerValue]) {
                case 1:
                {
                    cell.deviceImage.image = [UIImage imageNamed:@"img_thermostat_on"];
                }
                    break;
                    
                case 2:
                {
                    cell.deviceImage.image = [UIImage imageNamed:@"img_valve_on"];
                }
                    break;
                    
                case 3:
                {
                    cell.deviceImage.image = [UIImage imageNamed:@"img_wallHob"];
                }
                    break;
                    
                default:
                    break;
            }
            return cell;
        }
            break;
            
        default:{
            HouseSetCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_SharerDetailInfo];
            if (cell == nil) {
                cell = [[HouseSetCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_SharerDetailInfo];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.leftLabel.text = LocalString(@"共享给");
                cell.rightLabel.text = self.sharer.mobile;
            }
            if (indexPath.row == 1) {
                cell.leftLabel.text = LocalString(@"备注");
                cell.rightLabel.text = self.sharer.name;
            }
            return cell;
        }
        break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 40.f;
            break;
            
        case 1:
            return 55.f;
            break;
            
        default:
            return 0.f;
            break;
    }
    return 0.f;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0.f;
            break;
            
        case 1:
            return 40.f;
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
    
    if (section == 1) {
        UILabel *label = [[UILabel alloc] init];
        label.text = LocalString(@"共享给他的设备");
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
- (UITableView *)sharerDetailTable{
    if (!_sharerDetailTable) {
        _sharerDetailTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 100) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[HouseSetCommonCell class] forCellReuseIdentifier:CellIdentifier_SharerDetailInfo];
            [tableView registerClass:[ShareDeviceSelectCell class] forCellReuseIdentifier:CellIdentifier_SharerDetailDevice];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _sharerDetailTable;
}


@end
