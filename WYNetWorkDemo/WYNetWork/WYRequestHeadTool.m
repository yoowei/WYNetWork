//
//  WYRequestHeadTool.m
//  yoowei
//
//  Created by yoowei on 15/12/24.
//  Copyright © 2015年 yoowei. All rights reserved.
//

#import "WYRequestHeadTool.h"
#import <UIKit/UIKit.h>
@interface WYRequestHeadTool ()
@property (nonatomic,copy,readwrite) NSString * userAgent;
@end
@implementation WYRequestHeadTool

+ (NSString *)userAgent{
    NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [dic setValue:version forKey:@"version"];
    NSString *userAgent = [self getJsonString:dic];
    return userAgent;
}

+ (NSDictionary *)getRequestHead{
    NSDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString * userAgent = [WYRequestHeadTool userAgent];
    [dic setValue:userAgent forKey:@"User-Agent"];
//    return dic;
    return @{};
}
//字典转字符存
+ (NSString *)getJsonString:(NSDictionary *)dict
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *str    = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return str;
}
@end
