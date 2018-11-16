//
//  MyHouseController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/13.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "MyHouseController.h"
#import "HomeDeviceController.h"
#import "HouseSelectController.h"

static CGFloat const gleadHeaderHeight = 225.f;
static CGFloat const gleadWeatherViewWidth = 335.f;
static CGFloat const gleadHomeListHeight = 37.f;
static CGFloat const gleadHomeSetButtonWidth = 50.f;
static CGFloat const gleadMenuItemMargin = 25.f;

@interface MyHouseController ()

@property (strong, nonatomic) UIView *headerView;

@property (strong, nonatomic) NSMutableArray *houseList;
@property (strong, nonatomic) UIButton *houseButton;

@property (strong, nonatomic) UIButton *addDeviceButton;

@property (strong, nonatomic) UIView *weatherView;
@property (strong, nonatomic) UILabel *tempValueLabel;
@property (strong, nonatomic) UILabel *pmValueLabel;
@property (strong, nonatomic) UILabel *airValueLabel;

@property (strong, nonatomic) NSMutableArray *homeList;
@property (strong, nonatomic) UIButton *homeSetButton;

@end

@implementation MyHouseController{
    int selectHouse;
}

- (instancetype)init{
    if (self = [super init]) {
        //self.homeList = [[NSMutableArray alloc] init];
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.automaticallyCalculatesItemWidths = YES;
        self.titleColorSelected = [UIColor whiteColor];
        self.titleColorNormal = [UIColor whiteColor];
        self.itemMargin = gleadMenuItemMargin;
        self.pageAnimatable = YES;
        
        selectHouse = 2;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    //挡住了最上面的几个按钮的点击
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    
    self.headerView = [self headerView];
    self.houseList = [self houseList];
    self.houseButton = [self houseButton];
    self.weatherView = [self weatherView];
    self.tempValueLabel = [self tempValueLabel];
    self.pmValueLabel = [self pmValueLabel];
    self.airValueLabel = [self airValueLabel];
    self.homeList = [self homeList];
    self.homeSetButton = [self homeSetButton];
    self.addDeviceButton = [self addDeviceButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}
#pragma mark - Lazy load
-(UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor clearColor];
        [self.view insertSubview:_headerView atIndex:0];
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideTop);
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, yAutoFit(gleadHeaderHeight)));
            make.centerX.equalTo(self.view.mas_centerX);
        }];

        UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_headerBg"]];
        [_headerView insertSubview:bgImageView atIndex:0];
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(0);
        }];
    }
    return _headerView;
}

- (NSMutableArray *)houseList{
    if (!_houseList) {
        NSArray *homeList = @[@"公寓",@"公司",@"86-155****3550",@"我的家庭"];
        _houseList = [homeList mutableCopy];
    }
    return _houseList;
}

- (UIButton *)houseButton{
    if (!_houseButton) {
        _houseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_houseButton setTitle:self.houseList[selectHouse] forState:UIControlStateNormal];
        _houseButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        _houseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_houseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_houseButton setImage:[UIImage imageNamed:@"img_houseSelect"] forState:UIControlStateNormal];
        [_houseButton addTarget:self action:@selector(houseSelect) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:_houseButton];
        
        CGSize size = [self.houseList[selectHouse] sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica" size:15],NSFontAttributeName,nil]];
        CGFloat y = gleadHeaderHeight - 24.f - yAutoFit(13.f) * 2 - yAutoFit(100.f) - gleadHomeListHeight;
        [_houseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(yAutoFit(27.f));
            make.top.equalTo(self.view.mas_top).offset(y);
            make.size.mas_equalTo(CGSizeMake(yAutoFit(size.width + 24.f), yAutoFit(24.f)));
        }];
        
        [_houseButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -_houseButton.imageView.bounds.size.width, 0, _houseButton.imageView.bounds.size.width)];
        [_houseButton setImageEdgeInsets:UIEdgeInsetsMake(0, _houseButton.titleLabel.bounds.size.width, 0, -_houseButton.titleLabel.bounds.size.width)];

    }
    return _houseButton;
}

