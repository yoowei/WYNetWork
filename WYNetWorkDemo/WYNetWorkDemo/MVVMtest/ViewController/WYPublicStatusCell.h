//
//  WYPublicStatusCell.h
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/3/2.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WYPublicStatusModel;
@interface WYPublicStatusCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) WYPublicStatusModel *publicStatusModel;
@end
