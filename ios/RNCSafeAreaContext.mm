#import "RNCSafeAreaContext.h"

#import <React/RCTUtils.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif
#ifdef RCT_NEW_ARCH_ENABLED
#import <safeareacontext/safeareacontext.h>
#endif

#ifdef RCT_NEW_ARCH_ENABLED
using namespace facebook::react;

@interface RNCSafeAreaContext () <NativeSafeAreaContextSpec>
@end
#endif

@implementation RNCSafeAreaContext

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (NSDictionary *)constantsToExport
{
  return [self getConstants];
}

- (NSDictionary *)getConstants
{
  __block NSDictionary *constants;
  static NSString *const kSafeAreaInitialMetricsKey = @"safe-area-context-initial-window-metrics";

  RCTUnsafeExecuteOnMainQueueSync(^{
#if TARGET_OS_IPHONE
    UIWindow *window = RCTKeyWindow();
#elif TARGET_OS_OSX
    NSWindow *window = RCTKeyWindow();
#endif
    if (window == nil) {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      NSDictionary *cachedMetrics = [defaults objectForKey:kSafeAreaInitialMetricsKey];

      if (cachedMetrics != nil) {
        NSLog(@"RNCSafeAreaContext: using cached initial window metrics from NSUserDefaults");
        constants = @{@"initialWindowMetrics" : cachedMetrics};
      } else {
        NSLog(@"RNCSafeAreaContext: no cached metrics available");
        constants = @{@"initialWindowMetrics" : [NSNull null]};
      }
      return;
    }

#if TARGET_OS_IPHONE
    UIEdgeInsets safeAreaInsets = window.safeAreaInsets;
#elif TARGET_OS_OSX
    NSEdgeInsets safeAreaInsets = NSEdgeInsetsZero;
#endif

    NSDictionary *windowMetrics = @{
      @"insets" : @{
        @"top" : @(safeAreaInsets.top),
        @"right" : @(safeAreaInsets.right),
        @"bottom" : @(safeAreaInsets.bottom),
        @"left" : @(safeAreaInsets.left),
      },
      @"frame" : @{
        @"x" : @(window.frame.origin.x),
        @"y" : @(window.frame.origin.y),
        @"width" : @(window.frame.size.width),
        @"height" : @(window.frame.size.height),
      },
    };

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:kSafeAreaInitialMetricsKey] == nil) {
      [defaults setObject:windowMetrics forKey:kSafeAreaInitialMetricsKey];
      [defaults synchronize];
      NSLog(@"RNCSafeAreaContext: cached initial window metrics to NSUserDefaults for the first time");
    }

    constants = @{
      @"initialWindowMetrics" : windowMetrics
    };
  });

  return constants;
}

#ifdef RCT_NEW_ARCH_ENABLED

- (std::shared_ptr<TurboModule>)getTurboModule:(const ObjCTurboModule::InitParams &)params
{
  return std::make_shared<NativeSafeAreaContextSpecJSI>(params);
}

#endif

@end
