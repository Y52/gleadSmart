//
//  AddRoomsViewController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/2/26.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "AddRoomsViewController.h"
#import "AddRoomsTextCell.h"
NSString *const CellIdentifier_addRoomsText = @"addRoomsText";


@interface AddRoomsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *addRoomsTable;
@property (strong, nonatomic) UIView *footView;
@property (strong, nonatomic) UIButton *handBtn;
@property (strong, nonatomic) UIButton *recommendBtn;

@property (strong, nonatomic) UIButton *hostbedRoomBtn;//主卧
@property (strong, nonatomic) UIButton *secondarybedRoomBtn;//次卧
@property (strong, nonatomic) UIButton *guestRoomBtn;//客厅
@property (strong, nonatomic) UIButton *dinningRoomBtn;//餐厅
@property (strong, nonatomic) UIButton *kitchenRoomBtn;//厨房
@property (strong, nonatomic) UIButton *studyRoomBtn;//书房
@property (strong, nonatomic) UIButton *balconyRoomBtn;//阳台
@property (strong, nonatomic) UIButton *entranceRoomBtn;//玄关
@property (strong, nonatomic) UIButton *cloakRoomBtn;//衣帽间
@property (strong, nonatomic) UIButton *childrenRoomBtn;//儿童房
@property (strong, nonatomic) UIButton *bathRoomBtn;//卫生间


@end

@implementation AddRoomsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor;
    [self setNavItem];
    
    self.addRoomsTable = [self addRoomsTable];
    self.footView = [self footView];
    self.handBtn = [self handBtn];
    self.hostbedRoomBtn = [self hostbedRoomBtn];
    self.secondarybedRoomBtn = [self secondarybedRoomBtn];
    self.guestRoomBtn = [self guestRoomBtn];
    self.dinningRoomBtn = [self dinningRoomBtn];
    self.kitchenRoomBtn = [self kitchenRoomBtn];
    self.studyRoomBtn = [self studyRoomBtn];
    self.balconyRoomBtn = [self balconyRoomBtn];
    self.entranceRoomBtn = [self entranceRoomBtn];
    self.cloakRoomBtn = [self cloakRoomBtn];
    self.childrenRoomBtn = [self childrenRoomBtn];
    self.bathRoomBtn = [self bathRoomBtn];
    self.recommendBtn = [self recommendBtn];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    //去除导航透明
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - private methods
-(void)completeAddRooms{
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if ([cell.inputTF.text isEqualToString:@""]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"错误") message:LocalString(@"请输入正确的房间名字") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    [SVProgressHUD show];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    Database *db = [Database shareInstance];
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/room",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    NSDictionary *parameters = @{@"name":cell.inputTF.text,@"houseUid":self.houseUid};
    
    [manager POST:url parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"success:%@",daetr);
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  [self.navigationController popViewControllerAnimated:YES];
                  NSDictionary *data = [responseDic objectForKey:@"data"];
                  NSString *roomUid = [data objectForKey:@"roomUid"];
                  RoomModel *room = [[RoomModel alloc] init];
                  room.roomUid = roomUid;
                  room.name = cell.inputTF.text;
                  room.houseUid = self.houseUid;
                  room.sortId = self.sortId;
                  [[Database shareInstance] insertNewRoom:room];
              }else{
                  [NSObject showHudTipStr:LocalString(@"添加房间失败")];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"%@",error);
              if (error.code == -1001) {
                  [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
              }else{
                  [NSObject showHudTipStr:LocalString(@"添加房间失败")];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          }
     ];
    
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加房间");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(completeAddRooms) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}

- (UITableView *)addRoomsTable{
    if (!_addRoomsTable) {
        _addRoomsTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 100.f) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[AddRoomsTextCell class] forCellReuseIdentifier:CellIdentifier_addRoomsText];
           
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _addRoomsTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    AddRoomsTextCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_addRoomsText];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[AddRoomsTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_addRoomsText];
    }
    if (indexPath.row == 0) {
        cell.leftLabel.text = LocalString(@"房间名称");
        cell.inputTF.placeholder = LocalString(@"请您添加房间");
        cell.TFBlock = ^(NSString *text) {
            
        };
    }
    return cell;

}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   return 15;
}

