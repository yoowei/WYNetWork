//
//  WYHttpConnection.h
//  WYNetwork
//
//  Created by yoowei on 16/6/2.
//  Copyright © 2016年 yoowei. All rights reserved.
//

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

+ (instancetype)connection;
- (NSURLSessionTask*)connectWithRequest:(WYBaseRequest *)request success:(ConnectionSuccessBlock)success failure:(ConnectionFailureBlock)failure;
- (void)cancel;
@end


