//
//  WYDownLoadManager.h
//
//  Created by yoowei on 2017/2/17.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


@interface WYDownLoadManager : NSObject
typedef void(^WYResponseSuccess)(id response);
typedef void(^WYResponseFail)(NSError *error);
typedef void(^WYDownloadProgress)(int64_t bytesRead,int64_t totalBytesRead);

+ (instancetype)sharedManager;

- (NSURLSessionDownloadTask *)downloadWithUrl:(NSString *)url
                            saveToPath:(NSString *)saveToPath
                              progress:(WYDownloadProgress)progressBlock
                               success:(WYResponseSuccess)success
                               failure:(WYResponseFail)failure;

/**
 *	取消所有请求
 */
- (void)cancelAllRequest;
/**
 *	取消某个请求。如果是要取消某个请求，最好是引用接口所返回来的HYBURLSessionTask对象，
 *  然后调用对象的cancel方法。如果不想引用对象，这里额外提供了一种方法来实现取消某个请求
 *
 *	@param url				URL，可以是绝对URL，也可以是path（也就是不包括baseurl）
 */
- (void)cancelRequestWithURL:(NSString *)url;

- (void)stopDownloadWithUrl: (NSString *)url;//暂停某一个

- (void)startDownloadWithUrl: (NSString*)url;//开始某一个

- (void)stopDownloadAllRequest;//暂停所有

- (void)startDownloadAllRequest;//重新所有

@end

