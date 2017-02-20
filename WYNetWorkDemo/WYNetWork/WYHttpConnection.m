//
//  WYHttpConnection.m
//  ZJHNetwork
//
//  Created by yoowei on 16/6/2.
//  Copyright © 2016年 zjh. All rights reserved.
//

#import "WYHttpConnection.h"
#import <AFNetworking/AFNetworking.h>
#import <objc/runtime.h>
#import "WYNetworkConfig.h"
#import "WYNetworkManager.h"

@implementation WYBaseRequest (WYHttpConnection)
static const char kBaseRequestConnectionKey;
- (WYHttpConnection *)connection
{
    return objc_getAssociatedObject(self, &kBaseRequestConnectionKey);
}
- (void)setConnection:(WYHttpConnection *)connection
{
    objc_setAssociatedObject(self, &kBaseRequestConnectionKey, connection, OBJC_ASSOCIATION_ASSIGN);
}
@end

@interface WYHttpConnection()

@property (nonatomic, strong, readwrite) WYBaseRequest *request;

@property (nonatomic, strong, readwrite) NSURLSessionTask *task;

@property (nonatomic, copy) ConnectionSuccessBlock success;

@property (nonatomic, copy) ConnectionFailureBlock failure;

@end

@implementation WYHttpConnection

+ (instancetype)connection{
    return [[self alloc] init];
}

- (NSDictionary *)headersWithRequest:(WYBaseRequest *)request{
    WYNetworkConfig *config = [WYNetworkConfig defaultConfig];
    
    NSMutableDictionary *headers = [@{} mutableCopy];
    [config.additionalHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [headers setObject:obj forKey:key];
    }];
    [request.headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [headers setObject:obj forKey:key];
    }];
    return headers;
}

- (NSURLSessionTask*)connectWithRequest:(WYBaseRequest *)request success:(ConnectionSuccessBlock)success failure:(ConnectionFailureBlock)failure{
    self.request = request;
    self.success = success;
    self.failure = failure;
    
    AFHTTPSessionManager *manager =[self sessionManager:request];
    NSString *urlString = request.url.absoluteString;
    //添加的百分号什么的乱七八糟的
    if (request.shouldEncode) {
        urlString = [self encodeUrl:urlString];
    }

    NSDictionary *parameters = request.parameters;
    
    __block NSURLSessionTask *dateTask = nil;
   
    switch (request.method) {
        case WYBaseRequestMethodGet:{
            dateTask = [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                if (task&&responseObject) {
                    [self handleRequestResult:task responseObject:responseObject error:nil];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (task&&error) {
                    [self handleRequestResult:task responseObject:nil error:error];
                }
            }];
        }
            break;
        case WYBaseRequestMethodPost:{
            if (request.construction) {
                //文件上传？
                dateTask = [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    request.construction(formData);
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    if (request.uploadProgress) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            request.uploadProgress(uploadProgress);
                        });
                    }
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    if (task&&responseObject) {
                        [self handleRequestResult:task responseObject:responseObject error:nil];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    if (task&&error) {
                        [self handleRequestResult:task responseObject:nil error:error];
                    }
                }];
            }else{
                dateTask = [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    if (task&&responseObject) {
                        [self handleRequestResult:task responseObject:responseObject error:nil];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    if (task&&error) {
                        [self handleRequestResult:task responseObject:nil error:error];
                    }
                }];
            }
        }
        break;
            default:{
            NSLog(@"unsupport request method");
        } break;
    }
    self.task = dateTask;
    request.connection = self;
    return dateTask;
}


-(AFHTTPSessionManager*)sessionManager:(WYBaseRequest *)request{

    WYNetworkConfig *defaultConfig = [WYNetworkConfig defaultConfig];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // request
    if (request.requestSerializerType == WYBaseRequestSerializerTypeHttp) {
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }else if(request.requestSerializerType == WYBaseRequestSerializerTypeJson){
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.requestSerializer.timeoutInterval = request.timeoutInterval ?: defaultConfig.defaultTimeoutInterval ?: 30;
    NSDictionary *headers = [self headersWithRequest:request];
    [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
            [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }else{
            NSLog(@"error request header");
        }
    }];
    // response
    if (request.responseSerializerType == WYBaseResponseSerializerTypeHttp) {
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }else if(request.responseSerializerType == WYBaseResponseSerializerTypeJson){
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }else if(request.responseSerializerType == WYBaseResponseSerializerTypeXMLParser){
        manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    }
    NSIndexSet *acceptableStatusCodes = request.acceptableStatusCodes ?: defaultConfig.defaultAcceptableStatusCodes;
    if (acceptableStatusCodes) {
        manager.responseSerializer.acceptableStatusCodes = acceptableStatusCodes;
    }
    
    NSSet *acceptableContentTypes = request.acceptableContentTypes ?: defaultConfig.defaultAcceptableContentTypes;
    if (acceptableContentTypes) {
        manager.responseSerializer.acceptableContentTypes = acceptableContentTypes;
    }
    // 设置允许同时最大并发数量，过大容易出问题
    manager.operationQueue.maxConcurrentOperationCount = 5;
    return manager;
}

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    WYBaseRequest *request;
    @synchronized(self) {
         request = [WYNetworkManager sharedManager].requestsRecord[@(task.taskIdentifier)];
    }
    if (!request) {
        return;
    }
    if (responseObject) {
     [self requestHandleSuccess:request responseObject:responseObject];
    }
    
    if (error) {
    [self requestHandleFailure:request error:error];
    }
}

- (void)requestHandleSuccess:(WYBaseRequest *)request responseObject:(id)object{
    if (self.success) {
        //将返回的结果优化
        self.success(self, [self tryToParseData:object]);
    }
}
- (void)requestHandleFailure:(WYBaseRequest *)request error:(NSError *)error{
    if (self.failure) {
        self.failure(self, error);
    }
}
- (void)cancel{
    if (self.task) {
        [self.task cancel];
        self.task = nil;
    }
}

- (NSString *)encodeUrl:(NSString *)url {
    return [self WYUrlEncode:url];
}
- (NSString *)WYUrlEncode:(NSString *)url {
    NSString *newString =
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)url,
                                                              NULL,
                                                              CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    if (newString) {
        return newString;
    }
    
    return url;
}

- (id)tryToParseData:(id)responseData {
    //这个解析以后要进行重新优化
    if ([responseData isKindOfClass:[NSData class]]) {
        // 尝试解析成JSON
        if (responseData == nil) {
            return responseData;
        } else {
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
            
            if (error != nil) {
                return responseData;
            } else {
                return response;
            }
        }
    } else {
        return responseData;
    }
}

@end