-(UIView *)footView{
    if (!_footView) {
        _footView = [[UIView alloc] init];
        _footView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_footView];
        [_footView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake( ScreenWidth , 180.f));
            make.top.equalTo(self.view.mas_top).offset(yAutoFit(65.f));
            make.centerX.equalTo(self.view.mas_centerX);
        }];
        
    }
    return _footView;
}

- (UIButton *)handBtn{
    if (!_handBtn) {
        _handBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_handBtn setTitle:LocalString(@"") forState:UIControlStateNormal];
        [_handBtn setImage:[UIImage imageNamed:@"addRoom_hand"] forState:UIControlStateNormal];
        [_handBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_handBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_handBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        //[_recommendBtn.layer setBorderWidth:1.0];
        //_recommendBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        //_recommendBtn.layer.cornerRadius = 15.f;
        [_handBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [self.footView addSubview:_handBtn];
        [_handBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(20.f), 20.f));
            make.left.equalTo(self.footView.mas_left).offset(yAutoFit(15.f));
            make.top.equalTo(self.footView.mas_top).offset(yAutoFit(5.f));
        }];
    }
    return _handBtn;
}

- (UIButton *)recommendBtn{
    if (!_recommendBtn) {
        _recommendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recommendBtn setTitle:LocalString(@"推荐") forState:UIControlStateNormal];
        [_recommendBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_recommendBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_recommendBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        //[_recommendBtn.layer setBorderWidth:1.0];
        //_recommendBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        //_recommendBtn.layer.cornerRadius = 15.f;
        [_recommendBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_recommendBtn addTarget:self action:@selector(recommend) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_recommendBtn];
        [_recommendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(40.f), 20.f));
            make.left.equalTo(self.handBtn.mas_right).offset(yAutoFit(5.f));
            make.top.equalTo(self.footView.mas_top).offset(yAutoFit(5.f));
        }];
    }
    return _recommendBtn;
}

- (UIButton *)hostbedRoomBtn{
    if (!_hostbedRoomBtn) {
        _hostbedRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hostbedRoomBtn setTitle:LocalString(@"主卧") forState:UIControlStateNormal];
        [_hostbedRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_hostbedRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_hostbedRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_hostbedRoomBtn.layer setBorderWidth:1.0];
        _hostbedRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _hostbedRoomBtn.layer.cornerRadius = 1.f;
        [_hostbedRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_hostbedRoomBtn addTarget:self action:@selector(hostbedRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_hostbedRoomBtn];
        [_hostbedRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.footView.mas_left).offset(yAutoFit(15.f));
            make.top.equalTo(self.footView.mas_top).offset(yAutoFit(40.f));
        }];
    }
    return _hostbedRoomBtn;
}

- (UIButton *)secondarybedRoomBtn{
    if (!_secondarybedRoomBtn) {
        _secondarybedRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_secondarybedRoomBtn setTitle:LocalString(@"次卧") forState:UIControlStateNormal];
        [_secondarybedRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_secondarybedRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_secondarybedRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_secondarybedRoomBtn.layer setBorderWidth:1.0];
        _secondarybedRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _secondarybedRoomBtn.layer.cornerRadius = 1.f;
        [_secondarybedRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_secondarybedRoomBtn addTarget:self action:@selector(secondarybedRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_secondarybedRoomBtn];
        [_secondarybedRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.hostbedRoomBtn.mas_right).offset(yAutoFit(25.f));
            make.top.equalTo(self.footView.mas_top).offset(yAutoFit(40.f));
        }];
    }
    return _secondarybedRoomBtn;
}

- (UIButton *)guestRoomBtn{
    if (!_guestRoomBtn) {
        _guestRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_guestRoomBtn setTitle:LocalString(@"客厅") forState:UIControlStateNormal];
        [_guestRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_guestRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_guestRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_guestRoomBtn.layer setBorderWidth:1.0];
        _guestRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _guestRoomBtn.layer.cornerRadius = 1.f;
        [_guestRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_guestRoomBtn addTarget:self action:@selector(guestRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_guestRoomBtn];
        [_guestRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.secondarybedRoomBtn.mas_right).offset(yAutoFit(25.f));
            make.top.equalTo(self.footView.mas_top).offset(yAutoFit(40.f));
        }];
    }
    return _guestRoomBtn;
}

