//
//  WYDownLoadManager.m
//
//  Created by yoowei on 2017/2/17.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import "WYDownLoadManager.h"
#import <AFNetworking/AFNetworking.h>


static NSMutableArray *wy_requestTasks;

@implementation WYDownLoadManager

+ (instancetype)sharedManager{
    static WYDownLoadManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (wy_requestTasks == nil) {
            wy_requestTasks = [[NSMutableArray alloc] init];
        }
    });
    
    return wy_requestTasks;
}

- (void)cancelAllRequest {
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
                [task cancel];
            }
        }];
        [[self allTasks] removeAllObjects];
    };
}

- (void)cancelRequestWithURL:(NSString *)url {
    if (url == nil) {
        return;
    }
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[NSURLSessionDownloadTask class]]
                && [task.currentRequest.URL.absoluteString hasSuffix:url]) {
                [task cancel];
                [[self allTasks] removeObject:task];
                return;
            }
        }];
    };
}


- (void)stopDownloadWithUrl: (NSString *)url{

    if (url == nil) {
        return;
    }
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[NSURLSessionDownloadTask class]]
                && [task.currentRequest.URL.absoluteString hasSuffix:url]) {
                [task suspend];
                return;
            }
        }];
    };
}

- (void)startDownloadWithUrl: (NSString*)url{
    
    if (url == nil) {
        return;
    }
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[NSURLSessionDownloadTask class]]
                && [task.currentRequest.URL.absoluteString hasSuffix:url]) {
                [task resume];
                return;
            }
        }];
    };

}

- (void)stopDownloadAllRequest{
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
                [task suspend];
            }
        }];
  };
}

- (void)startDownloadAllRequest{
    @synchronized(self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
                [task resume];
            }
        }];
    };
}

- (NSURLSessionDownloadTask *)downloadWithUrl:(NSString *)url
                            saveToPath:(NSString *)saveToPath
                              progress:(WYDownloadProgress)progressBlock
                               success:(WYResponseSuccess)success
                               failure:(WYResponseFail)failure {
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *downloadRequest= [NSURLRequest requestWithURL:URL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDownloadTask *session = nil;
    
    session = [manager downloadTaskWithRequest:downloadRequest
                                      progress:^(NSProgress * _Nonnull downloadProgress) {
                                          
                                      //测试，比如说在页面上显示下载的进度，可以给Progress添加监听 KVO
                                      //回到主队列刷新UI
//                                      dispatch_async(dispatch_get_main_queue(), ^{
//                                              self.progressView.progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
//                                          });

                       //我们也可以根据传进来的BLOCK，调用BLOCK
                        if (progressBlock) {
                            // @property int64_t totalUnitCount;  需要下载文件的总大小
                            // @property int64_t completedUnitCount; 当前已经下载的大小
                            progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                        }
                                          
    }
                                   destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                       //这里很明显，要给BLOCK传递值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
                                return [NSURL URLWithString:saveToPath];
                                       
//                                       测试
//                                       NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//                                       NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
//                                       return [NSURL fileURLWithPath:path];
//     return [NSURL fileURLWithPath:path]这个NSURL 打印： file:///Users/galahad/Library/Developer/CoreSimulator/Devices/AEBC86C1-6332-4C79-B028-FD4B0BE1B50F/data/Containers/Data/Application/597D7324-4694-4070-BF94-C0EA6814C4CC/Library/Caches/bdlogo.png                                       
                                       
                                       
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
//        测试
//  filePath打印   file:///Users/galahad/Library/Developer/CoreSimulator/Devices/AEBC86C1-6332-4C79-B028-FD4B0BE1B50F/data/Containers/Data/Application/597D7324-4694-4070-BF94-C0EA6814C4CC/Library/Caches/bdlogo.png

        
         // filePath就是你下载文件的位置NSURL，你可以解压，也可以直接拿来使用
//        NSString *imgFilePath = [filePath path];// 将NSURL转成NSString
//        UIImage *img = [UIImage imageWithContentsOfFile:imgFilePath];
//        self.imageView.image = img;

        @synchronized(self) {//万一有很多操作呢？
        [[self allTasks] removeObject:session];
        }
        
        if (error == nil) {
            if (success) {
                success(filePath.absoluteString);
            }
        } else {
            [self handleCallbackWithError:error fail:failure];
        }
    }];
    
    [session resume];
    
    if (session) {
    @synchronized(self) {
    [[self allTasks] addObject:session];
    }
    }
    return session;
}

- (void)handleCallbackWithError:(NSError *)error fail:(WYResponseFail)fail {
    if (fail) {
        fail(error);
    }
}

@end
