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
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:12.f]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(editedBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    self.navigationItem.title = LocalString(@"房间管理");
    self.homeManagementTable = [self homeManagementTable];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    
}
#pragma mark - Lazy Load
-(UITableView *)homeManagementTable{
    if (!_homeManagementTable) {
        _homeManagementTable = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,300) style:UITableViewStylePlain];
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
            
            _addShareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_addShareBtn setTitle:LocalString(@"添加共享") forState:UIControlStateNormal];
            [_addShareBtn setTitleColor:[UIColor cyanColor ] forState:UIControlStateNormal];
            [_addShareBtn.titleLabel setFont:[UIFont systemFontOfSize:15.f]];
            [_addShareBtn setTitleColor:[UIColor colorWithHexString:@"4778CC"] forState:UIControlStateNormal];
            [_addShareBtn.layer setBorderWidth:1.0];
            _addShareBtn.layer.borderColor = [UIColor colorWithRed:99/255.0 green:157/255.0 blue:248/255.0 alpha:1].CGColor;
             _addShareBtn.layer.cornerRadius = 15.f;
            [_addShareBtn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1]];
            [_addShareBtn addTarget:self action:@selector(goshare) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:_addShareBtn];
            [_addShareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(tableView.mas_bottom).offset(100);
                make.left.equalTo(self.view.mas_left).offset(46);
                make.right.equalTo(self.view.mas_right).offset(-46);
            }];
            
            tableView;
        });
    }
    return _homeManagementTable;
}

#pragma mark - UITableView delegate&datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_HomeManagementTable];
    if (cell == nil) {
        cell = [[HomeManagementCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_HomeManagementTable];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row) {
        case 0:
        {
            cell.leftLabel.text = LocalString(@"客厅");
        }
            break;
        case 1:
        {
            cell.leftLabel.text = LocalString(@"主卧");
        }
            break;
        case 2:
        {
            cell.leftLabel.text = LocalString(@"次卧");
        }
            break;
        case 3:
        {
            cell.leftLabel.text = LocalString(@"餐厅");
        }
            break;
        case 4:
        {
            cell.leftLabel.text = LocalString(@"厨房");
        }
            break;
        case 5:
        {
            cell.leftLabel.text = LocalString(@"书房");
        }
            break;
        default:
            break;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return Cell_Height;
}

-(void)goshare{
    NSLog(@"dd");
}
-(void)editedBtn{
    NSLog(@"rr");
    
}

@end
