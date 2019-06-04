//
//  DeviceSetRoomController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/6/3.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceSetRoomController.h"
#import "RoomButtonCollectCell.h"

NSString *const CollectCellIdentifier_DeviceRoom = @"CollectCellID_DeviceRoom";

@interface DeviceSetRoomController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *roomList;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *deviceImage;
@property (nonatomic, strong) UITextField *nameButton;
@property (nonatomic, strong) UICollectionView *buttonView;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation DeviceSetRoomController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1].CGColor;

    self.navigationItem.title = LocalString(@"添加设备");
    
    Database *db = [Database shareInstance];
    self.roomList = [db queryRoomsWith:db.currentHouse.houseUid];
    
    self.titleLabel = [self titleLabel];
    self.deviceImage = [self deviceImage];
    self.nameButton = [self nameButton];
    self.buttonView = [self buttonView];
    self.doneButton = [self doneButton];
}
#pragma mark - private methods
- (void)clickRoombutton:(UIButton *)button{
    
}

#pragma mark - setters and getters
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel =[[UILabel alloc] init];
        _titleLabel.text = LocalString(@"添加设备成功");
        _titleLabel.font = [UIFont boldSystemFontOfSize:25.f];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
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

-(UIImageView *)deviceImage{
    if (!_deviceImage) {
        _deviceImage = [[UIImageView alloc] init];
        _deviceImage.contentMode = UIViewContentModeScaleAspectFit;
        _deviceImage.image = [UIImage imageNamed:@"img_switch_icon_1"];
        [self.view addSubview:_deviceImage];
        [_deviceImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(44.f), yAutoFit(44.f)));
            make.left.equalTo(self.view.mas_left).offset(yAutoFit(40.f));
            make.top.equalTo(self.titleLabel.mas_bottom).offset(yAutoFit(30.f));
        }];
    }
    return _deviceImage;
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
