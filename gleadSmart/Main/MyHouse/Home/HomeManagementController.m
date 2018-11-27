//
//  HomeManagementController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HomeManagementController.h"
#import "HomeManagementCell.h"

NSString *const CellIdentifier_HomeManagementTable = @"CellID_HomeManagementTable";
static CGFloat const Cell_Height = 50.f;

@interface HomeManagementController () <UITableViewDataSource,UITableViewDelegate>

#warning TODO 完成房间管理列表UI
@property (strong, nonatomic) UITableView *homeManagementTable;
@property (strong, nonatomic) UIButton *addShareBtn;

@end

@implementation HomeManagementController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setTitle:@"编辑" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(editedBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.navigationItem.title = LocalString(@"房间管理");
    self.homeManagementTable = [self homeManagementTable];
    self.addShareBtn = [self addShareBtn];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
}
#pragma mark - Lazy Load
-(UITableView *)homeManagementTable{
    if (!_homeManagementTable) {
        _homeManagementTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeight - getRectNavAndStatusHight - 100.f) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor whiteColor];
            [tableView registerClass:[HomeManagementCell class] forCellReuseIdentifier:CellIdentifier_HomeManagementTable];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = NO;
            
            tableView;
        });
    }
    return _homeManagementTable;
}

- (UIButton *)addShareBtn{
    if (!_addShareBtn) {
        _addShareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addShareBtn setTitle:LocalString(@"添加共享") forState:UIControlStateNormal];
        [_addShareBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_addShareBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_addShareBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_addShareBtn.layer setBorderWidth:1.0];
        _addShareBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _addShareBtn.layer.cornerRadius = 20.f;
        [_addShareBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_addShareBtn addTarget:self action:@selector(goshare) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_addShareBtn];
        [_addShareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), 40.f));
            make.bottom.equalTo(self.view.mas_bottom).offset(-60);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _addShareBtn;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _homeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeManagementTable];
    if (cell == nil) {
        cell = [[HomeManagementCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeManagementTable];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    RoomModel *room = _homeList[indexPath.row];
    cell.leftLabel.text = room.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

#pragma mark - Actions
/*
 *用于更新房间列表，现在不需要用到
 */
//- (void)updateHomeList{
//    [SVProgressHUD show];
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//    Database *db = [Database shareInstance];
//    
//    //设置超时时间
//    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
//    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//    
//    NSString *url = [NSString stringWithFormat:@"http://gleadsmart.thingcom.cn/api/room/list?houseUid=%@",db.currentHouse.houseUid];
//    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
//    
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
//    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
//        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
//        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"success:%@",daetr);
//        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
//            if ([responseDic objectForKey:@"data"]) {
//                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    RoomModel *room = [[RoomModel alloc] init];
//                    room.name = [obj objectForKey:@"name"];
//                    room.roomUid = [obj objectForKey:@"roomUid"];
//                    room.deviceNumber = [obj objectForKey:@"deviceNumber"];
//                    [self.homeList addObject:room];
//                    
//                    [db insertNewRoom:room];
//                }];
//            }
//        }else{
//            [NSObject showHudTipStr:LocalString(@"获取家庭房间列表失败")];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//        
//        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
//        
//        NSLog(@"error--%@",serializedData);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//            [NSObject showHudTipStr:@"从服务器获取信息失败"];
//        });
//    }];
//}

-(void)goshare{
    NSLog(@"dd");
}
-(void)editedBtn{
    NSLog(@"rr");
    
}

@end
