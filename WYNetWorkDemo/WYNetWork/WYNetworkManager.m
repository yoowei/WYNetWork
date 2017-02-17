//
//  WYNetworkManager.m
//  ZJHNetwork
//
//  Created by yoowei on 16/5/31.
//  Copyright © 2016年 zjh. All rights reserved.
//

#import "WYNetworkManager.h"
#import <AFNetworking/AFNetworking.h>
#import "WYNetworkConfig.h"
#import "WYHttpConnection.h"
//#import "HttpRetry.h"

@implementation WYNetworkManager {
    NSMutableDictionary<NSNumber *, WYBaseRequest*> *_requestsRecord;
}

+ (instancetype)sharedManager{
    static WYNetworkManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestsRecord = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addRequest:(WYBaseRequest *)request{
    
    NSParameterAssert(request != nil);
    __weak typeof(self) weakSelf = self;
    
    request.requestTask= [[WYHttpConnection connection] connectWithRequest:request success:^(WYHttpConnection *connection, id responseJsonObject) {
            [weakSelf processConnection:connection withResponseJsonObject:responseJsonObject];
        } failure:^(WYHttpConnection *connection, NSError *error) {
            [weakSelf processConnection:connection withError:error];
    }];
    
    NSAssert(request.requestTask != nil, @"requestTask should not be nil");
    
    // Set request task priority
    // !!Available on iOS 8 +
    if ([request.requestTask respondsToSelector:@selector(priority)]) {
        switch (request.requestPriority) {
            case YTKRequestPriorityHigh:
                request.requestTask.priority = NSURLSessionTaskPriorityHigh;
                break;
            case YTKRequestPriorityLow:
                request.requestTask.priority = NSURLSessionTaskPriorityLow;
                break;
            case YTKRequestPriorityDefault:
                /*!!fall through*/
            default:
                request.requestTask.priority = NSURLSessionTaskPriorityDefault;
                break;
        }
    }
    [self addRequestToRecord:request];
    [request.requestTask resume];
}

- (void)addRequestToRecord:(WYBaseRequest *)request {
    @synchronized(self) {
    _requestsRecord[@(request.requestTask.taskIdentifier)] = request;
    };
}

- (void)removeRequestFromRecord:(WYBaseRequest *)request {
     @synchronized(self) {
    [_requestsRecord removeObjectForKey:@(request.requestTask.taskIdentifier)];
     };
}

- (void)cancelRequest:(WYBaseRequest *)request {
    NSParameterAssert(request != nil);
    if (request.connection) {
        [request.connection cancel];
    }
    request.delegate = nil;
    [self removeRequestFromRecord:request];
    [self clearRequestBlock:request];
}

- (void)cancelAllRequests {
    NSArray *allKeys;
    @synchronized(self) {
    allKeys = [_requestsRecord allKeys];
    };
    if (allKeys && allKeys.count > 0) {
        NSArray *copiedKeys = [allKeys copy];
        for (NSNumber *key in copiedKeys) {
            WYBaseRequest *request;
            @synchronized(self) {
            request = _requestsRecord[key];
            }
            [self cancelRequest:request];
        }
    }
}

//成功的结果返回过来了？
#pragma mark - 处理网络返回数据
- (void)processConnection:(WYHttpConnection *)connection withResponseJsonObject:(id)responseJsonObjet{
    WYBaseRequest *request = connection.request;
      if (nil != responseJsonObjet && ![[responseJsonObjet objectForKey:@"result"] isKindOfClass:[NSDictionary class]]) {
        int state = [[responseJsonObjet objectForKey:@"result"] intValue];
        if (state == 9999) {
            //这个可以地方需要自动重新进行网络请求
            }
        }
    
    if (request.success) {
        request.success(request,responseJsonObjet);
    }
    if ([request.delegate respondsToSelector:@selector(baseRequestDidFinishSuccess:responseObject:)]) {
        [request.delegate baseRequestDidFinishSuccess:request responseObject:responseJsonObjet];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeRequestFromRecord:request];
        [self clearRequestBlock:request];
    });
}

- (void)processConnection:(WYHttpConnection *)connection withError:(NSError *)error{
    
    WYBaseRequest *request = connection.request;
    [self callbackRequestFailure:request withError:error];
}

- (void)callbackRequestFailure:(WYBaseRequest *)request withError:(NSError *)error{
    
    if (request.failure) {
        request.failure(request,error);
    }
    if ([request.delegate respondsToSelector:@selector(baseRequestDidFinishFailure:error:)]) {
        [request.delegate baseRequestDidFinishFailure:request error:error];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeRequestFromRecord:request];
        [self clearRequestBlock:request];
    });
}

- (void)clearRequestBlock:(WYBaseRequest *)request{
    request.success = nil;
    request.failure = nil;
    request.construction = nil;
    request.uploadProgress = nil;
}
@end
