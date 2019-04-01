//
//  AddDeviceShareController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/1.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "AddDeviceShareController.h"
#import "AreaCodeCell.h"
#import "MemberAccountCell.h"

NSString *const CellIdentifier_DeviceSharerInputAreaCode = @"CellID_DeviceSharerInputAreaCode";
NSString *const CellIdentifier_DeviceSharerInputAccount = @"CellID_DeviceSharerInputAccount";

@interface AddDeviceShareController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *deviceSharerTable;

@end

@implementation AddDeviceShareController{
    NSString *mobile;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    
    [self setNavItem];
    self.deviceSharerTable = [self deviceSharerTable];
}

#pragma mark - private methods
- (void)addSharer{
    if (!([self->mobile isKindOfClass:[NSString class]] && self->mobile.length > 0)) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"错误") message:LocalString(@"请输入手机号码") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
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
    
    NSString *url = [NSString stringWithFormat:@"%@/api/share",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSMutableArray *deviceDicArr = [[NSMutableArray alloc] init];
    NSDictionary *dic = @{@"mac":self.device.mac,@"type":self.device.type};
    [deviceDicArr addObject:dic];
    NSDictionary *parameters = @{@"houseUid":db.currentHouse.houseUid,@"mobile":self->mobile,@"ownerUid":db.user.userId,@"deviceList":deviceDicArr};
    NSLog(@"%@",parameters);
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [NSObject showHudTipStr:@"添加共享失败"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"添加共享失败"];
        });
    }];
    
}

#pragma mark - setters and getters
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加共享");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(addSharer) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}

- (UITableView *)deviceSharerTable{
    if (!_deviceSharerTable) {
        _deviceSharerTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            [tableView registerClass:[AreaCodeCell class] forCellReuseIdentifier:CellIdentifier_DeviceSharerInputAreaCode];
            [tableView registerClass:[MemberAccountCell class] forCellReuseIdentifier:CellIdentifier_DeviceSharerInputAccount];
            tableView.dataSource = self;
            tableView.delegate = self;
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _deviceSharerTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        AreaCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_DeviceSharerInputAreaCode];
        if (cell == nil) {
            cell = [[AreaCodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_DeviceSharerInputAreaCode];
        }
        cell.leftLabel.text = LocalString(@"国家/地区");
        cell.areaCodeLabel.text = LocalString(@"中国 +86");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }else{
        MemberAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_DeviceSharerInputAccount];
        if (cell == nil) {
            cell = [[MemberAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_DeviceSharerInputAccount];
        }
        cell.leftLabel.text = LocalString(@"帐号");
        cell.accountLabel.placeholder = LocalString(@"输入手机号/邮箱");
        cell.TFBlock = ^(NSString *text) {
            self->mobile = text;
        };
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}

@end
