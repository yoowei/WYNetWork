//
//  WYBaseViewModel.m
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/3/3.
//  Copyright © 2017年 yoowei. All rights reserved.
//

#import "WYBaseViewModel.h"
@implementation WYBaseViewModel

-(void) setBlockWithReturnBlock: (ReturnValueBlock) returnBlock
                 WithErrorBlock: (ErrorCodeBlock) errorBlock
               WithFailureBlock: (FailureBlock) failureBlock
{
    _returnBlock = returnBlock;
    _errorBlock = errorBlock;
    _failureBlock = failureBlock;
}

@end
