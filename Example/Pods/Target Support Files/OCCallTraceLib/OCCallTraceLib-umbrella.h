#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AMTHCallTrace.h"
#import "AMTHCallTraceCore.h"
#import "AMTHCallTraceTimeCostModel.h"

FOUNDATION_EXPORT double OCCallTraceLibVersionNumber;
FOUNDATION_EXPORT const unsigned char OCCallTraceLibVersionString[];

