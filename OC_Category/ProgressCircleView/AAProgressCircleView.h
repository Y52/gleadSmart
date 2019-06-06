//
//  AAProgressCircleView.h
//  gleadSmart
//
//  Created by 安建伟 on 2019/6/3.
//  Copyright © 2019 杭州轨物科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AAProgressCircleView : UIView

/** 圆环底层视图 */
@property (nonatomic, strong) UIView *bgView;
@property (strong, nonatomic) UILabel *progressLab;
@property (strong, nonatomic) UIView *pointView;

//进度条
@property (nonatomic,strong) CAShapeLayer *progressLayer;
//定时器
@property (strong, nonatomic) NSTimer *timer;
//进度值
@property (assign, nonatomic) CGFloat progress;
//当前显示进度值
@property (assign, nonatomic) CGFloat showProgress;
//动画百分比
@property (assign, nonatomic) CGFloat percent;

- (void)didCircleProgressAction;
- (void)configSecondAnimate;

- (void)deleteTimer;
@end

NS_ASSUME_NONNULL_END
