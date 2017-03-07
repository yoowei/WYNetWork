//
//  WYPublicWeiboViewModel.m
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/3/3.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import "WYPublicWeiboViewModel.h"
#import "WYPublicDetailViewController.h"
#import "WYPublicRequest.h"
@implementation WYPublicWeiboViewModel
//获取公共微博
-(void) fetchPublicWeiBo
{
    [[[WYPublicRequest alloc]init] startWithSuccess:^(WYBaseRequest * _Nonnull request, id  _Nullable responseObject) {
        [self fetchValueSuccess:responseObject];
    } failure:^(WYBaseRequest * _Nullable request, NSError * _Nonnull error) {
        self.failureBlock();
//        self.errorBlock(error);
        //假如请求失败的话，我们模拟数据
        [self getTestdate];
    }];
}


-(void)getTestdate{

    NSString *path = [[NSBundle mainBundle] pathForResource:@"homeBusiness" ofType:@"geojson"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    
    NSMutableArray *publicArry = [[NSMutableArray alloc] init];
    NSMutableArray *publicModelArry = [[NSMutableArray alloc] init];//kengdie
    
    if (dic) {
        publicArry = dic[@"data"];
        //遍历字典
        for (NSDictionary *status  in publicArry) {
            if ([status isKindOfClass:[NSDictionary class]]){
                WYPublicStatusModel *publicModel = [[WYPublicStatusModel alloc] init];
                publicModel.date = status[CREATETIME];
                publicModel.userName = status[USERNAME];
                publicModel.text = status[WEIBOTEXT];
                publicModel.imageUrl = [NSURL URLWithString:status[HEADIMAGEURL] ];
                publicModel.userId = @"101";
                publicModel.weiboId = @"101";
                [publicModelArry addObject:publicModel];
            }
        }
    }
        self.errorBlock(publicModelArry);//仅仅是进行测试
}

#pragma 获取到正确的数据，对正确的数据进行处理
-(void)fetchValueSuccess: (id) returnValue
{
    if (returnValue&&[returnValue isKindOfClass:[NSDictionary class]]) {
        
        NSArray *statuses = returnValue[STATUSES];
        
        NSMutableArray *publicModelArray = [[NSMutableArray alloc] initWithCapacity:statuses.count];
        
        for (int i = 0; i < statuses.count; i ++) {
            WYPublicStatusModel *publicModel = [[WYPublicStatusModel alloc] init];
            
         
            NSDateFormatter *iosDateFormater=[[NSDateFormatter alloc]init];
            iosDateFormater.dateFormat=@"EEE MMM d HH:mm:ss Z yyyy";
            
            //必须设置，否则无法解析
            iosDateFormater.locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
            NSDate *date=[iosDateFormater dateFromString:statuses[i][CREATETIME]];
            
            //目的格式
            NSDateFormatter *resultFormatter=[[NSDateFormatter alloc]init];
            [resultFormatter setDateFormat:@"MM月dd日 HH:mm"];
            
            publicModel.date = [resultFormatter stringFromDate:date];
            publicModel.userName = statuses[i][USER][USERNAME];
            publicModel.text = statuses[i][WEIBOTEXT];
            publicModel.imageUrl = [NSURL URLWithString:statuses[i][USER][HEADIMAGEURL]];
            publicModel.userId = statuses[i][USER][UID];
            publicModel.weiboId = statuses[i][WEIBOID];
            [publicModelArray addObject:publicModel];
        }
        
        self.returnBlock(publicModelArray);
    }
}

#pragma 跳转到详情页面，如需网路请求的，可在此方法中添加相应的网络请求
-(void) weiboDetailWithPublicModel: (WYPublicStatusModel *) publicModel WithViewController:(UIViewController *)superController
{
    WYPublicDetailViewController *detailController = [[WYPublicDetailViewController  alloc]init];
    detailController.publicStatusModel = publicModel;
    [superController.navigationController pushViewController:detailController animated:YES];
}
@end
