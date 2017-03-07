//
//  WYPublicRequest.m
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/3/2.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import "WYPublicRequest.h"
#import "Config.h"

@implementation WYPublicRequest
//重写父类的属性
- (NSString *)requestUrl{
    NSString*strUrl= [NSString stringWithFormat:@"%@",@"/3/statuses/public_timeline.json"];
    return strUrl;
}
- (NSString *)requestBaseUrl{
    return @"https://api.weibo.com/";
}
-(NSDictionary*)parameters{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ACCESSTOKEN;
    params[@"count"] = @"100";
    return params;
}
-(WYBaseRequestMethod)method{
    return WYBaseRequestMethodGet;
}
@end

