//
//  WYBaseRequest.H
//  WYNetwork
//
//  Created by yoowei on 16/5/31.
//  Copyright © 2016年 yoowei. All rights reserved.
//

// 此类封装请求参数与返回结果，结果可转为model，也可直接使用字典

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
@class WYBaseRequest;
/**
 *  请求类型 HTTP Request method.
 */
typedef NS_ENUM(NSUInteger, WYBaseRequestMethod) {
    WYBaseRequestMethodGet  = 0, //get请求
    WYBaseRequestMethodPost    //post请求
};
/**
 *  请求格式 Request serializer type.
 */
typedef NS_ENUM(NSUInteger, WYBaseRequestSerializerType) {
    WYBaseRequestSerializerTypeHttp = 0,// text/html,NSData
    WYBaseRequestSerializerTypeJson
};
/**
 *  返回格式 Response serializer type
 */

typedef NS_ENUM(NSUInteger, WYBaseResponseSerializerType) {
    WYBaseResponseSerializerTypeHttp,      // NSData type
    WYBaseResponseSerializerTypeJson,      // JSON object type
    WYBaseResponseSerializerTypeXMLParser  // NSXMLParser type
};

/**
 *  Request priority
 */
typedef NS_ENUM(NSInteger, WYRequestPriority) {
    WYRequestPriorityLow = -4L,
    WYRequestPriorityDefault = 0,
    WYRequestPriorityHigh = 4
};


//将WYBaseRequest返回来备用
typedef void(^WYSuccessBlock)(WYBaseRequest * _Nonnull  request,id _Nullable responseObject);
typedef void(^WYFailureBlock)(WYBaseRequest * _Nullable request,NSError *_Nonnull error);
typedef void(^ConstructionBlock)(id<AFMultipartFormData> _Nonnull formData);
typedef void(^UploadProgressBlock)(NSProgress * _Nonnull progress);


//供一些想用代理的地方用(后续可能某个地方能够用到)
@protocol WYBaseRequestDelegate <NSObject>
@optional
- (void)baseRequestDidFinishSuccess:(WYBaseRequest *_Nonnull)request responseObject:(id _Nullable)responseObject;
- (void)baseRequestDidFinishFailure:(WYBaseRequest *_Nonnull)request error:(NSError*_Nonnull)error;
@end


@interface WYBaseRequest : NSObject

// status
@property (nonatomic, assign, getter=isRunning)    BOOL running;
@property (nonatomic, assign, getter=isCancelling) BOOL cancelling;
//是否URLEncode，采用UTF-8编码
@property (nonatomic, assign, getter=isShouldEncode) BOOL shouldEncode;
@property (nonatomic, assign, getter=isUseCDN) BOOL useCDN;

// request config

@property (nonatomic, assign) WYRequestPriority requestPriority;
@property (nonatomic, assign) WYBaseRequestSerializerType requestSerializerType;
@property (nonatomic, assign) WYBaseRequestMethod method;
@property (nonatomic, copy,nullable) NSString *requestBaseUrl;
@property (nonatomic, copy,nullable) NSString *requestUrl;
@property (nonatomic, strong,nullable) NSDictionary*parameters;
@property (nonatomic, strong,nullable) NSDictionary *headers;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, strong, readonly,nullable) NSURL *url;

///  Request CDN URL. Default is empty string.
@property (nonatomic, copy) NSString * _Nullable cdnUrl;

// response
@property (nonatomic, assign) WYBaseResponseSerializerType responseSerializerType;
@property (nonatomic, strong,nullable) NSIndexSet *acceptableStatusCodes;
@property (nonatomic, strong,nullable) NSSet<NSString *> *acceptableContentTypes;
@property (nonatomic, assign, readonly) NSInteger responseStatusCode;//
@property (nonatomic, strong, readonly) NSDictionary * _Nullable responseHeaders;//


// callback
@property (nonatomic, copy,nullable) WYSuccessBlock success;
@property (nonatomic, copy,nullable) WYFailureBlock failure;
@property (nonatomic, copy,nullable) ConstructionBlock construction;
@property (nonatomic, copy,nullable) UploadProgressBlock uploadProgress;
@property (nonatomic, weak,nullable) id<WYBaseRequestDelegate> delegate;

// function
- (void)start;
- (void)startWithSuccess:(nullable WYSuccessBlock)success failure:(nullable WYFailureBlock)failure;
- (void)startWithSuccess:(nullable WYSuccessBlock)success failure:(nullable WYFailureBlock)failure construction:(nullable ConstructionBlock)construction uploadProgress:(nullable UploadProgressBlock)uploadProgress;
- (void)stop;

@end
