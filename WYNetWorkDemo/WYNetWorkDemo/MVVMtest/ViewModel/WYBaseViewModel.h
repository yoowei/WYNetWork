//
//  WYBaseViewModel.h
//  WYNetWorkDemo
//
//  Created by yoowei on 2017/3/3.
//  Copyright © 2017年 yoowei. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Config.h"

@interface WYBaseViewModel : NSObject

@property (strong, nonatomic) ReturnValueBlock returnBlock;
@property (strong, nonatomic) ErrorCodeBlock errorBlock;
@property (strong, nonatomic) FailureBlock failureBlock;

-(void) setBlockWithReturnBlock: (ReturnValueBlock) returnBlock
                 WithErrorBlock: (ErrorCodeBlock) errorBlock
               WithFailureBlock: (FailureBlock) failureBlock;
@end
