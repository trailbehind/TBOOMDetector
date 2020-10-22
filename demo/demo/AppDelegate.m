//
//  AppDelegate.m
//  TBOOMDetector
//
//  Created by Jesse Crocker on 9/1/15.
//  Copyright (c) 2015 Trailbehind inc. All rights reserved.
//

#import "AppDelegate.h"
#import "TBOOMDetector.h"

@interface AppDelegate ()
@property (nonatomic, strong) TBOOMDetector *oomDetector;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSArray *paths = NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSUserDomainMask, YES);
  self.oomDetector = [[TBOOMDetector alloc] initWithDirectory:paths[0]
                                                   crashCheck:^BOOL{
    // return [[Crashlytics crashlytics] didCrashDuringPreviousExecution];
    return NO;
  }
                                                             callback:^(TBTerminationType terminationType) {
                                                               NSLog(@"Termination type %li - %@", (long)terminationType, [TBOOMDetector stringFromTBTerminationType:terminationType]);
                                                             }];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
