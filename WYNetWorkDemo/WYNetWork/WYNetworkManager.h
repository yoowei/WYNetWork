//
//  WYNetworkManager.h
//  WYNetwork
//
//  Created by yoowei on 16/5/31.
//  Copyright © 2016年 yoowei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "WYBaseRequest.h"

@interface WYNetworkManager : NSObject
@property (nonatomic,strong) NSMutableDictionary<NSNumber *, WYBaseRequest*> *requestsRecord;
// 本类为单例，只处理网络数据逻辑，不持有任何变量
+ (instancetype)sharedManager;

- (void)addRequest:(WYBaseRequest *)request;

- (void)cancelRequest:(WYBaseRequest *)request;

- (void)cancelAllRequests;

@end

