

//
//  LZMobilePayManager.m
//  GoldeneyeFrame
//
//  Created by goldeneye on 2017/6/6.
//  Copyright © 2017年 ZZgoldeneye. All rights reserved.
//

#import "LZMobilePayManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "RSADataSigner.h"
#import <CommonCrypto/CommonCryptor.h>
#import "CommonCrypto/CommonDigest.h"
#import "WechatPayManager.h" //微信支付类

/*************** 支付宝支付 ********************/
static NSString * const AlipayAppId = @"2017050907171985";
static NSString * const AlipayRSA2PrivateKey = @"MIIEogIBAAKCAQEAtzO09vrYJjbMzx0FR9Zr5YYQXOQsEvfhX3ubfcnl+7QHYD+AxTmYvD707h37PjpZqgfEFlC28o417VxyoOZ2i/EAHxn3rPW08rExptIc3AnYiXmYfI9c+oH2Nnl/HUzXSVn7r6vJ6M0eHdaOHDHZyoE5CGYxShfIQYAUTzzvSMmaVgsUI0SpFpq/Y42ptWjpvdG1O0Loqomw4FGJXWAkRbzJe44ugEFjlvrWHk85d0Bx0N5YdT7LWWLTnP4RJztXpjK8omwg5/QQGfI5XTrXN1tQxdh2bkmcdmhmV2jEIeAeZuQF2QVIuzt0adPDaov5e9B04IHtzIhkEpfb89rj9wIDAQABAoIBAFX99VGAyPiW/GezLYlcwmSIGyIfD/kPVUBmWsQegs8038lzxVPOBz1FJ96lQAsjhHblEkuPM3CDBBkYLc4Mn1RsmSwAGlubMYZBWhb9xQIbtQJCiyrceD41xoYnXV05dkw96n+42RtnPF2xGh9t3tbI9SZWIYivxRXJsr7G0WKOQ34H1sg/EkyAS6WbGAFn4xb4OS8jDxEFS7F5IlCzMIhQg3lkEADM9p3oJimteBdPWqq5s5eQ/oEfchwXuaL/7Q2WFpj7KgJwnOoot3Ij9wpr+LwYhXZi9GYAYvqBMiGIW9+9qxFpFwYHBaYc27dhzWj3nPMQ4FfgIm7tAg2IsNECgYEA3i8ANGzr9cqL6r6Bw4IoJvMHjpD7PNjUlQRI9TGWL6bCEkrebqcCsFi7S+8njJxB0ramgTMCIRZLFsvVmK3u1ynMJIxGrVZZ4Jq/FIFq1YqMy/wvo0hwssO78FNBXYMFoeiSuf9eHDXftbc/cKvSyV2BWM+siXZnROSKm8PLrTUCgYEA0xXa2XQWmlW02jijdj/FJHfXlNYmuy5LZbxFIY/9Rm4SIqThq2cXyqMjIMedxARtCZKmgOqNTeMsnYwFSaG/RyKUqbQZV9Ofnef57O2PUYd/0RDzl8nAyhEJwjRi8o50g5U5MG2/zaQuuc+8PJtK4dXuysEtYGb4E0mNWcxW7fsCgYB/j0h00Nwfv2vZGAr0LjPTONBr33z+kBZsf4tLim6JaRoe2nEd4jC/AhJ2JBX2undn/IlXv+tHB7+QlPJKuAFZ8ptLmGWzetIbC30MzsiBVQxEyMKo4hwh5hJuhb4Pa/u92wLyWlSzqZKIh26ax2s7RL3QOVr7iMj9WqDhkOXMyQKBgATpbEdFGUWMGwI88SjOQRMhKsYO2aXfZOfAIseuJxGdfBSMS6gGZRpVA3s+yeAGzla7r94uFw2p7J7Z5EGbXu0T0+vDAhf2F6+/9yPZP02BXqsJvvFYQ4EwNk7rkyXbxMBPF56V3zG00VWHjPTIFEz/Amh7aEfm/XzNaFmflKJDAoGAOSADLjIm+gv2EfLIAyi5Z5G82Ev/Ax9i56h+vcRZOiZkn7pnxXjnOhEuPy6y8Xgewp8xSNxO4nz4Uvl8v62HK2Z/xdFpol4TVPjtjdBUdANL+HuUyIp62t9qPMcXzooUoOT1xSfDDhDo04ZyXW93hCQZg6WPtCaUUYOe6WJd44I=";
static NSString * const AlipayRSAPrivateKey = @"";

