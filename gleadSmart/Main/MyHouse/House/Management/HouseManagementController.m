//
//  HouseManagementController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/16.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HouseManagementController.h"
#import "HouseManagementTableViewCell.h"
#import "AddFamilyViewController.h"
#import "HouseNameCell.h"
#import "HouseSettingController.h"

NSString *const CellIdentifier_HouseManagement = @"CellID_HouseManagement";
NSString *const CellIdentifier_HouseManagementAdd = @"CellID_HouseManagementAdd";

static CGFloat const Cell_Height = 50.f;
static CGFloat const Header_Height = 25.f;

@interface HouseManagementController () <UITableViewDataSource,UITableViewDelegate>

#warning TODO 完成家庭管理UI
@property (nonatomic, strong) UITableView *HouseManagement;

@end

@implementation HouseManagementController

-(instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1].CGColor;
    
    self.navigationItem.title = LocalString(@"家庭管理");
    
    self.HouseManagement = [self HouseManagement];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.HouseManagement reloadData];
}

- (void)didMoveToParentViewController:(UIViewController *)parent{
    [super didMoveToParentViewController:parent];
    Database *data = [Database shareInstance];
    Network *net = [Network shareNetwork];
    if (data.currentHouse) {
        BOOL isDelete = YES;//判断当前家庭是否被移除了
        //更新家庭信息，避免家庭设置中修改了家庭信息而主页面未改变
        for (HouseModel *house in data.houseList) {
            if ([data.currentHouse.houseUid isEqualToString:house.houseUid]) {
                data.currentHouse = house;
                isDelete = NO;
            }
        }
        if (isDelete) {
            //当前家庭被移除了，换成第一个家庭
            HouseModel *house = data.houseList[0];
            data.currentHouse = house;
            [data.shareDeviceArray removeAllObjects];
            [net.deviceArray removeAllObjects];
            if (net.mySocket.isConnected) {
                [net.mySocket disconnect];
            }
        }
    }
    if (self.popBlock && !parent) {
        self.popBlock();
    }
}

#pragma mark - Lazy Load
-(UITableView *)HouseManagement{
    if (!_HouseManagement) {
        _HouseManagement = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,ScreenHeight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            tableView.separatorColor = [UIColor clearColor];
            [tableView registerClass:[HouseNameCell class] forCellReuseIdentifier:CellIdentifier_HouseManagement];
            [tableView registerClass:[HouseManagementTableViewCell class] forCellReuseIdentifier:CellIdentifier_HouseManagementAdd];
            [self.view addSubview:tableView];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = NO;
            tableView;
        });
    }
    return _HouseManagement;
}
#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        {
            return [Database shareInstance].houseList.count;
        }
            break;
            
        case 1:
        {
            return 1;
        }
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            HouseNameCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseManagement];
            if (cell == nil) {
                cell = [[HouseNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseManagement];
            }
            HouseModel *house = [Database shareInstance].houseList[indexPath.row];
            cell.houseName.text = house.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
            break;
            
        case 1:
        {
            HouseManagementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseManagementAdd];
            if (cell == nil) {
                cell = [[HouseManagementTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseManagementAdd];
            }
            return cell;
        }
            break;
            
        default:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseManagement];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseManagement];
            }
            return cell;
        }
          break;
      }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        AddFamilyViewController *addVC = [[AddFamilyViewController alloc] init];
        [self.navigationController pushViewController:addVC animated:YES];
    }else if (indexPath.section == 0){
        HouseModel *house = [Database shareInstance].houseList[indexPath.row];
        [self updateHouseDetailInfoWith:house.houseUid];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return Cell_Height;
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    
    return view ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10.f;
    }else if (section == 1){
        return Header_Height;
    }
    return 0;
}

#pragma mark - Actions
/*
 *用在设置页面获取家庭详细信息
 */
- (void)updateHouseDetailInfoWith:(NSString *)houseUid{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    Database *db = [Database shareInstance];

    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];

    NSString *url = [NSString stringWithFormat:@"%@/api/house?houseUid=%@",httpIpAddress,houseUid];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0 && [responseDic objectForKey:@"data"]) {
            NSDictionary *dic = [responseDic objectForKey:@"data"];
            HouseModel *house = [[HouseModel alloc] init];
            house.houseUid = houseUid;
            house.name = [dic objectForKey:@"name"];
            house.roomNumber = [dic objectForKey:@"roomNumber"];
            house.lon = [dic objectForKey:@"lon"];
            house.lat = [dic objectForKey:@"lat"];
            NSMutableArray *members = [[NSMutableArray alloc] init];
            if ([[dic objectForKey:@"members"] count] > 0) {
                [[dic objectForKey:@"members"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MemberModel *member = [[MemberModel alloc] init];
                    member.name = [obj objectForKey:@"name"];
                    member.mobile = [obj objectForKey:@"mobile"];
                    member.auth = [obj objectForKey:@"auth"];
                    if ([member.mobile isEqualToString:db.user.mobile]) {
                        house.auth = member.auth;//当前用户在该家庭的权限
                    }
                    [members addObject:member];
                }];
                house.members = [members copy];
            }
            HouseSettingController *setVC = [[HouseSettingController alloc] init];
            setVC.house = house;
            [self.navigationController pushViewController:setVC animated:YES];
        }else{
            [NSObject showHudTipStr:LocalString(@"获取家庭详细信息失败")];
        }
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"从服务器获取信息失败,请检查网络状况"];
        });
    }];
}



@end
