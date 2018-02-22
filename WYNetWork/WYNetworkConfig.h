//
//  WYNetworkConfig.h
//  WYNetwork
//
//  Created by yoowei on 16/6/1.
//  Copyright © 2016年 yoowei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYNetworkConfig : NSObject

+ (instancetype)defaultConfig;

// 每个request都会加上的headers

@property (nonatomic, strong) NSDictionary *additionalHeaders;

@property (nonatomic, assign) NSTimeInterval defaultTimeoutInterval;

@property (nonatomic, strong) NSIndexSet *defaultAcceptableStatusCodes;

@property (nonatomic, strong) NSSet *defaultAcceptableContentTypes;

@property (nonatomic, strong) NSString *baseUrl;

@property (nonatomic, strong) NSString *cdnUrl;

@end
