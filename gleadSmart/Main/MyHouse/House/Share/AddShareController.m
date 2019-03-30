//
//  AddShareController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/18.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "AddShareController.h"
#import "HomeDeviceSelectController.h"
#import "SharerInputController.h"
#import "HouseShareController.h"

static CGFloat const gleadHomeListHeight = 37.f;
static CGFloat const gleadMenuItemMargin = 25.f;

@interface AddShareController ()

@property (nonatomic, strong) NSMutableArray *homeList;
@property (nonatomic, strong) NSMutableArray *deviceList;
@property (nonatomic, strong) UIButton *shareButton;

@end

@implementation AddShareController{
    int selectCount;
}

- (instancetype)init{
    if (self = [super init]) {
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.automaticallyCalculatesItemWidths = YES;
        self.titleColorSelected = [UIColor colorWithHexString:@"2879FF"];
        self.titleColorNormal = [UIColor blackColor];
        self.itemMargin = gleadMenuItemMargin;
        self.pageAnimatable = YES;
        self.scrollEnable = YES;
        
        selectCount = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavItem];

    [self getHouseHomeListAndDevice];
}

- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加共享");

    _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareButton.frame = CGRectMake(0, 0, 100, 30);
    [_shareButton setTitle:@"共享" forState:UIControlStateNormal];
    [_shareButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [_shareButton setTitleColor:[UIColor colorWithHexString:@"639DF8"] forState:UIControlStateNormal];
    _shareButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    _shareButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [_shareButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [_shareButton addTarget:self action:@selector(shareSelectedDevice) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:_shareButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}


#pragma mark - private methods
//获取房间列表和所有设备
- (void)getHouseHomeListAndDevice{
    Database *db = [Database shareInstance];
    [db getHouseHomeListAndDevice:self.house success:^{
        [self getHouseHomeListAndDeviceWithDatabase];
        [self reloadData];//wmpagecontroller更新滑动列表
    } failure:^{
        [self getHouseHomeListAndDeviceWithDatabase];
    }];
}

/*
 *从本地获取设备信息和房间信息
 */
- (void)getHouseHomeListAndDeviceWithDatabase{
    Database *db = [Database shareInstance];
    
    if (!self.homeList) {
        self.homeList = [[NSMutableArray alloc] init];
    }
    [self.homeList removeAllObjects];
    self.homeList = [db queryRoomsWith:self.house.houseUid];
    
    self.deviceList = [db queryAllDevice:self.house.houseUid];
    for (DeviceModel *device in self.deviceList) {
        if ([device.type intValue] == 0) {
            //移除中央控制器
            [self.deviceList removeObject:device];
            break;
        }
    }
    
    if (self.isSharedDiviceMacList.count <= 0) {
        return;
    }
    for (DeviceModel *device in self.deviceList) {
        for (NSString *mac in self.isSharedDiviceMacList) {
            if ([device.mac isEqualToString:mac]) {
                device.isShared = YES;
            }
        }
    }
}

- (void)shareSelectedDevice{
    BOOL isSelect = NO;
    for (DeviceModel *device in self.deviceList) {
        if (device.tag == ySelect && !device.isShared) {
            isSelect = YES;
        }
    }
    if (!isSelect) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"请选择设备再分享") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if (self.sharer != nil) {
        //如果是从分享者界面进入的不需要输入手机号码，直接添加
        [self addSharer];
        return;
    }
    
    SharerInputController *vc = [[SharerInputController alloc] init];
    vc.deviceList = [[NSMutableArray alloc] init];
    for (DeviceModel *device in self.deviceList) {
        if (device.tag == ySelect) {
            [vc.deviceList addObject:device];
        }
    }
    vc.houseUid = self.house.houseUid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addSharer{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/share",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSMutableArray *deviceDicArr = [[NSMutableArray alloc] init];
    for (DeviceModel *device in self.deviceList) {
        if (device.tag == ySelect && !device.isShared) {
            NSDictionary *dic = @{@"mac":device.mac,@"type":device.type};
            [deviceDicArr addObject:dic];
        }
    }
    NSDictionary *parameters = @{@"houseUid":self.house.houseUid,@"mobile":self.sharer.mobile,@"ownerUid":db.user.userId,@"deviceList":deviceDicArr};
    NSLog(@"%@",parameters);
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[HouseShareController class]]) {
                    [self.navigationController popToViewController:vc animated:YES];
                }
            }
        }else{
            [NSObject showHudTipStr:@"添加共享失败"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"添加共享失败"];
        });
    }];
}

#pragma mark - WMPage Datasource & Delegate
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.homeList.count + 1;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    HomeDeviceSelectController *vc = [[HomeDeviceSelectController alloc] init];
    vc.house = self.house;
    vc.deviceList = [[NSMutableArray alloc] init];
    
    vc.selectBlock = ^(NSString *mac) {
        for (DeviceModel *device in self.deviceList) {
            if ([device.mac isEqualToString:mac]) {
                if (device.tag == ySelect) {
                    device.tag = yUnselect;
                    self->selectCount--;
                }else{
                    device.tag = ySelect;
                    self->selectCount++;
                }
                break;
            }
        }
        if (self->selectCount > 0) {
            [self.shareButton setTitle:[NSString stringWithFormat:@"%@(%d)",LocalString(@"共享"),self->selectCount] forState:UIControlStateNormal];
        }else{
            [self.shareButton setTitle:@"共享" forState:UIControlStateNormal];
        }
    };
    
    if (index == 0) {
        [vc.deviceList addObjectsFromArray:self.deviceList];//所有设备,添加的device对象使用同一块内存
        return vc;
    }
    RoomModel *room = self.homeList[index-1];
    for (DeviceModel *device in self.deviceList) {
        if ([device.roomUid isEqualToString:room.roomUid]) {
            [vc.deviceList addObject:device];
        }
    }
    
    return vc;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    if (index == 0) {
        return LocalString(@"所有设备");
    }
    RoomModel *room = self.homeList[index-1];
    return room.name;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0, self.view.frame.size.width, gleadHomeListHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    return CGRectMake(0, gleadHomeListHeight, self.view.frame.size.width, self.view.bounds.size.height - getRectNavAndStatusHight - gleadHomeListHeight);
}

@end
