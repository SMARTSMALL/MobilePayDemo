

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
static NSString * const AlipayAppId = @"";
static NSString * const AlipayRSA2PrivateKey = @"";
static NSString * const AlipayRSAPrivateKey = @"";

/*************** 微信支付 ********************/
static NSString * const  kWEIXINID  = @"";
static NSString * const  kWEIXINKEY = @"";
/**
 * 支付成功回调地址
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 */
static NSString * const kWEIXINNOTIFYURL = @"";
/**
 * 微信开放平台和商户约定的支付密钥
 *
 * 注意：不能hardcode在客户端，建议genSign这个过程由服务器端完成
 */
static NSString * const  KWXPartnerKey = @"";
/**
 *  微信公众平台商户模块生成的ID
 */
static NSString * const  kWEIXINPartnerId = @"";

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
