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

static CGFloat const gleadHeaderHeight = 225.f;
static CGFloat const gleadWeatherViewWidth = 335.f;
static CGFloat const gleadHomeListHeight = 37.f;
static CGFloat const gleadHomeSetButtonWidth = 50.f;
static CGFloat const gleadMenuItemMargin = 25.f;

@interface MyHouseController ()

@property (strong, nonatomic) UIView *headerView;

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
        self.pageAnimatable = YES;
        
        self.homeList = [[NSMutableArray alloc] init];
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
        [self getHouseHomeListAndDevice];
    }
    [Network shareNetwork];//初始化network，为了开始udp自动查询连接
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
    
    //挡住了最上面的几个按钮的点击
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
        [_houseButton setTitle:[Database shareInstance].currentHouse.name forState:UIControlStateNormal];
        _houseButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        _houseButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_houseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_houseButton setImage:[UIImage imageNamed:@"img_houseSelect"] forState:UIControlStateNormal];
        [_houseButton addTarget:self action:@selector(houseSelect) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:_houseButton];
        
        CGSize size = [[Database shareInstance].currentHouse.name sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Helvetica" size:15],NSFontAttributeName,nil]];
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
    return self.homeList.count + 1;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    HomeDeviceController *vc = [[HomeDeviceController alloc] init];
    vc.filledSpcingHeight = gleadHeaderHeight + tabbarHeight + ySafeArea_Bottom;
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
    return CGRectMake(0, gleadHeaderHeight - gleadHomeListHeight - 5, self.view.frame.size.width - gleadHomeSetButtonWidth, gleadHomeListHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat fillingSpaceHeight = gleadHeaderHeight + tabbarHeight + ySafeArea_Bottom;
    return CGRectMake(0, gleadHeaderHeight, self.view.frame.size.width, self.view.bounds.size.height - fillingSpaceHeight);
}

#pragma mark - update with API
- (void)getHouseHomeListAndDevice{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"http://gleadsmart.thingcom.cn/api/house/device/list?houseUid=%@",db.currentHouse.houseUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            NSDictionary *dic = [responseDic objectForKey:@"data"];
            
            /*
             *取出家庭详细信息
             */
            NSDictionary *houseInfo = [dic objectForKey:@"house"];
            db.currentHouse.lon = [houseInfo objectForKey:@"lon"];
            db.currentHouse.lat = [houseInfo objectForKey:@"lat"];
            [self getWeatherByLocation];//获取天气信息
            [self getAirQualityByLocation];//获取空气质量
            db.currentHouse.apiKey = [houseInfo objectForKey:@"apiKey"];
            db.currentHouse.deviceId = [houseInfo objectForKey:@"deviceId"];
            /*
             *把houselist中的该house更新，防止在切换house时丢失数据
             */
            for (HouseModel *house in db.houseList) {
                if (house.houseUid == db.currentHouse.houseUid) {
                    [db.houseList addObject:db.currentHouse];
                    [db.houseList removeObject:house];
                    break;
                }
            }
            /*
             *把本地数据库的该house更新
             */
            [db updateHouse:db.currentHouse];
            
            /*
             *取出房间内容
             */
            if ([[dic objectForKey:@"rooms"] count] > 0) {
                [[dic objectForKey:@"rooms"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    RoomModel *room = [[RoomModel alloc] init];
                    room.name = [obj objectForKey:@"roomName"];
                    room.roomUid = [obj objectForKey:@"roomUid"];
                    room.houseUid = db.currentHouse.houseUid;
                    room.deviceArray = [[NSMutableArray alloc] init];
                    [[obj objectForKey:@"devices"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        DeviceModel *device = [[DeviceModel alloc] init];
                        device.name = [obj objectForKey:@"deviceName"];
                        device.mac = [obj objectForKey:@"mac"];
                        device.roomUid = room.roomUid;
                        device.houseUid = db.currentHouse.houseUid;
                        if ([NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(0, 2)]] == 0x01) {
                            device.type = @0;
                        }else{
                            device.type = [NSNumber numberWithInteger:[[Network shareNetwork] judgeDeviceTypeWith:[NSString stringScanToInt:[device.mac substringWithRange:NSMakeRange(2, 2)]]]];
                        }
                        //插入房间的设备
                        [db insertNewDevice:device];
                    }];
                    [db insertNewRoom:room];
                    [self.homeList addObject:room];
                }];
                [self reloadData];
            }
        }else{
            [NSObject showHudTipStr:LocalString(@"获取家庭详细信息失败")];
        }
        [self getHouseHomeListAndDeviceWithDatabase];
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
        [self getHouseHomeListAndDeviceWithDatabase];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"从服务器获取信息失败"];
        });
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
    self.homeList = [db queryRoomsWith:db.currentHouse.houseUid];
    db.localDeviceArray = [db queryAllDevice:db.currentHouse.houseUid];
    for (DeviceModel *device in db.localDeviceArray) {
        if ([device.type intValue] == 0) {
            db.currentHouse.mac = device.mac;
            NSLog(@"%@",device.mac);
            [db.localDeviceArray removeObject:device];
            break;
        }
    }
    [[Network shareNetwork] onlineNodeInquire:db.currentHouse.mac];
}

#pragma mark - Actions
- (void)houseSelect{
    HouseSelectController *hsVC = [[HouseSelectController alloc] init];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    hsVC.dismissBlock = ^{
        [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
        [self getHouseHomeListAndDevice];
        [self.houseButton setTitle:[Database shareInstance].currentHouse.name forState:UIControlStateNormal];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:hsVC];
    nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)homeSetting{
    if ([Database shareInstance].currentHouse == nil) {
        [NSObject showHudTipStr:LocalString(@"请先创建家庭")];
        return;
    }
    HomeManagementController *HomeManagementVC = [[HomeManagementController alloc] init];
    HomeManagementVC.homeList = self.homeList;
    [self.navigationController pushViewController:HomeManagementVC animated:YES];
}

- (void)addDevice{
    if ([Database shareInstance].currentHouse == nil) {
        [NSObject showHudTipStr:LocalString(@"请先创建家庭")];
        return;
    }
    SelectDeviceTypeController *SelectDeviceVC = [[SelectDeviceTypeController alloc] init];
    [self.navigationController pushViewController:SelectDeviceVC animated:YES];
}
@end
