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
}

- (void)shareSelectedDevice{
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
