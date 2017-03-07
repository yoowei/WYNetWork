//
//  WYPublicDetailViewController.m
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/3/7.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import "WYPublicDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+Extension.h"

@interface WYPublicDetailViewController ()
@property (strong, nonatomic)  UIImageView *headImageView;
@property (strong, nonatomic)  UILabel *userNameLabel;
@property (strong, nonatomic)  UILabel *timeLabel;
@property (strong, nonatomic)  UILabel *textLable;
@end
@implementation WYPublicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self setupOriginal];
    [self publicStatusModel:self.publicStatusModel];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupOriginal
{
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 74, 60, 60)];
    self.headImageView = iconView;
    [self.view addSubview:iconView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 74, 200, 20)];
    self.userNameLabel = nameLabel;
    [self.view addSubview:nameLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 104, 200, 20)];
    timeLabel.textColor = [UIColor orangeColor];
    self.timeLabel = timeLabel;
    [self.view addSubview:timeLabel];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 120, 300, 200)];
    contentLabel.numberOfLines=0;
    self.textLable = contentLabel;
    [self.view addSubview:contentLabel];
}

- (void)publicStatusModel:(WYPublicStatusModel *)publicStatusModel{
    
    _publicStatusModel=publicStatusModel;
    if (_publicStatusModel.imageUrl) {
        [_headImageView sd_setImageWithURL:_publicStatusModel.imageUrl placeholderImage:[UIImage imageNamed:@"hello"]];    }
    
    CGFloat cellW = [UIScreen mainScreen].bounds.size.width;
    
    if (_publicStatusModel.userName) {
        self.userNameLabel.text = _publicStatusModel.userName;
    }else{
        
        self.userNameLabel.text = @"hello,你好";
    }
    
    self.userNameLabel.font=[UIFont systemFontOfSize:14];
    CGFloat nameX = 80;
    CGFloat nameY = 74;
    CGSize nameSize = [self.userNameLabel.text sizeWithFont:[UIFont systemFontOfSize:14]];
    self.userNameLabel.frame = CGRectMake(nameX, nameY, cellW-100, nameSize.height);
    
    NSString *time;
    if (_publicStatusModel.date) {
        time = _publicStatusModel.date;
    }else{
        time =@"2017.3.3";
    }
    self.timeLabel.text = time;
    self.timeLabel.font=[UIFont systemFontOfSize:14];
    CGFloat timeX = 80;
    CGFloat timeY = CGRectGetMaxY(self.userNameLabel.frame) + 10;
    CGSize timeSize = [self.timeLabel.text sizeWithFont:[UIFont systemFontOfSize:14]];
    self.timeLabel.frame = CGRectMake(timeX, timeY, cellW-100, timeSize.height);
    
    if (_publicStatusModel.text) {
        self.textLable.text = _publicStatusModel.text;
    }else{
        self.textLable.text = @"生无可恋";
    }
    
    self.textLable.font=[UIFont systemFontOfSize:14];
    CGFloat contentX = 10;
    CGFloat contentY = MAX(CGRectGetMaxY(self.headImageView.frame), CGRectGetMaxY(self.timeLabel.frame)) + 10;
    CGFloat maxW = cellW - 2 * contentX;
    CGSize contentSize = [self.textLable.text sizeWithFont:[UIFont systemFontOfSize:14] maxW:maxW ];
    self.textLable.frame = CGRectMake(contentX, contentY, maxW, contentSize.height);
}
@end
