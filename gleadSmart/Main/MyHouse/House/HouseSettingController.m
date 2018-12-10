//
//  HouseSettingController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2018/11/27.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "HouseSettingController.h"
#import "HouseSetCommonCell.h"
#import "HouseSetMemberCell.h"

NSString *const CellIdentifier_HouseSetCommon = @"CellID_HouseSetCommon";
NSString *const CellIdentifier_HouseSetMember = @"CellID_HouseSetMember";

@interface HouseSettingController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *houseSettingTable;
@property (strong, nonatomic) UIButton *removeHouseButton;

@end

@implementation HouseSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
    
    self.houseSettingTable = [self houseSettingTable];
    self.removeHouseButton = [self removeHouseButton];
}

#pragma mark - Lazy load
- (UITableView *)houseSettingTable{
    if (!_houseSettingTable) {
        _houseSettingTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight - 100) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[HouseSetCommonCell class] forCellReuseIdentifier:CellIdentifier_HouseSetCommon];
            [tableView registerClass:[HouseSetMemberCell class] forCellReuseIdentifier:CellIdentifier_HouseSetMember];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _houseSettingTable;
}

- (UIButton *)removeHouseButton{
    if (!_removeHouseButton) {
        _removeHouseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_removeHouseButton setTitle:LocalString(@"移除家庭") forState:UIControlStateNormal];
        [_removeHouseButton.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
        [_removeHouseButton setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
        [_removeHouseButton.layer setBorderWidth:1.0];
        _removeHouseButton.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
        _removeHouseButton.layer.cornerRadius = 15.f;
        [_removeHouseButton setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
        [_removeHouseButton addTarget:self action:@selector(removeHouse) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_removeHouseButton];
        
        [_removeHouseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(276.f), 44.f));
            make.bottom.equalTo(self.view.mas_bottom).offset(56.f);
            make.centerX.equalTo(self.view.mas_centerX);
        }];
    }
    return _removeHouseButton;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0){
        return 3;
    }
    if (section == 1) {
        return 1;
    }
    if (section == 2) {
        return self.house.members.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            HouseSetCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseSetCommon];
            if (cell == nil) {
                cell = [[HouseSetCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseSetCommon];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.leftLabel.text = LocalString(@"家庭名称");
                cell.rightLabel.text = _house.name;
            }
            if (indexPath.row == 1) {
                cell.leftLabel.text = LocalString(@"家庭管理");
                cell.rightLabel.text = [NSString stringWithFormat:@"%@%@",_house.roomNumber,LocalString(@"个房间")];
            }
            if (indexPath.row == 2) {
                cell.leftLabel.text = LocalString(@"家庭位置");
            }
            
            return cell;
        }
            break;
            
        case 1:
        {
            HouseSetCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseSetCommon];
            if (cell == nil) {
                cell = [[HouseSetCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseSetCommon];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.leftLabel.text = LocalString(@"设备共享");
            return cell;
        }
            break;
            
        case 2:
        {
            HouseSetMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HouseSetMember];
            if (cell == nil) {
                cell = [[HouseSetMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HouseSetMember];
            }
            MemberModel *member = _house.members[indexPath.row];
            cell.memberName.text = member.name;
            cell.mobile.text = member.mobile;
            if ([member.auth intValue] == 0) {
                cell.identity.text = LocalString(@"管理员");
            }else{
                cell.identity.text = LocalString(@"成员");
            }
            return cell;
        }
            break;
            
        default:
        {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellindetify_houseSetdefaultcell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellindetify_houseSetdefaultcell"];
            }
            return cell;
        }
            break;
    }
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
    switch (section) {
        case 0:
            return 0.f;
            break;
            
        case 1:
            return 20.f;
            break;
            
        case 2:
            return 40.f;
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
    
    if (section == 2) {
        UILabel *label = [[UILabel alloc] init];
        label.text = LocalString(@"家庭成员");
        label.font = [UIFont fontWithName:@"Helvetica" size:17];
        label.textColor = [UIColor colorWithHexString:@"7C7C7B"];
        label.textAlignment = NSTextAlignmentLeft;
        [view addSubview:label];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(250.f), 20.f));
            make.left.equalTo(view.mas_left).offset(20.f);
            make.centerY.equalTo(view.mas_centerY);
        }];
    }
    
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


#pragma mark - Actions
- (void)removeHouse{
    
}

@end
