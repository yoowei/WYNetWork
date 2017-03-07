//
//  WYPublicTableViewController.h
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/3/3.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import "WYPublicTableViewController.h"
#import "WYPublicWeiboViewModel.h"
#import "WYPublicStatusCell.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface WYPublicTableViewController ()
@property (strong, nonatomic) NSArray *publicModelArray;
@end
@implementation WYPublicTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    WYPublicWeiboViewModel *publicViewModel = [[WYPublicWeiboViewModel alloc] init];
    [publicViewModel setBlockWithReturnBlock:^(id returnValue) {
        [SVProgressHUD dismiss];
        if (returnValue&&[returnValue isKindOfClass:[NSArray class]]) {
        _publicModelArray = returnValue;
        }
        [self.tableView reloadData];
        
    } WithErrorBlock:^(id errorCode) {
        
        [SVProgressHUD dismiss];
        //这个是我弄的本地数据进行测试****
        if (errorCode&&[errorCode isKindOfClass:[NSArray class]]) {
            _publicModelArray = errorCode;
        }
        [self.tableView reloadData];
        //这个是我弄的本地数据进行测试****
        
    } WithFailureBlock:^{
        [SVProgressHUD dismiss];
    }];
    
    //先来到这里，获取微博数据
    [publicViewModel fetchPublicWeiBo];
    
    [SVProgressHUD showWithStatus:@"正在获取用户信息……"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _publicModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获得cell
    WYPublicStatusCell *cell = [WYPublicStatusCell cellWithTableView:tableView];
    
    // 给cell传递模型数据
    cell.publicStatusModel = _publicModelArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WYPublicWeiboViewModel *publicViewModel = [[WYPublicWeiboViewModel alloc] init];
    [publicViewModel weiboDetailWithPublicModel:_publicModelArray[indexPath.row] WithViewController:self];
}
@end
