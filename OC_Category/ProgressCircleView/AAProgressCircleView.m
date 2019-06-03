//
//  AAProgressCircleView.m
//  gleadSmart
//
//  Created by 安建伟 on 2019/6/3.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import "AAProgressCircleView.h"

//RGB颜色
#define kRGBColor(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define duration_First 60.0 //设定预估配网时间
#define TimeInterval 1  //定时器刷新间隔

#define lineWH 217

@implementation AAProgressCircleView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //创建基本视图
        [self createSubview];
        //创建路径及layer
        [self createLayerPath];
    }
    return self;
}

- (void)createSubview{
    [self addSubview:self.bgView];
    [self addSubview:self.progressLab];
    [self addSubview:self.pointView];
    
    self.bgView.frame = CGRectMake(0, 0, lineWH, lineWH);
    
    [self.progressLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(120.f, 40.f));
        make.centerX.equalTo(self.bgView.mas_centerX);
        make.centerY.equalTo(self.bgView.mas_centerY);
    }];
    self.pointView.frame = CGRectMake((lineWH-11)/2, 3, 11, 11);
    
}

- (void)createLayerPath{
    //贝塞尔曲线画圆弧
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(lineWH/2, lineWH/2) radius:(lineWH-17)/2.0 startAngle:-M_PI/2 endAngle:3*M_PI/2 clockwise:YES];
    //设置颜色
    [kRGBColor(0xF6F6F9) set];
    circlePath.lineWidth = 10;
    //开始绘图
    [circlePath stroke];
    
    //创建背景视图
    CAShapeLayer *bgLayer = [CAShapeLayer layer];
    bgLayer.frame = self.bounds;
    bgLayer.fillColor = [UIColor clearColor].CGColor;//填充色 - 透明
    bgLayer.lineWidth = 10;//线条宽度
    bgLayer.strokeColor = kRGBColor(0xDFDFDF).CGColor;//线条颜色
    bgLayer.strokeStart = 0;//起始点
    bgLayer.strokeEnd = 1;//终点
    bgLayer.lineCap = kCALineCapRound;//让线两端是圆滑的状态
    bgLayer.path = circlePath.CGPath;//这里就是把背景的路径设为之前贝塞尔曲线的那个路径
    [self.bgView.layer addSublayer:bgLayer];
    
    //创建进度条视图
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.lineWidth = 17;
    _progressLayer.lineCap = kCALineCapRound;
    _progressLayer.strokeColor = kRGBColor(0xC8A159).CGColor;
    _progressLayer.strokeStart = 0;
    _progressLayer.strokeEnd = 0;
    _progressLayer.path = circlePath.CGPath;
    [self.bgView.layer addSublayer:_progressLayer];
    
    //创建渐变色图层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    [self.bgView.layer addSublayer:gradientLayer];
    
    //#C8A159 #EBD6AB  C6A05D
    CAGradientLayer *leftGradientLayer = [CAGradientLayer layer];
    leftGradientLayer.frame = CGRectMake(0, 0, lineWH/2, lineWH);
    [leftGradientLayer setColors:[NSArray arrayWithObjects:(id)kRGBColor(0xFF4800).CGColor, (id)kRGBColor(0xFF4800).CGColor, nil]];
    [leftGradientLayer setLocations:@[@0.0,@1.0]];
    [leftGradientLayer setStartPoint:CGPointMake(0, 0)];
    [leftGradientLayer setEndPoint:CGPointMake(0, 1)];
    [gradientLayer addSublayer:leftGradientLayer];
    
    CAGradientLayer *rightGradientLayer = [CAGradientLayer layer];
    rightGradientLayer.frame = CGRectMake(lineWH/2, 0, lineWH/2, lineWH);
    [rightGradientLayer setColors:[NSArray arrayWithObjects:(id)kRGBColor(0xFF4800).CGColor, (id)kRGBColor(0xFF4800).CGColor, nil]];
    [rightGradientLayer setLocations:@[@0.0,@1.0]];
    [rightGradientLayer setStartPoint:CGPointMake(0, 0)];
    [rightGradientLayer setEndPoint:CGPointMake(0, 1)];
    [gradientLayer addSublayer:rightGradientLayer];
    [gradientLayer setMask:_progressLayer];
}

- (void)configCircleAnimate{
    CABasicAnimation *animation_1 = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation_1.fromValue = @0;
    animation_1.toValue = [NSNumber numberWithDouble:self.progress];
    animation_1.duration = duration_First;
    animation_1.fillMode = kCAFillModeForwards;
    animation_1.removedOnCompletion = NO;
    [self.progressLayer addAnimation:animation_1 forKey:nil];
    
    CAKeyframeAnimation *pathAnimation_1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation_1.calculationMode = kCAAnimationPaced;
    pathAnimation_1.fillMode = kCAFillModeForwards;
    pathAnimation_1.removedOnCompletion = NO;
    pathAnimation_1.duration = duration_First;
    pathAnimation_1.repeatCount = 0;
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(lineWH/2, lineWH/2) radius:(lineWH-17)/2.0 startAngle:-M_PI/2 endAngle:-M_PI/2+2*M_PI*self.progress clockwise:YES];
    pathAnimation_1.path = circlePath.CGPath;
    [self.pointView.layer addAnimation:pathAnimation_1 forKey:@"movePoint"];
}

- (void)startTimer{
    [self deleteTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TimeInterval target:self selector:@selector(animate:) userInfo:nil repeats:YES];
}

- (void)animate:(NSTimer *)time{
    if (self.showProgress <= self.progress) {
        self.showProgress += TimeInterval*self.progress/duration_First;
    }else{
        [self deleteTimer];
    }
    
    if (self.showProgress > 1) {
        self.showProgress = 1;
    }
    
    self.progressLab.text = [NSString stringWithFormat:@"%d%%", (int)(self.showProgress*100)];
}

- (void)deleteTimer{
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - action

- (void)didCircleProgressAction{
    
    [self deleteTimer];
    [self.progressLayer removeAllAnimations];
    self.progressLayer.strokeEnd = 0;
    self.pointView.frame = CGRectMake((lineWH-11)/2, 3, 11, 11);
    self.progressLab.text = @"0%";
    
    //进度初始值
    self.progress = 0.99;
    self.showProgress = 0;
    
    __weak __typeof(&*self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
        //设置第一段动画
        [weakSelf configCircleAnimate];
        //开启定时器
        [weakSelf startTimer];
        
    });
}

#pragma mark - getter

- (UIView *)bgView{
    if (_bgView == nil) {
        _bgView = [[UIView alloc]init];
    }
    return _bgView;
}

- (UILabel *)progressLab{
    if (_progressLab == nil) {
        _progressLab = [[UILabel alloc]init];
        _progressLab.textColor = kRGBColor(0x333333);
        _progressLab.textAlignment = NSTextAlignmentCenter;
        _progressLab.adjustsFontSizeToFitWidth = YES;
        _progressLab.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:50];
        _progressLab.text = @"0%";
    }
    return _progressLab;
}

- (UIView *)pointView{
    if (_pointView == nil) {
        _pointView = [[UIView alloc]init];
        _pointView.backgroundColor = [UIColor whiteColor];
        _pointView.layer.cornerRadius = 5.5;
        _pointView.layer.masksToBounds = YES;
    }
    return _pointView;
}

@end
