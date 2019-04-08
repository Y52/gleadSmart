//
//  ShareDeviceListController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/27.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

@interface OwnerModel : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *houseUid;
@property (nonatomic, strong) NSString *ownerUid;

@end

@implementation OwnerModel

@end

#import "ShareDeviceListController.h"
#import "ShareDeviceListCell.h"
#import "ShareDeviceDetailController.h"

NSString *const CellIdentifier_ShareDeviceList = @"Cell_ShareDeviceList";
static float HEIGHT_CELL = 50.f;
static float HEIGHT_HEADER = 40.f;

@interface ShareDeviceListController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *deviceListTable;
@property (nonatomic, strong) NSMutableArray *ownerList;


@end

@implementation ShareDeviceListController


#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor;
    self.navigationItem.title = LocalString(@"我收到的共享");
    
    self.deviceListTable = [self deviceListTable];
    [self getHouseSharerInfo];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)didMoveToParentViewController:(UIViewController *)parent{
    [super didMoveToParentViewController:parent];
    if (self.popBlock && !parent) {
        self.popBlock();
    }
}

#pragma mark - private methods
- (void)getHouseSharerInfo{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/share/ownerList",httpIpAddress];
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
            if ([[responseDic objectForKey:@"data"] isKindOfClass:[NSArray class]] && [[responseDic objectForKey:@"data"] count] > 0) {
                if (!self.ownerList) {
                    self.ownerList = [[NSMutableArray alloc] init];
                }
                [self.ownerList removeAllObjects];
                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (![obj isKindOfClass:[NSNull class]]) {
                        OwnerModel *owner = [[OwnerModel alloc] init];
                        owner.name = [obj objectForKey:@"name"];
                        owner.houseUid = [obj objectForKey:@"houseUid"];
                        owner.ownerUid = [obj objectForKey:@"ownerUid"];
                        [self.ownerList addObject:owner];
                    }
                }];
                [self.deviceListTable reloadData];
            }
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"获取共享设备拥有者列表失败"];
        });
    }];
}

- (void)removeSharerHttpDelMethod:(OwnerModel *)owner success:(void(^)(void))success failure:(void(^)(void))failure{
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
    
    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];//不加这句代码，delete方法会把字典以param形式加到url后面，而不是生成一个body，服务器会收不到信息
    
    NSDictionary *parameters = @{@"houseUid":owner.houseUid,@"ownerUid":owner.ownerUid};
    
    NSString *url = [NSString stringWithFormat:@"%@/api/share/house",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager DELETE:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            if (success) {
                success();
            }
        }else{
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            if (failure) {
                failure();
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        if (failure) {
            failure();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"移除共享失败"];
        });
    }];
}

#pragma mark - setters and getters
- (UITableView *)deviceListTable{
    if (!_deviceListTable) {
        _deviceListTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 100.f) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[ShareDeviceListCell class] forCellReuseIdentifier:CellIdentifier_ShareDeviceList];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _deviceListTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    return self.ownerList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ShareDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_ShareDeviceList];
    cell.backgroundColor = [UIColor whiteColor];
    if (cell == nil) {
        cell = [[ShareDeviceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_ShareDeviceList];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    OwnerModel *owner = self.ownerList[indexPath.row];
    cell.leftLabel.text = owner.name;
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
    headerView.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, HEIGHT_HEADER)];
    textLabel.textColor = [UIColor colorWithHexString:@"999999"];
    textLabel.font = [UIFont systemFontOfSize:13.f];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.backgroundColor = [UIColor clearColor];
    [headerView addSubview:textLabel];
    textLabel.text = LocalString(@"您收到的共享设备，对您的家庭成员不可见");
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(ScreenWidth, 13));
        make.centerY.equalTo(headerView.mas_centerY);
        make.centerX.equalTo(headerView.mas_centerX);
    }];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OwnerModel *owner = self.ownerList[indexPath.row];
    ShareDeviceDetailController *ShareDeviceDetailVC = [[ShareDeviceDetailController alloc] init];
    ShareDeviceDetailVC.houseUid = owner.houseUid;
    ShareDeviceDetailVC.ownerName = owner.name;
    [self.navigationController pushViewController:ShareDeviceDetailVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

static bool isDeleted = NO;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        OwnerModel *owner = self.ownerList[indexPath.row];
        [self removeSharerHttpDelMethod:owner success:^{
            [self.ownerList removeObject:owner];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [NSObject showHudTipStr:LocalString(@"删除成功")];
            isDeleted = YES;
        } failure:^{
            
        }];
    }
}

@end
