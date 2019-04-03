//
//  AddFamilyViewController.m
//  gleadSmart
//
//  Created by Mac on 2018/11/22.
//  Copyright © 2018 杭州轨物科技有限公司. All rights reserved.
//

#import "AddFamilyViewController.h"
#import "AddFamilyTextCell.h"
#import "AddFamilySelectCell.h"
#import "FamilyLocationController.h"

NSString *const CellIdentifier_addFamilyText = @"addFamilyText";
NSString *const CellIdentifier_addFaminlySelect = @"CellID_addFaminlySelect";

@interface AddFamilyViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *addFamilyTable;
@property (strong, nonatomic) NSArray *defaultRoomList;
@property (strong, nonatomic) UIButton *addRoomButton;

@end

@implementation AddFamilyViewController{
    NSString *name;
    NSNumber *lon;
    NSNumber *lat;
    NSMutableArray *checkedRoomArray;
}

- (instancetype)init{
    if (self) {
        self->checkedRoomArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor;
    [self setNavItem];
    
    self.defaultRoomList = [self defaultRoomList];
    self.addFamilyTable = [self addFamilyTable];
    self.addRoomButton = [self addRoomButton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - Lazyload
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加家庭");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(completeAddFamily) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}

-(NSArray *)defaultRoomList{
    if (!_defaultRoomList) {
        _defaultRoomList = @[@"主卧",@"次卧",@"客厅",@"餐厅",@"厨房",@"书房"];
        [checkedRoomArray addObjectsFromArray:_defaultRoomList];
    }
    return _defaultRoomList;
}

- (UITableView *)addFamilyTable{
    if (!_addFamilyTable) {
        _addFamilyTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 100.f) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[AddFamilyTextCell class] forCellReuseIdentifier:CellIdentifier_addFamilyText];
            [tableView registerClass:[AddFamilySelectCell class] forCellReuseIdentifier:CellIdentifier_addFaminlySelect];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _addFamilyTable;
}

- (UIButton *)addRoomButton{
    if (!_addRoomButton) {
        _addRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addRoomButton setTitle:LocalString(@"添加其他房间") forState:UIControlStateNormal];
        [_addRoomButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_addRoomButton setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_addRoomButton.layer setBorderWidth:1.0];
        _addRoomButton.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _addRoomButton.layer.cornerRadius = 15.f;
        [_addRoomButton setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_addRoomButton addTarget:self action:@selector(addotherRoom) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_addRoomButton];
        
        [_addRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(276.f), 44.f));
            make.bottom.equalTo(self.view.mas_bottom).offset(56.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _addRoomButton;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 2;
    }
    if (section == 1) {
        return _defaultRoomList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            AddFamilyTextCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_addFamilyText];
            cell.backgroundColor = [UIColor whiteColor];
            if (cell == nil) {
                cell = [[AddFamilyTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_addFamilyText];
            }
            if (indexPath.row == 0) {
                cell.leftLabel.text = LocalString(@"家庭名称");
                cell.inputTF.placeholder = LocalString(@"填写家庭名称");
                cell.TFBlock = ^(NSString *text) {
                    self->name = text;
                };
            }
            if (indexPath.row == 1) {
                cell.leftLabel.text = LocalString(@"家庭位置");
                cell.inputTF.placeholder = LocalString(@"设定地理位置");
                cell.inputTF.userInteractionEnabled = NO;
            }
            return cell;
        }
            break;
            
        case 1:
        {
            AddFamilySelectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_addFaminlySelect];
            if (cell == nil) {
                cell = [[AddFamilySelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_addFaminlySelect];
            }
            cell.backgroundColor = [UIColor clearColor];
            cell.tag = ySelect;
            cell.leftLabel.text = _defaultRoomList[indexPath.row];
            cell.checkImage.image = [UIImage imageNamed:@"addFamily_check"];
            return cell;
        }
            break;
            
        default:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellindetify_addfamilidefaultcell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellindetify_addfamilydefaultcell"];
            }
            return cell;
        }
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        AddFamilySelectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.tag == yUnselect) {
            cell.tag = ySelect;
            cell.checkImage.image = [UIImage imageNamed:@"addFamily_check"];
            [self->checkedRoomArray addObject:cell.leftLabel.text];
        }else{
            cell.tag = yUnselect;
            cell.checkImage.image = [UIImage imageNamed:@"addFamily_uncheck"];
            for (NSString *roomName in self->checkedRoomArray) {
                if ([cell.leftLabel.text isEqualToString:roomName]) {
                    [self->checkedRoomArray removeObject:roomName];
                    break;
                }
            }
        }
    }else{
        if (indexPath.row == 1) {
            FamilyLocationController *locaVC = [[FamilyLocationController alloc] init];
            locaVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            locaVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            locaVC.contentOriginY = 100.f + getRectNavAndStatusHight;
            locaVC.dismissBlock = ^(HouseModel *house) {
                AddFamilyTextCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.inputTF.text = house.location;
                NSLog(@"11111%@",house.location);
                self->lon = house.lon;
                self->lat = house.lat;
            };
            [self presentViewController:locaVC animated:YES completion:nil];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 50.f;
            break;
            
        case 1:
            return 44.f;
            break;

        default:
            return 50.f;
            break;
    }
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 40;
    }
    return 0;//section头部高度
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addFamily_device"]];
    [view addSubview:image];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = LocalString(@"在哪些房间里有智能设备");
    label.font = [UIFont fontWithName:@"Helvetica" size:15];
    label.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    
    [image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16.f, 12.f));
        make.left.equalTo(view.mas_left).offset(20.f);
        make.centerY.equalTo(view.mas_centerY);
    }];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(yAutoFit(250.f), 20.f));
        make.left.equalTo(image.mas_right).offset(5.f);
        make.centerY.equalTo(view.mas_centerY);
    }];
    
    return view ;
}
//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

#pragma mark - Action
- (void)completeAddFamily{
    if (self->checkedRoomArray.count <= 0 || [self->name isKindOfClass:[NSNull class]] || self->lon == NULL || self->lat == NULL) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"请填写正确信息,必须选择房间") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
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

    NSMutableArray *rooms = [[NSMutableArray alloc] init];
    for (int i = 0; i < self->checkedRoomArray.count; i++) {
        NSDictionary *dic = @{@"name":self->checkedRoomArray[i]};
        [rooms addObject:dic];
    }
    NSDictionary *parameters = @{@"name":self->name,@"lon":self->lon,@"lat":self->lat,@"rooms":rooms};
    
    NSString *url = [NSString stringWithFormat:@"%@/api/house",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

    [manager POST:url parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
              NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
              NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
              NSLog(@"success:%@",daetr);
              if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
                  [NSObject showHudTipStr:LocalString(@"成功创建新家庭")];
                  
                  
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHouseList" object:nil userInfo:nil];
                  [self.navigationController popToRootViewControllerAnimated:YES];
              }else{
                  [NSObject showHudTipStr:LocalString(@"创建新家庭失败")];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//              NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//
//              NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
//
//              NSLog(@"error--%@",serializedData);
              NSLog(@"%@",error);
              
              if (error.code == -1001) {
                  [NSObject showHudTipStr:LocalString(@"当前网络状况不佳")];
              }else{
                  [NSObject showHudTipStr:LocalString(@"创建新家庭失败")];
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [SVProgressHUD dismiss];
              });
          }
     ];
}
- (void)addotherRoom{
    NSLog(@"ss");
}
@end
