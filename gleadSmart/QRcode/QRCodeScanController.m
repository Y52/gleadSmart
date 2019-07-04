//
//  QRCodeScanController.m
//  Coffee
//
//  Created by 杭州轨物科技有限公司 on 2018/10/17.
//  Copyright © 2018年 杭州轨物科技有限公司. All rights reserved.
//

#import "QRCodeScanController.h"
#import <AVFoundation/AVFoundation.h>
#import "EspViewController.h"

@interface QRCodeScanController () <AVCaptureMetadataOutputObjectsDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *scanLayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) UIView *borderView;

@end

@implementation QRCodeScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self codeScan];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

#pragma mark - Lazyload
- (AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)scanLayer
{
    if (!_scanLayer) {
        _scanLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _scanLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _scanLayer.frame = self.view.bounds;
    }
    return _scanLayer;
}

- (AVCaptureMetadataOutput *)output
{
    if (!_output) {
        _output = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _output;
}

- (UIView *)borderView
{
    if (!_borderView) {
        _borderView = [[UIView alloc] initWithFrame:CGRectMake(0.1 * ScreenWidth, 150, 0.8 *ScreenWidth, 0.8*ScreenWidth)];
        _borderView.layer.borderColor = [UIColor whiteColor].CGColor;
        _borderView.layer.borderWidth = 2.0f;
    }
    return _borderView;
}

#pragma mark - Actions
- (void)codeScan
{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied)
    {
        [NSObject showHudTipStr:LocalString(@"请到隐私设置中开启相机使用权限")];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        // 创建回话对象
        self.session = [[AVCaptureSession alloc] init];
        // 设置回话对象图像采集率
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        //获取摄像头设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (device) {
            // 设置输出数据类型,需要将元数据输出添加到回话后,才能制定元数据,否则会报错
            // 二维码和条形码可以一起设置
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
            // 添加会话输入
            [self.session addInput:input];
            
            [self.session addOutput:self.output];
            [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
        }
        [self.view.layer addSublayer:self.scanLayer];
        self.output.rectOfInterest = CGRectMake(150/ScreenHeight, 0.1, 150/ScreenHeight+0.8*ScreenWidth/ScreenHeight, 0.9);
        [self.view addSubview:self.borderView];
        // 启动会话
        [self.session startRunning];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
        if (object.stringValue.length >= 8){
            [self.session stopRunning];
            NSArray *resultArray = [object.stringValue componentsSeparatedByString:@":"];
            NSLog(@"%@ %@",resultArray[0],resultArray[1]);
            //保存mac
            Database *data = [Database shareInstance];
            data.macDeviceByQR = resultArray[1];
            if (data.macDeviceByQR) {
                EspViewController *espVC = [[EspViewController alloc] init];
                [self.navigationController pushViewController:espVC animated:YES];
            }
            
        }else{
            [NSObject showHudTipStr:LocalString(@"设备的二维码信息错误")];
            [self.session stopRunning];
            [self.scanLayer removeFromSuperlayer];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self.session stopRunning];
        [self showAlert];
    }
}

- (void)showAlert{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"未扫描正确的设备数据,是否继续" preferredStyle:UIAlertControllerStyleAlert];
    alertController.view.tintColor = [UIColor colorWithRed:71/255.0 green:120/255.0 blue:204/255.0 alpha:1];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.session startRunning];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
