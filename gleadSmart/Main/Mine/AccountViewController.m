//
//  AccountViewController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/12/6.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "AccountViewController.h"
#import "MineNormalCell.h"
#import "AccountHeaderCell.h"
#import "LogOutCell.h"
#import "RegisterController.h"
#import "AppDelegate.h"
#import "ModifyPasswordViewController.h"
#import "UsernameViewController.h"

NSString *const CellIdentifier_accountHeader = @"CellID_accountHeader";
NSString *const CellIdentifier_accountNormal = @"CellID_accountNormal";
NSString *const CellIdentifier_accountLogout = @"CellID_accountLogout";
static CGFloat const HEIGHT_CELL = 51.f;

@interface AccountViewController ()

@property (strong, nonatomic) UITableView *accountTable;

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    self.navigationItem.title = LocalString(@"我的账号");
    
    self.accountTable = [self accountTable];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.accountTable reloadData];
    
}

#pragma mark - Lazy load
- (UITableView *)accountTable{
    if (!_accountTable) {
        _accountTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight)];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[MineNormalCell class] forCellReuseIdentifier:CellIdentifier_accountNormal];
            [tableView registerClass:[AccountHeaderCell class] forCellReuseIdentifier:CellIdentifier_accountHeader];
            [tableView registerClass:[LogOutCell class] forCellReuseIdentifier:CellIdentifier_accountLogout];
            tableView.separatorColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.08];
            
            [self.view addSubview:tableView];
            
            tableView.scrollEnabled = NO;
            tableView;
        });
    }
    return _accountTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 3;
    }else if (section == 1){
        return 2;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        AccountHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_accountHeader];
        if (cell == nil) {
            cell = [[AccountHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_accountHeader];
        }
        cell.normalLabel.text = LocalString(@"头像");
        cell.normalImage.image = [UIImage imageNamed:@"img_mine_account"];
        cell.rightImage.image = [UIImage imageNamed:@"img_account_header"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    MineNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_accountNormal];
    if (cell == nil) {
        cell = [[MineNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_accountNormal];
    }
    if (indexPath.section == 0){
        if(indexPath.row == 1){
            cell.normalLabel.text = LocalString(@"昵称");
            cell.normalImage.image = [UIImage imageNamed:@"img_mine_houseManage"];
            cell.rightLabel.text = [Database shareInstance].user.userName;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }else{
            cell.normalLabel.text = LocalString(@"账号");
            cell.normalImage.image = [UIImage imageNamed:@"img_mine_wechat"];
            cell.rightLabel.text = [Database shareInstance].user.mobile;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.normalLabel.text = LocalString(@"修改登录密码");
            cell.normalImage.image = [UIImage imageNamed:@"img_mine_editPW"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }else{
            cell.normalLabel.text = LocalString(@"注销账号");
            cell.normalImage.image = [UIImage imageNamed:@"img_mine_logout"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }else{
        LogOutCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_accountLogout];
        if (cell == nil) {
            cell = [[LogOutCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_accountLogout];
        }
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0){
        if (indexPath.row == 1){
            UsernameViewController *UsernameVC = [[UsernameViewController alloc] init];
            [self.navigationController pushViewController:UsernameVC animated:YES];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            ModifyPasswordViewController *modifyPasswordVC = [[ModifyPasswordViewController alloc] init];
            [self.navigationController pushViewController:modifyPasswordVC animated:YES];
        }else if (indexPath.row == 1){
            
        }
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalString(@"退出登录") message:LocalString(@"请再次确认是否退出登录") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"mobile"];
            [userDefaults removeObjectForKey:@"passWord"];
            [userDefaults removeObjectForKey:@"userId"];
            //清除单例
            [Network destroyInstance];
            [Database destroyInstance];
            
            RegisterController *loginVC = [[RegisterController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;

        }];
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}

//section头部间距

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;//section头部高度
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
    return 15;
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

@end