/*************** 微信支付 ********************/
static NSString * const  kWEIXINID  = @"wxf11ffd5d69e777b7";
static NSString * const  kWEIXINKEY = @"da7bfb83ec6b41223b9f6191c4350afd";
/**
 * 支付成功回调地址
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 */
static NSString * const kWEIXINNOTIFYURL = @"http://54.223.123.195:8088/lilian_web/index.php/home/wxpay/notify_url";
/**
 * 微信开放平台和商户约定的支付密钥
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 */
static NSString * const  KWXPartnerKey = @"FSA5DF5sf5fd5FG535dty987354DGYft";
/**
 *  微信公众平台商户模块生成的ID
 */
static NSString * const  kWEIXINPartnerId = @"1414067502";

@implementation LZMobilePayManager

//单利
+ (LZMobilePayManager *)shareInstance{
    
    static LZMobilePayManager * tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool  = [[LZMobilePayManager alloc]init];
    });
    return tool;
}
/*
 * 支付宝支付
 * orderTitle 订单title
 * orderId    订单编号
 * orderPrice 订单价格
 *
 */
- (void)alipayOrderTitle:(NSString *)orderTitle orderNumber:(NSString *)orderNumber orderPrice:(NSString *)orderPrice compltedHandle:(void (^)(PayCompltedHandle handel))compltedHandle{
    
    [LZMobilePayManager shareInstance].PayCompltedHandleBlock  = compltedHandle;
    
    //partner和seller获取失败,提示
    if ([AlipayAppId length] == 0 ||
        ([AlipayRSAPrivateKey length] == 0 && [AlipayRSA2PrivateKey length] == 0))
    {
        [self showErrorMessage:@"缺少appId或者私钥。"];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    
    //将商品信息拼接成字符串
    //将商品信息赋予AlixPayOrder的成员变量
    Order* order = [Order new];
    // NOTE: app_id设置
    order.app_id = AlipayAppId;
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    // NOTE: 支付版本 固定为：1.0
    order.version = @"1.0";
    // NOTE: sign_type 根据商户设置的私钥来决定
    order.sign_type = (AlipayRSA2PrivateKey.length > 1)?@"RSA2":@"RSA";
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    // NOTE: (非必填项)商品描述
    order.biz_content.body = @"我是测试数据";
    // NOTE: 商品的标题/交易标题/订单标题/订单关键字等。
    order.biz_content.subject = orderTitle;
    // NOTE: 商户网站唯一订单号
    order.biz_content.out_trade_no = orderNumber; //订单ID（由商家自行制定）
    // NOTE: 该笔订单允许的最晚付款时间，逾期将关闭交易。
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = [NSString stringWithFormat:@"%@", orderPrice]; //商品价格
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSLog(@"orderSpec = %@",orderInfo);
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    NSString *signedString = nil;
    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:((AlipayRSA2PrivateKey.length > 1)?AlipayRSA2PrivateKey:AlipayRSAPrivateKey)];
    if ((AlipayRSA2PrivateKey.length > 1)) {
        
        signedString = [signer signString:orderInfo withRSA2:YES];
    } else {
        signedString = [signer signString:orderInfo withRSA2:NO];
    }
    
    NSLog(@"signedString = %@",signedString);
    
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"alisdkgoldeneye.item";
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];
        
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
           
    
            NSLog(@"payOrder =reslut = %@",resultDic);
            
            if (resultDic) {
//                9000 订单支付成功
//                8000 正在处理中
//                4000 订单支付失败
//                6001 用户中途取消
//                6002 网络连接出错
                NSInteger orderState = [resultDic[@"resultStatus"] integerValue];
                if (orderState == 9000) {
                    if ([[LZMobilePayManager alloc]init].PayCompltedHandleBlock) {
                        [[LZMobilePayManager alloc]init].PayCompltedHandleBlock(PaySuccessHandle);
                    }
                }else if (orderState == 6001)
                {
                    if ([LZMobilePayManager shareInstance].PayCompltedHandleBlock ){
                        [LZMobilePayManager shareInstance].PayCompltedHandleBlock(PayCancleHandle);
                        
                    }
                }else{
                    if ([[LZMobilePayManager alloc]init].PayCompltedHandleBlock) {
                        [[LZMobilePayManager alloc]init].PayCompltedHandleBlock(PayFailedHandle);
                    }
                    
                }
            }
            
        }];
        
 
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(AliPayHandle:) name:@"AlipayNotification" object:nil];
        
            //  [[NSNotificationCenter defaultCenter]postNotificationName:@"AlipayNotification" object:self  userInfo:resultDic];
        
    }else{
        [self showErrorMessage:@"支付宝加密失败"];
    }
}

