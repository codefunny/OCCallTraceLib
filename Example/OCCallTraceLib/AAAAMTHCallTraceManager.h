//
//  AMTHCallTraceManager.h
//  OCCallTraceLib_Example
//
//  Created by Aaron on 2021/10/12.
//  Copyright © 2021 zhengwenchao1. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AAAAMTHCallTraceManager : NSObject

+ (instancetype)sharedObject;
- (void)start;

- (void)stopAndRecordWithPath:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
