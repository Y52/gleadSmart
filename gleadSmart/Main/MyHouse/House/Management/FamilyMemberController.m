//
//  FamilyMemberController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/15.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "FamilyMemberController.h"
#import "FamilyMemberInfoCell.h"
#import "FamilyMemberSetCell.h"

NSString *const CellIdentifier_FamilyMemberInfo = @"CellID_FamilyMemberInfo";
NSString *const CellIdentifier_FamilyMemberSet = @"CellID_FamilyMemberSet";

@interface FamilyMemberController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *familyMemberTable;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *removeButton;

@end

@implementation FamilyMemberController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    
    [self setNavItem];
    self.familyMemberTable = [self familyMemberTable];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.popBlock) {
        self.popBlock();
    }
}

#pragma mark - private methods
- (void)setUpFamilyMemberAuth:(BOOL)isManager{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/house/member/auth",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"mobile":self.member.mobile,@"houseUid":self.house.houseUid,@"auth":[NSNumber numberWithInt:(int)!isManager]};
    
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            if (isManager) {
                self.removeButton.hidden = YES;//是管理员时隐藏移除按钮
            }else{
                self.removeButton.hidden = NO;
            }
        }else{
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"修改成员权限失败"];
        });
    }];
}

- (void)removeMember{
    YAlertViewController *alert = [[YAlertViewController alloc] init];
    alert.lBlock = ^{
        
    };
    alert.rBlock = ^{
        [self removeMemberHttpDelMethod];
    };
    alert.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:alert animated:NO completion:^{
        [alert showView];
        alert.titleLabel.text = LocalString(@"提示");
        alert.messageLabel.text = LocalString(@"确定移除该成员吗？");
        [alert.leftBtn setTitle:LocalString(@"取消") forState:UIControlStateNormal];
        [alert.rightBtn setTitle:LocalString(@"确认") forState:UIControlStateNormal];
    }];
}

- (void)removeMemberHttpDelMethod{
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
    
    NSDictionary *parameters = @{@"houseUid":self.house.houseUid,@"mobile":self.member.mobile};
    
    NSString *url = [NSString stringWithFormat:@"%@/api/house/member",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];

    [manager DELETE:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData *data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString *daetr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [NSObject showHudTipStr:[NSString stringWithFormat:@"%@",[responseDic objectForKey:@"error"]]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            [NSObject showHudTipStr:@"移除成员失败"];
        });
    }];
}

#pragma mark - setters and getters
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"添加成员");
}

- (UITableView *)familyMemberTable{
    if (!_familyMemberTable) {
        _familyMemberTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 100) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            [tableView registerClass:[FamilyMemberInfoCell class] forCellReuseIdentifier:CellIdentifier_FamilyMemberInfo];
            [tableView registerClass:[FamilyMemberSetCell class] forCellReuseIdentifier:CellIdentifier_FamilyMemberSet];
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
    return _familyMemberTable;
}

- (UIView *)tableFooterView{
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, ScreenWidth, 200.f);
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20.f, 5.f, ScreenWidth - 40.f, 90.f);
    label.font = [UIFont systemFontOfSize:14.f];
    label.text = LocalString(@"管理员具备所有权限，可以添加和删除设备、智能场景，也可以添加和移除其他成员，以及移除整个家庭。");
    label.textColor = [UIColor colorWithHexString:@"7A7A79"];
    label.numberOfLines = 0;
    [view addSubview:label];
    
    _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_removeButton setTitle:LocalString(@"移除成员") forState:UIControlStateNormal];
    [_removeButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
    [_removeButton setTitleColor:[UIColor colorWithHexString:@"3987F8"] forState:UIControlStateNormal];
    [_removeButton.layer setBorderWidth:1.0];
    _removeButton.layer.borderColor = [UIColor colorWithRed:57/255.0 green:135/255.0 blue:248/255.0 alpha:1.0].CGColor;
    _removeButton.layer.cornerRadius = 20.f;
    [_removeButton setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
    [_removeButton addTarget:self action:@selector(removeMember) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_removeButton];
    [_removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(yAutoFit(284.f), 40.f));
        make.top.equalTo(label.mas_bottom).offset(30.f);
        make.centerX.equalTo(view.mas_centerX);
    }];
    if ([self.house.auth integerValue] == 0 && [self.member.auth integerValue] != 0) {
        _removeButton.hidden = NO;
    }else{
        _removeButton.hidden = YES;
    }
    
    return view;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 1;
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
            FamilyMemberInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_FamilyMemberInfo];
            if (cell == nil) {
                cell = [[FamilyMemberInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_FamilyMemberInfo];
            }
            cell.memberImage.image = [UIImage imageNamed:@"img_account_header"];
            cell.memberName.text = self.member.name;
            cell.mobile.text = self.member.mobile;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
            break;
            
        case 1:
        {
            FamilyMemberSetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_FamilyMemberSet];
            if (cell == nil) {
                cell = [[FamilyMemberSetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_FamilyMemberSet];
            }
            cell.leftLabel.text = LocalString(@"设为家庭管理员");
            if ([self.house.auth integerValue] == 0) {
                cell.controlSwitch.enabled = YES;
            }else{
                cell.controlSwitch.enabled = NO;
            }
            cell.controlSwitch.on = ![self.member.auth boolValue];//0是管理员，1是普通
            cell.switchBlock = ^(BOOL isOn) {
                [self setUpFamilyMemberAuth:isOn];
            };
            return cell;
        }
            break;
            
        default:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellindetify_familymemberdefaultcell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellindetify_familymemberdefaultcell"];
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
            return 10.f;
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
