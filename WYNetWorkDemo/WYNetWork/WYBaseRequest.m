//
//  WYBaseRequest.m
//  ZJHNetwork
//
//  Created by yoowei on 16/5/31.
//  Copyright © 2016年 zjh. All rights reserved.
//

#import "WYBaseRequest.h"
#import "WYNetworkManager.h"
#import "WYHttpConnection.h"
#import "WYRequestHeadTool.h"

@interface WYBaseRequest()

@end

@implementation WYBaseRequest

// request config
- (WYBaseRequestMethod)method{
    return WYBaseRequestMethodPost;
}
- (NSString *)requestBaseUrl{
    return @"";
}
- (NSString *)requestUrl{
    return @"";
}
- (NSDictionary *)headers{
    return [WYRequestHeadTool getRequestHead];
}
- (WYBaseRequestSerializerType)requestSerializerType{
    return WYBaseRequestSerializerTypeHttp;
}
- (NSTimeInterval)timeoutInterval{
    return 60;
}
- (BOOL)isShouldEncode {
    return NO;
}
- (NSURL *)url{
    NSString *urlString = self.requestUrl;
    if (self.requestBaseUrl.length > 0) {
        urlString = [NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:self.requestBaseUrl]].absoluteString;
    }
    return [NSURL URLWithString:urlString];
}

//respond
- (WYBaseResponseSerializerType)responseSerializerType{
    return WYBaseResponseSerializerTypeJson;
}
// function
- (void)start{
    if (self.running) {return;}
    self.running = YES;
    [[WYNetworkManager sharedManager] addRequest:self];
}
- (void)startWithSuccess:(WYSuccessBlock)success failure:(WYFailureBlock)failure{
    self.success = [success copy];
    self.failure = [failure copy];
    [self start];
}
- (void)startWithSuccess:(WYSuccessBlock)success failure:(WYFailureBlock)failure construction:(ConstructionBlock)construction uploadProgress:(UploadProgressBlock)uploadProgress{
    self.construction = construction;
    self.uploadProgress = uploadProgress;
    [self startWithSuccess:success failure:failure];
}
- (void)stop{
    if (self.cancelling) {return;}
    self.cancelling = YES;
    [[WYNetworkManager sharedManager] cancelRequest:self];
    self.cancelling = NO;
}
@end