- (UIButton *)addDeviceButton{
    if (!_addDeviceButton) {
        _addDeviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addDeviceButton setImage:[UIImage imageNamed:@"img_addDevice"] forState:UIControlStateNormal];
        [_addDeviceButton addTarget:self action:@selector(addDevice) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:_addDeviceButton];
        [_addDeviceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(20.f), yAutoFit(20.f)));
            make.right.equalTo(self.weatherView.mas_right).offset(-5);
            make.centerY.equalTo(self.houseButton.mas_centerY);
        }];
    }
    return _addDeviceButton;
}

- (UIView *)weatherView{
    if (!_weatherView) {
        _weatherView = [[UIView alloc] init];
        [self.headerView addSubview:_weatherView];
        [_weatherView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.houseButton.mas_bottom).mas_equalTo(yAutoFit(13.f));
            make.size.mas_equalTo(CGSizeMake(yAutoFit(gleadWeatherViewWidth), yAutoFit(100.f)));
            make.centerX.equalTo(self.headerView.mas_centerX);
        }];
        
        UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_weatherBg"]];
        [_weatherView insertSubview:bgImage atIndex:0];
        [bgImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(0.f);
        }];
    }
    return _weatherView;
}

- (UILabel *)tempValueLabel{
    if (!_tempValueLabel) {
        _tempValueLabel = [[UILabel alloc] init];
        _tempValueLabel.textAlignment = NSTextAlignmentCenter;
        _tempValueLabel.textColor = [UIColor whiteColor];
        _tempValueLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        _tempValueLabel.text = @"22℃";
        [self.weatherView addSubview:_tempValueLabel];
        [_tempValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0.f);
            make.top.equalTo(self.weatherView.mas_top).offset(yAutoFit(56.f));
            make.size.mas_equalTo(CGSizeMake(yAutoFit(gleadWeatherViewWidth) / 3.0, yAutoFit(17.f)));
        }];
        
        UILabel *tempTextLabel = [[UILabel alloc] init];
        tempTextLabel.text = LocalString(@"室外温度");
        tempTextLabel.textAlignment = NSTextAlignmentCenter;
        tempTextLabel.textColor = [UIColor whiteColor];
        tempTextLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        [self.weatherView addSubview:tempTextLabel];
        [tempTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0.f);
            make.top.equalTo(self.weatherView.mas_top).offset(yAutoFit(31.f));
            make.size.mas_equalTo(CGSizeMake(yAutoFit(gleadWeatherViewWidth) / 3.0, yAutoFit(17.f)));
        }];
        
        UIView *dividingLine = [[UIView alloc] init];
        dividingLine.backgroundColor = [UIColor whiteColor];
        [self.weatherView addSubview:dividingLine];
        [dividingLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(1.f,yAutoFit(36.f)));
            make.centerY.equalTo(self.weatherView.mas_centerY);
            make.centerX.equalTo(self.weatherView.mas_left).offset(yAutoFit(gleadWeatherViewWidth) / 3.0);
        }];
    }
    return _tempValueLabel;
}

- (UILabel *)pmValueLabel{
    if (!_pmValueLabel) {
        _pmValueLabel = [[UILabel alloc] init];
        _pmValueLabel.textAlignment = NSTextAlignmentCenter;
        _pmValueLabel.textColor = [UIColor whiteColor];
        _pmValueLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        _pmValueLabel.text = @"良";
        [self.weatherView addSubview:_pmValueLabel];
        [_pmValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(yAutoFit(gleadWeatherViewWidth) / 3.0);
            make.top.equalTo(self.weatherView.mas_top).offset(yAutoFit(56.f));
            make.size.mas_equalTo(CGSizeMake(yAutoFit(gleadWeatherViewWidth) / 3.0, yAutoFit(17.f)));
        }];
        
        UILabel *pmTextLabel = [[UILabel alloc] init];
        pmTextLabel.text = LocalString(@"PM2.5");
        pmTextLabel.textAlignment = NSTextAlignmentCenter;
        pmTextLabel.textColor = [UIColor whiteColor];
        pmTextLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        [self.weatherView addSubview:pmTextLabel];
        [pmTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(yAutoFit(gleadWeatherViewWidth) / 3.0);
            make.top.equalTo(self.weatherView.mas_top).offset(yAutoFit(31.f));
            make.size.mas_equalTo(CGSizeMake(yAutoFit(gleadWeatherViewWidth) / 3.0, yAutoFit(17.f)));
        }];
        
        UIView *dividingLine = [[UIView alloc] init];
        dividingLine.backgroundColor = [UIColor whiteColor];
        [self.weatherView addSubview:dividingLine];
        [dividingLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(1.f,yAutoFit(36.f)));
            make.centerY.equalTo(self.weatherView.mas_centerY);
            make.centerX.equalTo(self.weatherView.mas_left).offset(yAutoFit(gleadWeatherViewWidth) / 3.0 * 2.0);
        }];
    }
    return _pmValueLabel;
}

