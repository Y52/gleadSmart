//
//  DeviceSetRoomController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/6/3.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceSetRoomController.h"
#import "RoomButtonCollectCell.h"
#import "YTFAlertController.h"

NSString *const CollectCellIdentifier_DeviceRoom = @"CollectCellID_DeviceRoom";

@interface DeviceSetRoomController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *roomList;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *nameButton;
@property (nonatomic, strong) UICollectionView *buttonView;
@property (nonatomic, strong) UIButton *doneButton;

@property (strong, nonatomic) NSString *selectRoomUid;

@end

@implementation DeviceSetRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;

    self.navigationItem.title = LocalString(@"设置设备信息");
    self.selectRoomUid = @"";
    Database *db = [Database shareInstance];
    self.roomList = [db queryRoomsWith:db.currentHouse.houseUid];
    
    self.titleLabel = [self titleLabel];
    self.nameButton = [self nameButton];
    self.buttonView = [self buttonView];
    self.doneButton = [self doneButton];
}
#pragma mark - private methods
- (void)clickRoombutton:(UIButton *)button{
    NSArray *indexpathArr = [self.buttonView indexPathsForVisibleItems];
    for (NSIndexPath *perIndexPath in indexpathArr) {
        RoomButtonCollectCell *cell = (RoomButtonCollectCell *)[self.buttonView cellForItemAtIndexPath:perIndexPath];
        if (cell.button == button) {
            cell.button.backgroundColor = [UIColor grayColor];
            RoomModel *room = _roomList[perIndexPath.item];
            self.selectRoomUid = room.roomUid;
        }else{
            cell.button.backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)nameModify{
    
    YTFAlertController *alert = [[YTFAlertController alloc] init];
    alert.lBlock = ^{
    };
    alert.rBlock = ^(NSString * _Nullable text) {
        self.device.name = text;
        //使用Api更新
        [self deviceNameModify];
        self.nameButton.titleLabel.text = text;
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        alert.titleLabel.text = LocalString(@"更改设备名称");
        alert.textField.text = self.device.name;
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void)deviceNameModify{
    
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/device",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"name":self.device.name,@"mac":self.device.mac};
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            //[NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            
        }else{
            [NSObject showHudTipStr:@"修改设备名称失败"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"修改设备名称失败"];
        });
    }];
}

- (void)completeAddRoom{
    
    if ([self.selectRoomUid isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:LocalString(@"您没有选择设备") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableArray *maclist = [[NSMutableArray alloc] init];
    NSDictionary *dic = @{@"mac":self.device.mac};
    [maclist addObject:dic];
    
    NSDictionary *parameters = @{@"roomUid":self.selectRoomUid,@"macList":maclist};
    
    NSString *url = [NSString stringWithFormat:@"%@/api/device/room",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
    
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NSObject showHudTipStr:LocalString(@"网络异常")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

#pragma mark - setters and getters
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel =[[UILabel alloc] init];
        _titleLabel.text = LocalString(@"添加设备成功");
        _titleLabel.font = [UIFont boldSystemFontOfSize:25.f];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        [self.view addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(290.f), 50.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(yAutoFit(50.f));
        }];
    }
    return _titleLabel;
}

- (UIButton *)nameButton{
    if (!_nameButton) {
        _nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nameButton setTitle:self.device.name forState:UIControlStateNormal];
        [_nameButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _nameButton.backgroundColor = [UIColor clearColor];
        [_nameButton addTarget:self action:@selector(nameModify) forControlEvents:UIControlEventTouchUpInside];
        _nameButton.layer.cornerRadius = 3.f;
        _nameButton.enabled = YES;
        [self.view addSubview:_nameButton];
        [_nameButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), yAutoFit(40.f)));
            make.top.equalTo(self.titleLabel.mas_bottom).offset(yAutoFit(20.f));
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _nameButton;
}

- (UICollectionView *)buttonView{
    if (!_buttonView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _buttonView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, yAutoFit(180.f), ScreenWidth, 300.f) collectionViewLayout:layout];
        [self.view addSubview:_buttonView];
        _buttonView.backgroundColor = [UIColor clearColor];
        _buttonView.scrollEnabled = NO;
        
        [_buttonView registerClass:[RoomButtonCollectCell class] forCellWithReuseIdentifier:CollectCellIdentifier_DeviceRoom];
        
        _buttonView.delegate = self;
        _buttonView.dataSource = self;
    }
    return _buttonView;
}

- (UIButton *)doneButton{
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setTitle:LocalString(@"完成") forState:UIControlStateNormal];
        [_doneButton.titleLabel setFont:[UIFont systemFontOfSize:18.f]];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton setBackgroundColor:[UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0]];
        [_doneButton addTarget:self action:@selector(completeAddRoom) forControlEvents:UIControlEventTouchUpInside];
        _doneButton.layer.cornerRadius = 10.f;
        _doneButton.enabled = YES;
        [self.view addSubview:_doneButton];
        [_doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), yAutoFit(40.f)));
            make.bottom.equalTo(self.view.mas_bottom).offset(-40.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _doneButton;
}

#pragma mark - collectionView代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.roomList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RoomButtonCollectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectCellIdentifier_DeviceRoom forIndexPath:indexPath];
    RoomModel *room = self.roomList[indexPath.row];
    [cell.button setTitle:room.name forState:UIControlStateNormal];
    [cell.button addTarget:self action:@selector(clickRoombutton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(ScreenWidth/3.f, 50.f);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5.f;
}


@end
