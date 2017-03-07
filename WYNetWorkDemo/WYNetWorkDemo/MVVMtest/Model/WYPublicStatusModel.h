//
//  WYPublicStatusModel.h
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/3/2.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface WYPublicStatusModel : NSObject
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *weiboId;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSURL *imageUrl;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *text;
@end
