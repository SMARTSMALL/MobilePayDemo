//
//  LZMobilePayManager.h
//  GoldeneyeFrame
//
//  Created by goldeneye on 2017/6/6.
//  Copyright © 2017年 ZZgoldeneye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AlipaySDK/AlipaySDK.h>
//定义支付返回类型
typedef enum : NSUInteger {
    PaySuccessHandle, //支付成功
    PayFailedHandle,  //支付失败
    PayCancleHandle,  //取消支付
} PayCompltedHandle;

@interface LZMobilePayManager : NSObject
//单利
+ (LZMobilePayManager *)shareInstance;


/************ 支付宝支付 ****************/
/*
 1. 导入（AlipaySDK.bundle AlipaySDK.framework）到项目文件库下
 2. 在Build Phases选项卡的Link Binary With Libraries中，增加以下依赖：libc++.tbd、libz.tbd、SystemConfiguration.framework、CoreTelephony.framework、QuartzCore.framework、CoreText.framework、CoreGraphics.framework、UIKit.framework、Foundation.framework、CFNetwork.framework、CoreMotion.framework、AlipaySDK.framework
 3.  导入 #import <AlipaySDK/AlipaySDK.h>
 
 - (BOOL)application:(UIApplication *)application
 openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
 annotation:(id)annotation {
 
 if ([url.host isEqualToString:@"safepay"]) {
 // 支付跳转支付宝钱包进行支付，处理支付结果
 [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
 NSLog(@"result = %@",resultDic);
 if (resultDic) {
 
 [[NSNotificationCenter defaultCenter]postNotificationName:@"AlipayNotification" object:self  userInfo:resultDic];
 }
 }];
 
 // 授权跳转支付宝钱包进行支付，处理支付结果
 [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
 NSLog(@"defaultService result = %@",resultDic);
 // 解析 auth code
 NSString *result = resultDic[@"result"];
 NSString *authCode = nil;
 if (result.length>0) {
 NSArray *resultArr = [result componentsSeparatedByString:@"&"];
 for (NSString *subResult in resultArr) {
 if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
 authCode = [subResult substringFromIndex:10];
 break;
 }
 }
 }
 NSLog(@"授权结果 authCode = %@", authCode?:@"");
 }];
 }
 }
 return YES;
 }
 
 // NOTE: 9.0以后使用新API接口
 - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
 {
 // 支付跳转支付宝钱包进行支付，处理支付结果
 [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
 if (resultDic) {
 
 [[NSNotificationCenter defaultCenter]postNotificationName:@"AlipayNotification" object:self  userInfo:resultDic];
 }
 NSLog(@"result = %@",resultDic);
 }];
 
 // 授权跳转支付宝钱包进行支付，处理支付结果
 [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
 NSLog(@"defaultService==result = %@",resultDic);
 // 解析 auth code
 NSString *result = resultDic[@"result"];
 NSString *authCode = nil;
 if (result.length>0) {
 NSArray *resultArr = [result componentsSeparatedByString:@"&"];
 for (NSString *subResult in resultArr) {
 if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
 authCode = [subResult substringFromIndex:10];
 break;
 }
 }
 }
 NSLog(@"授权结果 authCode = %@", authCode?:@"");
 }];

 }
 return YES;
 }
 4. 、点击项目名称，点击“Info”选项卡，在“URL Types”选项中，点击“+”，在“URL Schemes”中输入“alisdkdemo”。“alisdkdemo”来自于文件“APViewController.m”的NSString *appScheme = @“alisdkdemo”;。
 
 注意：这里的URL Schemes中输入的alisdkdemo，为测试demo，实际商户的app中要填写独立的scheme，建议跟商户的app有一定的标示度，要做到和其他的商户app不重复，否则可能会导致支付宝返回的结果无法正确跳回商户app。
 5.注意  'openssl/asn1.h' file not found  在Build Setting 下 Header search paths 添加 "$(SRCROOT)/工程名/文件夹"
 6.注意  如果出现  【rsa_private read error : private key is NULL】
 1.修改 RSADataSigner 中 方法 formatPrivateKey 中
 [result appendString:@"-----BEGIN PRIVATE KEY-----\n"];
 [result appendString:@"\n-----END PRIVATE KEY-----"];
 为
 [result appendString:@"-----BEGIN RSA PRIVATE KEY-----\n"];
 [result appendString:@"\n-----END RSA PRIVATE KEY-----"];
 2.
 检查提供是私钥是否正确 */

/*
 * 支付宝支付
 * orderTitle 订单title
 * orderId    订单编号
 * orderPrice 订单价格
 * compltedHandle 操作完成回掉函数
 *
 */
- (void)alipayOrderTitle:(NSString *)orderTitle orderNumber:(NSString *)orderNumber orderPrice:(NSString *)orderPrice compltedHandle:(void (^)(PayCompltedHandle handel))compltedHandle;


/************ 微信支付 ****************/

/*
 * 微信支付
 * orderTitle 订单title
 * orderId    订单编号
 * orderPrice 订单价格
 * compltedHandle 操作完成回掉函数
 *
 */
- (void)wechatPayOrderTitle:(NSString *)orderTitle orderNumber:(NSString *)orderNumber orderPrice:(NSString *)orderPrice compltedHandle:(void (^)(PayCompltedHandle handel))compltedHandle;
//调用支付类回掉函数
@property(nonatomic,copy)void (^PayCompltedHandleBlock)(PayCompltedHandle handel);



@end
