
//  WYHttpConnection.m
//  WYNetwork
//
//  Created by yoowei on 16/6/2.
//  Copyright © 2016年 yoowei. All rights reserved.
//

#import "WYHttpConnection.h"
#import <AFNetworking/AFNetworking.h>
#import <objc/runtime.h>
#import "WYNetworkConfig.h"

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
    //如果要求编码的话，再这里进行编码
    if (request.shouldEncode) {
        urlString = [self encodeUrl:urlString];
    }
    
    NSDictionary*  parameters = request.parameters;//这个要跟服务端商量好
    
    __block NSURLSessionDataTask *dateTask = nil;
    
    switch (request.method) {
        case WYBaseRequestMethodGet:{
            dateTask = [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (request&&responseObject) {
                    [self requestHandleSuccess:request responseObject:responseObject];
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (request&&error) {
                    [self requestHandleFailure:request error:error];
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
                    if (request&&responseObject) {
                    [self requestHandleSuccess:request responseObject:responseObject];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    if (request&&error) {
                        [self requestHandleFailure:request error:error];
                    }
                }];
            }else{
                dateTask = [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    if (request&&responseObject) {
                        [self requestHandleSuccess:request responseObject:responseObject];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    if (request&&error) {
                        [self requestHandleFailure:request error:error];
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
    /*request
     AFHTTPRequestSerializer是用于构建NSURLRequest的类，通过-init:方法进行初始化，指定编码方式为NSUTF-8。
     HTTP请求分为请求头和请求体，请求头主要包含以下字段：
     User-Agent、Pragma、Content-Type、Content-Length、Accept-Language、Accept、Accept-Encoding、Cookie 。
     init方法，指定了请求头的Accept-Language，根据版本号、操作系统版本、设备屏幕scale等信息生成User-Agent，然后设置一些参数，
     如HTTPMethodsEncodingParametersInURI包含了指定的HTTP method，mutableObservedChangedKeyPaths存放监听到的属性，
     同时开始kvo监听。接着判断当前http请求的method是否包含在HTTPMethodsEncodingParametersInURI中，如果是GET请求，则会将参
     数拼在url后面，因为GET请求不设置http的request body。如果是POST请求，则将query字符串序列化成nsdata后，设置为http的
     request body。
     有两个子类继承了AFHTTPRequestSerializer类，即AFJSONRequestSerializer和AFPropertyListRequestSerializer，都重写
     了父类的方法，下面看一下AFJSONRequestSerializer的方法：分析该方法，当http的method是POST类型时，
     AFJSONRequestSerializer和父类的处理不同，该方法将parameters序列化为JSON数据，设置为http的请求体，且请求头的"Content-
     Type"参数设置为"application/json"。
     */
    if (request.requestSerializerType == WYBaseRequestSerializerTypeHttp) {
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }else if(request.requestSerializerType == WYBaseRequestSerializerTypeJson){
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
//  manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;//这个其实没有必要，AFHTTPRequestSerializer初始化的时候，已经设置过了。
//  manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithArray:@[@"POST", @"GET", @"HEAD"]];//一般的服务器不推荐使用put和delete，所以这里就没有添加。这个设置是将post请求参数也拼接在url后面，注意AFHTTPRequestSerializer选择要注意。

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
