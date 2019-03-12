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
#import "SelectDeviceTypeController.h"
#import "HomeManagementController.h"
#import "HouseManagementController.h"

static CGFloat const gleadHeaderHeight = 225.f;
static CGFloat const gleadWeatherViewWidth = 335.f;
static CGFloat const gleadHomeListHeight = 37.f;
static CGFloat const gleadHomeSetButtonWidth = 50.f;
static CGFloat const gleadMenuItemMargin = 20.f;

@interface MyHouseController ()

@property (strong, nonatomic) UIView *headerView;

@property (strong, nonatomic) UIButton *houseButton;

@property (strong, nonatomic) UIButton *addDeviceButton;

@property (strong, nonatomic) UIView *weatherView;
@property (strong, nonatomic) UILabel *tempValueLabel;
@property (strong, nonatomic) UILabel *pmValueLabel;
@property (strong, nonatomic) UILabel *airValueLabel;

@property (nonatomic, strong) UILabel *testLabel;

@property (strong, nonatomic) NSMutableArray *homeList;
@property (strong, nonatomic) UIButton *homeSetButton;

@end

@implementation MyHouseController{

}

- (instancetype)init{
    if (self = [super init]) {
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 15;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.automaticallyCalculatesItemWidths = YES;
        self.titleColorSelected = [UIColor whiteColor];
        self.titleColorNormal = [UIColor whiteColor];
        self.itemMargin = gleadMenuItemMargin;
        self.menuViewContentMargin = 0.f;
        self.pageAnimatable = YES;
        self.scrollEnable = NO;
        self.menuViewLayoutMode = WMMenuViewLayoutModeLeft;
        
        if (!self.homeList) {
            self.homeList = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    self.headerView = [self headerView];
    self.houseButton = [self houseButton];
    self.weatherView = [self weatherView];
    self.tempValueLabel = [self tempValueLabel];
    self.pmValueLabel = [self pmValueLabel];
    self.airValueLabel = [self airValueLabel];
    self.homeSetButton = [self homeSetButton];
    self.addDeviceButton = [self addDeviceButton];
    
    if ([Database shareInstance].currentHouse) {
        //如果已经选中了家庭，获取家庭中的房间列表和所有设备
        [self getHouseHomeListAndDevice];
    }
    
    //测试用代码
//    self.testLabel = [self testLabel];
//    Network *net = [Network shareNetwork];//初始化network，为了开始udp自动查询连接
//    [net addObserver:self forKeyPath:@"testSendCount" options:NSKeyValueObservingOptionNew context:nil];
//    [net addObserver:self forKeyPath:@"testRecieveCount" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    
    //挡住了最上面的几个按钮的点击
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)dealloc{
    //测试用代码
    Network *net = [Network shareNetwork];
    [net removeObserver:self forKeyPath:@"testSendCount"];
    [net removeObserver:self forKeyPath:@"testRecieveCount"];
}

#pragma mark - Datasource & Delegate
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.homeList.count + 1;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    HomeDeviceController *vc = [[HomeDeviceController alloc] init];
    vc.filledSpcingHeight = yAutoFit(gleadHeaderHeight) + tabbarHeight + ySafeArea_Bottom;
    if (index == 0) {
        vc.room = nil;
        return vc;
    }
    RoomModel *room = self.homeList[index-1];
    vc.room = room;
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
    return CGRectMake(0, yAutoFit(gleadHeaderHeight) - gleadHomeListHeight - 5, self.view.frame.size.width - gleadHomeSetButtonWidth, gleadHomeListHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat fillingSpaceHeight = yAutoFit(gleadHeaderHeight) + tabbarHeight + ySafeArea_Bottom;
    return CGRectMake(0, yAutoFit(gleadHeaderHeight), self.view.frame.size.width, self.view.bounds.size.height - fillingSpaceHeight);
}

#pragma mark - API methods
//获取房间列表和所有设备
- (void)getHouseHomeListAndDevice{
    Database *db = [Database shareInstance];
    [db getHouseHomeListAndDevice:db.currentHouse success:^{
        for (HouseModel *newHouse in db.houseList) {
            if ([db.currentHouse.houseUid isEqualToString:newHouse.houseUid]) {
                db.currentHouse = newHouse;//更新当前家庭信息
            }
        }
        [self getWeatherByLocation];//获取天气信息
        [self getAirQualityByLocation];//获取空气质量
        [self getHouseHomeListAndDeviceWithDatabase];//数据库获取房间和设备
        [self reloadData];//wmpagecontroller更新滑动列表
    } failure:^{
        [self getWeatherByLocation];//获取天气信息
        [self getAirQualityByLocation];//获取空气质量
        [self getHouseHomeListAndDeviceWithDatabase];//数据库获取房间和设备
        db.shareDeviceArray = [db queryAllShareDevice];//http请求失败后数据库获取共享设备
        [self reloadData];//wmpagecontroller更新滑动列表
    }];
}

/*
 *根据经纬度获取当地天气情况
 */
- (void)getWeatherByLocation{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"https://free-api.heweather.com/s6/weather/now?location=%@,%@&key=%@",db.currentHouse.lon,db.currentHouse.lat,@"6efda5ac4ceb40ffb4c07d7ff740d628"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    NSLog(@"%@",url);
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([responseDic objectForKey:@"HeWeather6"]) {
            NSArray *dataArr = [responseDic objectForKey:@"HeWeather6"];
            if (dataArr.count == 0) {
                return ;
            }
            NSDictionary *dataDic = dataArr[0];
            if ([[dataDic objectForKey:@"status"] isEqualToString:@"ok"]) {
                NSDictionary *weather = [dataDic objectForKey:@"now"];
                self.tempValueLabel.text = [NSString stringWithFormat:@"%@℃",[weather objectForKey:@"tmp"]];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject showHudTipStr:@"获取当前天气失败"];
        });
    }];
}

