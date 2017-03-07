//
//  WYPublicStatusCell.m
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/3/2.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import "WYPublicStatusCell.h"
#import "WYPublicStatusModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+Extension.h"
@interface WYPublicStatusCell()
@property (strong, nonatomic)  UILabel *userNameLble;
@property (strong, nonatomic)  UILabel *dateLable;
@property (strong, nonatomic)  UIImageView *headImageView;
@property (strong, nonatomic)  UILabel *weiboText;
@end

@implementation WYPublicStatusCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"wystatus";
    WYPublicStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[WYPublicStatusCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

/**
 *  cell的初始化方法，一个cell只会调用一次
 *  一般在这里添加所有可能显示的子控件，以及子控件的一次性设置
 */
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        // 设置选中时的背景为蓝色
        //        UIView *bg = [[UIView alloc] init];
        //        bg.backgroundColor = [UIColor blueColor];
        //        self.selectedBackgroundView = bg;
        //注意selectedBackgroundView属性很有用处
        
        // 以下这个做法不行
        //        self.selectedBackgroundView.backgroundColor = [UIColor blueColor];
        [self setupOriginal];
    }
    return self;
}

- (void)setupOriginal
{
 
    UIImageView *iconView = [[UIImageView alloc] init];
    [self.contentView addSubview:iconView];
    self.headImageView = iconView;
    self.headImageView.frame = CGRectMake(10, 10, 35, 35);
    
  
    UILabel *nameLabel = [[UILabel alloc] init];
    [self.contentView addSubview:nameLabel];
    self.userNameLble = nameLabel;
    self.userNameLble.frame = CGRectMake(55, 10, 100, 20);
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.textColor = [UIColor orangeColor];
    [self.contentView addSubview:timeLabel];
    self.dateLable = timeLabel;
    self.dateLable.frame = CGRectMake(55, 30, 100, 20);
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.numberOfLines=0;
    [self.contentView addSubview:contentLabel];
    self.weiboText = contentLabel;
    self.weiboText.frame = CGRectMake(10, 10, 200, 200);
}


- (void)setPublicStatusModel:(WYPublicStatusModel *)publicStatusModel//重写set方法后，再进行赋值
{
    _publicStatusModel=publicStatusModel;
    if (_publicStatusModel.imageUrl) {
      [_headImageView sd_setImageWithURL:_publicStatusModel.imageUrl placeholderImage:[UIImage imageNamed:@"hello"]];
    }

    CGFloat cellW = [UIScreen mainScreen].bounds.size.width;
 
    if (_publicStatusModel.userName) {
        self.userNameLble.text = _publicStatusModel.userName;
    }else{
    
    self.userNameLble.text = @"hello,你好";
    }
    
    self.userNameLble.font=[UIFont systemFontOfSize:14];
    CGFloat nameX = 55;
    CGFloat nameY = 10;
    CGSize nameSize = [self.userNameLble.text sizeWithFont:[UIFont systemFontOfSize:14]];
    self.userNameLble.frame = CGRectMake(nameX, nameY, cellW-100, nameSize.height);
    
    NSString *time;
    if (_publicStatusModel.date) {
        time = _publicStatusModel.date;
    }else{
        time =@"2017.3.3";
    }
    self.dateLable.text = time;
    self.dateLable.font=[UIFont systemFontOfSize:14];
    CGFloat timeX = 55;
    CGFloat timeY = CGRectGetMaxY(self.userNameLble.frame) + 10;
    CGSize timeSize = [time sizeWithFont:[UIFont systemFontOfSize:14]];
    self.dateLable.frame = CGRectMake(timeX, timeY, cellW-100, timeSize.height);

    if (_publicStatusModel.text) {
        self.weiboText.text = _publicStatusModel.text;
    }else{
        self.weiboText.text = @"生无可恋";
    }
    
    self.weiboText.font=[UIFont systemFontOfSize:14];
    CGFloat contentX = 10;
    CGFloat contentY = MAX(CGRectGetMaxY(self.headImageView.frame), CGRectGetMaxY(self.dateLable.frame)) + 10;
    CGFloat maxW = cellW - 2 * contentX;
    CGSize contentSize = [self.weiboText.text sizeWithFont:[UIFont systemFontOfSize:14] maxW:maxW ];
    self.weiboText.frame = CGRectMake(contentX, contentY, maxW, contentSize.height);
}

@end
