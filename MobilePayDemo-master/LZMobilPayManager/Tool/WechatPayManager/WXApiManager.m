//
//  WXApiManager.m
//  GoldeneyeFrame
//
//  Created by goldeneye on 2017/6/7.
//  Copyright © 2017年 ZZgoldeneye. All rights reserved.
//

#import "WXApiManager.h"

//支付通知
#define WechatPayHandle_NOTIFICATION @"WechatPayNotification"

@implementation WXApiManager

//单利模式
+ (WXApiManager*)shareInstance{
    
    static WXApiManager * manage = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[WXApiManager alloc]init];
        
    });
    
    return manage;
}
//微信支付状态返回
- (void)onResp:(BaseResp *)resp
{
    
    
    
    if ([resp isKindOfClass:[PayResp class]])
    {
        PayResp *response = (PayResp *)resp;
        
        NSLog(@"response.errCode===%d response.errStr===%@",response.errCode,response.errStr);
        //                WXSuccess           = 0,    /**< 成功    */
        //                WXErrCodeCommon     = -1,   /**< 普通错误类型    */
        //                WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
        //                WXErrCodeSentFail   = -3,   /**< 发送失败    */
        //                WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
        //                WXErrCodeUnsupport  = -5,   /**< 微信不支持    */
        //                Success ,Common ,UserCancel ,SentFail ,AuthDeny ,Unsupport
        switch (response.errCode) {
            case WXSuccess:
            {
                NSNotification *notification = [NSNotification notificationWithName:WechatPayHandle_NOTIFICATION object:@"WXSuccess"];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                
            }
                break;
            case WXErrCodeCommon:
            {
                NSNotification *notification = [NSNotification notificationWithName:WechatPayHandle_NOTIFICATION object:@"WXErrCodeCommon"];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                
            }
                break;
            case WXErrCodeUserCancel:{
                
                NSNotification *notification = [NSNotification notificationWithName:WechatPayHandle_NOTIFICATION object:@"WXErrCodeUserCancel"];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                
            }
                break;
            case WXErrCodeSentFail:
            {
                NSNotification *notification = [NSNotification notificationWithName:WechatPayHandle_NOTIFICATION object:@"WXErrCodeSentFail"];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
                break;
                
            case WXErrCodeAuthDeny:
            {
                NSNotification *notification = [NSNotification notificationWithName:WechatPayHandle_NOTIFICATION object:@"WXErrCodeAuthDeny"];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                
            }
                break;
            case WXErrCodeUnsupport:
            {
                
                NSNotification *notification = [NSNotification notificationWithName:WechatPayHandle_NOTIFICATION object:@"WXErrCodeUnsupport"];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
                break;
                
            default:
                break;
        }
        
    }
}


@end
