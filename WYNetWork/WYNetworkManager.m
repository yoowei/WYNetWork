//
//  WYNetworkManager.m
//  WYNetwork
//
//  Created by yoowei on 16/5/31.
//  Copyright © 2016年 yoowei. All rights reserved.
//

#import "WYNetworkManager.h"
#import <AFNetworking/AFNetworking.h>
#import "WYNetworkConfig.h"
#import "WYHttpConnection.h"

@implementation WYNetworkManager

+ (instancetype)sharedManager{
    static WYNetworkManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)addRequest:(WYBaseRequest *)request{
    NSParameterAssert(request != nil);
    __weak typeof(self) weakSelf = self;
    [[WYHttpConnection connection] connectWithRequest:request success:^(WYHttpConnection *connection, id responseJsonObject) {
            request.running=NO;
            [weakSelf processConnection:connection withResponseJsonObject:responseJsonObject];
        
        } failure:^(WYHttpConnection *connection, NSError *error) {
            request.running=NO;
            [weakSelf processConnection:connection withError:error];
    }];
}
//成功的结果返回过来了
#pragma mark - 处理网络返回数据
- (void)processConnection:(WYHttpConnection *)connection withResponseJsonObject:(id)responseJsonObjet{
   
    WYBaseRequest *request = connection.request;
    //我是将最原始数据给到用户，要由用户自己去转化成模型
    if (request.success) {
        request.success(request,responseJsonObjet);
    }
    if ([request.delegate respondsToSelector:@selector(baseRequestDidFinishSuccess:responseObject:)]) {
        [request.delegate baseRequestDidFinishSuccess:request responseObject:responseJsonObjet];
    }
        [self clearRequestBlock:request];
 
}

- (void)processConnection:(WYHttpConnection *)connection withError:(NSError *)error{
    WYBaseRequest *request = connection.request;
    [self callbackRequestFailure:request withError:error];
}

- (void)callbackRequestFailure:(WYBaseRequest *)request withError:(NSError *)error{
    
    if (request.failure) {
        request.failure(request,error);
    }
    //供一些想用代理的地方调用
    if ([request.delegate respondsToSelector:@selector(baseRequestDidFinishFailure:error:)]) {
        [request.delegate baseRequestDidFinishFailure:request error:error];
    }
        [self clearRequestBlock:request];
}
- (void)clearRequestBlock:(WYBaseRequest *)request{
    request.success = nil;
    request.failure = nil;
    request.construction = nil;
    request.uploadProgress = nil;
}
@end
