//
//  AddShareController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/18.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "AddShareController.h"
#import "HomeDeviceSelectController.h"

static CGFloat const gleadHomeListHeight = 37.f;
static CGFloat const gleadMenuItemMargin = 25.f;

@interface AddShareController ()

@property (nonatomic, strong) NSMutableArray *homeList;
@property (nonatomic, strong) NSMutableArray *deviceList;

@end

@implementation AddShareController

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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = LocalString(@"添加共享");

    [self getHouseHomeListAndDevice];
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
}


#pragma mark - WMPage Datasource & Delegate
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.homeList.count + 1;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    HomeDeviceSelectController *vc = [[HomeDeviceSelectController alloc] init];
    vc.house = self.house;
    vc.deviceList = [[NSMutableArray alloc] init];
    if (index == 0) {
        [vc.deviceList addObjectsFromArray:self.deviceList];
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
