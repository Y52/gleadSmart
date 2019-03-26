//
//  MainViewController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/12.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "MainViewController.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "MyHouseController.h"
#import "MineViewController.h"

@interface MainViewController () <RDVTabBarControllerDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MyHouseController *vc1 = [[MyHouseController alloc] init];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    
    UIViewController *vc2 = [[UIViewController alloc] init];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];

    MineViewController *vc3 = [[MineViewController alloc] init];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:vc3];

    self.viewControllers = @[nav1,nav3];
    
    [self customizeTabBarForController];
    
    self.selectedIndex = 0;
    self.delegate = self;
}

#pragma mark - customizeInterface
- (void)customizeTabBarForController{
    NSArray *tabBarItemTitle = @[@"我的家",@"我的"];
    NSArray *tabBarItemImages = @[@"img_tab_01_unselect",@"img_tab_03_unselect"];
    NSArray *tabBarItemSelectImages = @[@"img_tab_01_select",@"img_tab_03_select"];
    
    NSDictionary *tabBarTitleUnselectedDic = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"DADBDA"],NSFontAttributeName:[UIFont systemFontOfSize:11]};
    NSDictionary *tabBarTitleSelectedDic = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"FFFFFF"],NSFontAttributeName:[UIFont systemFontOfSize:11]};
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in self.tabBar.items) {
        item.tag = 1000 + index;
        UIImage *selectedImage = [UIImage imageNamed:[tabBarItemSelectImages objectAtIndex:index]];
        UIImage *unselectedImage = [UIImage imageNamed:[tabBarItemImages objectAtIndex:index]];
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:unselectedImage];
        
        item.selectedTitleAttributes = tabBarTitleSelectedDic;
        item.unselectedTitleAttributes = tabBarTitleUnselectedDic;
        [item setTitle:[tabBarItemTitle objectAtIndex:index]];
        index++;
    }
    
    [self.tabBar setHeight:tabbarHeight + ySafeArea_Bottom];
    self.tabBar.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0 + ySafeArea_Bottom / 2.f, 0);
    
    self.tabBar.translucent = YES;
    self.tabBar.backgroundView.backgroundColor = [UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1];
}

-  (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    return YES;
}

- (void)tabBarController:(RDVTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
}

@end