/*
 * 微信支付
 * orderTitle 订单title
 * orderId    订单编号
 * orderPrice 订单价格
 *
 */
- (void)wechatPayOrderTitle:(NSString *)orderTitle orderNumber:(NSString *)orderNumber orderPrice:(NSString *)orderPrice compltedHandle:(void (^)(PayCompltedHandle handel))compltedHandle{
    
    
    [LZMobilePayManager shareInstance].PayCompltedHandleBlock = compltedHandle;
    
    //微信
    WechatPayManager * wxpayManager  = [[WechatPayManager alloc]initWithAppID:kWEIXINID mchID:kWEIXINPartnerId spKey:KWXPartnerKey notifyUrl:kWEIXINNOTIFYURL];
    //错误提示
    //NSString *debug = [wxpayManager getDebugInfo];
    
    //[NSString stringWithFormat:@"%.0lf",_price*100]
    NSMutableDictionary  * params = [wxpayManager getPrepayWithOrderName:orderTitle price:orderPrice orderNo:orderNumber];
    
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.openID              = [params objectForKey:@"appid"];  //微信开放平台审核通过的应用APPID
    req.partnerId          = [params objectForKey:@"partnerid"]; //微信支付分配的商户号
    req.prepayId            = [params objectForKey:@"prepayid"]; //微信返回的支付交易会话ID
    req.nonceStr            = [params objectForKey:@"noncestr"]; //随机字符串，不长于32位。推荐
    req.timeStamp          =  [[params objectForKey:@"timestamp"] intValue];   //时间戳
    req.package            =   @"Sign=WXPay"; //[dataDict objectForKey:@"package"];// Sign=WXPay
    req.sign                = [params objectForKey:@"sign"]; // 签名
    
    [WXApi sendReq:req];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(wechatPayHandle:) name:@"WechatPayNotification" object:nil];
    
}
//微信支付通知
- (void)wechatPayHandle:(NSNotification *)notification
{
    
    if ([notification.object isEqualToString:@"WXErrCodeUserCancel"]) {
        
        if ([LZMobilePayManager shareInstance].PayCompltedHandleBlock ){
            [LZMobilePayManager shareInstance].PayCompltedHandleBlock(PayCancleHandle);
            
        }
    }else if ([notification.object isEqualToString:@"WXSuccess"])
    {
        if ([[LZMobilePayManager alloc]init].PayCompltedHandleBlock) {
            [[LZMobilePayManager alloc]init].PayCompltedHandleBlock(PaySuccessHandle);
        }
        
    }else{
        if ([[LZMobilePayManager alloc]init].PayCompltedHandleBlock) {
            [[LZMobilePayManager alloc]init].PayCompltedHandleBlock(PayFailedHandle);
        }
    }
    
}
//支付宝回掉通知

- (void)AliPayHandle:(NSNotification *)notification{

    NSLog(@"notification.userInfo==%@",notification.userInfo);
    
    NSInteger orderState = [notification.userInfo[@"resultStatus"] integerValue];
    if (orderState == 9000) {
        if ([[LZMobilePayManager alloc]init].PayCompltedHandleBlock) {
            [[LZMobilePayManager alloc]init].PayCompltedHandleBlock(PaySuccessHandle);
        }
    }else if (orderState == 6001)
    {
        if ([LZMobilePayManager shareInstance].PayCompltedHandleBlock ){
            [LZMobilePayManager shareInstance].PayCompltedHandleBlock(PayCancleHandle);
            
        }
    }else{
        if ([[LZMobilePayManager alloc]init].PayCompltedHandleBlock) {
            [[LZMobilePayManager alloc]init].PayCompltedHandleBlock(PayFailedHandle);
        }
        
    }
    

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
}


- (void)showErrorMessage:(NSString *)message{
    
    UIAlertView  * alert  = [[UIAlertView alloc]initWithTitle:@"错误提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
    
}

@end
