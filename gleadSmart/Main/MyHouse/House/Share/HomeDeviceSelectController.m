//
//  HomeDeviceSelectController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/19.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "HomeDeviceSelectController.h"
#import "ShareDeviceSelectCell.h"
#import <CoreLocation/CoreLocation.h>

NSString *const CellIdentifier_HomeDeviceSelect = @"CellID_HomeDeviceSelect";
CGFloat const Cell_Height = 50.f;

@interface HomeDeviceSelectController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *deviceTable;

@end

@implementation HomeDeviceSelectController
- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    self.deviceTable = [self deviceTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.deviceTable) {
        [self.deviceTable reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - privite methods
/**
 根据经纬度获取地理位置详细信息
 @param lon 地理经度
 @param lat 地理纬度
 **/
- (void)deviceLocation:(NSNumber *)lon lat:(NSNumber *)lat success:(void(^)(NSString *locality))success failure:(void(^)(void))failure{
    //反地理编码
    CLGeocoder *geocodel = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
    [geocodel reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = placemarks[0];
            NSString *locality = [NSString stringWithFormat:@"%@",placeMark.locality];
            if (!location) {
                locality = @"";
            }
            if (success) {
                success(locality);
            }
        }else{
            if (failure) {
                failure();
            }
        }
    }];
}

#pragma mark - setters and getters
-(UITableView *)deviceTable{
    if (!_deviceTable) {
        _deviceTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[ShareDeviceSelectCell class] forCellReuseIdentifier:CellIdentifier_HomeDeviceSelect];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            
            tableView;
        });
    }
    return _deviceTable;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deviceList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShareDeviceSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeDeviceSelect];
    if (cell == nil) {
        cell = [[ShareDeviceSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeDeviceSelect];
    }
    DeviceModel *device = self.deviceList[indexPath.row];
    cell.deviceName.text = device.name;
    RoomModel *room = [[Database shareInstance] queryRoomWith:device.roomUid];
    [self deviceLocation:self.house.lon lat:self.house.lat success:^(NSString *locality) {
        cell.status.text = locality;
        if (room.name) {
            cell.status.text = [cell.status.text stringByAppendingString:[NSString stringWithFormat:@" | %@",room.name]];
        }
    } failure:^{
        if (room.name) {
            cell.status.text = room.name;
        }
    }];
    
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
    if (device.tag == ySelect) {
        cell.selectImage.image = [UIImage imageNamed:@"addFamily_check"];
    }else{
        cell.selectImage.image = [UIImage imageNamed:@"addFamily_uncheck"];
    }
    if (device.isShared) {
        cell.selectImage.image = [UIImage imageNamed:@"img_addShareCheck_notable"];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ShareDeviceSelectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    DeviceModel *device = self.deviceList[indexPath.row];
    if (device.isShared) {
        return;//已经分享过
    }
    if (device.tag == ySelect) {
        cell.selectImage.image = [UIImage imageNamed:@"addFamily_uncheck"];
    }else{
        cell.selectImage.image = [UIImage imageNamed:@"addFamily_check"];
    }
    if (self.selectBlock) {
        self.selectBlock(device.mac);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

@end
