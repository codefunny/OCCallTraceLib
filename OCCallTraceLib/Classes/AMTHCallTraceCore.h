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


#ifndef AMTHCallTraceCore_h
#define AMTHCallTraceCore_h

#include <objc/objc.h>
#include <stdint.h>
#include <stdio.h>

#define AMTHawkeyeCallTracePerformanceTestEnabled 0

#ifdef AMTHawkeyeCallTracePerformanceTestEnabled
#define _InternalMTCallTracePerformanceTestEnabled AMTHawkeyeCallTracePerformanceTestEnabled
#else
#define _InternalMTCallTracePerformanceTestEnabled NO
#endif

typedef struct {
    __unsafe_unretained Class cls;
    SEL sel;
    uint32_t cost; // us (1/1000 ms), max 4290s.
    uint32_t depth;
    double event_time; // unix time
} amth_call_record;

extern void amth_calltraceStart(void);
extern void amth_calltraceStop(void);
extern bool amth_calltraceRunning(void);

extern void amth_calltraceConfigTimeThreshold(uint32_t us); // default 15 * 1000
extern void amth_calltraceConfigMaxDepth(int depth);        // default 5

extern void amth_calltraceTraceAll(void);
extern void amth_calltraceTraceByThreshold(void);

extern uint32_t amth_calltraceTimeThreshold(void); // in us, max 4290 * 1e6 us.
extern int amth_calltraceMaxDepth(void);

extern amth_call_record *amth_getCallRecords(int *num);
extern void amth_clearCallRecords(void);

#endif /* MTHCallTraceCore_h */
