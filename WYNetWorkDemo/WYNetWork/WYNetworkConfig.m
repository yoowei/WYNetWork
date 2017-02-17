//
//  WYNetworkConfig.m
//  ZJHNetwork
//
//  Created by yoowei on 16/6/1.
//  Copyright © 2016年 yoowei. All rights reserved.
//

#import "WYNetworkConfig.h"
@implementation WYNetworkConfig

+ (instancetype)defaultConfig{
    static WYNetworkConfig *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
        [_instance setDefault];
    });
    return _instance;
}
- (void)setDefault{
    self.additionalHeaders = @{};
    self.defaultTimeoutInterval = 25;
    self.defaultAcceptableStatusCodes  = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    self.defaultAcceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/xml", @"text/plain", @"text/json", @"text/javascript", @"image/png", @"image/jpeg", @"application/json",@"image/*", nil];
}
@end
