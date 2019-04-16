//
//  AddMemberController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/1/16.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "AddMemberController.h"
#import "AreaCodeCell.h"
#import "MemberAccountCell.h"
#import "ManagerSetCell.h"

NSString *const CellIdentifier_AddMemberAreaCode = @"CellID_AddMemberAreaCode";
NSString *const CellIdentifier_AddMemberAccount = @"CellID_AddMemberAccount";
NSString *const CellIdentifier_AddMemberManagerSet = @"CellID_AddMemberManagerSer";

@interface AddMemberController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *addMemberTable;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation AddMemberController{
    NSString *mobile;
    NSNumber *isManager;
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    
    [self setNavItem];
    self.addMemberTable = [self addMemberTable];
    
    isManager = @1;//默认设置为非管理员
}

#pragma mark - private methods
- (void)memberAdd{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/house/member",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"houseUid":self.houseUid,@"mobile":self->mobile,@"auth":isManager};
    
    [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            if (self.popBlock) {
                self.popBlock();
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [NSObject showHudTipStr:@"添加成员失败"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"添加成员失败"];
        });
    }];
}

#pragma mark - setters and getters
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加成员");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setTitle:@"添加" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(memberAdd) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}

- (UITableView *)addMemberTable{
    if (!_addMemberTable) {
        _addMemberTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 100) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            [tableView registerClass:[AreaCodeCell class] forCellReuseIdentifier:CellIdentifier_AddMemberAreaCode];
            [tableView registerClass:[MemberAccountCell class] forCellReuseIdentifier:CellIdentifier_AddMemberAccount];
            [tableView registerClass:[ManagerSetCell class] forCellReuseIdentifier:CellIdentifier_AddMemberManagerSet];
            tableView.dataSource = self;
            tableView.delegate = self;
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [self tableFooterView];
            tableView;
        });
    }
    return _addMemberTable;
}

- (UIView *)tableFooterView{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, ScreenWidth, 100.f);
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20.f, 5.f, ScreenWidth - 40.f, 90.f);
    label.font = [UIFont systemFontOfSize:14.f];
    label.text = LocalString(@"添加后，即可用该手机号注册的账号登录家庭。家庭管理员具备所有操作权限，包括移除整个家庭。普通成员只可以操作设备和场景，不能添加和移除。");
    label.textColor = [UIColor colorWithHexString:@"7A7A79"];
    label.numberOfLines = 0;
    [view addSubview:label];
    
    return view;
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
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                AreaCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_AddMemberAreaCode];
                if (cell == nil) {
                    cell = [[AreaCodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_AddMemberAreaCode];
                }
                cell.leftLabel.text = LocalString(@"国家/地区");
                cell.areaCodeLabel.text = LocalString(@"中国 +86");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }else{
                MemberAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_AddMemberAccount];
                if (cell == nil) {
                    cell = [[MemberAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_AddMemberAccount];
                }
                cell.leftLabel.text = LocalString(@"帐号");
                cell.accountLabel.placeholder = LocalString(@"输入手机号/邮箱");
                cell.TFBlock = ^(NSString *text) {
                    self->mobile = text;
                };
                return cell;
            }
        }
            break;
            
        case 1:
        {
            ManagerSetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_AddMemberManagerSet];
            if (cell == nil) {
                cell = [[ManagerSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_AddMemberManagerSet];
            }
            cell.leftLabel.text = LocalString(@"设为管理员");
            cell.switchBlock = ^(BOOL isOn) {
                if (isOn) {
                    self->isManager = @0;
                }else{
                    self->isManager = @1;
                }
            };
            return cell;
        }
            break;
            
        default:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellindetify_addmemberdefaultcell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellindetify_addmemberdefaultcell"];
            }
            return cell;
        }
            break;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                
            }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.f;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0.f;
            break;
            
        case 1:
            return 10.f;
            break;
            
        default:
            return 0.f;
            break;
    }
}

//section头部视图
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    
    return view ;
}
//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.f;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
@end
