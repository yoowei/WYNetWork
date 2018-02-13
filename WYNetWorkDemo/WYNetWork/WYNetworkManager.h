//
//  WYNetworkManager.h
//  WYNetwork
//
//  Created by yoowei on 16/5/31.
//  Copyright © 2016年 yoowei. All rights reserved.
//

#import <Foundation/Foundation.h>
@class  WYBaseRequest;
@interface WYNetworkManager : NSObject
// 本类为单例，只处理网络数据逻辑，不持有任何变量
+ (instancetype)sharedManager;
- (void)addRequest:(WYBaseRequest *)request;
@end

