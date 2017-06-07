//
//  IPDetector.h
//  IPDetector
//
//  Created by JUN on 15/5/6.
//  Copyright (c) 2015年 com.adaxi.AdailyShop All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPDetector : NSObject


+ (void)getLANIPAddressWithCompletion:(void (^)(NSString *IPAddress))completion;

+ (void)getWANIPAddressWithCompletion:(void(^)(NSString *IPAddress))completion;

@end
