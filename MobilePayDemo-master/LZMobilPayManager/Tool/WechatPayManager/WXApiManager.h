//
//  WXApiManager.h
//  GoldeneyeFrame
//
//  Created by goldeneye on 2017/6/7.
//  Copyright © 2017年 ZZgoldeneye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WechatPayReadme.h"

@interface WXApiManager : NSObject<WXApiDelegate>

//单利模式
+ (WXApiManager*)shareInstance;


@end
