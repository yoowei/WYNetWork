//
//  NSString+Extension.h
//  yoowei
//
//  Created by apple on 14-10-18.
//  Copyright (c) 2014年 yoowei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Extension)
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW;
- (CGSize)sizeWithFont:(UIFont *)font;

/**
 *  计算当前文件\文件夹的内容大小
 */
- (NSInteger)fileSize;
@end
