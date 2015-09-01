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

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSArray *paths = NSSearchPathForDirectoriesInDomains (NSLibraryDirectory, NSUserDomainMask, YES);
  TBOOMDetector *oomDetector = [[TBOOMDetector alloc] initWithCrashlyticsApiKey:@""
                                                                      directory:paths[0]
                                                                       callback:^(TBTerminationType terminationType) {
                                                                         NSLog(@"Termination type %li", (long)terminationType);
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
