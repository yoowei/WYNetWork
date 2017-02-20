//
//  WYTestRequest.m
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/2/20.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import "WYTestRequest.h"
@implementation WYTestRequest
//http://webservice.36wu.com/MobilePhoneService.asmx/getInfoByMobilePhone

//重写父类的属性
- (NSString *)requestUrl{
    NSString*strUrl= [NSString stringWithFormat:@"%@",@"MobilePhoneService.asmx/getInfoByMobilePhone"];
    return strUrl;
}
- (NSString *)requestBaseUrl{
    return @"http://webservice.36wu.com/";
}
-(NSDictionary*)parameters{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"PhoneNumber"] = @"13858782424";
    params[@"UserId"] = @"";
    return params;
}

@end
