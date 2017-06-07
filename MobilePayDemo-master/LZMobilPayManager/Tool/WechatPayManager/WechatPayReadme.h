//
//  WechatPayReadme.h
//  GoldeneyeFrame
//
//  Created by goldeneye on 2017/6/7.
//  Copyright © 2017年 ZZgoldeneye. All rights reserved.
//

#ifndef WechatPayReadme_h
#define WechatPayReadme_h


//1.在AppDelegate 导入头文件 #import "WXApiManager.h"
//2. 在 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 中 注册微信appid
////向微信注册
//[WXApi registerApp:@"wxf11ffd5d69e777b7" enableMTA:YES];
//3. 回掉
//- (BOOL)application:(UIApplication *)application
//openURL:(NSURL *)url
//sourceApplication:(NSString *)sourceApplication
//annotation:(id)annotation {
//    
//    return [WXApi handleOpenURL:url delegate:[WXApiManager shareInstance]];
//    
//    return YES;
//}
//// NOTE: 9.0以后使用新API接口
//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
//{
//     return  [WXApi handleOpenURL:url delegate:[WXApiManager shareInstance]];
//}
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    return  [WXApi handleOpenURL:url delegate:[WXApiManager shareInstance]];
//}
//
//
////使用微信支付
////导入头文件
//#import "WechatPayManager.h"
//
////配置微信支付
//WechatPayManager * wxpayManager  = [[WechatPayManager alloc]initWithAppID:kWEIXINID mchID:kWEIXINPartnerId spKey:KWXPartnerKey notifyUrl:kWEIXINNOTIFYURL];
////获取错误提示
//NSString *debug = [wxpayManager getDebugInfo];
//LRLog(@"微信支付debug===%@",debug);
////获取微信支付参数
//NSMutableDictionary  * params = [wxpayManager getPrepayWithOrderName:@"text" price:@"1"];
////调起微信支付
//PayReq* req          = [[PayReq alloc] init];
//req.openID           = [params objectForKey:@"appid"];  //微信开放平台审核通过的应用APPID
//req.partnerId        = [params objectForKey:@"partnerid"]; //微信支付分配的商户号
//req.prepayId         = [params objectForKey:@"prepayid"]; //微信返回的支付交易会话ID
//req.nonceStr         = [params objectForKey:@"noncestr"]; //随机字符串，不长于32位。推荐
//req.timeStamp        =  [[params objectForKey:@"timestamp"] intValue];   //时间戳
//req.package          =   @"Sign=WXPay"; //[dataDict objectForKey:@"package"];// Sign=WXPay
//req.sign             = [params objectForKey:@"sign"]; // 签名
////发起微信支付
//[WXApi sendReq:req];

#import "WXApi.h"
#import "WXUtil.h"
#import "ApiXml.h"
#import "IPDetector.h"



#endif /* WechatPayReadme_h */