/*
 *根据经纬度获取当地空气质量
 */
- (void)getAirQualityByLocation{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"https://free-api.heweather.com/s6/air/now?location=%@,%@&key=%@",db.currentHouse.lon,db.currentHouse.lat,@"6efda5ac4ceb40ffb4c07d7ff740d628"];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    NSLog(@"%@",url);
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([responseDic objectForKey:@"HeWeather6"]) {
            NSArray *dataArr = [responseDic objectForKey:@"HeWeather6"];
            if (dataArr.count == 0) {
                return ;
            }
            NSDictionary *dataDic = dataArr[0];
            if ([[dataDic objectForKey:@"status"] isEqualToString:@"ok"]) {
                NSDictionary *weather = [dataDic objectForKey:@"air_now_city"];
                self.pmValueLabel.text = [NSString stringWithFormat:@"%@",[weather objectForKey:@"pm25"]];
                self.airValueLabel.text = [NSString stringWithFormat:@"%@",[weather objectForKey:@"qlty"]];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject showHudTipStr:@"获取当前天气失败"];
        });
    }];
}

#pragma mark - Update by database
/*
 *从本地获取设备信息和房间信息
 */
- (void)getHouseHomeListAndDeviceWithDatabase{
    Database *db = [Database shareInstance];
    
    if (!self.homeList) {
        self.homeList = [[NSMutableArray alloc] init];
    }
    [self.homeList removeAllObjects];
    self.homeList = [db queryRoomsWith:db.currentHouse.houseUid];
    
    db.localDeviceArray = [db queryAllDevice:db.currentHouse.houseUid];
    for (DeviceModel *device in db.localDeviceArray) {
        if ([device.type intValue] == 0) {
            //获取中央控制器的mac并设置为当前家庭的mac
            db.currentHouse.mac = device.mac;
            [db.localDeviceArray removeObject:device];
            break;
        }
    }
    
    //获取家庭网关下所有下挂设备
    UInt8 controlCode = 0x00;
    NSArray *data = @[@0xFE,@0x01,@0x45,@0x00];//在网节点查询
    [[Network shareNetwork] sendData69With:controlCode mac:db.currentHouse.mac data:data failuer:nil];
}

