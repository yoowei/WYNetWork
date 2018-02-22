//
//  WYBaseRequest.m
//  WYNetwork
//
//  Created by yoowei on 16/5/31.
//  Copyright © 2016年 yoowei. All rights reserved.
//

#import "WYBaseRequest.h"
#import "WYNetworkManager.h"
#import "WYHttpConnection.h"
#import "WYRequestHeadTool.h"
#import "WYNetworkConfig.h"

@interface WYBaseRequest()

@end

@implementation WYBaseRequest{
    
    WYNetworkConfig *_config;
}
// request config
- (WYBaseRequestMethod)method{//默认用post请求
    return WYBaseRequestMethodPost;
}
- (NSString *)requestBaseUrl{
    return @"";
}
- (NSString *)requestUrl{
    return @"";
}
//set方法没有返回值的，get方法是有返回值的
- (BOOL)isUseCDN {//默认不使用CDN，如果有的话，可以再具体的请求类里面进行设置
    return NO;
}
- (NSString *)cdnUrl {
    return @"";
}
- (NSDictionary *)headers{
    return [WYRequestHeadTool getRequestHead];
}
- (WYBaseRequestSerializerType)requestSerializerType{
// AFN post请求的话，默认参数是以Dictionary的形式传入，是用表单参数的方式序列化为 POST body 来提交的。如果我们的服务端期待的是 POST body 直接是 JSON 格式这种形式的话，需要设置为WYBaseRequestSerializerTypeJson。否则可能会报500 Internal Server Error。
    return WYBaseRequestSerializerTypeHttp;
}
- (NSTimeInterval)timeoutInterval{
    return 60;
}
- (BOOL)isShouldEncode {//默认url不进行编码，应该和服务端商量
    return NO;
}
- (NSURL *)url{
    NSString *baseUrl;
    if (self.isUseCDN) {
        if (self.cdnUrl.length > 0) {
            baseUrl = self.cdnUrl;
        } else {
            baseUrl = _config.cdnUrl;
        }
    } else {
        if (self.requestBaseUrl.length > 0) {
            baseUrl = self.requestBaseUrl;
        } else {
            baseUrl = _config.baseUrl;
        }
    }
    
    NSString *urlString = self.requestUrl;
    urlString = [NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:baseUrl]].absoluteString;
    
    return [NSURL URLWithString:urlString];
}

//respond
- (WYBaseResponseSerializerType)responseSerializerType{
    return WYBaseResponseSerializerTypeHttp;
}

// response
- (NSInteger)responseStatusCode{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.connection.task.response;
    return response.statusCode;
}
- (NSDictionary *)responseHeaders{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.connection.task.response;
    return response.allHeaderFields;
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
    if (self.connection) {
        [self.connection cancel];
    }
    self.cancelling = NO;
}
@end
