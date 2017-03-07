//
//  WYPublicWeiboViewModel.h
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/3/3.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYBaseViewModel.h"
#import "WYPublicStatusModel.h"

@interface WYPublicWeiboViewModel : WYBaseViewModel
//获取微博列表
-(void) fetchPublicWeiBo;

//跳转到微博详情页
-(void) weiboDetailWithPublicModel: (WYPublicStatusModel *) publicModel WithViewController: (UIViewController *)superController;
@end
