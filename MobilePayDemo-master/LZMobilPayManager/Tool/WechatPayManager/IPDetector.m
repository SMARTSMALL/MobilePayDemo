//
//  IPDetector.m
//  IPDetector
//
//  Created by JUN on 15/5/6.
//  Copyright (c) 2015年 com.adaxi.AdailyShop All rights reserved.
//

#import "IPDetector.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation IPDetector


+ (void)getLANIPAddressWithCompletion:(void (^)(NSString * IPAddress))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * IP = [self getIPAddress];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(IP);
            }
        });
    });
}

+ (void)getWANIPAddressWithCompletion:(void(^)(NSString * IPAddress))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString * IP             = @"0.0.0.0";
        NSURL * url               = [NSURL URLWithString:@"http://ifconfig.me/ip"];
        NSURLRequest * request    = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
        NSURLResponse * response  = nil;
        NSError * error = nil;
        NSData * data             = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if (error) {
        } else {
            NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            IP                    = responseStr;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(IP);
        });
    });
}

+ (NSString *)getIPAddress
{
    NSString * address                          = @"error";
    struct ifaddrs *interfaces                  = NULL;
    struct ifaddrs *temp_addr                   = NULL;
    int success                                 = 0;
    success                                     = getifaddrs(&interfaces);
    if (success == 0) {
        temp_addr                               = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    address                     = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr                           = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return address;
}



@end
