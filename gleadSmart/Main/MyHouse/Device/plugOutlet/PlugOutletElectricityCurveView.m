//
//  PlugOutletElectricityDetailsController.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/6/17.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "PlugOutletElectricityCurveView.h"
#import "DeviceSettingController.h"
#import <Charts/Charts-Swift.h>

@interface PlugOutletElectricityCurveView () <ChartViewDelegate,IChartAxisValueFormatter>

@property (strong, nonatomic) UIView *electricityBackgroundView;
@property (strong, nonatomic) UIImageView *electricityImage;
@property (strong, nonatomic) UILabel *degreeLabel;

@property (strong, nonatomic) UILabel *rightElectricityLabel;

///@brief 曲线图参数
@property (nonatomic, strong) LineChartView *chartView;

@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, strong) NSMutableArray *valueArray;

@end

@implementation PlugOutletElectricityCurveView

- (instancetype)init{
    self = [super init];
    if (self) {
        if (!self.dateArray) {
            self.dateArray = [[NSMutableArray alloc] init];
        }
        if (!self.valueArray) {
            self.valueArray = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.layer.backgroundColor = [UIColor colorWithHexString:@"EAE9E8"].CGColor;
    [self setNavItem];
    
    self.electricityBackgroundView = [self electricityBackgroundView];
    self.electricityImage = [self electricityImage];
    self.degreeLabel = [self degreeLabel];
    self.rightElectricityLabel = [self rightElectricityLabel];
    self.chartView = [self chartView];
    [self getElectricityCurveData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - private methods

- (void)goSetting{
    DeviceSettingController *VC = [[DeviceSettingController alloc] init];
    VC.device = self.device;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - getters and setters

- (void)setNavItem{
    self.navigationItem.title = LocalString(@"电量详情");
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 30, 30);
    [rightButton setImage:[UIImage imageNamed:@"thermostatMoer"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(goSetting) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UIView *)electricityBackgroundView{
    if (!_electricityBackgroundView) {
        _electricityBackgroundView = [[UIView alloc] init];
        _electricityBackgroundView.backgroundColor = [UIColor colorWithRed:130/255.0 green:181/255.0 blue:244/255.0 alpha:1.0];
        [self.view addSubview:_electricityBackgroundView];
        [_electricityBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, yAutoFit(238.f)));
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(self.view.mas_top).offset(20.f);
            
        }];
    }
    return _electricityBackgroundView;
}

- (UIImageView *)electricityImage{
    if (!_electricityImage) {
        _electricityImage = [[UIImageView alloc] init];
        _electricityImage.image = [UIImage imageNamed:@"currenttemperature"];
        [self.electricityBackgroundView addSubview:_electricityImage];
        [_electricityImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(158.f), yAutoFit(147.f)));
            make.centerX.equalTo(self.electricityBackgroundView.mas_centerX);
            make.centerY.equalTo(self.electricityBackgroundView.mas_centerY).offset(-yAutoFit(15.f));
        }];
    }
    return _electricityImage;
}

- (UILabel *)rightElectricityLabel{
    if (!_rightElectricityLabel) {
        _rightElectricityLabel = [[UILabel alloc] init];
        _rightElectricityLabel.text = [NSString stringWithFormat:@"%@%@",self.month,@"月份电量(度)"];
        _rightElectricityLabel.textAlignment = NSTextAlignmentCenter;
        _rightElectricityLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:254/255.0 alpha:1];
        _rightElectricityLabel.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        [self.electricityBackgroundView addSubview:_rightElectricityLabel];
        [_rightElectricityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(100.f), yAutoFit(13.f)));
            make.top.equalTo(self.electricityBackgroundView.mas_top).offset(yAutoFit(20.f));
            make.right.equalTo(self.electricityBackgroundView.mas_right).offset(-yAutoFit(15.f));
        }];
    }
    return _rightElectricityLabel;
}

