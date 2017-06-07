//
//  ViewController.m
//  MobilePayDemo-master
//
//  Created by goldeneye on 2017/6/7.
//  Copyright © 2017年 goldeneye by smart-small. All rights reserved.
//

#import "ViewController.h"
#import "LZMobilePayManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  
    for (int i = 0 ; i < 2; i++) {
        
        UIButton * btn  = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:i==0?@"支付宝支付":@"微信支付" forState:UIControlStateNormal];
        [btn setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100)/2.0, 64+50+(50+20)*i, 100, 50)];
        btn.backgroundColor = [UIColor redColor];
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(isClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)isClick:(UIButton *)btn{

    switch (btn.tag) {
        case 1000:
        {
            __weak typeof(self) weakSelf = self;
            [[LZMobilePayManager  shareInstance]alipayOrderTitle:@"支付宝支付测试" orderNumber:[self generateRomNumWithNumber:18] orderPrice:@"0.01" compltedHandle:^(PayCompltedHandle handel) {
                
                
                
                
                if (handel == PayCancleHandle) {
                    NSLog(@"取消支付宝支付");
                    [weakSelf showSuccessAlertView:@"取消支付宝支付"];
                    
                }else if (handel == PaySuccessHandle)
                {
                    NSLog(@"支付宝支付成功");
                    [weakSelf showSuccessAlertView:@"支付宝支付成功"];
                }else{
                    NSLog(@"支付宝支付失败");
                    [weakSelf showSuccessAlertView:@"支付宝支付失败"];
                }
                
            }];
            
            NSLog(@"支付包");
        }
            break;
        case 1001:
        {
            NSLog(@"微信");
            __weak typeof(self) weakSelf = self;
            [[LZMobilePayManager  shareInstance]wechatPayOrderTitle:@"微信支付测试" orderNumber:[self generateRomNumWithNumber:18] orderPrice:@"1" compltedHandle:^(PayCompltedHandle handel) {
                
                if (handel == PayCancleHandle) {
                    NSLog(@"取消微信支付");
                    [weakSelf showSuccessAlertView:@"取消微信支付"];
                }else if (handel == PaySuccessHandle)
                {
                    NSLog(@"微信支付成功");
                    [weakSelf showSuccessAlertView:@"微信支付成功"];
                }else{
                    NSLog(@"微信支付失败");
                    [weakSelf showSuccessAlertView:@"微信支付失败"];
                }
                
            }];

        }
            break;
        default:
            break;
    }
}
- (void)showSuccessAlertView:(NSString *)message{
    
    UIAlertView  *alertView = [[UIAlertView alloc]initWithTitle:@"支付提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
    
}
/**
 *  生成随机字符串
 *
 *  @param kNumber 订单号的长度
 */
- (NSString *)generateRomNumWithNumber: (NSInteger)kNumber
{
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned int)time(0));
    for (NSInteger i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
