//
//  WYWYRequestHeadTool.h
//  WYNetwork
//
//  Created by yoowei on 15/12/24.
//  Copyright © 2015年 yoowei. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface WYRequestHeadTool : NSObject
/**
 *  网络请求的请求头
 *
 *  @return dic
 */
+ (NSDictionary*)getRequestHead;
@end