- (UILabel *)degreeLabel{
    if (!_degreeLabel) {
        _degreeLabel = [[UILabel alloc] init];
        _degreeLabel.textAlignment = NSTextAlignmentCenter;
        _degreeLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:254/255.0 alpha:1];
        _degreeLabel.font = [UIFont fontWithName:@"Helvetica" size:30.f];
        _degreeLabel.adjustsFontSizeToFitWidth = YES;
        _degreeLabel.text = [NSString stringWithFormat:@"%.2f",[self.monthElectricity floatValue]];
        [self.electricityBackgroundView addSubview:_degreeLabel];
        [_degreeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(yAutoFit(80.f), yAutoFit(30.f)));
            make.centerX.equalTo(self.electricityImage.mas_centerX);
            make.centerY.equalTo(self.electricityImage.mas_centerY);
        }];
    }
    return _degreeLabel;
}

#pragma mark - lazy load
- (LineChartView *)chartView{
    if (!_chartView) {
        _chartView = [[LineChartView alloc] init];
        
        //_chartView.frame = CGRectMake(yAutoFit(45+44)), yAutoFit(45+44), ScreenHeight - 87  - 44, ScreenWidth - 100);
        
        [self.view addSubview:_chartView];
        
        [_chartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, yAutoFit(ScreenHeight - 350)));
            make.centerX.equalTo(self.electricityImage.mas_centerX);
            make.top.equalTo(self.electricityBackgroundView.mas_bottom).offset(yAutoFit(20.f));
        }];
        
        _chartView.noDataText = LocalString(@"暂无数据");
        _chartView.delegate = self;
        _chartView.rightAxis.enabled = NO;//关闭右坐标
        _chartView.chartDescription.enabled = NO;
        _chartView.dragEnabled = YES;
        _chartView.scaleEnabled = YES;//缩放
        _chartView.scaleYEnabled = NO;
        _chartView.drawGridBackgroundEnabled = YES;//网格线
        _chartView.pinchZoomEnabled = YES;
        //_chartView.doubleTapToZoomEnabled = NO;//取消双击缩放
        //_chartView.dragDecelerationEnabled = NO;//拖拽后是否有惯性效果
        //_chartView.dragDecelerationFrictionCoef = 0;//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
        _chartView.backgroundColor = [UIColor clearColor];
        
        _chartView.legend.enabled = NO;//不显示图例说明
        ChartLegend *l = _chartView.legend;
        l.form = ChartLegendFormLine;
        l.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
        l.textColor = UIColor.whiteColor;
        l.horizontalAlignment = ChartLegendHorizontalAlignmentLeft;
        l.verticalAlignment = ChartLegendVerticalAlignmentBottom;
        l.drawInside = YES;//legend显示在图表里
        
        //X轴属性设置
        ChartXAxis *xAxis = _chartView.xAxis;
        xAxis.labelFont = [UIFont fontWithName:@"Avenir-Light" size:12];
        //控制x轴坐标的文字属性
        xAxis.labelTextColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        xAxis.drawGridLinesEnabled = NO;
        xAxis.drawAxisLineEnabled = NO;
        xAxis.granularityEnabled = YES;
        xAxis.avoidFirstLastClippingEnabled = YES; //避免x轴的文字显示不全
        xAxis.labelPosition = XAxisLabelPositionBottom;//一般把x轴放在底部
        xAxis.valueFormatter = self;
        xAxis.axisMinimum = 0;
        xAxis.axisMaximum = 5;
        xAxis.axisRange = 10;
        xAxis.granularity = 1;
        [_chartView setVisibleXRangeWithMinXRange:1 maxXRange:UI_IS_IPHONE5?500:600];//修改缩小放大最多显示数量
        
        ChartYAxis *leftAxis = _chartView.leftAxis;
        leftAxis.labelTextColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        leftAxis.labelFont = [UIFont fontWithName:@"Avenir-Light" size:12];
        leftAxis.axisMaximum = 20;
        leftAxis.axisMinimum = 0;
        leftAxis.spaceTop = 10.f;
        leftAxis.drawGridLinesEnabled = YES;
        leftAxis.gridLineWidth = 0.6f;
        leftAxis.gridColor = [UIColor colorWithHexString:@"EBEDF0"];
        leftAxis.gridLineDashLengths = @[@5.f,@5.f];//虚线
        leftAxis.drawZeroLineEnabled = YES;
        leftAxis.granularityEnabled = YES;
        leftAxis.granularity = 2;
        
    }
    return _chartView;
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

- (void)chartScaled:(ChartViewBase * _Nonnull)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    NSLog(@"图表缩放");
}

