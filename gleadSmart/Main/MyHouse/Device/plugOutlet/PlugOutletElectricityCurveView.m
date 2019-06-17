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

@end

@implementation PlugOutletElectricityCurveView

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
            make.size.mas_equalTo(CGSizeMake(ScreenWidth, yAutoFit(ScreenHeight - 200)));
            make.centerX.equalTo(self.electricityImage.mas_centerX);
            make.top.equalTo(self.electricityBackgroundView.mas_bottom).offset(yAutoFit(20.f));
        }];
        
        UILabel *leftLabel = [[UILabel alloc] init];
        //leftLabel.text = [DataBase shareDataBase].setting.tempUnit;
        leftLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        leftLabel.textColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        leftLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:leftLabel];
        
        UILabel *rightLabel = [[UILabel alloc] init];
        //rightLabel.text = [NSString stringWithFormat:@"%@/min",[DataBase shareDataBase].setting.tempUnit];
        rightLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        rightLabel.textColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        rightLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:rightLabel];
        
        UILabel *bottomLabel = [[UILabel alloc] init];
        bottomLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12];
        bottomLabel.textColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        bottomLabel.text = LocalString(@"(min)");
        [self.view addSubview:bottomLabel];
        
        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(22, 15));
            make.left.equalTo(self.chartView.mas_left);
            make.bottom.equalTo(self.chartView.mas_top).offset(3);
        }];
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(47, 12));
            make.right.equalTo(self.chartView.mas_right);
            make.bottom.equalTo(self.chartView.mas_top).offset(3);
        }];
        [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(29, 12));
            make.left.equalTo(self.chartView.mas_right).offset(-15);
            make.bottom.equalTo(self.chartView.mas_bottom);
        }];
        
        _chartView.noDataText = LocalString(@"暂无数据");
        _chartView.delegate = self;
        
        _chartView.chartDescription.enabled = NO;
        
        _chartView.dragEnabled = YES;
        [_chartView setScaleEnabled:YES];//缩放
        [_chartView setScaleYEnabled:NO];
        
        _chartView.drawGridBackgroundEnabled = NO;//网格线
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
        xAxis.labelPosition = XAxisLabelPositionBottom;
        xAxis.valueFormatter = self;
        xAxis.axisMinimum = 0;
        //xAxis.axisMaximum = 60 * [DataBase shareDataBase].setting.timeAxis;
        //[xAxis setLabelCount:[DataBase shareDataBase].setting.timeAxis + 1];
        //xAxisMax = [DataBase shareDataBase].setting.timeAxis;
        //xAxis.axisRange = 60 * [DataBase shareDataBase].setting.timeAxis;
        xAxis.granularity = 1;
        [_chartView setVisibleXRangeWithMinXRange:60 maxXRange:UI_IS_IPHONE5?500:600];//修改缩小放大最多显示数量
        //避免x轴的文字显示不全
        xAxis.avoidFirstLastClippingEnabled = YES;
        [xAxis setLabelPosition:XAxisLabelPositionBottom]; //一般把x轴放在底部
        
        ChartYAxis *leftAxis = _chartView.leftAxis;
        leftAxis.labelTextColor = [UIColor colorWithRed:184/255.0 green:190/255.0 blue:204/255.0 alpha:1];
        leftAxis.labelFont = [UIFont fontWithName:@"Avenir-Light" size:12];
        leftAxis.axisMaximum = [NSString diffTempUnitStringWithTemp:5 - 0.5];
        leftAxis.axisMinimum = [NSString diffTempUnitStringWithTemp:15 - 0.5];
        leftAxis.axisMinimum = 50.0;
        leftAxis.spaceTop = 30.f;
        leftAxis.drawGridLinesEnabled = YES;
        leftAxis.gridLineWidth = 0.6f;
        leftAxis.gridColor = [UIColor colorWithHexString:@"EBEDF0"];
        //leftAxis.gridLineDashLengths = @[@5.f,@5.f];//虚线
        leftAxis.drawZeroLineEnabled = NO;
        leftAxis.granularityEnabled = YES;
        leftAxis.granularity = 0;
        
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
    //NSLog(@"图表移动");
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase * _Nullable)axis {
    //value从0开始，我要从1开始
    return [NSString stringWithFormat:@"%d月",(int)value + 1];
}

@end