- (UILabel *)airValueLabel{
    if (!_airValueLabel) {
        _airValueLabel = [[UILabel alloc] init];
        _airValueLabel.textAlignment = NSTextAlignmentCenter;
        _airValueLabel.textColor = [UIColor whiteColor];
        _airValueLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        _airValueLabel.text = @"良";
        [self.weatherView addSubview:_airValueLabel];
        [_airValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(yAutoFit(gleadWeatherViewWidth) / 3.0 * 2.0);
            make.top.equalTo(self.weatherView.mas_top).offset(yAutoFit(56.f));
            make.size.mas_equalTo(CGSizeMake(yAutoFit(gleadWeatherViewWidth) / 3.0, yAutoFit(17.f)));
        }];
        
        UILabel *airTextLabel = [[UILabel alloc] init];
        airTextLabel.text = LocalString(@"空气质量");
        airTextLabel.textAlignment = NSTextAlignmentCenter;
        airTextLabel.textColor = [UIColor whiteColor];
        airTextLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        [self.weatherView addSubview:airTextLabel];
        [airTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(yAutoFit(gleadWeatherViewWidth) / 3.0 * 2.0);
            make.top.equalTo(self.weatherView.mas_top).offset(yAutoFit(31.f));
            make.size.mas_equalTo(CGSizeMake(yAutoFit(gleadWeatherViewWidth) / 3.0, yAutoFit(17.f)));
        }];
    }
    return _airValueLabel;
}

- (NSMutableArray *)homeList{
    if (!_homeList) {
        NSArray *homeList = @[@"所有房间",@"主卧",@"次卧"];
        _homeList = [homeList mutableCopy];
    }
    return _homeList;
}

-(UIButton *)homeSetButton{
    if (!_homeSetButton) {
        _homeSetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _homeSetButton.frame = CGRectMake(self.view.frame.size.width - gleadHomeSetButtonWidth, gleadHeaderHeight - gleadHomeListHeight - 5, gleadHomeSetButtonWidth, gleadHomeListHeight + 5);
        [_homeSetButton setImage:[UIImage imageNamed:@"img_homeSet"] forState:UIControlStateNormal];
        [_homeSetButton addTarget:self action:@selector(homeSetting) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:_homeSetButton];

    }
    return _homeSetButton;
}

#pragma mark - Datasource & Delegate
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.homeList.count;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    HomeDeviceController *vc = [[HomeDeviceController alloc] init];
    vc.filledSpcingHeight = gleadHeaderHeight + tabbarHeight + ySafeArea_Bottom;
    return vc;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.homeList[index];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, gleadHeaderHeight - gleadHomeListHeight - 5, self.view.frame.size.width - gleadHomeSetButtonWidth, gleadHomeListHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat fillingSpaceHeight = gleadHeaderHeight + tabbarHeight + ySafeArea_Bottom;
    return CGRectMake(0, gleadHeaderHeight, self.view.frame.size.width, self.view.bounds.size.height - fillingSpaceHeight);
}

#pragma mark - Actions
- (void)houseSelect{
    NSLog(@"asdf");
    HouseSelectController *hsVC = [[HouseSelectController alloc] init];
    hsVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    hsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    hsVC.dismissBlock = ^{
        [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    };
    [self presentViewController:hsVC animated:YES completion:nil];
}

- (void)homeSetting{
    NSLog(@"asdf");
}

- (void)addDevice{
    NSLog(@"asdf");
}
@end