- (void)chartTranslated:(ChartViewBase * _Nonnull)chartView dX:(CGFloat)dX dY:(CGFloat)dY{
    NSLog(@"图表移动");
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase * _Nullable)axis {
    //value从0开始，我要从1开始
    return [NSString stringWithFormat:@"%@-%02d",self.month,(int)value + 1];
}

#pragma mark - Actions
/*
 *获取设备每年的月电量详情
 */
- (void)getElectricityCurveData{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    Database *db = [Database shareInstance];
    
    //设置超时时间
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = yHttpTimeoutInterval;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/device/electric/month",httpIpAddress];
    
    NSDictionary *parameters = @{@"mac":self.device.mac,@"year":self.year,@"month":self.month};
    
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:db.user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",db.token] forHTTPHeaderField:@"Authorization"];
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"success:%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            if ([[responseDic objectForKey:@"data"] isKindOfClass:[NSArray class]] && [[responseDic objectForKey:@"data"] count] > 0) {
                
                [[responseDic objectForKey:@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.dateArray addObject:[obj objectForKey:@"modifiedTime"]];
                    [self.valueArray addObject:[obj objectForKey:@"value"]];
                }];
            }
            //加载数据
            [self setChartData];
            NSLog(@"gsdfhgh%@",self.valueArray);
        }else{
            [NSObject showHudTipStr:LocalString(@"获取电量详细失败")];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject showHudTipStr:@"从服务器获取信息失败,请检查网络状况"];
        });
    }];
    
}

-(void) setChartData{
    
    if (!self.dateArray) {
        self.dateArray = [[NSMutableArray alloc] init];
    }
    if (!self.valueArray) {
        self.valueArray = [[NSMutableArray alloc] init];
    }
    NSMutableArray *yValue1 = [[NSMutableArray alloc] init];
    //对于每个x轴对应的点，添加相应的数据
//    for (int i = 0; i < 31; i++) {
//        [self.dateArray addObject:[NSString stringWithFormat:@"%02d",i]];
//    }
    for (int i = 0; i < self.valueArray.count; i++)
    {
        double val = [self.valueArray[i] doubleValue];
        double month = [self.dateArray[i] doubleValue];
        [yValue1 addObject:[[ChartDataEntry alloc] initWithX:i y:val]]; //对应加入数据
    }
    
    //三个数据集
    LineChartDataSet *set1 = nil;
    
    if (self.chartView.data.dataSetCount > 0)
    {
        //数据集已经绑定过了，就直接为数据集设置数据
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        set1.values = yValue1;
        [self.chartView.data notifyDataChanged];
        [self.chartView notifyDataSetChanged];
    }
    else
    {
        //没有，则初始化数据集
        set1 = [[LineChartDataSet alloc] initWithValues:yValue1 label:@""]; //第一套数据的数据和代表的值
        set1.axisDependency = AxisDependencyLeft; //数据依赖的是左边的轴
        [set1 setColor:[UIColor colorWithRed:52/255.f green:188/255.f blue:248/255.f alpha:1.f]]; //线的颜色
        [set1 setCircleColor:[UIColor lightGrayColor]]; //折点的颜色
        set1.lineWidth = 3.0; //线宽
        set1.circleRadius = 3.0; //折点半径
        set1.fillAlpha = 65/255.0;
        set1.fillColor = [UIColor colorWithRed:52/255.f green:188/255.f blue:248/255.f alpha:1.f];
        //这个控制的是，点击某个点之后的十字线的颜色，这里我不需要十字线
        //  set1.highlightColor = [UIColor blueColor];
        //去掉highlightColor的颜色，但还是有默认颜色，我只能将线宽设置为0
        set1.highlightLineWidth = 0;  //这个控制的是，点击某个点之后的十字线的颜色，这里我不需要十字线(去掉highlightColor的颜色，但还是有默认颜色，我只能将线宽设置为0)
        set1.drawCircleHoleEnabled = YES; //是否可以空心
        set1.circleHoleRadius = 2.0; //设置折点空心圆角
        set1.drawValuesEnabled = YES;//是否在拐点处显示数据
    }
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set1];
    
    LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
    //这里的颜色控制的是每个折点的颜色
    data.valueTextColor = UIColor.redColor;
    data.valueFont = [UIFont systemFontOfSize:9.f];
    
    //每个这点上是否显示数值
    data.drawValues = YES;
    
    self.chartView.data = data;
}

@end