#pragma mark - Actions
- (void)houseSelect{
    HouseSelectController *hsVC = [[HouseSelectController alloc] init];
    //[self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    hsVC.dismissBlock = ^{
        [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
        [self getHouseHomeListAndDevice];
        if (![Database shareInstance].currentHouse) {
            [self.houseButton setTitle:LocalString(@"请选择家庭") forState:UIControlStateNormal];
        }else{
            [self.houseButton setTitle:[Database shareInstance].currentHouse.name forState:UIControlStateNormal];
        }
    };
    hsVC.pushBlock = ^{
        HouseManagementController *HouseManagementVC = [[HouseManagementController alloc] init];
        HouseManagementVC.popBlock = ^{
            [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
            [self getHouseHomeListAndDevice];
            if (![Database shareInstance].currentHouse) {
                [self.houseButton setTitle:LocalString(@"请选择家庭") forState:UIControlStateNormal];
            }else{
                [self.houseButton setTitle:[Database shareInstance].currentHouse.name forState:UIControlStateNormal];
            }
        };
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
        [self.navigationController pushViewController:HouseManagementVC animated:YES];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:hsVC];
    nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)homeSetting{
    if ([Database shareInstance].currentHouse == nil) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"家庭错误") message:LocalString(@"请先添加或选择家庭") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }else if ([[Database shareInstance].currentHouse.auth integerValue] > 0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"普通成员不可操作") message:LocalString(@"请先联系管理员在\"家庭设置-家庭成员\"中开启权限") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    HomeManagementController *HomeManagementVC = [[HomeManagementController alloc] init];
    HomeManagementVC.homeList = self.homeList;
    HomeManagementVC.houseUid = [Database shareInstance].currentHouse.houseUid;
    [self.navigationController pushViewController:HomeManagementVC animated:YES];
}

- (void)addDevice{
    if ([Database shareInstance].currentHouse == nil) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"家庭错误") message:LocalString(@"请先添加或选择家庭") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }else if ([[Database shareInstance].currentHouse.auth integerValue] > 0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"普通成员不可操作") message:LocalString(@"请先联系管理员在\"家庭设置-家庭成员\"中开启权限") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    SelectDeviceTypeController *SelectDeviceVC = [[SelectDeviceTypeController alloc] init];
    [self.navigationController pushViewController:SelectDeviceVC animated:YES];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    Network *net = [Network shareNetwork];
    if ([keyPath isEqualToString:@"testSendCount"] || [keyPath isEqualToString:@"testRecieveCount"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.testLabel.text = [NSString stringWithFormat:@"send:%d,rece:%d",net.testSendCount,net.testRecieveCount];
        });
    }
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

- (UIButton *)houseButton{
    if (!_houseButton) {
        _houseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (![Database shareInstance].currentHouse) {
            [self.houseButton setTitle:LocalString(@"请选择家庭") forState:UIControlStateNormal];
        }else{
            [self.houseButton setTitle:[Database shareInstance].currentHouse.name forState:UIControlStateNormal];
        }
        _houseButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        _houseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _houseButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _houseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_houseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_houseButton addTarget:self action:@selector(houseSelect) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:_houseButton];
        
        CGFloat y = yAutoFit(gleadHeaderHeight) - yAutoFit(24.f) - yAutoFit(13.f) * 2 - yAutoFit(100.f) - gleadHomeListHeight;
        [_houseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_left).offset(yAutoFit(35.f));
            make.top.equalTo(self.view.mas_top).offset(y);
            make.size.mas_equalTo(CGSizeMake(yAutoFit(150.f), yAutoFit(24.f)));
        }];
        
        [_houseButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
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

//测试用代码
- (UILabel *)testLabel{
    if (!_testLabel) {
        _testLabel = [[UILabel alloc] init];
        _testLabel.textAlignment = NSTextAlignmentCenter;
        _testLabel.textColor = [UIColor whiteColor];
        _testLabel.backgroundColor = [UIColor blackColor];
        _testLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
        [self.headerView addSubview:_testLabel];
        [self.headerView bringSubviewToFront:_testLabel];
        [_testLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0.f);
            make.top.equalTo(self.headerView.mas_top).offset(yAutoFit(56.f));
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, yAutoFit(30.f)));
        }];

    }
    return _testLabel;
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

-(UIButton *)homeSetButton{
    if (!_homeSetButton) {
        _homeSetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _homeSetButton.frame = CGRectMake(self.view.frame.size.width - gleadHomeSetButtonWidth, yAutoFit(gleadHeaderHeight) - gleadHomeListHeight - 5, gleadHomeSetButtonWidth, gleadHomeListHeight + 5);
        [_homeSetButton setImage:[UIImage imageNamed:@"img_homeSet"] forState:UIControlStateNormal];
        [_homeSetButton addTarget:self action:@selector(homeSetting) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:_homeSetButton];

    }
    return _homeSetButton;
}

@end
