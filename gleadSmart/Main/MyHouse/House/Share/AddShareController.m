//
//  AddShareController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/18.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "AddShareController.h"

static CGFloat const gleadHomeListHeight = 37.f;
static CGFloat const gleadHomeSetButtonWidth = 50.f;
static CGFloat const gleadMenuItemMargin = 25.f;

@interface AddShareController ()

@property (nonatomic, strong) NSArray *homeList;
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
    
}

#pragma mark - WMPage Datasource & Delegate
//- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
//    return self.homeList.count + 1;
//}
//
//- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
//    HomeDeviceController *vc = [[HomeDeviceController alloc] init];
//    vc.filledSpcingHeight = yAutoFit(gleadHeaderHeight) + tabbarHeight + ySafeArea_Bottom;
//    if (index == 0) {
//        vc.room = nil;
//        return vc;
//    }
//    RoomModel *room = self.homeList[index-1];
//    vc.room = room;
//    return vc;
//}
//
//- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
//    if (index == 0) {
//        return LocalString(@"所有设备");
//    }
//    RoomModel *room = self.homeList[index-1];
//    return room.name;
//}
//
//- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
//    return CGRectMake(0, yAutoFit(gleadHeaderHeight) - gleadHomeListHeight - 5, self.view.frame.size.width - gleadHomeSetButtonWidth, gleadHomeListHeight);
//}
//
//- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
//    CGFloat fillingSpaceHeight = yAutoFit(gleadHeaderHeight) + tabbarHeight + ySafeArea_Bottom;
//    return CGRectMake(0, yAutoFit(gleadHeaderHeight), self.view.frame.size.width, self.view.bounds.size.height - fillingSpaceHeight);
//}

@end