- (UIButton *)dinningRoomBtn{
    if (!_dinningRoomBtn) {
        _dinningRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dinningRoomBtn setTitle:LocalString(@"餐厅") forState:UIControlStateNormal];
        [_dinningRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_dinningRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_dinningRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_dinningRoomBtn.layer setBorderWidth:1.0];
        _dinningRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _dinningRoomBtn.layer.cornerRadius = 1.f;
        [_dinningRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_dinningRoomBtn addTarget:self action:@selector(dinningRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_dinningRoomBtn];
        [_dinningRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.guestRoomBtn.mas_right).offset(yAutoFit(25.f));
            make.top.equalTo(self.footView.mas_top).offset(yAutoFit(40.f));
        }];
    }
    return _dinningRoomBtn;
}

- (UIButton *)kitchenRoomBtn{
    if (!_kitchenRoomBtn) {
        _kitchenRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_kitchenRoomBtn setTitle:LocalString(@"厨房") forState:UIControlStateNormal];
        [_kitchenRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_kitchenRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_kitchenRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_kitchenRoomBtn.layer setBorderWidth:1.0];
        _kitchenRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _kitchenRoomBtn.layer.cornerRadius = 1.f;
        [_kitchenRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_kitchenRoomBtn addTarget:self action:@selector(kitchenRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_kitchenRoomBtn];
        [_kitchenRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.footView .mas_left).offset(yAutoFit(15.f));
            make.top.equalTo(self.hostbedRoomBtn.mas_bottom).offset(yAutoFit(15.f));
        }];
    }
    return _kitchenRoomBtn;
}

- (UIButton *)studyRoomBtn{
    if (!_studyRoomBtn) {
        _studyRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_studyRoomBtn setTitle:LocalString(@"书房") forState:UIControlStateNormal];
        [_studyRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_studyRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_studyRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_studyRoomBtn.layer setBorderWidth:1.0];
        _studyRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _studyRoomBtn.layer.cornerRadius = 1.f;
        [_studyRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_studyRoomBtn addTarget:self action:@selector(studyRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_studyRoomBtn];
        [_studyRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.kitchenRoomBtn.mas_right).offset(yAutoFit(25.f));
            make.top.equalTo(self.hostbedRoomBtn.mas_bottom).offset(yAutoFit(15.f));
        }];
    }
    return _studyRoomBtn;
}

- (UIButton *)balconyRoomBtn{
    if (!_balconyRoomBtn) {
        _balconyRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_balconyRoomBtn setTitle:LocalString(@"阳台") forState:UIControlStateNormal];
        [_balconyRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_balconyRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_balconyRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_balconyRoomBtn.layer setBorderWidth:1.0];
        _balconyRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _balconyRoomBtn.layer.cornerRadius = 1.f;
        [_balconyRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_balconyRoomBtn addTarget:self action:@selector(balconyRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_balconyRoomBtn];
        [_balconyRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.studyRoomBtn.mas_right).offset(yAutoFit(25.f));
            make.top.equalTo(self.hostbedRoomBtn.mas_bottom).offset(yAutoFit(15.f));
        }];
    }
    return _balconyRoomBtn;
}

- (UIButton *)entranceRoomBtn{
    if (!_entranceRoomBtn) {
        _entranceRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_entranceRoomBtn setTitle:LocalString(@"玄关") forState:UIControlStateNormal];
        [_entranceRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_entranceRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_entranceRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_entranceRoomBtn.layer setBorderWidth:1.0];
        _entranceRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _entranceRoomBtn.layer.cornerRadius = 1.f;
        [_entranceRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_entranceRoomBtn addTarget:self action:@selector(entranceRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_entranceRoomBtn];
        [_entranceRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.balconyRoomBtn.mas_right).offset(yAutoFit(25.f));
            make.top.equalTo(self.hostbedRoomBtn.mas_bottom).offset(yAutoFit(15.f));
        }];
    }
    return _entranceRoomBtn;
}

