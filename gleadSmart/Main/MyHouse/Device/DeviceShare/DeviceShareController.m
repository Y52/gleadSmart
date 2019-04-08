//
//  DeviceShareController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/1.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "DeviceShareController.h"
#import "UILabel+YBAttributeTextTapAction.h"
#import "SharerInfoCell.h"
#import "AddDeviceShareController.h"

NSString *const CellIdentifier_DeviceShare = @"CellIdentifier_DeviceShare";

@interface DeviceShareController () <YBAttributeTapActionDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *noShareImageView;
@property (nonatomic, strong) UIButton *addSharerButton;
@property (nonatomic, strong) UITableView *sharerTable;

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) NSMutableArray *sharerList;

@end

@implementation DeviceShareController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    self.navigationItem.title = LocalString(@"设备共享");
    
    self.noShareImageView = [self noShareImageView];
    self.addSharerButton = [self addSharerButton];
    self.sharerTable = [self sharerTable];
    self.tipLabel = [self tipLabel];
    
    [self reloadTableView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getDeviceSharerInfo];
}

#pragma mark - private methods
- (void)reloadTableView{
    if (self.sharerList.count > 0) {
        self.sharerTable.hidden = NO;
        [self.sharerTable reloadData];
    }else{
        self.sharerTable.hidden = YES;
    }
}

//添加共享
- (void)addSharer{
    AddDeviceShareController *addVC = [[AddDeviceShareController alloc] init];
    addVC.device = self.device;
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)getDeviceSharerInfo{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/share/device/sharer?mac=%@&houseUid=%@",httpIpAddress,self.device.mac,db.currentHouse.houseUid];
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
            if (!self.sharerList) {
                self.sharerList = [[NSMutableArray alloc] init];
            }
            [self.sharerList removeAllObjects];
            if ([[responseDic objectForKey:@"data"] isKindOfClass:[NSArray class]] && [[responseDic objectForKey:@"data"] count] > 0) {
                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (![obj isKindOfClass:[NSNull class]]) {
                        SharerModel *sharer = [[SharerModel alloc] init];
                        sharer.name = [obj objectForKey:@"name"];
                        sharer.sharerUid = [obj objectForKey:@"sharerUid"];
                        sharer.mobile = [obj objectForKey:@"mobile"];
                        [self.sharerList addObject:sharer];
                    }
                }];
                [self reloadTableView];
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
            [NSObject showHudTipStr:@"获取分享者列表失败"];
        });
    }];
}

- (void)removeSharerHttpDelMethod:(NSString *)sharerUid success:(void(^)(void))success failure:(void(^)(void))failure{
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
    NSDictionary *parameters = @{@"shareUid":sharerUid,@"mac":self.device.mac};
    
    NSString *url = [NSString stringWithFormat:@"%@/api/share/device/sharer",httpIpAddress];
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
            [NSObject showHudTipStr:@"移除分享失败"];
        });
    }];
}

#pragma mark - YBAttributeTapActionDelegate
- (void)yb_tapAttributeInLabel:(UILabel *)label string:(NSString *)string range:(NSRange)range index:(NSInteger)index{
    if (label.tag == 1000) {//点击tiplabel中家庭设置
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - setter and getter
- (UILabel *)tipLabel{
    if (!_tipLabel) {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.frame = CGRectMake(0, 0, ScreenWidth, 46);
        backgroundView.backgroundColor = [UIColor colorWithRed:213/255.0 green:227/255.0 blue:247/255.0 alpha:1.0];
        [self.view addSubview:backgroundView];

        _tipLabel = [[UILabel alloc] init];
        _tipLabel.frame = CGRectMake(24, 0, ScreenWidth - 48, 46);
        _tipLabel.numberOfLines = 0;
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        [backgroundView addSubview:_tipLabel];

        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:LocalString(@"如果是家中常住成员，建议您将他设为家庭成员，共享家中所有设备和智能场景。家庭设置") attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.f],NSForegroundColorAttributeName:[UIColor colorWithRed:124/255.0 green:124/255.0 blue:123/255.0 alpha:1.0]}];

        [string addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0],NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]} range:NSMakeRange(string.length - 4, 4)];

        _tipLabel.attributedText = string;

        _tipLabel.tag = 1000;
        [_tipLabel yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(string.length - 4, 4))] delegate:self];
    }
    return _tipLabel;
}

- (UIImageView *)noShareImageView{
    if (!_noShareImageView) {
        _noShareImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_noSharer"]];
        [self.view addSubview:_noShareImageView];
        
        [_noShareImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(130.f, 130.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.tipLabel.mas_bottom).offset(200.f);
        }];
        
        UILabel *noSharerLabel = [[UILabel alloc] init];
        noSharerLabel.text = LocalString(@"暂无共享，请添加。");
        noSharerLabel.font = [UIFont systemFontOfSize:13.f];
        noSharerLabel.textColor = [UIColor colorWithRed:120/255.0 green:117/255.0 blue:117/255.0 alpha:1.0];
        noSharerLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:noSharerLabel];
        
        [noSharerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(200.f, 20.f));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.noShareImageView.mas_bottom).offset(15.f);
        }];
    }
    return _noShareImageView;
}

- (UIButton *)addSharerButton{
    if (!_addSharerButton) {
        _addSharerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addSharerButton setTitle:LocalString(@"添加共享") forState:UIControlStateNormal];
        [_addSharerButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_addSharerButton setTitleColor:[UIColor colorWithHexString:@"639DF8"] forState:UIControlStateNormal];
        [_addSharerButton.layer setBorderWidth:1.0];
        _addSharerButton.layer.borderColor = [UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0].CGColor;
        _addSharerButton.layer.cornerRadius = 20.f;
        [_addSharerButton setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_addSharerButton addTarget:self action:@selector(addSharer) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_addSharerButton];
        [_addSharerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), 40.f));
            make.bottom.equalTo(self.view.mas_bottom).offset(-40.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _addSharerButton;
}

- (UITableView *)sharerTable{
    if (!_sharerTable) {
        _sharerTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 46 + 20, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 46 - 20 - 80.f) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[SharerInfoCell class] forCellReuseIdentifier:CellIdentifier_DeviceShare];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = YES;
            tableView.hidden = YES;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _sharerTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sharerList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SharerInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_DeviceShare];
    if (cell == nil) {
        cell = [[SharerInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_DeviceShare];
    }
    SharerModel *sharer = self.sharerList[indexPath.row];
    cell.sharerName.text = sharer.name;
    cell.mobile.text = sharer.mobile;
    cell.sharerImage.image = [UIImage imageNamed:@"img_account_header"];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28.f;
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = LocalString(@"家中部分设备已共享给这些用户");
    label.font = [UIFont fontWithName:@"Helvetica" size:15];
    label.textColor = [UIColor colorWithHexString:@"7C7C7B"];
    label.textAlignment = NSTextAlignmentLeft;
    [view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(yAutoFit(250.f), 20.f));
        make.left.equalTo(view.mas_left).offset(20.f);
        make.centerY.equalTo(view.mas_centerY);
    }];
    
    return view ;
}
//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SharerModel *sharer = self.sharerList[indexPath.row];
        [self removeSharerHttpDelMethod:sharer.sharerUid success:^{
            [self.sharerList removeObject:sharer];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [NSObject showHudTipStr:LocalString(@"删除成功")];
        } failure:^{
            
        }];
    }
}

@end
