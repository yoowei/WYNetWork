//
//  WYHttpConnection.h
//  WYNetwork
//
//  Created by yoowei on 16/6/2.
//  Copyright © 2016年 yoowei. All rights reserved.
//

// 此类解析BaseRequest的内容，与网络直接通讯，并返回结果，不处理业务逻辑

#import <Foundation/Foundation.h>
#import "WYBaseRequest.h"

@class WYHttpConnection;

typedef void(^ConnectionSuccessBlock)(WYHttpConnection *connection, id responseJsonObject);
typedef void(^ConnectionFailureBlock)(WYHttpConnection *connection, NSError *error);

@interface WYBaseRequest (WYHttpConnection)
@property (nonatomic, strong, readonly) WYHttpConnection *connection;
@end

@interface WYHttpConnection : NSObject
@property (nonatomic, strong, readonly) WYBaseRequest *request;
@property (nonatomic, strong, readwrite) NSURLSessionDataTask *task;
+ (instancetype)connection;
- (NSURLSessionTask*)connectWithRequest:(WYBaseRequest *)request success:(ConnectionSuccessBlock)success failure:(ConnectionFailureBlock)failure;
- (void)cancel;
@end


