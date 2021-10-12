//
// Copyright (c) 2008-present, Meitu, Inc.
// All rights reserved.
//
// This source code is licensed under the license found in the LICENSE file in
// the root directory of this source tree.
//
// Created on: 01/11/2017
// Created by: EuanC
//


#import "AMTHCallTrace.h"
#import <objc/runtime.h>
#import <sys/time.h>

#import "AMTHCallTraceCore.h"
#import "AMTHCallTraceTimeCostModel.h"


NSString *const kAHawkeyeCalltraceAutoLaunchKey = @"mth-calltrace-auto-launch-enabled";
NSString *const kAHawkeyeCalltraceMaxDepthKey = @"mth-calltrace-max-depth";
NSString *const kAHawkeyeCalltraceMinCostKey = @"mth-calltrace-min-cost";


@implementation AMTHCallTrace

+ (void)setAutoStartAtLaunchEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kAHawkeyeCalltraceAutoLaunchKey];
}

+ (BOOL)autoStartAtLaunchEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kAHawkeyeCalltraceAutoLaunchKey];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL needStart = [[NSUserDefaults standardUserDefaults] boolForKey:kAHawkeyeCalltraceAutoLaunchKey];
        if (needStart) {
            [self startAtOnce];
        }
    });
}

+ (void)startAtOnce {
    if (amth_calltraceRunning())
        return;

    CGFloat costInMS = [[NSUserDefaults standardUserDefaults] floatForKey:kAHawkeyeCalltraceMinCostKey];
    NSInteger depth = [[NSUserDefaults standardUserDefaults] integerForKey:kAHawkeyeCalltraceMaxDepthKey];
    [self configureTraceTimeThreshold:costInMS];
    [self configureTraceMaxDepth:depth];
    [self start];
}

+ (void)disable {
    amth_calltraceStop();
}

+ (void)enable {
    amth_calltraceStart();
}

+ (BOOL)isRunning {
    return amth_calltraceRunning();
}

+ (void)start {
    amth_calltraceStart();
}

+ (void)configureTraceAll {
    amth_calltraceTraceAll();
}

+ (void)configureTraceByThreshold {
    amth_calltraceTraceByThreshold();
}

+ (void)configureTraceMaxDepth:(NSInteger)depth {
    if (depth > 0) {
        amth_calltraceConfigMaxDepth((int)depth);
        [[NSUserDefaults standardUserDefaults] setInteger:depth forKey:kAHawkeyeCalltraceMaxDepthKey];
    }
}

+ (void)configureTraceTimeThreshold:(double)timeInMS {
    if (timeInMS > 0.f) {
        amth_calltraceConfigTimeThreshold((uint32_t)(timeInMS * 1000));
        [[NSUserDefaults standardUserDefaults] setFloat:timeInMS forKey:kAHawkeyeCalltraceMinCostKey];
    }
}

+ (void)stop {
    amth_calltraceStop();
}

+ (int)currentTraceMaxDepth {
    return amth_calltraceMaxDepth();
}

+ (double)currentTraceTimeThreshold {
    return amth_calltraceTimeThreshold() / 1000;
}

+ (NSArray<AMTHCallTraceTimeCostModel *> *)records {
    return [self recordsFromIndex:0];
}

+ (NSArray<AMTHCallTraceTimeCostModel *> *)recordsFromIndex:(NSInteger)index {
    NSMutableArray<AMTHCallTraceTimeCostModel *> *arr = @[].mutableCopy;
    int num = 0;
    amth_call_record *records = amth_getCallRecords(&num);
    if (index >= num) {
        return [arr copy];
    }

    for (int i = (int)index; i < num; ++i) {
        amth_call_record *record = &records[i];
        AMTHCallTraceTimeCostModel *model = [AMTHCallTraceTimeCostModel new];
        model.className = NSStringFromClass(record->cls);
        model.methodName = NSStringFromSelector(record->sel);
        model.isClassMethod = class_isMetaClass(record->cls);
        model.timeCostInMS = (double)record->cost * 1e-3;
        model.eventTime = record->event_time;
        model.callDepth = record->depth;
        [arr addObject:model];
    }
    return [arr copy];
}

+ (NSArray<AMTHCallTraceTimeCostModel *> *)prettyRecords {
    NSArray *arr = [self records];
    NSUInteger count = arr.count;
    NSMutableArray *stack = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; ++i) {
        AMTHCallTraceTimeCostModel *top = stack.lastObject;
        AMTHCallTraceTimeCostModel *item = arr[i];
        while (top && top.callDepth > item.callDepth) {
            NSMutableArray *sub = item.subCosts ? [item.subCosts mutableCopy] : @[].mutableCopy;
            [sub insertObject:top atIndex:0];
            item.subCosts = [sub copy];
            [stack removeLastObject]; // stack pop

            top = stack.lastObject;
        }
        [stack addObject:item];
    }

    NSArray *result = [stack copy];
    return result;
}

@end
