//
//  FamilyLocationController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/25.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "FamilyLocationController.h"
#import "KYDivisionPickerView.h"
#import <CoreLocation/CoreLocation.h>

@interface FamilyLocationController () <KYDivisionPickerViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIButton *autoLocationBtn;
@property (strong, nonatomic) KYDivisionPickerView *locationPicker;
@property (strong, nonatomic) UIButton *dismissButton;

@end

@implementation FamilyLocationController{
    CLLocationManager *_locationManager;
    CLGeocoder *_geocodel;
    NSString *currentCity;
    NSNumber *lon;
    NSNumber *lat;
}

-(instancetype)init{
    if (self) {
        // 打开定位 然后得到数据
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        //控制定位精度,越高耗电量越
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager requestAlwaysAuthorization];
        currentCity = @"";
        
        _geocodel = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6]];

    self.contentView = [self contentView];
    self.autoLocationBtn = [self autoLocationBtn];
    self.locationPicker = [self locationPicker];
    self.dismissButton = [self dismissButton];
}

#pragma mark - Lazy load
-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(0, _contentOriginY, ScreenWidth, ScreenHeight - _contentOriginY);
        _contentView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1];
        [self.view addSubview:_contentView];
    }
    return _contentView;
}

- (UIButton *)autoLocationBtn{
    if (!_autoLocationBtn) {
        _autoLocationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _autoLocationBtn.frame = CGRectMake(0, 0.f, ScreenWidth, 40.f);
        [_autoLocationBtn addTarget:self action:@selector(autoLocation) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_autoLocationBtn];
        [self.contentView bringSubviewToFront:_autoLocationBtn];
        
        UIImageView *leftImage = [[UIImageView alloc] init];
        leftImage.image = [UIImage imageNamed:@"img_autoLocation"];
        [self.contentView addSubview:leftImage];
        
        UILabel *rightLabel = [[UILabel alloc] init];
        rightLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:LocalString(@"帮我定位") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:158/255.0 green:159/255.0 blue:159/255.0 alpha:1.0]}];
        rightLabel.adjustsFontSizeToFitWidth = YES;
        [self.contentView addSubview:rightLabel];
        [leftImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16.f, 20.f));
            make.centerY.equalTo(self.autoLocationBtn.mas_centerY);
            make.left.equalTo(self.autoLocationBtn.mas_centerX).offset(-35.f);
        }];
        
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(49.f, 14.f));
            make.left.equalTo(leftImage.mas_right).offset(5.f);
            make.centerY.equalTo(self.autoLocationBtn.mas_centerY);
        }];
    }
    return _autoLocationBtn;
}

- (UIButton *)dismissButton{
    if (!_dismissButton) {
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dismissButton.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        [_dismissButton addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view insertSubview:_dismissButton atIndex:0];
    }
    return _dismissButton;
}

- (KYDivisionPickerView *)locationPicker{
    if (!_locationPicker) {
        _locationPicker = [[KYDivisionPickerView alloc] init];
        _locationPicker.frame = CGRectMake(0, 40.f, ScreenWidth, ScreenHeight - 40.f - _contentOriginY);
        _locationPicker.adjustsFontSizeToFitWidth = YES;
        _locationPicker.divisionDelegate = self;
        [self.contentView addSubview:_locationPicker];
    }
    return _locationPicker;
}

#pragma mark - locationPicker delegate
- (void)didGetAddressFromPickerViewWithProvinceName:(NSString *)provinceName cityName:(NSString *)cityName countyName:(NSString *)countyName streetName:(NSString *)streetName{
    NSString *addr = [NSString stringWithFormat:@"%@%@%@",provinceName,cityName,countyName];
    self->currentCity = addr;
    [_geocodel geocodeAddressString:addr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark=[placemarks firstObject];
        
        CLLocation *location=placemark.location;//位置
        CLRegion *region=placemark.region;//区域
        NSDictionary *addressDic= placemark.addressDictionary;//详细地址信息字典,包含以下部分信息
        NSLog(@"位置:%@,区域:%@,详细信息:%@",location,region,addressDic);
        
        self->lon = [NSNumber numberWithFloat:location.coordinate.longitude];
        self->lat = [NSNumber numberWithFloat:location.coordinate.latitude];
    }];
}

#pragma mark CoreLocation delegate
//定位失败后调用此代理方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    //设置提示提醒用户打开定位服务
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"允许定位提示" message:@"请在设置中打开定位" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"打开定位" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    [_locationManager stopUpdatingLocation];
    //旧址
    CLLocation *currentLocation = [locations lastObject];
    //打印当前的经度与纬度
    NSLog(@"%f,%f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    
    self->lon = [NSNumber numberWithFloat:currentLocation.coordinate.longitude];
    self->lat = [NSNumber numberWithFloat:currentLocation.coordinate.latitude];

    //反地理编码
    [_geocodel reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = placemarks[0];
            self->currentCity = [NSString stringWithFormat:@"%@%@%@",placeMark.administrativeArea,placeMark.locality,placeMark.subLocality];
            if (!self->currentCity) {
                self->currentCity = @"无法定位当前城市";
            }
            
            /*看需求定义一个全局变量来接收赋值*/
            NSLog(@"----%@",placeMark.country);//当前国家
            NSLog(@"%@",self->currentCity);//当前的城市
            //            NSLog(@"%@",placeMark.subLocality);//当前的位置
            //            NSLog(@"%@",placeMark.thoroughfare);//当前街道
            //            NSLog(@"%@",placeMark.name);//具体地址
            
        }
        [SVProgressHUD dismiss];
        [self dismissVC];
    }];
    
}

#pragma mark - Actions
- (void)autoLocation{
    [SVProgressHUD show];
    [_locationManager startUpdatingLocation];
}

- (void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.dismissBlock) {
        self.dismissBlock(self->currentCity);
    }
}
@end
