//
//  SharerRemarkController.m
//  gleadSmart
//
//  Created by 杭州轨物科技有限公司 on 2019/2/22.
//  Copyright © 2019年 杭州轨物科技有限公司. All rights reserved.
//

#import "SharerRemarkController.h"

@interface SharerRemarkController () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *sharerRemarkTF;
@property (nonatomic, strong) UIButton *rightButton;

@end

@implementation SharerRemarkController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.layer.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1].CGColor;
    
    [self setNavItem];
    self.sharerRemarkTF = [self sharerRemarkTF];
}

#pragma mark - private methods
- (void)setNavItem{
    self.navigationItem.title = LocalString(@"修改备注");
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"完成") style:UIBarButtonItemStylePlain target:self action:@selector(Done)];
    [rightBar setTintColor:[UIColor colorWithHexString:@"4778CC"]];
    [rightBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.f], NSFontAttributeName,nil] forState:(UIControlStateNormal)];
    self.navigationItem.rightBarButtonItem = rightBar;
    
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithTitle:LocalString(@"取消") style:UIBarButtonItemStylePlain target:self action:@selector(Cancel)];
    [leftBar setTintColor:[UIColor colorWithHexString:@"222222"]];
    [leftBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:16.f], NSFontAttributeName,nil] forState:(UIControlStateNormal)];
    self.navigationItem.leftBarButtonItem = leftBar;
}

- (void)Done{
    [SVProgressHUD show];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 6.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    NSString *url = [NSString stringWithFormat:@"%@/api/share/sharer",httpIpAddress];
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[Database shareInstance].user.userId forHTTPHeaderField:@"userId"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"bearer %@",[Database shareInstance].token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *parameters = @{@"shareUid":self.sharer.sharerUid,@"houseUid":self.houseUid,@"shareName":self.sharerRemarkTF.text};
    
    [manager PUT:url parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        NSData * data = [NSJSONSerialization dataWithJSONObject:responseDic options:(NSJSONWritingOptions)0 error:nil];
        NSString * daetr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@",daetr);
        if ([[responseDic objectForKey:@"errno"] intValue] == 0) {
            [NSObject showHudTipStr:@"修改备注成功"];
            self.sharer.name = self.sharerRemarkTF.text;
            if (self.popBlock) {
                self.popBlock();
            }
            [self resignFirstResponder];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [NSObject showHudTipStr:[responseDic objectForKey:@"error"]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [NSObject showHudTipStr:LocalString(@"修改备注失败")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];
}

- (void)Cancel{
    [self.navigationController popViewControllerAnimated:YES];
    [self resignFirstResponder];
}


#pragma mark - setters and getters
- (UITextField *)sharerRemarkTF{
    if (!_sharerRemarkTF) {
        _sharerRemarkTF = [[UITextField alloc] init];
        _sharerRemarkTF.text = self.sharer.name;
        _sharerRemarkTF.backgroundColor = [UIColor whiteColor];
        _sharerRemarkTF.font = [UIFont systemFontOfSize:15.f];
        _sharerRemarkTF.tintColor = [UIColor blackColor];
        _sharerRemarkTF.clearButtonMode = UITextFieldViewModeAlways;
        _sharerRemarkTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _sharerRemarkTF.delegate = self;
        [_sharerRemarkTF becomeFirstResponder];
        _sharerRemarkTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _sharerRemarkTF.frame = CGRectMake(0, 20, ScreenWidth, 50.f);
        [_sharerRemarkTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
        [self.view addSubview:_sharerRemarkTF];
        
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 0)];
        _sharerRemarkTF.leftView = paddingView;
        _sharerRemarkTF.leftViewMode = UITextFieldViewModeAlways;
    }
    return _sharerRemarkTF;
}

#pragma mark - UITextField Delegate
- (void)textFieldTextChange:(UITextField *)textField{
    if ([textField.text isEqualToString:self.sharer.name]) {
        _rightButton.enabled = NO;
        _rightButton.alpha = 0.4;
    }else{
        _rightButton.enabled = YES;
        _rightButton.alpha = 1;
    }
}
@end
