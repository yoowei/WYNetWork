//
//  ViewController.m
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/2/17.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import "ViewController.h"
#import "WYNetwork.h"
#import "WYTestRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  UIButton *testBtn=  [UIButton buttonWithType:UIButtonTypeCustom];
  testBtn.frame=CGRectMake(100, 200, 100, 100);
  [testBtn setTitle:@"点击测试" forState:UIControlStateNormal];
    [testBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
  [testBtn addTarget:self action:@selector(downTest) forControlEvents:UIControlEventTouchDown];
 [self.view addSubview:testBtn];
    
}

-(void)downTest{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    //要监控网络连接状态，必须要先调用单例的startMonitoring方法
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWiFi) {
            [self downFromServer];
        }
    }];
}
- (void)downFromServer{
    
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
   
    [[WYDownLoadManager sharedManager]  downloadWithUrl:@"http://www.baidu.com/img/bdlogo.png" saveToPath:cachesPath progress:^(int64_t bytesRead, int64_t totalBytesRead) {
        
        NSLog(@"%f",1.0 * bytesRead / totalBytesRead);

        
    } success:^(id success) {
        
         NSLog(@"responseObject success obj:%@",success);
        
    } failure:^(NSError *error) {
        
         NSLog(@"responseObject error obj:%@",error);
        
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[[WYTestRequest alloc]init] startWithSuccess:^(WYBaseRequest * _Nonnull request, id  _Nullable responseObject) {
        
         NSLog(@"responseObject success obj:%@",responseObject);
        
    } failure:^(WYBaseRequest * _Nullable request, NSError * _Nonnull error) {
         NSLog(@"responseObject request error:%@",error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
