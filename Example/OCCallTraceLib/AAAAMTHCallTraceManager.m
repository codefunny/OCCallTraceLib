//
//  AMTHCallTraceManager.m
//  OCCallTraceLib_Example
//
//  Created by Aaron on 2021/10/12.
//  Copyright © 2021 zhengwenchao1. All rights reserved.
//

#import "AAAAMTHCallTraceManager.h"
#import <OCCallTraceLib/AMTHCallTrace.h>
#import <OCCallTraceLib/AMTHCallTraceTimeCostModel.h>


@implementation AAAAMTHCallTraceManager

+ (void)load {
    [[AAAAMTHCallTraceManager sharedObject] start];
}

+ (instancetype)sharedObject
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)start {
    [AMTHCallTrace configureTraceMaxDepth:20];
    [AMTHCallTrace configureTraceTimeThreshold:1];
    [AMTHCallTrace startAtOnce];
}

- (void)stopAndRecordWithPath:(NSString *)name {
    
    [AMTHCallTrace disable];
    NSArray<AMTHCallTraceTimeCostModel *> *records = [AMTHCallTrace records];
    NSArray<AMTHCallTraceTimeCostModel *> *prettyRecords = [AMTHCallTrace prettyRecords];
    
    NSLog(@"records:%@",records);
    NSLog(@"prettyRecords:%@",prettyRecords);
}

@end