- (UIButton *)cloakRoomBtn{
    if (!_cloakRoomBtn) {
        _cloakRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cloakRoomBtn setTitle:LocalString(@"衣帽间") forState:UIControlStateNormal];
        [_cloakRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_cloakRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_cloakRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_cloakRoomBtn.layer setBorderWidth:1.0];
        _cloakRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _cloakRoomBtn.layer.cornerRadius = 1.f;
        [_cloakRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_cloakRoomBtn addTarget:self action:@selector(cloakRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_cloakRoomBtn];
        [_cloakRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.footView.mas_left).offset(yAutoFit(15.f));
            make.top.equalTo(self.kitchenRoomBtn.mas_bottom).offset(yAutoFit(15.f));
        }];
    }
    return _cloakRoomBtn;
}

- (UIButton *)childrenRoomBtn{
    if (!_childrenRoomBtn) {
        _childrenRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_childrenRoomBtn setTitle:LocalString(@"儿童房") forState:UIControlStateNormal];
        [_childrenRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_childrenRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_childrenRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_childrenRoomBtn.layer setBorderWidth:1.0];
        _childrenRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _childrenRoomBtn.layer.cornerRadius = 1.f;
        [_childrenRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_childrenRoomBtn addTarget:self action:@selector(childrenRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_childrenRoomBtn];
        [_childrenRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.cloakRoomBtn.mas_right).offset(yAutoFit(25.f));
            make.top.equalTo(self.kitchenRoomBtn.mas_bottom).offset(yAutoFit(15.f));
        }];
    }
    return _childrenRoomBtn;
}

- (UIButton *)bathRoomBtn{
    if (!_bathRoomBtn) {
        _bathRoomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bathRoomBtn setTitle:LocalString(@"卫生间") forState:UIControlStateNormal];
        [_bathRoomBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_bathRoomBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_bathRoomBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_bathRoomBtn.layer setBorderWidth:1.0];
        _bathRoomBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _bathRoomBtn.layer.cornerRadius = 1.f;
        [_bathRoomBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_bathRoomBtn addTarget:self action:@selector(bathRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.footView addSubview:_bathRoomBtn];
        [_bathRoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(63.f), 32.f));
            make.left.equalTo(self.childrenRoomBtn.mas_right).offset(yAutoFit(25.f));
            make.top.equalTo(self.kitchenRoomBtn.mas_bottom).offset(yAutoFit(15.f));
        }];
    }
    return _bathRoomBtn;
}

-(void)recommend{
    NSLog(@"推荐");
    
}

-(void)hostbedRoom{
    NSLog(@"主卧");
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.inputTF.text = LocalString(@"主卧");
}

-(void)secondarybedRoom{
    NSLog(@"次卧");
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.inputTF.text = LocalString(@"次卧");
}

-(void)guestRoom{
    NSLog(@"客厅");
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.inputTF.text = LocalString(@"客厅");
}

-(void)dinningRoom{
    NSLog(@"餐厅");
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.inputTF.text = LocalString(@"餐厅");
}

-(void)kitchenRoom{
    NSLog(@"厨房");
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.inputTF.text = LocalString(@"厨房");
}

-(void)studyRoom{
    NSLog(@"书房");
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.inputTF.text = LocalString(@"书房");
}

-(void)balconyRoom{
    NSLog(@"阳台");
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.inputTF.text = LocalString(@"阳台");
}

-(void)entranceRoom{
    NSLog(@"玄关");
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.inputTF.text = LocalString(@"玄关");
}

-(void)cloakRoom{
    NSLog(@"衣帽间");
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.inputTF.text = LocalString(@"衣帽间");
}

-(void)childrenRoom{
    NSLog(@"儿童房");
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.inputTF.text = LocalString(@"儿童房");
}

-(void)bathRoom{
    NSLog(@"卫生间");
    AddRoomsTextCell *cell = [self.addRoomsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.inputTF.text = LocalString(@"卫生间");
}

@end
