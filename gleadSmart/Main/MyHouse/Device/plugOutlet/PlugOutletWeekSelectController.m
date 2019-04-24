//
//  PlugOutletWeekSeletController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/4/18.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "PlugOutletWeekSelectController.h"
#import "PlugOutletWeekSelectCell.h"
#import "ClockModel.h"

static float HEIGHT_HEADER = 20.f;
NSString *const CellIdentifier_PlugOutletWeekSelectCell = @"CellID_PlugOutletWeekSelect";

@interface PlugOutletWeekSelectController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *addWeekTable;
@property (strong, nonatomic) NSArray *defaultWeekList;


@end

@implementation PlugOutletWeekSelectController

- (instancetype)init{
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1].CGColor;
    
    self.defaultWeekList = [self defaultWeekList];
    self.addWeekTable = [self addWeekTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didMoveToParentViewController:(UIViewController *)parent{
    [super didMoveToParentViewController:parent];
    if (self.popBlock && !parent) {
        self.popBlock(self.clock);
    }
}

#pragma mark - Lazyload
- (NSArray *)defaultWeekList{
    if (!_defaultWeekList) {
        _defaultWeekList = @[@"周日",@"周一",@"周二",@"周三",@"周四",@"周五",@"周六"];
    }
    return _defaultWeekList;
}

- (UITableView *)addWeekTable{
    if (!_addWeekTable) {
        _addWeekTable = ({
            TouchTableView *tableView = [[TouchTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - getRectNavAndStatusHight) style:UITableViewStylePlain];
            tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
            tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
            tableView.dataSource = self;
            tableView.delegate = self;
            [tableView registerClass:[PlugOutletWeekSelectCell class] forCellReuseIdentifier:CellIdentifier_PlugOutletWeekSelectCell];
            [self.view addSubview:tableView];
            tableView.scrollEnabled = NO;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.tableFooterView = [[UIView alloc] init];
            tableView;
        });
    }
    return _addWeekTable;
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _defaultWeekList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PlugOutletWeekSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_PlugOutletWeekSelectCell];
    if (cell == nil) {
        cell = [[PlugOutletWeekSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_PlugOutletWeekSelectCell];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.leftLabel.text = _defaultWeekList[indexPath.row];
    if (self.clock.week & (0x40 >> indexPath.row)) {
        cell.tag = ySelect;
        cell.checkImage.image = [UIImage imageNamed:@"addFamily_check"];
    }else{
        cell.tag = yUnselect;
        cell.checkImage.image = [UIImage imageNamed:@"addFamily_uncheck"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PlugOutletWeekSelectCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag == yUnselect) {
        cell.tag = ySelect;
        cell.checkImage.image = [UIImage imageNamed:@"addFamily_check"];
        [self.clock setMyWeek:self.clock.week | (0x40 >> indexPath.row)];
    }else{
        cell.tag = yUnselect;
        cell.checkImage.image = [UIImage imageNamed:@"addFamily_uncheck"];
        [self.clock setMyWeek:self.clock.week & ~(0x40 >> indexPath.row)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 41.f;
}

//section头部间距
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEIGHT_HEADER;
}

@end
